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
        process-compose up \
          -f ${config.outputs.settingsYaml} \
          ${config.outputs.upCommandArgs} \
          "$@"
      '';
    };
}

