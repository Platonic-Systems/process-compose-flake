{ config, lib, ... }:

let
  inherit (lib) types mkOption;
in
{
  options = {
    port = mkOption {
      type = types.int;
      default = 8080;
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

