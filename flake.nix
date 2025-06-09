{
  outputs = _: {
    flakeModule = ./nix/flake-module.nix;

    lib = ./nix/lib.nix;

    templates.default = {
      description = "Example flake using process-compose-flake";
      path = builtins.path { path = ./example; filter = path: _: baseNameOf path == "flake.nix"; };
    };

    # We don't use nix-ci.com (#96)
    nix-ci.enable = false;

    # https://github.com/srid/nixci
    nixci.default = let overrideInputs = { process-compose-flake = ./.; }; in {
      example = {
        inherit overrideInputs;
        dir = "example";
      };
      dev = {
        inherit overrideInputs;
        dir = "dev";
      };
    };
  };
}
