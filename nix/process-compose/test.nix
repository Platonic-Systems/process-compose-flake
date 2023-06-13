{ name, config, pkgs, lib, ... }:

let
  inherit (lib) types mkOption;
in
{
  options = {
    testScript = mkOption {
      type = types.nullOr types.str;
      description = ''
        If set, add a flake check running nixosTest running this process-compose
        configuration, followed by the specified testScript.

        Useful if you want to test your configuration in CI.
      '';
      default = null;
    };
    outputs.check = mkOption {
      type = types.nullOr types.package;
      default = if config.testScript == null then null else 
        pkgs.nixosTest {
          inherit (config) testScript;
          name = "process-compose-${name}-test";
          nodes.machine = {
            environment.systemPackages = [ pkgs.bash ]; # process-compose requires it.
            systemd.services.process-compose = {
              enable = true;
              wantedBy = [ "default.target" ];
              serviceConfig = {
                WorkingDirectory = "/tmp";
                ExecStart = lib.getExe (pkgs.writeShellApplication {
                  name = "process-compose-${name}";
                  text = ''
                    set -x
                    echo "Launching procese-compose on ${name} ..."
                    # make bash available to process-compose
                    export PATH=/run/current-system/sw/bin:$PATH
                    ${lib.getExe config.outputs.package} -t=false
                  '';
                });
              };
            };
          };
        };
    }; 
  };
}