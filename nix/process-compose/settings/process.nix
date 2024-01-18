{ name, lib, ... }:

let
  inherit (lib) types mkOption;
  probeType = types.submoduleWith {
    specialArgs = { inherit lib; };
    modules = [ ./probe.nix ];
  };
in
{
  options = {
    command = import ./command.nix { inherit lib; } {
      description = ''
        The command or script or package that runs this process

        If a package is given, its executable is used as the command. Otherwise,
        the command string is wrapped in a `pkgs.writeShellApplication` which
        uses ShellCheck and runs the command in bash.
      '';
    };

    depends_on = mkOption {
      description = "Process dependency relationships";
      type = types.nullOr (types.attrsOf (types.submodule {
        options = {
          condition = mkOption {
            type = types.enum [
              "process_completed"
              "process_completed_successfully"
              "process_healthy"
              "process_started"
            ];
            example = "process_healthy";
          };
        };
      }));
      default = null;
    };

    availability = {
      restart = mkOption {
        type = types.nullOr (types.enum [
          "always"
          "on_failure"
          "exit_on_failure"
          "no"
        ]);
        default = null;
        example = "on_failure";
      };
      exit_on_end = mkOption {
        type = types.nullOr types.bool;
        default = null;
        example = true;
      };
      backoff_seconds = mkOption {
        type = types.nullOr types.ints.unsigned;
        default = null;
        example = 2;
      };
      max_restarts = mkOption {
        type = types.nullOr types.ints.unsigned;
        default = null;
        example = 0;
      };
    };

    shutdown = {
      command = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "sleep 2 && pkill -f 'test_loop.bash my-proccess'";
      };
      signal = mkOption {
        type = types.nullOr types.ints.unsigned;
        default = null;
        example = 15;
      };
      timeout_seconds = mkOption {
        type = types.nullOr types.ints.unsigned;
        default = null;
        example = 10;
      };
    };

    working_dir = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "/tmp";
    };
    readiness_probe = mkOption {
      type = types.nullOr probeType;
      default = null;
    };
    liveness_probe = mkOption {
      type = types.nullOr probeType;
      default = null;
    };

    namespace = mkOption {
      type = types.str;
      default = "default";
    };

    environment = import ./environment.nix { inherit lib; };
    log_location = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "./pc.my-proccess.log";
    };
    disable_ansi_colors = mkOption {
      type = types.nullOr types.bool;
      default = null;
      example = true;
    };
    is_daemon = mkOption {
      type = types.nullOr types.bool;
      default = null;
      example = true;
    };
    is_foreground = mkOption {
      type = types.nullOr types.bool;
      default = null;
      example = true;
    };
    disabled = mkOption {
      type = types.nullOr types.bool;
      default = if name == "test" then true else null;
      example = true;
    };

  };
}
