# Agent loop: NL -> EARS+model -> TLA+ -> Gherkin.
# Everything comes from the hymme skill-tools profile entry (flake.nix of
# github:Hakkadaikon/hymme): tlc / sany / apalache-mc, the oracles, the hymme
# command, and agentloop-outer / agentloop-middle / agentloop-inner as real executables that
# carry their own Makefile and templates. No fish function wraps them, so a
# Claude Code Bash call (zsh) and this shell run the same commands.

# A LOOPENG_HOME left over from when the loop commands were fish functions
# would make an old Makefile win over the one the commands ship with.
set -e LOOPENG_HOME

# Makefile.agentloop falls back to `java -cp $TLA_JAR` only when no tlc wrapper
# is on PATH; keep the path for that case.
set -l _tla_jar "$HOME/.nix-profile/share/tlaplus/tla2tools.jar"
test -f "$_tla_jar"; and set -gx TLA_JAR "$_tla_jar"

set -l _apalache "$HOME/.nix-profile/bin/apalache-mc"
test -x "$_apalache"; and set -gx APALACHE_BIN "$_apalache"

# Short alias; tlc/sany/apalache-mc are already on PATH from the profile.
abbr -a apalache apalache-mc
