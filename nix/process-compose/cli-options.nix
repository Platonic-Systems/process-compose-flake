{ lib, config, options, ... }:
let
  inherit (lib) types mkOption;
in
{
  options = {
    cli = {
      options = {
        log-file = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        no-server = mkOption {
          type = types.bool;
          default = false;
        };
        ordered-shutdown = mkOption {
          type = types.bool;
          default = false;
        };
        port = mkOption {
          type = types.nullOr types.int;
          default = null;
        };
        read-only = mkOption {
          type = types.bool;
          default = false;
        };
        unix-socket = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        use-uds = mkOption {
          type = types.bool;
          default = false;
        };
      };

      # The final CLI arguments we will pass to process-compose binary.
      outputs = {
        # TODO: We should refactor this to generically iterate on options and produce the CLI automatically using naming conventions and types.
        options = lib.mkOption {
          type = types.str;
          default = let o = config.cli.options; in lib.escapeShellArgs (
            (lib.optionals (o.log-file != null) [ "--log-file" o.log-file ])
            ++ (lib.optionals o.no-server [ "--no-server" ])
            ++ (lib.optionals o.ordered-shutdown [ "--ordered-shutdown" ])
            ++ (lib.optionals (o.port != null) [ "--port" "${builtins.toString o.port}" ])
            ++ (lib.optionals o.read-only [ "--read-only" ])
            ++ (lib.optionals (o.unix-socket != null) [ "--unix-socket" o.unix-socket ])
            ++ (lib.optionals o.use-uds [ "--use-uds" ])
          );
        };
      };
    };
  };
}
