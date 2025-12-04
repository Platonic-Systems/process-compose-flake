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
      description = ''
        Number of times to fail before giving up on restarting the process.
      '';
    };
    http_get = mkOption {
      description = ''
        URL to determine the health of the process.
      '';
      type = types.nullOr (types.submodule {
        options = {
          host = mkOption {
            type = types.str;
            example = "google.com";
            description = ''
              The host address which `process-compose` uses to probe the process.
            '';
          };
          scheme = mkOption {
            type = types.str;
            default = "http";
            example = "http";
            description = ''
              The protocol used to probe the process listening on `host`.
            '';
          };
          path = mkOption {
            type = types.str;
            default = "/";
            example = "/";
            description = ''
              The path to the healtcheck endpoint.
            '';
          };
          port = mkOption {
            type = types.port;
            example = "8080";
            description = ''
              Which port to probe the process on.
            '';
          };
          headers = mkOption {
            type = types.nullOr (types.attrsOf types.str);
            default = null;
            example = { "x-foo" = "bar"; };
            description = ''
              Additional headers to set on an HTTP probe
            '';
          };
          status_code = mkOption {
            type = types.nullOr types.int;
            default = null;
            example = 200;
            description = ''
              Expected status code.
            '';
          };
        };
      });
      default = null;
    };
    exec = mkOption {
      type = types.nullOr (types.submodule {
        options.command = mkOption {
          type = types.str;
          example = "ps -ef | grep -v grep | grep my-proccess";
          description = ''
            The command to execute in order to check the health of the process.
          '';
        };
        options.working_dir = mkOption {
          type = types.str;
          example = "./directory";
          description = ''
            Directory in which to execute the exec probe command.
          '';
        };
      });
      default = null;
      description = ''
        Execution settings.
      '';
    };
    initial_delay_seconds = mkOption {
      type = types.ints.unsigned;
      default = 0;
      example = 0;
      description = ''
        Wait for `initial_delay_seconds` before starting the probe/healthcheck.
      '';
    };
    period_seconds = mkOption {
      type = types.ints.unsigned;
      default = 10;
      example = 10;
      description = ''
        Check the health every `period_seconds`. 
      '';
    };
    success_threshold = mkOption {
      type = types.ints.unsigned;
      default = 1;
      example = 1;
      description = ''
        Number of successful checks before marking the process `Ready`.
      '';
    };
    timeout_seconds = mkOption {
      type = types.ints.unsigned;
      default = 3;
      example = 3;
      description = ''
        How long to wait for a given probe request.
      '';
    };
  };
}
