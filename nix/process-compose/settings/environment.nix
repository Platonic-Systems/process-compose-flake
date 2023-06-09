{ lib, ... }:
let
  inherit (lib) types;
  inherit (types) nullOr either listOf str attrsOf;
in
lib.mkOption {
  type = 
    nullOr 
      (either (listOf str) (attrsOf str));
  default = null;
  example = { ABC="2221"; PRINT_ERR="111"; };
  description = ''
    Attrset of environment variables.

    List of strings is also allowed.
  '';
  apply = attrs:
    if ! builtins.isAttrs attrs then attrs else 
    lib.mapAttrsToList (name: value: "${name}=${value}") attrs;
}
