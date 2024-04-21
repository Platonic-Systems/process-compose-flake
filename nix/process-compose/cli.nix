{ lib, ... }:

let
  inherit (lib) types mkOption;
in
{
  options =
    {
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
        type = types.submodule ({ config, ... }: {
          options = {
            enable = lib.mkEnableOption "Enable the HTTP server";
            port = lib.mkOption {
              type = types.nullOr types.port;
              default = null;
              description = ''
                Port to serve process-compose's Swagger API on.
              '';
            };
            uds = lib.mkOption {
              type = types.either types.bool types.str;
              default = false;
              description = ''
                UDP socket to serve process-compose's Swagger API on.

                If set to `true`, the socket will be created in the default
                location. If set to a string, the socket will be created at the
                specified location.
              '';
            };
            outputs.cliOpts = lib.mkOption {
              type = types.str;
              internal = true;
              readOnly = true;
              default = lib.optionalString config.enable ''
                ${if config.port != null then "--port ${builtins.toString config.port}" else ""} \
                ${if builtins.isBool config.uds then if config.uds then "-U" else "" else "--unix-socket ${config.uds}"} \
              '';
            };
          };
        });
        default = { };
      };
      tui = mkOption {
        type = types.bool;
        default = true;
        description = "Enable or disable the TUI for the application.";
      };
    };
}

