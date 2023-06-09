{ lib, ... }:

let
  inherit (lib) types mkOption;
in
{
  options = {
    failure_threshold = mkOption {
      type = types.ints.unsigned;
      default = 3;
      example = 3;
    };
    http_get = mkOption {
      type = types.nullOr (types.submodule {
        options = {
          host = mkOption {
            type = types.str;
            example = "google.com";
          };
          scheme = mkOption {
            type = types.str;
            default = "http";
            example = "http";
          };
          path = mkOption {
            type = types.str;
            default = "/";
            example = "/";
          };
          port = mkOption {
            type = types.port;
            example = "8080";
          };
        };
      });
      default = null;
    };
    exec = mkOption {
      type = types.nullOr (types.submodule {
        command = mkOption {
          type = types.str;
          example = "ps -ef | grep -v grep | grep my-proccess";
        };
      });
      default = null;
    };
    initial_delay_seconds = mkOption {
      type = types.ints.unsigned;
      default = 0;
      example = 0;
    };
    period_seconds = mkOption {
      type = types.ints.unsigned;
      default = 10;
      example = 10;
    };
    success_threshold = mkOption {
      type = types.ints.unsigned;
      default = 1;
      example = 1;
    };
    timeout_seconds = mkOption {
      type = types.ints.unsigned;
      default = 3;
      example = 3;
    };
  };
}
