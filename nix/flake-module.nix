{ self, lib, flake-parts-lib, ... }:
let
  inherit (flake-parts-lib)
    mkPerSystemOption;
  inherit (lib)
    mdDoc
    mkOption
    types
    literalExpression;
in
{
  options.perSystem = mkPerSystemOption ({ config, pkgs, lib, ... }:
    let
      submoduleWithPkgs = mod:
        types.submoduleWith {
          specialArgs = { inherit pkgs lib; };
          modules = [ mod ];
        };
    in
    {
      options.process-compose = mkOption {
        description = mdDoc ''
          process-compose-flake: creates [process-compose](https://github.com/F1bonacc1/process-compose)
          executables from process-compose configurations written as Nix attribute sets.
        '';
        type = types.attrsOf (submoduleWithPkgs {
          imports = [
            ./process-compose
          ];
        });
      };

      config.packages = lib.mapAttrs
        (name: cfg: cfg.outputs.package)
        config.process-compose;
    });
}

