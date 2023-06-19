# Revision history for process-compose-flake

## Unreleased

- #18: Add `testScript` option for adding flake checks based on nixosTest library.
- Fixes
    - #19: Reintroduce the `shell` option so process-compose doesn't rely on user's global bash (which doesn't exist nixosTest runners).
    - #20: Fix definiton of `probe.exec`


## 0.1.0 (Jun 12, 2023)

- Initial release
