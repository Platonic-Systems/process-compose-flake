{
  outputs = _: {
    flakeModule = ./nix/flake-module.nix;

    processComposeModules = {
      services = ./nix/services;
    };

    templates.default = {
      description = "Example flake using process-compose-flake";
      path = builtins.path { path = ./example; filter = path: _: baseNameOf path == "flake.nix"; };
    };
  };
}
