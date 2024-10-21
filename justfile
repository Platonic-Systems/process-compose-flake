# List all the just commands
default:
    @just --list

# Auto-format the project tree
fmt:
    treefmt

# Run doc server with hot-reload
doc:
    cd ./doc && nix run

# Build docs static website (this runs linkcheck automatically)
doc-static:
    nix build ./doc

# Run example, using current process-compose
ex *ARGS:
  cd ./example && nix run --override-input process-compose-flake .. . -- {{ARGS}}

# Run example's test
ex-check:
  cd ./example && nix flake check -L --override-input process-compose-flake ..
