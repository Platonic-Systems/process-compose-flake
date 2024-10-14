{ lib, config, options, ... }:
let
  inherit (lib) types mkOption;
in
{
  options = {
    cli = {
      global = {
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
      up = {
        detached = mkOption {
          type = types.bool;
          default = false;
        };
        disable-dotenv = mkOption {
          type = types.bool;
          default = false;
        };
        env = mkOption {
          type = types.listOf types.str;
          default = [ ];
        };
        hide-disabled = mkOption {
          type = types.bool;
          default = false;
        };
        keep-project = mkOption {
          type = types.bool;
          default = false;
        };
        namespace = mkOption {
          type = types.listOf types.str;
          default = [ ];
        };
        no-deps = mkOption {
          type = types.bool;
          default = false;
        };
        ref-rate = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        reverse = mkOption {
          type = types.bool;
          default = false;
        };
        sort = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        theme = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        tui = mkOption {
          type = types.bool;
          default = true;
        };
      };

      # The final CLI arguments we will pass to process-compose binary.
      outputs = {
        # TODO: We should refactor this to generically iterate on options and produce the CLI automatically using naming conventions and types.
        global = lib.mkOption {
          type = types.str;
          default = let global = config.cli.global; in lib.escapeShellArgs (
            (lib.optionals (global.log-file != null) [ "--log-file" global.log-file ])
            ++ (lib.optionals global.no-server [ "--no-server" ])
            ++ (lib.optionals global.ordered-shutdown [ "--ordered-shutdown" ])
            ++ (lib.optionals (global.port != null) [ "--port" "${builtins.toString global.port}" ])
            ++ (lib.optionals global.read-only [ "--read-only" ])
            ++ (lib.optionals (global.unix-socket != null) [ "--unix-socket" global.unix-socket ])
            ++ (lib.optionals global.use-uds [ "--use-uds" ])
          );
        };
        up = lib.mkOption {
          type = types.str;
          default = let up = config.cli.up; in lib.escapeShellArgs (
            (lib.optionals up.detached [ "--detached" ])
            ++ (lib.optionals up.disable-dotenv [ "--disable-dotenv" ])
            ++ (lib.concatMap (v: [ "--env" v ]) up.env)
            ++ (lib.optionals up.hide-disabled [ "--hide-disabled" ])
            ++ (lib.optionals up.keep-project [ "--keep-project" ])
            ++ (lib.concatMap (v: [ "--namespace" v ]) up.namespace)
            ++ (lib.optionals up.no-deps [ "--no-deps" ])
            ++ (lib.optionals (up.ref-rate != null) [ "--ref-rate" up.ref-rate ])
            ++ (lib.optionals up.reverse [ "--reverse" ])
            ++ (lib.optionals (up.sort != null) [ "--sort" up.sort ])
            ++ (lib.optionals (up.theme != null) [ "--theme" up.theme ])
            ++ (lib.optionals up.reverse [ "--reverse" ])
            ++ (lib.optionals (!up.tui) [ "--tui=false" ])
          );
        };
      };
    };
  };
}
