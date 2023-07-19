{ name, config, pkgs, lib, ... }:

let
  inherit (lib) types mkOption;
in
{
  imports = [
    ./cli.nix
    ./settings
    ./test.nix
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
    outputs.package = mkOption {
      type = types.package;
      description = ''
        The final package that will run 'process-compose up' for this configuration.
      '';
    };
    debug = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to dump the process-compose YAML file at start.
      '';
    };
  };

  config.outputs.package =
    pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = [ config.package ];
      text = ''
        ${if config.debug then "cat ${config.outputs.settingsYaml}" else ""}
        export PC_CONFIG_FILES=${config.outputs.settingsYaml}
        ${
          # Once the following issue is fixed we should be able to simply do:
          # export PC_DISABLE_TUI=${builtins.toJSON (!config.tui)}
          # https://github.com/F1bonacc1/process-compose/issues/75
          if config.tui then "" else "export PC_DISABLE_TUI=true"
        }
        exec process-compose -p ${toString config.port} "$@"
      '';
    };
}

