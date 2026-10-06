# List all the just commands
default:
    @just --list

# Auto-format the project tree
fmt:
    treefmt

# Run example, using current process-compose
ex *ARGS:
  cd ./example && nix run --override-input process-compose-flake .. . -- {{ARGS}}

# Run example's test
ex-check:
  cd ./example && nix flake check -L --override-input process-compose-flake ..
