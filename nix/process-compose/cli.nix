{ lib, config, options, ... }:
let
  inherit (lib) types mkOption;
in
{
  options = {
    cli = {
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
      environment = mkOption {
        default = { };
        description = "Environment variables to pass to process-compose binary.";
        type = types.submodule {
          options = {
            PC_DISABLE_TUI = mkOption {
              type = types.nullOr types.bool;
              default = null;
              description = "Disable the TUI (Text User Interface) of process-compose";
            };
          };
        };
      };
      options = mkOption {
        description = "CLI options to pass to process-compose binary";
        default = { };
        type = types.submodule {
          options = {
            detached = mkOption {
              type = types.bool;
              default = false;
              description = "Pass --detached to process-compose";
            };
            log-file = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Pass --log-file to process-compose";
            };
            no-server = mkOption {
              type = types.bool;
              default = false;
              description = "Pass --no-server to process-compose";
            };
            ordered-shutdown = mkOption {
              type = types.bool;
              default = false;
              description = "Pass --ordered-shutdown to process-compose";
            };
            port = mkOption {
              type = types.nullOr types.int;
              default = null;
              description = "Pass --port to process-compose";
            };
            read-only = mkOption {
              type = types.bool;
              default = false;
              description = "Pass --read-only to process-compose";
            };
            unix-socket = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Pass --unix-socket to process-compose";
            };
            use-uds = mkOption {
              type = types.bool;
              default = false;
              description = "Pass --use-uds to process-compose";
            };
          };
        };
      };

      # The final CLI arguments we will pass to process-compose binary.
      outputs = {
        # TODO: We should refactor this to generically iterate on options and produce the CLI automatically using naming conventions and types.
        options = lib.mkOption {
          type = types.str;
          readOnly = true;
          description = "The final CLI arguments we will pass to process-compose binary.";
          default = let o = config.cli.options; in lib.escapeShellArgs (
            (lib.optionals o.detached [ "--detached" ])
            ++ (lib.optionals (o.log-file != null) [ "--log-file" o.log-file ])
            ++ (lib.optionals o.no-server [ "--no-server" ])
            ++ (lib.optionals o.ordered-shutdown [ "--ordered-shutdown" ])
            ++ (lib.optionals (o.port != null) [ "--port" "${builtins.toString o.port}" ])
            ++ (lib.optionals o.read-only [ "--read-only" ])
            ++ (lib.optionals (o.unix-socket != null) [ "--unix-socket" o.unix-socket ])
            ++ (lib.optionals o.use-uds [ "--use-uds" ])
          );
        };

        environment = lib.mkOption {
          type = types.str;
          description = "Shell script prefix setting environment variables";
          readOnly = true;
          default =
            lib.concatStringsSep " " (lib.mapAttrsToList
              (name: value:
                if value == null then "" else "${name}=${builtins.toJSON value}")
              config.cli.environment);
        };
      };
    };
  };
}
