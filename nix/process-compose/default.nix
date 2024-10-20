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

            set +u
            if [ -z "$1" ] || [[ "$1" == -* ]] ; then
              echo "process-compose-flake requires a subcommand like 'up' as the first argument. Configured subcommand cli options are ignored otherwise."
              echo "To get a list about available subcommands, use the 'help' subcommand"
              exit 1
            fi
            
            params=(${cliOutputs.global})
            if [[ "$1" == "up" ]] ; then
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
