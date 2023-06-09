{ config, lib, ... }: 

let 
  inherit (lib) types mkOption;
in 
{
  options = {
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
  };
}

