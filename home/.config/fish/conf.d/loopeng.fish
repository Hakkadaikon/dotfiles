# Loop engineering: NL -> EARS+model -> TLA+ -> Gherkin.
# Tools (tlc/sany/apalache-mc) come from the nix profile bin via flake.nix.
# Here we just export the paths the oracles and Makefile.loopeng look for.
# Makefile.loopeng/bin/templates live in the hymme plugin repo, not dotfiles,
# so the fish functions always pick up the latest checked-out version.

set -gx LOOPENG_HOME "$HOME/repos/hakkadaikon/hymme/loopeng"

# tla2tools.jar lives under the tlaplus derivation's share/ (linked into profile).
set -l _tla_jar "$HOME/.nix-profile/share/tlaplus/tla2tools.jar"
test -f "$_tla_jar"; and set -gx TLA_JAR "$_tla_jar"

set -l _apalache "$HOME/.nix-profile/bin/apalache-mc"
test -x "$_apalache"; and set -gx APALACHE_BIN "$_apalache"

# Short alias; tlc/sany/apalache-mc are already on PATH from the profile.
abbr -a apalache apalache-mc
