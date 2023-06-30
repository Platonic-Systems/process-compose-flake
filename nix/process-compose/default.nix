{ name, config, pkgs, lib, flakeModuleConfig, ... }:

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
    fromFlakeRoot = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to start process-compose from $FLAKE_ROOT (see https://github.com/srid/flake-root).
      '';
    };
  };

  config.outputs.package =
    pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = [ config.package ];
      text =
        let
          targetCommand = ''
            process-compose up \
              -f ${config.outputs.settingsYaml} \
              ${config.outputs.upCommandArgs} \
              "$@"
          '';
          invokeCommand =
            if !lib.inPureEvalMode && config.fromFlakeRoot then
              ''
                ROOT=$(${lib.getExe flakeModuleConfig.flake-root.package})
                [[ -n $ROOT ]] && (cd "$ROOT" && ${targetCommand})
              ''
            else targetCommand;
        in
        ''
          ${if config.debug then "cat ${config.outputs.settingsYaml}" else ""}
          ${invokeCommand}
        '';
    };
}

