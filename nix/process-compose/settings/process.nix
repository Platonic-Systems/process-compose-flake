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
              "process_log_ready"
              "process_started"
            ];
            example = "process_healthy";
            description = ''
              The condition the parent process must be in before starting the current one.
            '';
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
        description = ''
          When to restart the process.
        '';
      };
      exit_on_end = mkOption {
        type = types.nullOr types.bool;
        default = null;
        example = true;
        description = ''
          Whether to gracefully stop all the processes upon the exit of the current process.
        '';
      };
      # Added to process-compose in https://github.com/F1bonacc1/process-compose/pull/226
      exit_on_skipped = mkOption {
        type = types.nullOr types.bool;
        default = null;
        example = true;
        description = ''
          Whether to gracefully stop all the processes upon the process being skipped.
        '';
      };
      backoff_seconds = mkOption {
        type = types.nullOr types.ints.unsigned;
        default = null;
        example = 2;
        description = ''
          Restart will wait `process.availability.backoff_seconds` seconds between `stop` and `start` of the process. If not configured the default value is 1s.
        '';
      };
      max_restarts = mkOption {
        type = types.nullOr types.ints.unsigned;
        default = null;
        example = 0;
        description = ''
          Max. number of times to restart.

          Tip: It might be sometimes useful to `exit_on_end` with `restart: on_failure` and `max_restarts` in case you want the process to recover from failure and only cause termination on success.
        '';
      };
    };

    shutdown = {
      command = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "sleep 2 && pkill -f 'test_loop.bash my-proccess'";
        description = ''
          The command to run while process-compose is trying to gracefully shutdown the current process.

          Note: The `shutdown.command` is executed with all the Environment Variables of the primary process
        '';
      };
      signal = mkOption {
        type = types.nullOr types.ints.unsigned;
        default = null;
        example = 15;
        description = ''
          If `shutdown.command` is not defined, exit the process with this signal. Defaults to `15` (SIGTERM)
        '';
      };
      timeout_seconds = mkOption {
        type = types.nullOr types.ints.unsigned;
        default = null;
        example = 10;
        description = ''
          Wait for `timeout_seconds` for its completion (if not defined wait for 10 seconds). Upon timeout, `SIGKILL` is sent to the process.
        '';
      };
      parent_only = mkOption {
        type = types.nullOr types.bool;
        default = null;
        example = false;
        description = ''
          If `shutdown.parent_only` is enabled, the termination signal is only sent to the parent process, not the whole group.
        '';
      };
    };

    working_dir = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "/tmp";
      description = ''
        The directory to run the process in.
      '';
    };
    readiness_probe = mkOption {
      type = types.nullOr probeType;
      default = null;
      description = ''
        The settings used to check if the process is ready to accept connections.
      '';
    };
    liveness_probe = mkOption {
      type = types.nullOr probeType;
      default = null;
      description = ''
        The settings used to check if the process is alive.
      '';
    };
    ready_log_line = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "process is ready";
      description = ''
        A string to search for in the output of the command that indicates
        the process is ready. String will be part of a regex '.*{ready_log_line}.*'.
        This should be used for long running processes that do not have a
        readily accessible check for http or similar other checks.
      '';
    };

    namespace = mkOption {
      type = types.str;
      default = "default";
      description = ''
        Used to group processes together.
      '';
    };

    environment = import ./environment.nix { inherit lib; };
    log_location = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "./pc.my-proccess.log";
      description = ''
        Log location of the `process-compose` process.
      '';
    };

    log_configuration = mkOption {
      type = types.nullOr (types.submoduleWith {
        specialArgs = { inherit lib; };
        modules = [ ./log-config.nix ];
      });
      default = { };
      description = ''
        The settings for process-specific logging.
      '';
    };

    disable_ansi_colors = mkOption {
      type = types.nullOr types.bool;
      default = null;
      example = true;
      description = ''
        Whether to disable colors in the logs.
      '';
    };
    is_daemon = mkOption {
      type = types.nullOr types.bool;
      default = null;
      example = true;
      description = ''
        - For processes that start services / daemons in the background, please use the `is_daemon` flag set to `true`.
        - In case a process is daemon it will be considered running until stopped.
        - Daemon processes can only be stopped with the `$PROCESSNAME.shutdown.command` as in the example above.
      '';
    };
    is_foreground = mkOption {
      type = types.nullOr types.bool;
      default = null;
      example = true;
      description = ''
        Foreground processes are useful for cases when a full `tty` access is required (e.g. `vim`, `top`, `gdb -tui`)

        - Foreground process have to be started manually (`F7`). They can be started multiple times.
        - They are available in TUI mode only.
        - To return to TUI, exit the foreground process.
        - In TUI mode, a local process will be started.
      '';
    };
    is_tty = mkOption {
      type = types.nullOr types.bool;
      default = null;
      example = true;
      description = ''
        Simulate TTY mode for this process
      '';
    };
    disabled = mkOption {
      type = types.nullOr types.bool;
      default = if name == "test" then true else null;
      example = true;
      description = ''
        Whether the process is disabled. Useful when a process is required to be started only in a given scenario, like while running in CI.

        Even if disabled, the process is still listed in the TUI and the REST client, and can be started manually when needed.
      '';
    };

    vars = import ./vars.nix { inherit lib; };

    replicas = mkOption {
      type = types.nullOr types.int;
      default = null;
      example = 2;
      description = ''
        Run multiple replicas of a given process.

        Will set the PC_REPLICA_NUM var for expansion such that configs can run on unique ports or similar.
      '';
    };

    description = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "process does a thing";
      description = ''
        Set a description for the process in the UI.
      '';
    };

    entrypoint = mkOption {
      type = types.nullOr (types.listOf types.str);
      default = null;
      example = [
        "ls"
        "-l"
        "/some/dir"
      ];
      description = ''
        Specifies the process command as a list of arguments.
        Overridden by the command option if it is present.
      '';
    };

    is_elevated = mkOption {
      type = types.nullOr types.bool;
      default = null;
      example = true;
      description = ''
        Run the command with elevated permissions,
        using sudo or runas.
      '';
    };

    is_disabled = mkOption {
      type = types.nullOr types.bool;
      default = null;
      example = false;
      description = ''
        Allows turning off the disabled flag when dealing with merged configs via `extend` or multiple config file command arguments.

        is_disabled has priority over disabled, so in general:
        - use disabled in base or primary configurations
        - use is_disabled in override configurations.
      '';
    };

    is_dotenv_disabled = mkOption {
      type = types.nullOr types.bool;
      default = null;
      example = true;
      description = ''
        If set to true, prevents process-compose from loading any .env files in the working directory.

        Does not prevent other sources of env variables, such as the env section of the configuration.
      '';
    };

    launch_timeout_seconds = mkOption {
      type = types.nullOr types.int;
      default = null;
      example = 2;
      description = ''
        If a parent process with is_daemon takes longer than this to fork in to the background, process-compose will stop waiting for logs and start waiting for process termination.
      '';
    };
  };
}
