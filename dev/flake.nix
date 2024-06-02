{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    process-compose-flake.url = "github:Platonic-Systems/process-compose-flake";
  };
  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;
      imports = [
        inputs.treefmt-nix.flakeModule
      ];
      perSystem = { pkgs, lib, config, ... }: {
        treefmt = {
          projectRoot = inputs.process-compose-flake;
          projectRootFile = "flake.nix";
          programs = {
            nixpkgs-fmt.enable = true;
          };
        };
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            nixd
          ];
          inputsFrom = [
            config.treefmt.build.devShell
          ];
        };
      };
    };
}
