rec {
  evalModules = { pkgs, name, modules }: (pkgs.lib.evalModules {
    specialArgs = {
      inherit name pkgs;
      process-compose-flake-lib = (import ./process-compose-flake-lib.nix) { lib = pkgs.lib; };
    };
    modules = [
      ./process-compose
    ] ++ modules;
  });

  makeProcessCompose = { pkgs, name, modules }: (evalModules {
    inherit pkgs name;
    modules = modules;
  }).config.outputs.package;
}
