{
  outputs = _: {
    flakeModule = ./nix/flake-module.nix;

    lib = ./nix/lib.nix;

    templates.default = {
      description = "Example flake using process-compose-flake";
      path = builtins.path { path = ./example; filter = path: _: baseNameOf path == "flake.nix"; };
    };
  };
}
