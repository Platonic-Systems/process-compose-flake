{ name, config, pkgs, lib, ... }:
let
  inherit (lib) types mkOption literalExpression;
in
{
  options = {
    settings = mkOption {
      default = { };
      type = types.submoduleWith {
        modules = [{
          options = {
            processes = mkOption {
              type = types.attrsOf (types.submoduleWith { modules = [ ./process.nix ]; });
              default = { };
              description = ''
                A map of process names to their configuration.
              '';
            };

            environment = import ./environment.nix { inherit lib; };

            log_length = mkOption {
              type = types.nullOr types.ints.unsigned;
              default = null;
              example = 3000;
              description = ''
                Log length to display in TUI mode.
              '';
            };
            log_level = mkOption {
              type = types.nullOr (types.enum [
                "trace"
                "debug"
                "info"
                "warn"
                "error"
                "fatal"
                "panic"
              ]);
              default = null;
              example = "info";
              description = ''
                Level of logs to output.
              '';
            };
            log_location = mkOption {
              type = types.nullOr types.str;
              default = null;
              example = "./pc.log";
              description = ''
                File to write the logs to.
              '';
            };

            shell = {
              shell_argument = mkOption {
                type = types.str;
                default = "-c";
                example = "-c";
                description = ''
                  Arguments to pass to the shell given by `shell_command`.
                '';
              };
              shell_command = mkOption {
                type = types.str;
                description = ''
                  The shell to use to run the process `command`s.

                  For reproducibility across systems, by default this uses
                  `pkgs.bash`.
                '';
                default = lib.getExe pkgs.bash;
                defaultText = "lib.getExe pkgs.bash";
              };
            };

            version = mkOption {
              type = types.nullOr types.str;
              default = null;
              example = "0.5";
              description = ''
                Version of the process-compose configuration.
              '';
            };
          };
        }];
      };
      example =
        # packages.${system}.watch-server becomes available
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
      description = ''
        For each attribute `x = process-compose config` a flake app and package `x` is added to the flake.
        Which runs process-compose with the declared config.
      '';
    };
    outputs.settingsFile = mkOption {
      type = types.attrsOf types.raw;
      internal = true;
      description = ''
        The settings file that will be used to run the process-compose flake.
      '';
    };

    outputs.settingsTestFile = mkOption {
      type = types.attrsOf types.raw;
      internal = true;
    };
  };
  config.outputs =
    let
      removeNullAndEmptyAttrs = attrs:
        let
          f = lib.filterAttrsRecursive (key: value: value != null && value != { });
          # filterAttrsRecursive doesn't delete the *resulting* empty attrs, so we must
          # evaluate it again and to get rid of it.
        in
        lib.pipe attrs [ f f ];
      toPCJson = name: attrs:
        pkgs.writeTextFile {
          name = "process-compose-${name}.json";
          text = builtins.toJSON attrs;
        };
    in
    {
      settingsFile = toPCJson name (removeNullAndEmptyAttrs config.settings);
      settingsTestFile = toPCJson "${name}-test" (removeNullAndEmptyAttrs
        (lib.updateManyAttrsByPath [
          {
            path = [ "processes" "test" ];
            update = old: old // { disabled = false; availability.exit_on_end = true; };
          }
        ]
          config.settings));
    };
}
