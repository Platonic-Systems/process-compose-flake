{ lib, ... }:

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
    preHook = mkOption {
      type = types.lines;
      default = "";
      description = "Shell commands to run before process-compose starts.";
    };
    port = mkOption {
      type = types.int;
      default = 0;
      description = ''
        Port to serve process-compose's Swagger API on.
      '';
    };
    postHook = mkOption {
      type = types.lines;
      default = "";
      description = "Shell commands to run after process-compose completes.";
    };
    tui = mkOption {
      type = types.bool;
      default = true;
      description = "Enable or disable the TUI for the application.";
    };
  };
}

