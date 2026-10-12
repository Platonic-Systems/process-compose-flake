{ lib, ... }:
let
  inherit (lib) types mkOption;
in
mkOption {
  type = types.nullOr (types.submodule {
    options = {
      paths = mkOption {
        type = types.listOf (types.submodule {
          options = {
            path = mkOption {
              type = types.str;
              example = "./src";
              description = ''
                The directory to watch, resolved against the process `working_dir`. The whole subtree is watched.
              '';
            };
            include = mkOption {
              type = types.listOf types.str;
              default = [ ];
              example = [ "**/*.go" ];
              description = ''
                If set, only matching files trigger a restart.
              '';
            };
            exclude = mkOption {
              type = types.listOf types.str;
              default = [ ];
              example = [ "**/*_test.go" "generated/**" ];
              description = ''
                Matching files are ignored and matching directories are not descended into.
              '';
            };
          };
        });
        example = [{ path = "./src"; }];
        description = ''
          The watched roots and their filters. A `watch` section must have at least one path.
        '';
      };
      debounce = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "300ms";
        description = ''
          Go duration to let a burst of changes settle before restarting.
        '';
      };
      cascade = mkOption {
        type = types.nullOr types.bool;
        default = null;
        example = true;
        description = ''
          Also restart this process's dependents, transitively, in dependency order.
        '';
      };
      max_entries = mkOption {
        type = types.nullOr types.ints.unsigned;
        default = null;
        example = 8192;
        description = ''
          Cap on the number of directories watched by this process.
        '';
      };
      buffer_size = mkOption {
        type = types.nullOr types.ints.unsigned;
        default = null;
        example = 65536;
        description = ''
          Event buffer size, per watched directory. Windows only.
        '';
      };
      disable_default_excludes = mkOption {
        type = types.nullOr types.bool;
        default = null;
        example = true;
        description = ''
          Turn off the built-in ignore list.
        '';
      };
    };
  });
  default = null;
  example = {
    paths = [{ path = "./src"; exclude = [ "**/*_test.go" ]; }];
  };
  description = ''
    Restart the process when files under the watched paths change.
    See https://f1bonacc1.github.io/process-compose/watch/
  '';
}
