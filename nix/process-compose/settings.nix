{ name, config, pkgs, lib, ... }: 
let 
  inherit (lib) types mkOption literalExpression;
in 
{
  options = {
    settings = mkOption {
      type = (pkgs.formats.yaml { }).type;
      example =
        # packages.${system}.watch-server becomes available
        # execute `nix run .#watch-server` or incude packages.${system}.watch-server
        # as a nativeBuildInput to your devShell
        literalExpression ''
          {
            watch-server = {
              processes = {
                backend = "''${pkgs.simple-http-server}";
                frontend = "''${pkgs.simple-http-server}";
              };
            };
          };
        '';
      description = ''
        For each attribute `x = process-compose config` a flake app and package `x` is added to the flake.
        Which runs process-compose with the declared config.
      '';
    };

    settingsYaml = mkOption {
      type = types.attrsOf types.raw;
      internal = true;
    };
  };

  config.settingsYaml =
    let
      toYAMLFile =
        attrs:
        pkgs.runCommand "toYamlFile" { buildInputs = [ pkgs.yq-go ]; } ''
          yq -P '.' ${pkgs.writeTextFile { name = "process-compose-${name}.json"; text = (builtins.toJSON attrs); }} > $out
        '';
    in
    toYAMLFile config.settings;
}

