{ name, pkgs, lib, ... }:

args:
lib.mkOption (args // {
  type = lib.types.either lib.types.package lib.types.str;
  apply = pkg:
    if builtins.isString pkg
    # process-compose is unreliable in handling environment variable, so let's
    # wrap it in a bash script.
    then lib.getExe (pkgs.writeShellApplication { inherit name; text = pkg; })
    else lib.getExe pkg;
})
