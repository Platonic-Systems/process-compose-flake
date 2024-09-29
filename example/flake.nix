{
  description = "A demo of sqlite-web";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
    process-compose-flake.url = "github:Platonic-Systems/process-compose-flake";

    chinookDb.url = "github:lerocha/chinook-database";
    chinookDb.flake = false;
  };
  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      imports = [
        inputs.process-compose-flake.flakeModule
      ];
      perSystem = { self', pkgs, lib, ... }: {
        # This adds a `self.packages.default`
        process-compose."default" =
          let
            port = 8213;
            dataFile = "data.sqlite";
          in
          {
            # httpServer.enable = true;
            settings = {
              environment = {
                SQLITE_WEB_PASSWORD = "demo";
              };

              processes = {
                # Print a pony every 2 seconds, because why not.
                ponysay.command = ''
                  while true; do
                    ${lib.getExe pkgs.ponysay} "Enjoy our sqlite-web demo!"
                    sleep 2
                  done
                '';

                # Create .sqlite database from chinook database.
                sqlite-init.command = ''
                  echo "$(date): Importing Chinook database (${dataFile}) ..."
                  ${lib.getExe pkgs.sqlite} "${dataFile}" < ${inputs.chinookDb}/ChinookDatabase/DataSources/Chinook_Sqlite.sql
                  echo "$(date): Done."
                '';

                # Run sqlite-web on the local chinook database.
                sqlite-web = {
                  command = ''
                    ${pkgs.sqlite-web}/bin/sqlite_web \
                      --password \
                      --port ${builtins.toString port} "${dataFile}"
                  '';
                  # The 'depends_on' will have this process wait until the above one is completed.
                  depends_on."sqlite-init".condition = "process_completed_successfully";
                  readiness_probe.http_get = {
                    host = "localhost";
                    inherit port;
                  };
                };

                # If a process is named 'test', it will be ignored. But a new
                # flake check will be created that runs it so as to test the
                # other processes.
                test = {
                  command = pkgs.writeShellApplication {
                    name = "sqlite-web-test";
                    runtimeInputs = [ pkgs.curl ];
                    text = ''
                      curl -v http://localhost:${builtins.toString port}/
                    '';
                  };
                  depends_on."sqlite-web".condition = "process_healthy";
                };
              };
            };
          };

        # nix run .#ponysay up to start the process
        # nun run .#ponysay attach to show the output
        # nix run .#ponysay down to stop the process
        packages.ponysay = (import ../nix/eval-modules.nix).makeProcessCompose {
          inherit pkgs;
          name = "ponysay";
          modules = [{
            arguments.detached = true;
            settings = {
              processes = {
                ponysay.command = ''
                  while true; do
                    ${lib.getExe pkgs.ponysay} "Hi!"
                    sleep 2
                  done
                '';
              };
            };
          }];
        };
      };
    };
}
