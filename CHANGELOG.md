# Revision history for process-compose-flake

## Unreleased

- New features
    - #81, #84: Support for specifying process-compose global CLI options
      - **Breaking changes**:
        - `preHook` and `postHook` are now inside `cli` module.
        - Old options `httpServer` and `tui` were removed; users should use the new `cli` module to set all process-compose cli arguments and options.
    - ~~#18: Add `testScript` option for adding flake checks based on nixosTest library.~~
    - #39: Allow `test` process to act as a test, which then gets run as part of flake checks.
    - #55: Add `lib` flake output - library of useful functions
        - #80: Add `evalModules`, to use process-compose-flake without flake-parts
    - New options
      - #52: Add `is_foreground` option
      - ~~#54: Add `apiServer` option to control REST API server~~
      - $60: Add `httpServer.{enable, port, uds}` options to control the HTTP server.
      - #56: Add `preHook` and `postHook` for running commands before and after launching process-compose respectively.
      - #67: Add `ready_log_line`
      - #226: Add `availability.exit_on_skipped`
      - #77: Add `is_tty`
- Notable changes
    - #58: Obviate IFD by switching to JSON config
- Fixes
    - #19: Reintroduce the `shell` option so process-compose doesn't rely on user's global bash (which doesn't exist nixosTest runners).
    - #22: `command` option is no longer wrapped in `writeShellApplication`.
    - #20: Fix definiton of `probe.exec`
    - #53: Make process submodule a proper submodule (allowing use of `imports` etc)


## 0.1.0 (Jun 12, 2023)

- Initial release
