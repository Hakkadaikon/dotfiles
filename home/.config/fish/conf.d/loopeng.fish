# Loop engineering: NL -> EARS+model -> TLA+ -> Gherkin.
# Tools (tlc/sany/apalache-mc) come from the nix profile bin via flake.nix.
# Here we just export the paths the oracles and Makefile.loopeng look for.
# Makefile.loopeng/bin/templates live in the hymme plugin repo, not dotfiles,
# so the fish functions always pick up the latest checked-out version.
#
# Set LOOPENG_HOME yourself (e.g. in ~/.config/fish/config.fish) if your hymme
# checkout or plugin cache isn't in one of the guessed locations below.

# A stale $HOME/.config/loopeng from before the toolchain moved into the hymme
# plugin can still be lying around (leftover env var, old universal var). That
# path no longer holds the Makefile/bin/templates, so don't let it block
# auto-discovery below.
set -q LOOPENG_HOME; and test "$LOOPENG_HOME" = "$HOME/.config/loopeng"; and set -e LOOPENG_HOME

if not set -q LOOPENG_HOME
    # Globs must stay unquoted/unexpanded-in-a-string for fish to expand them,
    # so build each candidate list separately rather than looping over a
    # quoted pattern string (that would pass the literal "*" through).
    for _match in $HOME/repos/*/hymme/loopeng $HOME/.claude/plugins/cache/hymme/hymme/*/loopeng
        test -d "$_match"; and set -gx LOOPENG_HOME "$_match"; and break
    end
end

# tla2tools.jar lives under the tlaplus derivation's share/ (linked into profile).
set -l _tla_jar "$HOME/.nix-profile/share/tlaplus/tla2tools.jar"
test -f "$_tla_jar"; and set -gx TLA_JAR "$_tla_jar"

set -l _apalache "$HOME/.nix-profile/bin/apalache-mc"
test -x "$_apalache"; and set -gx APALACHE_BIN "$_apalache"

# Short alias; tlc/sany/apalache-mc are already on PATH from the profile.
abbr -a apalache apalache-mc
