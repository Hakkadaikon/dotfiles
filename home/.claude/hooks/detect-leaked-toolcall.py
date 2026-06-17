#!/usr/bin/env python3
"""Stop/SubagentStop hook: bounce leaked tool-call markup back to the model.

Models occasionally regress to the legacy in-text XML tool-call format
(anthropics/claude-code#49747, #66400). When the markup is mangled enough
that the harness never recognizes it as a tool call, it streams to the user
as plain text with no error — and the unlabeled broken block then acts as a
few-shot exemplar that poisons later tool calls (#62344).

This hook detects such orphan markup in the turn's final assistant message
and blocks the stop once, feeding a correction back so the model re-issues
the call properly. This both recovers the turn and converts the silent
poison into a labeled negative example in history.

Deliberate properties:
- Detect-and-bounce only; never parses or executes the leaked call
  (lenient parse + execute would be a prompt-injection escalation path).
- stop_hook_active guard caps the bounce at one per turn, so a false
  positive (e.g. legitimately quoted markup) costs a single retry.
- Fails open: any internal error exits 0 so a hook bug can never wedge
  the session.
- Each trigger is appended to leaked-toolcall-triggers.log to gauge fire
  frequency. A sustained zero (over enough usage/turns) is evidence toward
  retiring the guard — though zero can also come from low usage, a model
  change, or the regex missing a new variant, so it is a signal, not proof.
"""
import json
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

LOG_PATH = Path(__file__).with_name("leaked-toolcall-triggers.log")

# Opening forms of the legacy XML tool-call markup, with or without a
# namespace prefix. Anchored to line start to cut false positives from
# inline mentions in prose.
LEAK_RE = re.compile(
    r"^[ \t]*<(?:[A-Za-z][\w.-]*:)?"
    r"(?:invoke\s+name=|function_calls\s*>|parameter\s+name=)",
    re.M,
)


def last_assistant_text(transcript_path: str) -> str:
    """Concatenated text blocks of the last assistant entry in the JSONL."""
    text = ""
    with open(transcript_path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                entry = json.loads(line)
            except json.JSONDecodeError:
                continue
            if entry.get("type") != "assistant":
                continue
            content = entry.get("message", {}).get("content", [])
            if isinstance(content, str):
                text = content
            else:
                text = "\n".join(
                    b.get("text", "") for b in content if b.get("type") == "text"
                )
    return text


def main() -> None:
    payload = json.load(sys.stdin)
    # Loop guard: if we are already continuing because of a stop hook,
    # never block again — one bounce per turn maximum.
    if payload.get("stop_hook_active"):
        return
    # Prefer the message the harness hands us directly. For SubagentStop this
    # is the subagent's OWN final message; transcript_path there points at the
    # PARENT session, so reading it would miss the subagent and mis-target the
    # parent conversation. Fall back to parsing the transcript only when the
    # field is absent (older CLI versions).
    text = payload.get("last_assistant_message")
    if text is None:
        transcript_path = payload.get("transcript_path")
        text = last_assistant_text(transcript_path) if transcript_path else ""
    match = LEAK_RE.search(text)
    if not match:
        return
    timestamp = datetime.now(timezone.utc).isoformat(timespec="seconds")
    with open(LOG_PATH, "a", encoding="utf-8") as log:
        log.write(
            f"{timestamp} session={payload.get('session_id', '?')} "
            f"match={match.group(0).strip()!r}\n"
        )
    print(
        json.dumps(
            {
                "decision": "block",
                "reason": (
                    "Your last message contains raw tool-call markup emitted as "
                    "plain text (it was NOT executed). Re-issue it as a proper "
                    "structured tool call. If the markup was an intentional "
                    "quotation rather than an attempted call, simply state that "
                    "and finish your turn."
                ),
                "systemMessage": (
                    "leaked-toolcall guard: 生のツール呼び出しマークアップを検知し、"
                    "モデルに再発行を要求しました"
                ),
            }
        )
    )


if __name__ == "__main__":
    try:
        main()
    except Exception:
        # Fail open: a broken guard must never prevent the session from
        # stopping or mask the model's output.
        sys.exit(0)
