set -euxo pipefail

cd "$(dirname "$0")"

# First, build the example.
pushd ./example
nix build -L --no-link --print-out-paths --override-input process-compose-flake ..

# On NixOS, run the VM tests to test runtime behaviour
if command -v nixos-rebuild &> /dev/null; then
  # TODO: Can we run all these tests in the same VM?

  # example
  nix flake check -L --override-input process-compose-flake ..
fi
