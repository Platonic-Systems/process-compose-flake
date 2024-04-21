{ lib, ... }:

let
  inherit (lib) types mkOption;
in
{
  options =
    {
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
      postHook = mkOption {
        type = types.lines;
        default = "";
        description = "Shell commands to run after process-compose completes.";
      };
      server = mkOption {
        description = ''
          Configuration for the process-compose server.
        '';
        type = types.submodule {
          options = {
            port = lib.mkOption {
              type = types.nullOr types.port;
              default = null;
              description = ''
                Port to serve process-compose's Swagger API on.
              '';
            };
            uds = lib.mkOption {
              type = types.nullOr (types.either types.bool types.str);
              default = null;
              description = ''
                UDP socket to serve process-compose's Swagger API on.

                If set to `true`, the socket will be created in the default
                location. If set to a string, the socket will be created at the
                specified location.
              '';
            };
          };
        };
        default = { };
      };
      tui = mkOption {
        type = types.bool;
        default = true;
        description = "Enable or disable the TUI for the application.";
      };
    };
}

