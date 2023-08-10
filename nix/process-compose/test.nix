{ name, config, pkgs, lib, ... }:

let
  inherit (lib) types mkOption;
  testLibrary = ''
    class ProcessCompose:
      # GET /processes of process-compose swagger API.
      def get_processes(self, port=8080):
        import json
        url = f"http://localhost:{port}/processes"
        return json.loads(
          machine.succeed("${lib.getExe pkgs.xh} get " + url))

      def wait_until(self, ready, timeout_mins=1):
        import time
        import json
        machine.wait_for_unit("default.target")

        timeout = time.time() + 60*timeout_mins   # 1 minutes from now
        data = None
        while True:
          if time.time() > timeout: 
            print("Processes not started!")
            machine.succeed("""
              journalctl -u process-compose.service
              cat process-compose*log
            """)
            raise Exception("Processes not started!")
          info = self.get_processes(${if config.port == null then "8080" else builtins.toString config.port})
          print(json.dumps(info))
          data = { x["name"]: x for x in info["data"] }
          if ready(data):
            break
          else:
            time.sleep(1)
        return data
    
    process_compose = ProcessCompose()
  '';
in
{
  options = {
    testScript = mkOption {
      type = types.nullOr types.str;
      description = ''
        If set, add a flake check running nixosTest running this process-compose
        configuration, followed by the specified testScript.

        Useful if you want to test your configuration in CI.

        The testScript will have access to `process_compose.wait` function that
        can be used to get the running process information, after waiting for
        the specified readiness status.

        The check is added only on Linux, inasmuch as nixosTest is not available
        on Darwin.
      '';
      default = null;
      example = ''
        process_compose.wait_until(lambda procs:
          procs["netdata"]["is_ready"] == "Ready"
        )
        machine.succeed("curl -v http://localhost:19999/")
      '';
    };
    outputs.check = mkOption {
      type = types.nullOr types.package;
      default =
        if (config.testScript == null || !pkgs.stdenv.isLinux) then null else
        pkgs.nixosTest {
          testScript = testLibrary + "\n" + config.testScript;
          name = "process-compose-${name}-test";
          nodes.machine = {
            users.users.tester = {
              isNormalUser = true;
            };
            systemd.services."process-compose-${name}" = {
              enable = true;
              wantedBy = [ "default.target" ];
              serviceConfig = {
                WorkingDirectory = "/tmp";
                User = "tester";
                ExecStart = lib.getExe (pkgs.writeShellApplication {
                  name = "process-compose-${name}";
                  text = ''
                    set -x
                    ${lib.getExe (config.outputs.getPackageWithTest false)} -t=false
                    echo "unexpected: process-compose exited successfully (all processes are completed?)"
                    exit 2
                  '';
                });
              };
            };
          };
        };
    };
  };
}
