{ lib, ... }:

args:
lib.mkOption (args // {
  type = lib.types.either lib.types.package lib.types.str;
  apply = pkg:
    if builtins.isString pkg then pkg else
    lib.getExe pkg;
})
