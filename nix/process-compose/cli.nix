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
    outputs.upCommandArgs =
      let
        cliArgsAttr = {
          port = "-p ${toString config.port}";
          tui = "-t=${lib.boolToString config.tui}";
        };
        args =
          lib.mapAttrsToList
            (opt: arg: lib.optionalString (config.${opt} != null) arg)
            cliArgsAttr;
      in
      mkOption {
        type = types.str;
        default = lib.concatStringsSep " " args;
        internal = true;
        readOnly = true;
        description = ''
          Additional CLI arguments to pass to 'process-compose up'.

          Note: `-f` option is always included, pointing to generated config.
          And is thus not handled by this option.
        '';
      };
  };
}

