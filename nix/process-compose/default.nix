{ name, config, pkgs, lib, ... }:

let
  inherit (lib) types mkOption;
in
{
  imports = [
    ./cli.nix
    ./settings
    ./test.nix
  ];

  options = {
    package = mkOption {
      type = types.package;
      default = pkgs.process-compose;
      defaultText = lib.literalExpression "pkgs.process-compose";
      description = ''
        The process-compose package to bundle up in the command package and flake app.
      '';
    };
    outputs.package = mkOption {
      type = types.package;
      description = ''
        The final package that will run 'process-compose up' for this configuration.
      '';
    };
    outputs.testPackage = mkOption {
      type = types.nullOr types.package;
      description = ''
        Like `outputs.package` but includes the "test" process

        Set to null if there is no "test" process.
      '';
    };
  };

  config.outputs =
    let
      mkGlobalArgs = config: lib.escapeShellArgs (
        (lib.optionals (config.log-file != null && config.log-file != "") [ "--log-file" config.log-file ])
        ++ (lib.optionals config.no-server [ "--no-server" ])
        ++ (lib.optionals config.ordered-shutdown [ "--ordered-shutdown" ])
        ++ (lib.optionals (config.port != null) [ "--port" "${builtins.toString config.port}" ])
        ++ (lib.optionals config.read-only [ "--read-only" ])
        ++ (lib.optionals (config.unix-socket != "") [ "--unix-socket" config.unix-socket ])
        ++ (lib.optionals config.use-uds [ "--use-uds" ])
      );
      mkUpArgs = config: lib.escapeShellArgs (
        (lib.concatMap (v: [ "--config" v ]) config.config)
        ++ (lib.optionals config.detached [ "--detached" ])
        ++ (lib.optionals config.disable-dotenv [ "--disable-dotenv" ])
        ++ (lib.concatMap (v: [ "--env" v ]) config.env)
        ++ (lib.optionals config.hide-disabled [ "--hide-disabled" ])
        ++ (lib.optionals config.keep-project [ "--keep-project" ])
        ++ (lib.concatMap (v: [ "--namespace" v ]) config.namespace)
        ++ (lib.optionals config.no-deps [ "--no-deps" ])
        ++ (lib.optionals (config.ref-rate != null && config.ref-rate != "") [ "--ref-rate" config.ref-rate ])
        ++ (lib.optionals config.reverse [ "--reverse" ])
        ++ (lib.optionals (config.sort != null && config.sort != "") [ "--sort" config.sort ])
        ++ (lib.optionals (config.theme != null && config.theme != "") [ "--theme" config.theme ])
        ++ (lib.optionals config.reverse [ "--reverse" ])
        ++ (lib.optionals (!config.tui) [ "--tui=false" ])
      );
      mkProcessComposeWrapper = { name, cli, preHook, postHook, }:
        pkgs.writeShellApplication {
          inherit name;
          runtimeInputs = [ config.package ];
          text = ''
            ${preHook}

            set -x; process-compose ${mkGlobalArgs cli.global} ${mkUpArgs cli.up} "$@"; set +x

            ${postHook}
          '';
        };
    in
    {
      package =
        mkProcessComposeWrapper
          {
            inherit name;
            inherit (config) preHook postHook;
            cli = config.cli;
          };
      testPackage =
        if
          (builtins.hasAttr "test" config.settings.processes)
        then
          mkProcessComposeWrapper
            {
              name = "${name}-test";
              inherit (config) preHook postHook;
              cli = config.test-cli;
            }
        else null;
    };
}
