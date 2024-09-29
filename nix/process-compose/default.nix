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
      mkProcessComposeWrapper = { name, arguments, preHook, postHook, }:
        pkgs.writeShellApplication {
          inherit name;
          runtimeInputs = [ config.package ];
          text = ''
            ${preHook}

            set -x; process-compose ${arguments.global} ${arguments.up}"$@"; set +x

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
            arguments = config.arguments.output;
          };
      testPackage =
        if
          (builtins.hasAttr "test" config.settings.processes)
        then
          mkProcessComposeWrapper
            {
              name = "${name}-test";
              inherit (config) preHook postHook;
              arguments = config.test-arguments.output;
            }
        else null;
    };
}
