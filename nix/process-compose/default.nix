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
    outputs.testPackage = mkOption {
      type = types.nullOr types.package;
      description = ''
        Like `outputs.package` but includes the "test" process

        Set to null if there is no "test" process.
      '';
    };
  };

  config.outputs =
    let
      mkProcessComposeWrapper = { name, tui, port, configFile }:
        pkgs.writeShellApplication {
          inherit name;
          runtimeInputs = [ config.package ];
          text = ''
            export PC_CONFIG_FILES=${configFile}
            ${
              # Once the following issue is fixed we should be able to simply do:
              # export PC_DISABLE_TUI=${builtins.toJSON (!config.tui)}
              # https://github.com/F1bonacc1/process-compose/issues/75
              if tui then "" else "export PC_DISABLE_TUI=true"
            }
            exec process-compose -p ${toString port} "$@"
          '';
        };
    in
    {
      package =
        mkProcessComposeWrapper
          {
            inherit name;
            inherit (config) tui port;
            configFile = config.outputs.settingsYaml;
          };
      testPackage =
        if
          (builtins.hasAttr "test" config.settings.processes)
        then
          mkProcessComposeWrapper
            {
              name = "${name}-test";
              inherit (config) tui port;
              configFile = config.outputs.settingsTestYaml;
            }
        else null;
    };
}

