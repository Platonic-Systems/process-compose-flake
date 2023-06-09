rm -f ./data.sqlite
nix run -L --override-input process-compose-flake .. . -- -t=false
[[ $(cat result.txt) == "Hello" ]] && echo "Test passed" || (echo "Test failed" && exit 1)
