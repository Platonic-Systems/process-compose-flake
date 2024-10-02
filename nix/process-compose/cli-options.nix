{ lib }:
let
  inherit (lib) types mkOption;
in
lib.mkOption {
  type = types.submodule {
    options = {
      global = lib.mkOption {
        type = types.submodule {
          options = {
            log-file = mkOption {
              type = types.nullOr types.str;
              default = null;
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
              type = types.nullOr types.str;
              default = null;
            };
            use-uds = mkOption {
              type = types.bool;
              default = false;
            };
          };
        };
        default = { };
      };
      up = lib.mkOption {
        type = types.submodule {
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
              type = types.nullOr types.str;
              default = null;
            };
            reverse = mkOption {
              type = types.bool;
              default = false;
            };
            sort = mkOption {
              type = types.nullOr types.str;
              default = null;
            };
            theme = mkOption {
              type = types.nullOr types.str;
              default = null;
            };
            tui = mkOption {
              type = types.bool;
              default = true;
            };
          };
        };
        default = { };
      };
    };
  };
  default = { };
}

