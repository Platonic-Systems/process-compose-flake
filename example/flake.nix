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
        process-compose."default" = let port = 8213; in {
          # process-compose-flake exports some handy services. You may use them
          # as follows: Import them in `imports`, and set the corresponding
          # option.
          imports = [
            inputs.process-compose-flake.processComposeModules.services
          ];
          services.hello = {
            enable = true;
            name = "welcome";
            greeting = "Welcome to sqlite-web demo";
          };

          # Raw settings (process-compose.yaml) can be specified here.
          settings = {
            environment = {
              DATAFILE = "data.sqlite";
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
                echo "$(date): Importing Chinook database ($DATAFILE) ..."
                ${lib.getExe pkgs.sqlite} "$DATAFILE" < ${inputs.chinookDb}/ChinookDatabase/DataSources/Chinook_Sqlite.sql
                echo "$(date): Done."
              '';

              # Run sqlite-web on the local chinook database.
              sqlite-web = {
                command = ''
                  ${pkgs.sqlite-web}/bin/sqlite_web --port ${builtins.toString port} "$DATAFILE"
                '';
                # The 'depends_on' will have this process wait until the above one is completed.
                depends_on."sqlite-init".condition = "process_completed_successfully";
                readiness_probe.http_get = {
                  host = "localhost";
                  inherit port;
                };
              };
            };
          };

          testScript = ''
            process_compose.wait_until(lambda procs:
              procs["sqlite-web"]["is_ready"] == "Ready"
            )
            machine.succeed("curl -v http://localhost:${builtins.toString port}/")
          '';
        };
      };
    };
}
