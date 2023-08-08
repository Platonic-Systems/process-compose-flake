{ lib, flake-parts-lib, ... }:
let
  inherit (flake-parts-lib)
    mkPerSystemOption;
  inherit (lib)
    mdDoc
    mkOption
    types;
in
{
  options.perSystem = mkPerSystemOption ({ config, pkgs, lib, ... }:
    {
      options.process-compose = mkOption {
        description = mdDoc ''
          process-compose-flake: creates [process-compose](https://github.com/F1bonacc1/process-compose)
          executables from process-compose configurations written as Nix attribute sets.
        '';
        type = types.attrsOf (types.submoduleWith {
          specialArgs = { inherit pkgs; };
          modules = [
            ./process-compose
          ];
        });
      };

      config = {
        packages = lib.mapAttrs
          (name: cfg: cfg.outputs.package false)
          config.process-compose;
        checks =
          let
            checks' = lib.mapAttrs
              (name: cfg: cfg.outputs.check)
              config.process-compose;
            runCommandInSimulatedShell = name: package:
              pkgs.runCommand "${name}-test" { nativeBuildInputs = [ package ]; } ''
                # Set pipefail option for safer bash
                set -euo pipefail
                export HOME=$TMP
                cd $HOME
                # Run with tui disabled because /dev/tty is disabled in the simulated shell
                ${name} -t=false
                # `runCommand` will fail if $out isn't created
                touch $out
              '';
          in
          (lib.mapAttrs
            (name: cfg: runCommandInSimulatedShell name (cfg.outputs.package true))
            config.process-compose) //
          lib.filterAttrs (_: v: v != null) checks';
      };
    });
}

