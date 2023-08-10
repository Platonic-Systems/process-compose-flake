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
    outputs.getPackageWithTest = mkOption {
      type = types.functionTo (types.nullOr types.package);
      description = ''
        Whether the final package will run 'process-compose up' for the configuration with or without test process.
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

  config.outputs.getPackageWithTest = useTestYaml:
    if (useTestYaml && config.outputs.settingsYamlWithTest == null) then null
    else
      pkgs.writeShellApplication {
        inherit name;
        runtimeInputs = [ config.package ];
        text = ''
          ${if config.debug then "cat ${if useTestYaml then config.outputs.settingsYamlWithTest else config.outputs.settingsYaml}" else ""}
          export PC_CONFIG_FILES=${if useTestYaml then config.outputs.settingsYamlWithTest else config.outputs.settingsYaml}
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

