set -euxo pipefail

cd "$(dirname "$0")"

cd ./example
# First, build the example.
nix build -L --no-link --print-out-paths --override-input process-compose-flake ..

# On NixOS, run the VM tests to test runtime behaviour
if command -v nixos-rebuild &> /dev/null; then
  nix flake check -L --override-input process-compose-flake ..
fi
