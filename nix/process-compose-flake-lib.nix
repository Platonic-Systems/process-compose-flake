{ lib }:
let
  inherit (lib) types;
in
{
  mkProcessComposeArgumentsOption = {}:
    lib.mkOption {
      type = types.submodule
        ({ config, lib, ... }:
          let inherit (lib) types mkOption;
          in
          {
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
                type = types.str;
                default = "";
              };
              reverse = mkOption {
                type = types.bool;
                default = false;
              };
              sort = mkOption {
                type = types.str;
                default = "";
              };
              theme = mkOption {
                type = types.str;
                default = "";
              };
              tui = mkOption {
                type = types.bool;
                default = true;
              };
              log-file = mkOption {
                type = types.str;
                default = "";
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
                type = types.str;
                default = "";
              };
              use-uds = mkOption {
                type = types.bool;
                default = false;
              };
            };
          });
      default = { };
    };
}
