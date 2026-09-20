---
name: designing-with-nasa-manual
description: Use when building or restyling a web UI "in the style of" the 1976 NASA Graphics Standards Manual (NHB 1430.2, the Vignelli-era worm manual) or a similar 1970s corporate identity manual — any brief asking for Helvetica, flush-left ragged-right type, hairline rules instead of boxes, a red/black/warm-gray palette, signage-style buttons with text arrows, or a uniform-stroke SVG wordmark. Also when such a design must survive dark mode without putting red on black.
---

# Designing with the NASA Graphics Standards Manual

## Overview

The manual is a set of rules, not a vibe. A page built from it has four
colours, one typeface, rules instead of boxes, and a manual section number
next to every decision. "In the style of" means obeying those rules; the
1970s look follows from obeying them, and evaporates the moment tracked
caps, red decorations or a fifth colour creep in.

The NASA logotype and insignia are NASA marks (14 CFR 1221). Draw your own
letters with the same construction rules; never reproduce the worm.

Files in this skill:

- `manual-rules.md`: the nine rules R1–R9 with section numbers, the web
  translation of each, and what does not translate. Read it once per project.
- `tokens-and-recipes.css`: a complete stylesheet to copy in. Read it when
  writing CSS.
- `wordmark.md`: constructing a uniform-stroke SVG wordmark. Read it when
  the brief needs a logo.
- `verification.md`: the screenshot matrix script and checklist. Read it
  before declaring the design done.

## Scope

Use for: standards-manual, Swiss/International-style, "Vignelli", "1976
NASA", "Helvetica and hairlines", "signage-like UI" briefs; restyling an
existing app to that look; any dark-mode work on such a design.

Do not use for: playful or gradient-heavy UIs; charts and dashboards (a
dataviz skill owns those); an organisation's own brand system (use its
brand-guidelines skill).

## Core pattern: tokens first

Every colour on the page comes from these tokens. The `--mark` token is
what keeps R1 true on both schemes: it is red on light paper and white on
dark, so the wordmark and accents can never land red-on-black.

```css
:root {
  --red: #fc3d21;        /* NASA Red, on white only (1.4) */
  --gray: #a19d94;       /* NASA Warm Gray (1.3) */
  --gray-light: #e8e6e1; /* hairlines between form rows */
  --ink: #000;
  --paper: #fff;
  --mark: var(--red);    /* wordmark + accents: red on light ... */
}
@media (prefers-color-scheme: dark) {
  :root {
    --gray-light: #3f3c38;
    --ink: #fff;
    --paper: #000;
    --mark: #fff;        /* ... white on dark (1.5) */
    color-scheme: dark;
  }
}
```

Red in dark mode is allowed in exactly one form: a filled panel at least
1em tall, carrying white text or no text (`.sign--red`, `.status__block`).
Red text, red hairlines, red outlines and red icons are forbidden on a dark
ground. Do not "brighten the red" to fix contrast; remove the red.

## Quick reference

| Rule | Manual § | Web translation | Token / class |
|------|----------|-----------------|---------------|
| R1 Four colours; red on white only; white on black | 1.3–1.5, 5.2 | tokens above; red only as `--mark` on light or as a panel | `--red --gray --gray-light --ink --paper --mark` |
| R2 Helvetica; Light body, Medium headings; flush-left; upper & lower case; normal spacing | 1.2, 5.2, 5.3, 6.2 | `font-weight: 300` body, `700` headings; `text-align: left`; no `text-transform`, `letter-spacing: normal` | `body`, `h1`, `.field__label` |
| R3 Heading band, hairline, body; rules not boxes | 5.14–5.20 | masthead → `hr.rule` → body → folio | `.page .masthead .rule .folio` |
| R4 Uniform-stroke logotype, no outline/shadow/box | 1.1, 1.6, 1.7, 9.1 | own SVG, `stroke="currentColor"`, one `stroke-width` | see `wordmark.md` |
| R5 Stem-word masthead | 5.1, 5.8, 5.9 | mark at 1.6em + one Light word on the baseline | `.masthead__brand .masthead__stem` |
| R6 Identification block, 2 Light lines + 1 Medium, flush-left | 1.2, 2.2, 7.4 | small paragraph with `<br>` at the masthead's right | `.masthead__id` |
| R7 Signs: black/white, red/white, white/black; arrows precede words | 6.1, 6.2 | buttons are panels; arrows are text ("→ Join") | `.sign .sign--red .sign--outline .tile .notice .status__block` |
| R8 Stacked identification, flush-left | 7.1, 7.4 | rail with `h2` + caption + list | `.room .rail` |
| R9 Folio in the outer margin | 5.14 | small gray footer, right-aligned, `margin-top: auto` | `.folio` |

## Layout recipes

Class names are in `tokens-and-recipes.css`; copy that file, do not retype.

- Page frame: `main.page` (max-width 64em, 1.5em gutters, flex column,
  `min-height: 100dvh`), then `header.masthead`, `hr.rule`, the body,
  `footer.folio`.
- Masthead: `.masthead__brand` holds the wordmark SVG and `.masthead__stem`
  on a shared baseline (`align-items: flex-end`); `.masthead__id` on the
  right carries the two-line formal name. After sign-in the right side
  becomes `.masthead__tools` with `.sign` buttons.
- Cover (join / landing): `.cover` grid `1fr 2fr`, rows `auto 1fr`; left
  column `h1` + `.cover__lede`; right column `form.form`; `.cover__mark`
  spans both columns, `align-self: end`, holds the large wordmark, hidden
  at or under 40em.
- Form: each row is a `label.field` with `.field__label` (bold, 0.8em) over
  an unbordered, transparent `input`. One hairline per row
  (`border-bottom: 1px solid var(--gray-light)`) is the input's underline.
  No card around the form, no borders on inputs.
- Picker: `.tiles` of `.tile` (white panel, 1px ink outline); the chosen
  one becomes the black panel. With a script: `button.tile` and
  `aria-pressed="true"`. Without a script: a `fieldset` of radio inputs,
  each wrapped in `label.tile`, styled with `.tile:has(input:checked)`.
- Status on the cover: `.status` sits in the left column under the lede
  (`margin-top: 1.5em`), never inside the form.
- Primary action: `button.sign.sign--red` with a text arrow, "→ Join".
  Secondary: `.sign` (black) or `.sign--outline`. Tertiary: `.link`.
- Status: `.status` = `.status__block` colour square + word. Connected =
  red block, connecting = warm gray block, idle = outlined empty block.
  No green, no dot, no icon.
- Notice / warning: `.notice` with `background: var(--ink); color:
  var(--paper)`, a bold heading and Light body, an outlined sign at the
  right. It inverts by itself in dark mode.
- Directory (after sign-in): `.room` grid `14em 1fr`; `aside.rail` stacks
  identification sections; `section.body` holds the content.
- Ruled rows (messages, log lines): `.message` grid `7em 1fr auto` with a
  light hairline between rows; sender bold, body Light, time as `.caption`.
- Narrow (≤40em): grids collapse to one column; `.cover__mark` hidden;
  sender column 5em.

## Type

- Stack: `"Helvetica Neue", Helvetica, Arial, "Liberation Sans", sans-serif`.
- Light role = `font-weight: 300`; Medium role = `700`. Where the machine
  has only Arial/Liberation, 300 falls back to 400 and the contrast becomes
  Regular/Bold; accept it (5.3), do not add tracking or caps to compensate.
- Headings in upper and lower case. No `text-transform: uppercase`
  anywhere, including labels, captions and the footer.
- `letter-spacing: normal` everywhere. Never negative, never tracked out.
- `line-height` 1.2 or more; `text-align: left` on everything except the
  folio.
- Keep `:focus-visible { outline: 2px solid var(--ink); outline-offset: 2px }`.
  No transitions, no hover colour changes; print has neither.

## Wordmark

Build it as inline SVG: `fill="none" stroke="currentColor"
stroke-width="10" stroke-linecap="butt"` on a 90-high viewBox with cap
height 70, arches of radius 20, stadium rects for round letters, and the
colour taken from `--mark` through the parent's `color`. Size it with
`height` in em. Render it to PNG and look at it before committing; the
numbers need one or two nudges. Full construction table, letter recipes and
the render loop: `wordmark.md`.

## Verification loop

1. Build, then render the screenshot matrix: light/dark × 1280/400
   (`verification.md` has the script).
2. At 400, confirm `scrollWidth == innerWidth`.
3. Read the four PNGs as images and check: no red text or hairline on the
   dark ground, wordmark white in dark, everything flush-left except the
   folio, no rounded corners or shadows, rule under the masthead, form rows
   ruled not boxed.
4. States that need a backend (connected, lost, failed) are rendered
   statically: a scratch HTML linking the built stylesheet with the markup
   hand-written, same four shots.
5. Run the mechanical greps in `verification.md`; expected empty.

## Test-harness coupling

DOM order is textContent order. An e2e harness that regexes textContent
will read a time or count placed right after a message body as part of the
body. Keep numbers out of the tail of the text in the DOM and reorder them
visually with `grid-area`, as the `.message` recipe does.

## Common mistakes

| Mistake | Why it breaks the manual | Fix |
|---------|--------------------------|-----|
| Red labels, numerals, links or outlines that turn red-on-black in dark mode | 1.4: red on white only; 1.5: white on black | route accents through `--mark`; red only as a white-text panel |
| Green "connected", blue links, off-white paper, cool grays | 1.3: four colours, no others | connected = red block; links underlined in ink; paper is `#fff`/`#000`; gray is warm |
| Tracked small caps for labels, captions, footer | 5.3, 6.2: upper & lower case, normal spacing | 0.8em bold or Light, no transform, no tracking |
| Tight-tracked display heading | 5.3: spacing normal | 1.5em bold, `letter-spacing: normal` |
| Boxed inputs, bordered picker cells, card around the form | 4.1, 5.14: rules divide, boxes do not exist | one hairline per row; tiles as white panels with an ink outline |
| Selected state shown as coloured text or a red checkbox | 6.1: state is a sign, black panel with white type | `aria-pressed="true"` → black panel |
| `border-radius`, `box-shadow`, `transition`, hover colour | print has none; 1.7 forbids shadows on the mark | remove; focus ring is the only interactive affordance |
| Icon library, SVG arrows, status dots | 6.1: arrows are type, indicators are blocks | text arrows in the label; `.status__block` |
| Centered hero heading and lede | 5.2: flush-left, ragged-right | left column of the cover grid |
| Decorative numbering ("4.1 Entry") with no citation | numbers in the manual are page codes, not ornament | cite the section in a comment next to the rule it drives |
| A second accent or pastel tint | 1.5: no pastels, no second saturated colour | delete it |
| Redrawing the NASA worm or insignia | 14 CFR 1221 | own letters, same construction (`wordmark.md`) |
| Committing the SVG without rendering it | first-guess arcs never align | PNG loop in `wordmark.md` |
| Removing `:focus-visible` because print has no focus | accessibility | keep the 2px ink outline |

## Applying the method to another manual

1. Read the manual and extract the rules that drive layout, type, colour and
   marks; keep each with its section number (the table format in
   `manual-rules.md`). Over-extract; drop later.
2. Write the tokens first: paper, ink, the one or two accent inks, and a
   derived token for anything that must change on a dark ground.
3. Translate each rule into a class or a one-line CSS decision, and write
   "does not translate" next to anything print-only (inks, trim, grids).
4. Build the wordmark from the manual's construction rules, never from its
   artwork.
5. Run the same screenshot matrix and the same greps; add checks for the new
   manual's own prohibitions.
