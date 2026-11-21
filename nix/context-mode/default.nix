# context-mode: Claude Code context-window optimizer (MCP server + hooks).
# Built from the npm tarball, whose JS bundles are prebuilt. Since 2.x it has no
# runtime dependencies (it uses node's built-in sqlite), so nothing is compiled
# here: the tarball is unpacked and wrapped with node.
# 1.0.169 linked better-sqlite3 and aborted (SIGABRT) when several hook
# processes ran at once, which Claude Code does on every parallel tool call.
{ lib, stdenvNoCC, fetchurl, nodejs, makeWrapper }:

stdenvNoCC.mkDerivation rec {
  pname = "context-mode";
  version = "2.2.1";

  src = fetchurl {
    url = "https://registry.npmjs.org/context-mode/-/context-mode-${version}.tgz";
    hash = "sha512-mG9r7fIwGSx71Kpnnj4FT6j8bQGv3ibaUlCGbeEjNesFt/5r+7uj0SeGuNNURuQcRaNuGRQ8uOXVAn/vA/Ryaw==";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/lib/node_modules/context-mode $out/bin
    cp -r . $out/lib/node_modules/context-mode/
    makeWrapper ${nodejs}/bin/node $out/bin/context-mode \
      --add-flags $out/lib/node_modules/context-mode/cli.mjs
  '';

  meta = {
    description = "Context window optimization for AI coding agents";
    homepage = "https://github.com/mksglu/context-mode";
    license = lib.licenses.elastic20;
    mainProgram = "context-mode";
  };
}
