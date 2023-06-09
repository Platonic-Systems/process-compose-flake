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
  options = {
    perSystem = mkPerSystemOption
      ({ config, self', inputs', pkgs, system, ... }: {
        options.process-compose = mkOption {
          description = mdDoc ''
            process-compose-flake: creates [process-compose](https://github.com/F1bonacc1/process-compose)
            executables from process-compose configurations written as Nix attribute sets.
          '';
          type = types.submodule {
            options = {
              package = mkOption {
                type = types.package;
                default = pkgs.process-compose;
                defaultText = lib.literalExpression "pkgs.process-compose";
                description = ''
                  The process-compose package to bundle up in the command package and flake app.
                '';
              };
              configs = mkOption {
                type = types.attrsOf (pkgs.formats.yaml { }).type;
                default = { };
                example =
                  # apps.${system}.watch-server and packages.${system}.watch-server become available
                  # execute `nix run .#watch-server` or incude packages.${system}.watch-server
                  # as a nativeBuildInput to your devShell
                  literalExpression ''
                    {
                      watch-server = {
                        processes = {
                          backend = "''${pkgs.simple-http-server}";
                          frontend = "''${pkgs.simple-http-server}";
                        };
                      };
                    };
                  '';
                description = mdDoc ''
                  For each attribute `x = process-compose config` a flake app and package `x` is added to the flake.
                  Which runs process-compose with the declared config.
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
                    port = "-p ${toString config.process-compose.port}";
                    tui = "-t=${lib.boolToString config.process-compose.tui}";
                  };
                  getCliArgs =
                    lib.mapAttrsToList
                      (opt: arg: lib.optionalString (config.process-compose.${opt} != null) arg)
                      cliArgsAttr;
                in
                mkOption {
                  type = types.str;
                  default = lib.concatStringsSep " " getCliArgs;
                  internal = true;
                  readOnly = true;
                  description = "Extra command-line arguments to pass to process-compose.";
                };
            };
          };
        };
      });
  };
  config = {
    perSystem = { config, self', inputs', pkgs, ... }:
      let
        toYAMLFile =
          attrs:
          pkgs.runCommand "toYamlFile" { buildInputs = [ pkgs.yq-go ]; } ''
            yq -P '.' ${pkgs.writeTextFile { name = "tmp.json"; text = (builtins.toJSON attrs); }} > $out
          '';
        packages = pkgs.lib.mapAttrs
          (name: processComposeConfig:
            pkgs.writeShellApplication {
              inherit name;
              runtimeInputs = [ config.process-compose.package ];
              text = ''
                process-compose -f ${toYAMLFile processComposeConfig} ${config.process-compose.extraCliArgs} "$@"
              '';
            }
          )
          config.process-compose.configs;
      in
      {
        inherit packages;
      };
  };
}

