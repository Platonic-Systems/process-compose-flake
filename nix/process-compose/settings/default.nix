{ name, config, pkgs, lib, submoduleWithPkgs, ... }:
let
  inherit (lib) types mkOption literalExpression;
in
{
  options = {
    settings = mkOption {
      type = types.submodule {
        options = {
          processes = mkOption {
            type = types.attrsOf (submoduleWithPkgs ./process.nix);
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
          };
          log_location = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = "./pc.log";
          };

          shell = {
            shell_argument = mkOption {
              type = types.str;
              default = "-c";
              example = "-c";
            };
            shell_command = mkOption {
              type = types.str;
              description = ''
                The shell to use to run the process `command`s.

                For reproducibility across systems, by default this uses
                `pkgs.bash`.
              '';
              default = lib.getExe pkgs.bash;
            };
          };

          version = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = "0.5";
          };
        };
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

    outputs.settingsYaml = mkOption {
      type = types.attrsOf types.raw;
      internal = true;
    };
  };

  config.outputs.settingsYaml =
    let
      removeNullAndEmptyAttrs = attrs:
        let
          f = lib.filterAttrsRecursive (key: value: value != null && value != { });
          # filterAttrsRecursive doesn't delete the *resulting* empty attrs, so we must
          # evaluate it again and to get rid of it.
        in
        lib.pipe attrs [ f f ];
      toYAMLFile =
        attrs:
        pkgs.runCommand "${name}.yaml" { buildInputs = [ pkgs.yq-go ]; } ''
          yq -oy -P '.' ${pkgs.writeTextFile { name = "process-compose-${name}.json"; text = (builtins.toJSON attrs); }} > $out
        '';
    in
    toYAMLFile (removeNullAndEmptyAttrs config.settings);
}

