# context-mode: Claude Code context-window optimizer (MCP server + hooks).
# Built from the npm tarball, whose JS bundles are prebuilt; the lockfile next
# to this file pins its runtime deps (better-sqlite3 is compiled here).
{ lib, buildNpmPackage, fetchurl, nodejs, python3 }:

buildNpmPackage rec {
  pname = "context-mode";
  version = "1.0.169";

  src = fetchurl {
    url = "https://registry.npmjs.org/context-mode/-/context-mode-${version}.tgz";
    hash = "sha512-94JIaFuLjF9SO2BsGTrbGtyT44K95+9OC8BdbaL/UT76xOkanJLfUR5CzmNw+GELXZQqH4nBrKg9wjBnSFkVnQ==";
  };

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-2mjAG45U9y/2CzHXeRO5ti5nw+4UwuzvNbCeuwWoJBQ=";
  inherit nodejs;
  nativeBuildInputs = [ python3 ];
  dontNpmBuild = true;

  meta = {
    description = "Context window optimization for AI coding agents";
    homepage = "https://github.com/mksglu/context-mode";
    license = lib.licenses.elastic20;
    mainProgram = "context-mode";
  };
}
