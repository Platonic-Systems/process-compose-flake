{
  description = "process-compose-flake test";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
    process-compose-flake.url = "github:Platonic-Systems/process-compose-flake";
  };
  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      imports = [
        inputs.process-compose-flake.flakeModule
      ];
      perSystem = { pkgs, lib, ... }: {
        # This adds a `self.packages.default`
        process-compose."default" = {
          debug = true;
          tui = false;
          settings = {
            environment = [
              "DATAFILE=data.sqlite"
            ];
            processes = {
              # Create a simple sqlite db
              sqlite-init.command =
                let
                  sqlFile = pkgs.writeTextFile {
                    name = "data.sql";
                    text = ''
                      CREATE TABLE demo (val TEXT);
                      INSERT INTO demo VALUES ("Hello");
                    '';
                  };
                in
                pkgs.writeShellApplication {
                  name = "sqlite-init";
                  text = ''
                    echo "$(date): Creating database ($DATAFILE) ..."
                    ${lib.getExe pkgs.sqlite} "$DATAFILE" < ${sqlFile}
                    echo "$(date): Done."
                  '';
                };

              # Query something, write to result.txt
              sqlite-query = {
                command = pkgs.writeShellApplication {
                  name = "sqlite-query";
                  text = ''
                    ${lib.getExe pkgs.sqlite} "$DATAFILE" \
                      'select val from demo where val = "Hello"' \
                      > result.txt
                  '';
                };
                # The 'depends_on' will have this process wait until the above one is completed.
                depends_on."sqlite-init".condition = "process_completed_successfully";
                availability.restart = "no";
              };
            };
          };
        };
      };
    };
}
