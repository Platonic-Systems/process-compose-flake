{ lib, config, process-compose-flake-lib, ... }:

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

      # This must be grouped because, even though upstream doesn't group them in
      # CLI opts, it does so in the source code:
      # https://github.com/F1bonacc1/process-compose/blob/5a7b83ed8a0f6be58efa9e4940ff41517892eca2/src/cmd/root.go#L136-L144
      httpServer = mkOption {
        description = ''
          Configuration for the process-compose server.
        '';
        type = types.submodule ({ config, ... }: {
          options = {
            enable = lib.mkEnableOption "Enable the HTTP server";

            # TODO: port and uds should form an enum of submodules
            # But we can't implement it until https://github.com/NixOS/nixpkgs/pull/254790 lands
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
          };
        });
        default = { };
      };
      tui = mkOption {
        type = types.bool;
        default = true;
        description = "Enable or disable the TUI for the application.";
      };
      arguments = process-compose-flake-lib.mkProcessComposeArgumentsOption { };
      test-arguments = process-compose-flake-lib.mkProcessComposeArgumentsOption { };
    };
  config = {
    arguments = lib.mkMerge [{
      tui = config.tui;
      port = config.httpServer.port;
      use-uds = config.httpServer.uds != false;
      unix-socket = if builtins.isString config.httpServer.uds then config.httpServer.uds else "";
      no-server = if config.httpServer.enable == true then true else false;
      config = [ "${config.outputs.settingsFile}" ];
    }];
    test-arguments = lib.mkMerge [
      (config.arguments // {
        config = [ "${config.outputs.settingsTestFile}" ];
      })
    ];
  };
}
