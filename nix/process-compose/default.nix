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
      mkProcessComposeWrapper = { name, tui, apiServer, configFile, preHook, postHook, server }:
        let
          portSet = if server.port != null then true else false;
          udsSet = if server.uds != false then true else false;
          portFlag = if portSet then "-p ${toString server.port}" else "";
          udsFlagPid = if (udsSet && (builtins.isBool server.uds)) then "-U" else "";
          udsFlagCustom = if builtins.isString server.uds then "--unix-socket ${server.uds}" else "";
          serverFlag =
            if (portSet && udsSet) then
              builtins.throw "Only one of port or uds can be set"
            else
              "${portFlag}${udsFlagPid}${udsFlagCustom}";
        in
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
            ${if apiServer then "" else "export PC_NO_SERVER=true"}

            ${preHook}

            process-compose ${serverFlag} "$@"

            ${postHook}
          '';
        };
    in
    {
      package =
        mkProcessComposeWrapper
          {
            inherit name;
            inherit (config) tui apiServer preHook postHook server;
            configFile = config.outputs.settingsFile;
          };
      testPackage =
        if
          (builtins.hasAttr "test" config.settings.processes)
        then
          mkProcessComposeWrapper
            {
              name = "${name}-test";
              inherit (config) tui apiServer preHook postHook server;
              configFile = config.outputs.settingsTestFile;
            }
        else null;
    };
}

