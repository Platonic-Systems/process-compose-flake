{ name, config, pkgs, lib, ... }:
let
  inherit (lib) types mkOption;
in
{
  options = {
    outputs.check = mkOption {
      type = types.nullOr types.package;
      default =
        if (config.outputs.testPackage != null) then
          pkgs.runCommand "${name}-test" { } ''
            # Set pipefail option for safer bash
            set -euo pipefail
            export HOME=$TMP
            cd $HOME
            # Run with tui disabled because /dev/tty is disabled in the simulated shell
            ${lib.getExe config.outputs.testPackage} -t=false
            # `runCommand` will fail if $out isn't created
            touch $out
          ''
        else null;
    };
  };
}
