rec {
  evalModules = { pkgs, name, modules }: (pkgs.lib.evalModules {
    specialArgs = {
      inherit name pkgs;
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
