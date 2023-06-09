cd "$(dirname "$0")"
rm -f ./data.sqlite
nix run -L --override-input process-compose-flake .. .
[[ $(cat result.txt) == "Hello" ]] && echo "Test passed" || (echo "Test failed" && exit 1)
