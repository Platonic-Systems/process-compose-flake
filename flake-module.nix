{ self, lib, flake-parts-lib, ... }:
let
  inherit (flake-parts-lib)
    mkPerSystemOption;
  inherit (lib)
    mdDoc
    mkOption
    types
    literalExpression
    warn;
in
{
  options = {
    perSystem = mkPerSystemOption
      ({ config, self', inputs', pkgs, system, ... }: {
        options.process-compose = mkOption {
          default = warn "process-compose flake module was imported but not used" { };
          description = mdDoc ''
            process-compose-flake: creates [process-compose](https://github.com/F1bonacc1/process-compose)
            executables from process-compose configurations written as Nix attribute sets.
          '';
          type = types.submodule {
            options = {
              package = mkOption {
                type = types.package;
                default = pkgs.process-compose;
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
                process-compose -f ${toYAMLFile processComposeConfig} "$@"
              '';
            }
          )
          config.process-compose.configs;

        apps = pkgs.lib.mapAttrs
          (name: _: {
            inherit name;
            value = {
              type = "app";
              program = packages.${name};
            };
          })
          config.process-compose.configs;
      in
      {
        inherit packages apps;
      };
  };
}

