{ config, lib, ... }:

let
  inherit (lib) types mkOption;
in
{
  options = {
    apiServer = mkOption {
      type = types.bool;
      default = true;
      description = "Enable or disable process-compose's Swagger API.";
    };
    port = mkOption {
      type = types.int;
      default = 0;
      description = ''
        Port to serve process-compose's Swagger API on.
      '';
    };
    tui = mkOption {
      type = types.bool;
      default = true;
      description = "Enable or disable the TUI for the application.";
    };
  };
}

