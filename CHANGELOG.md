# Revision history for process-compose-flake

## Unreleased

- New features
    - ~~#18: Add `testScript` option for adding flake checks based on nixosTest library.~~
    - #39: Allow `test` process to act as a test, which then gets run as part of flake checks.
    - #52: Add `is_foreground` option
- Fixes
    - #19: Reintroduce the `shell` option so process-compose doesn't rely on user's global bash (which doesn't exist nixosTest runners).
    - #22: `command` option is no longer wrapped in `writeShellApplication`.
    - #20: Fix definiton of `probe.exec`


## 0.1.0 (Jun 12, 2023)

- Initial release
