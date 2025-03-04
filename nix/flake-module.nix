{ lib, flake-parts-lib, ... }:
let
  inherit (flake-parts-lib)
    mkPerSystemOption;
  inherit (lib)
    mkOption
    types;
in
{
  options.perSystem = mkPerSystemOption ({ config, pkgs, lib, ... }:
    {
      options.process-compose = mkOption {
        description = ''
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
          (_: cfg: cfg.outputs.package)
          config.process-compose;
        checks =
          let
            checks' = lib.mapAttrs
              (_: cfg: cfg.outputs.check)
              config.process-compose;
          in
          lib.filterAttrs (_: v: v != null) checks';
      };
    });
}

