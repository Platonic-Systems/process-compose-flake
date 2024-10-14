{ name, config, pkgs, lib, ... }:

let
  inherit (lib) types mkOption;
in
{
  imports = [
    ./cli.nix
    ./cli-options.nix
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
      mkProcessComposeWrapper = { name, cliOutputs, configFile, preHook, postHook, }:
        pkgs.writeShellApplication {
          inherit name;
          runtimeInputs = [ config.package ];
          text = ''
            ${preHook}


            # If there are no arguments, it's the "up" command
            # If the first argument is "up", it's also the "up" command
            # If the first argument starts with a dash, we assume there isn't a subcommand, so it's also the "up" command
            # Otherwise, we assume it's a subcommand other than "up"
            params=(${cliOutputs.global})
            set +u
            if [ -z "$1" ] || [[ "$1" == "up" ]] || [[ "$1" == -* ]] ; then
              params+=(--config ${configFile} ${cliOutputs.up})
            fi

            set -x
            process-compose "$@" "''${params[@]}"
            set +x

            ${postHook}
          '';
        };
    in
    {
      package =
        mkProcessComposeWrapper
          {
            inherit name;
            inherit (config) preHook postHook;
            cliOutputs = config.cli.outputs;
            configFile = config.outputs.settingsFile;
          };
      testPackage =
        if
          (builtins.hasAttr "test" config.settings.processes)
        then
          mkProcessComposeWrapper
            {
              name = "${name}-test";
              inherit (config) preHook postHook;
              cliOutputs = config.cli.outputs;
              configFile = config.outputs.settingsTestFile;
            }
        else null;
    };
}
