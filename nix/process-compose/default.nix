{ name, config, pkgs, lib, ... }: 

let 
  inherit (lib) types mkOption literalExpression;
in 
{
  imports = [
    ./settings.nix
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
    port = mkOption {
      type = types.nullOr types.int;
      default = null;
      description = ''
        Port to serve process-compose's Swagger API on.
      '';
    };
    tui = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = "Enable or disable the TUI for the application.";
    };
    extraCliArgs =
      let
        cliArgsAttr = {
          port = "-p ${toString config.port}";
          tui = "-t=${lib.boolToString config.tui}";
        };
        getCliArgs =
          lib.mapAttrsToList
            (opt: arg: lib.optionalString (config.${opt} != null) arg)
            cliArgsAttr;
      in
      mkOption {
        type = types.str;
        default = lib.concatStringsSep " " getCliArgs;
        internal = true;
        readOnly = true;
        description = ''
          Extra command-line arguments to pass to process-compose.
        '';
      };
    outputs.package = mkOption {
      type = types.package;
      description = ''
        The final package that will run 'process-compose up' for this configuration.
      '';
    };
  };

  config.outputs.package =
    pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = [ config.package ];
      text = ''
        process-compose up \
          -f ${config.settingsYaml} \
          ${config.extraCliArgs} \
          "$@"
      '';
    };
}

