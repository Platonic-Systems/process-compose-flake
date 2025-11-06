{ name, lib, ... }:

let
  inherit (lib) types mkOption;
  inherit (types) nullOr listOf str enum bool;
in
{
  options = {
    rotation = mkOption {
      type = types.submodule {
        options = {
          max_size_mb = mkOption {
            type = types.nullOr types.ints.unsigned;
            default = null;
            example = 1;
            description = ''
              Maximum size in MB of the logfile before it's rolled.
            '';
          };
          max_backups = mkOption {
            type = types.nullOr types.ints.unsigned;
            default = null;
            example = 3;
            description = ''
              Maximum number of rolled logfiles to keep.
            '';
          };
          max_age_days = mkOption {
            type = types.nullOr types.ints.unsigned;
            default = null;
            example = 7;
            description = ''
              Maximum age in days to keep a rolled logfile.
            '';
          };
          compress = mkOption {
            type = types.nullOr types.bool;
            default = null;
            example = true;
            description = ''
              If enabled, compress rolled logfiles with gzip.
            '';
          };
        };
      };
      default = { };
      description = ''
        Settings related to process log rotation.
      '';
    };

    fields_order = mkOption {
      type = nullOr (listOf (enum [
        "time"
        "level"
        "message"
        # technically arbitrary, but these are defined in config.
      ])
      );
      default = null;
      example = [
        "time"
        "level"
        "message"
      ];
      description = ''
        Order of logging fields. The default is time, level, message
      '';
    };
    disable_json = mkOption {
      type = nullOr bool;
      default = null;
      example = false;
      description = ''
        If enabled, output as plain text rather than json.
      '';
    };
    timestamp_format = mkOption {
      type = nullOr str;
      default = null;
      example = "2006-01-02T15:04:05.000Z";
      description = ''
        Timestamp format, per Go's time.Parse function.
        Requires `add_timestamp` be enabled to be effective.

        See https://pkg.go.dev/time#pkg-constants for examples.
      '';
    };
    no_color = mkOption {
      type = nullOr bool;
      default = null;
      example = false;
      description = ''
        Enabling `no_color` prevents the use of ANSI colors in the logger.
      '';
    };
    no_metadata = mkOption {
      type = nullOr bool;
      default = null;
      example = true;
      description = ''
        If enabled, do not add process name and replica number to logs.
      '';
    };
    add_timestamp = mkOption {
      type = nullOr bool;
      default = null;
      example = true;
      description = ''
        If enabled, prepends a timestamp to log entries.
      '';
    };
    flush_each_line = mkOption {
      type = nullOr bool;
      default = null;
      example = true;
      description = ''
        If enabled, disables output buffering and flushes each line to the logfile immediately.
      '';
    };
  };
}
