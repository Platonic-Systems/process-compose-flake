{ lib, ... }:
lib.mkOption {
  type = lib.types.nullOr (lib.types.listOf lib.types.str);
  default = null;
  example = [ "ABC=2221" "PRINT_ERR=111" ];
}
