{ pkgs, lib, config, ... }:

{
  options.postgres = lib.mkOption {
    description = ''
      Enable postgresql server
    '';
    default = { };
    type = lib.types.submodule ({ config, ... }: {
      options = {
        enable = lib.mkEnableOption "postgres";
        name = lib.mkOption {
          type = lib.types.str;
          default = "postgres";
          description = "Unique process name";
        };
        package = lib.mkPackageOption pkgs "postgresql_12" { };
        dataDir = lib.mkOption {
          type = lib.types.str;
          default = "./data/${config.name}";
          description = "Postgres data directory";
        };
      };
    });
  };
  config = let cfg = config.postgres; in lib.mkIf cfg.enable {
    # TODO: Bring over https://github.com/cachix/devenv/blob/main/src/modules/services/postgres.nix
    settings.processes = {
      "${cfg.name}-init".command = ''
        mkdir -p "${cfg.dataDir}"
        export PATH="${cfg.package}"/bin:$PATH
        initdb -D "${cfg.dataDir}"
      '';
      ${cfg.name} = {
        command = ''
          export PATH="${cfg.package}"/bin:$PATH
          postgres -D ${cfg.dataDir}
        '';
        depends_on."${cfg.name}-init".condition = "process_completed_successfully";
      };
    };
  };
}
