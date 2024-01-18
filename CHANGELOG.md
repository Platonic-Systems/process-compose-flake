# Revision history for process-compose-flake

## Unreleased

- New features
    - ~~#18: Add `testScript` option for adding flake checks based on nixosTest library.~~
    - #39: Allow `test` process to act as a test, which then gets run as part of flake checks.
    - #55: Add `lib` flake output - library of useful functions
    - New options
      - #52: Add `is_foreground` option
      - #54: Add `apiServer` option to control REST API server
- Fixes
    - #19: Reintroduce the `shell` option so process-compose doesn't rely on user's global bash (which doesn't exist nixosTest runners).
    - #22: `command` option is no longer wrapped in `writeShellApplication`.
    - #20: Fix definiton of `probe.exec`
    - #53: Make process submodule a proper submodule (allowing use of `imports` etc)


## 0.1.0 (Jun 12, 2023)

- Initial release
