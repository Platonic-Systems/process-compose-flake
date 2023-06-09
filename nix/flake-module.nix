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
        type = types.attrsOf (submoduleWithPkgs ({ config, ... }: {
          imports = [
            ./settings.nix
          ];
          options = {
            package = mkOption {
              type = types.package;
              default = pkgs.process-compose;
              defaultText = lib.literalExpression "pkgs.process-compose";
              description = ''
                The process-compose package to bundle up in the command package and flake app.
              '';
            };
            port = mkOption {
              type = types.nullOr types.int;
              default = null;
              description = ''
                Port to serve process-compose's Swagger API on.
              '';
            };
            tui = mkOption {
              type = types.nullOr types.bool;
              default = null;
              description = "Enable or disable the TUI for the application.";
            };
            extraCliArgs =
              let
                cliArgsAttr = {
                  port = "-p ${toString config.port}";
                  tui = "-t=${lib.boolToString config.tui}";
                };
                getCliArgs =
                  lib.mapAttrsToList
                    (opt: arg: lib.optionalString (config.${opt} != null) arg)
                    cliArgsAttr;
              in
              mkOption {
                type = types.str;
                default = lib.concatStringsSep " " getCliArgs;
                internal = true;
                readOnly = true;
                description = ''
                  Extra command-line arguments to pass to process-compose.
                '';
              };
          };
        }));
      };

      config.packages = lib.mapAttrs
        (name: cfg:
          pkgs.writeShellApplication {
            inherit name;
            runtimeInputs = [ cfg.package ];
            text = ''
              process-compose up \
                -f ${cfg.settingsYaml} \
                ${cfg.extraCliArgs} \
                "$@"
            '';
          }
        )
        config.process-compose;
    });
}

