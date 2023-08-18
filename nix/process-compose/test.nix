{ name, config, pkgs, lib, ... }:
let
  inherit (lib) types mkOption;
in
{
  options = {
    outputs.check = mkOption {
      type = types.nullOr types.package;
      default =
        if (builtins.hasAttr "test" config.settings.processes) then
          pkgs.runCommand "${name}-test" { nativeBuildInputs = [ config.outputs.testPackage ]; } ''
            # Set pipefail option for safer bash
            set -euo pipefail
            export HOME=$TMP
            cd $HOME
            # Run with tui disabled because /dev/tty is disabled in the simulated shell
            ${name} -t=false
            # `runCommand` will fail if $out isn't created
            touch $out
          ''
        else null;
    };
  };
}
