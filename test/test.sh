set -euxo pipefail

cd "$(dirname "$0")"

# First, build the example.
(cd ../example && nix build -L --override-input process-compose-flake ..)

# Then run the test.
rm -f ./data.sqlite ./result.txt
nix run -L --override-input process-compose-flake .. .
[[ $(cat result.txt) == "Hello" ]] && echo "Test passed" || (echo "Test failed" && exit 1)
