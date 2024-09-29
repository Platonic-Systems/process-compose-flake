{ lib }:
let
  inherit (lib) types;
in
{
  mkProcessComposeArgumentsOption = {}:
    lib.mkOption {
      type = types.submodule
        ({ config, lib, ... }:
          let inherit (lib) types mkOption;
          in
          {
            options = {
              config = mkOption {
                type = types.listOf types.str;
                default = [ ];
              };
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
                type = types.str;
                default = "";
              };
              reverse = mkOption {
                type = types.bool;
                default = false;
              };
              sort = mkOption {
                type = types.str;
                default = "";
              };
              theme = mkOption {
                type = types.str;
                default = "";
              };
              tui = mkOption {
                type = types.bool;
                default = true;
              };
              log-file = mkOption {
                type = types.str;
                default = "";
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
                type = types.str;
                default = "";
              };
              use-uds = mkOption {
                type = types.bool;
                default = false;
              };
              output = mkOption {
                type = types.submodule {
                  options = {
                    global = mkOption {
                      type = types.str;
                      default = lib.escapeShellArgs (
                        (lib.optionals (config.log-file != "") [ "--log-file" config.log-file ])
                        ++ (lib.optionals config.no-server [ "--no-server" ])
                        ++ (lib.optionals config.ordered-shutdown [ "--ordered-shutdown" ])
                        ++ (lib.optionals (config.port != null) [ "--port" "${builtins.toString config.port}" ])
                        ++ (lib.optionals config.read-only [ "--read-only" ])
                        ++ (lib.optionals (config.unix-socket != "") [ "--unix-socket" config.unix-socket ])
                        ++ (lib.optionals config.use-uds [ "--use-uds" ])
                      );
                    };
                    up = mkOption {
                      type = types.str;
                      default = lib.escapeShellArgs (
                        (lib.concatMap (v: [ "--config" v ]) config.config)
                        ++ (lib.optionals config.detached [ "--detached" ])
                        ++ (lib.optionals config.disable-dotenv [ "--disable-dotenv" ])
                        ++ (lib.concatMap (v: [ "--env" v ]) config.env)
                        ++ (lib.optionals config.hide-disabled [ "--hide-disabled" ])
                        ++ (lib.optionals config.keep-project [ "--keep-project" ])
                        ++ (lib.concatMap (v: [ "--namespace" v ]) config.namespace)
                        ++ (lib.optionals config.no-deps [ "--no-deps" ])
                        ++ (lib.optionals (config.ref-rate != "") [ "--ref-rate" config.ref-rate ])
                        ++ (lib.optionals config.reverse [ "--reverse" ])
                        ++ (lib.optionals (config.sort != "") [ "--sort" config.sort ])
                        ++ (lib.optionals (config.theme != "") [ "--theme" config.theme ])
                        ++ (lib.optionals config.reverse [ "--reverse" ])
                        ++ (lib.optionals (!config.tui) [ "--tui=false" ])
                      );
                    };
                  };
                };
                default = { };
              };
            };
          });
      default = { };
    };
}
