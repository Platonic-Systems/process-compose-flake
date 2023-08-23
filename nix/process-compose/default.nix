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
      removeNullAndEmptyAttrs = attrs:
        let
          f = lib.filterAttrsRecursive (key: value: value != null && value != { });
          # filterAttrsRecursive doesn't delete the *resulting* empty attrs, so we must
          # evaluate it again and to get rid of it.
        in
        lib.pipe attrs [ f f ];
      toYAMLFile =
        attrs:
        pkgs.runCommand "${name}.yaml" { buildInputs = [ pkgs.yq-go ]; } ''
          yq -oy -P '.' ${pkgs.writeTextFile { name = "process-compose-${name}.json"; text = (builtins.toJSON attrs); }} > $out
        '';
      mkProcessComposeWrapper = { name, tui, port, settingsYaml }:
        pkgs.writeShellApplication {
          inherit name;
          runtimeInputs = [ config.package ];
          text = ''
            export PC_CONFIG_FILES=${settingsYaml}
            echo "Starting process-compose ${name} on port ${builtins.toString port}"
            cat ${settingsYaml}
            ${
              # Once the following issue is fixed we should be able to simply do:
              # export PC_DISABLE_TUI=${builtins.toJSON (!config.tui)}
              # https://github.com/F1bonacc1/process-compose/issues/75
              if tui then "" else "export PC_DISABLE_TUI=true"
            }
            exec process-compose -p ${toString port} "$@"
          '';
        };
    in
    {
      package =
        mkProcessComposeWrapper
          {
            inherit name;
            inherit (config) tui port;
            settingsYaml = toYAMLFile (removeNullAndEmptyAttrs config.settings);
          };
      testPackage =
        if
          (builtins.hasAttr "test" config.settings.processes)
        then
          mkProcessComposeWrapper
            {
              name = "${name}-test";
              inherit (config) tui port;
              settingsYaml = toYAMLFile (removeNullAndEmptyAttrs 
                (config.settings // 
                  { processes = 
                    { 
                      test = { disabled = false; availability.exit_on_end = true; }; 
                    }; 
                  }
                ));
            }
        else null;
    };
}

