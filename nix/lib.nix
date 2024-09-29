{ pkgs, lib ? pkgs.lib, ... }:

rec {
  # Lookup an environment in process-compose environment list
  # Returns null if environment doesn't otherwise.
  lookupEnv = name: envList:
    let
      env = parseEnvList envList;
    in
    lib.attrByPath [ name ] null env;

  # Parse "FOO=bar" into { FOO = "bar"; }
  parseEnv = s:
    let
      parts = lib.splitString "=" s;
    in
    if builtins.length parts == 2 then
      let
        k = builtins.head parts;
        v = builtins.head (builtins.tail parts);
      in
      { ${k} = v; }
    else
      null;

  # Parse `[ "FOO=bar" "BAZ=quux" ]` into `{ FOO = "bar"; BAZ = "quux"; }`
  parseEnvList = l:
    if l == null then { }
    else builtins.foldl' (x: y: x // y) { } (builtins.map parseEnv l);

  types = {
    command = import ./process-compose/setting/command.nix { inherit lib; };
  };

  # Run the process-compose-module stand-alone, without flake-parts
  # - modules: list of modules that set process-compose-flake options
  # - name: name of the module, you typically don't need to set this
  # Returns the full result of the module evaluation
  evalModules = { name ? "process-compose", modules }: (lib.evalModules {
    specialArgs = {
      inherit name pkgs;
    };
    modules = [
      ./process-compose
    ] ++ modules;
  });

  # Same as evalModules, but returns the process-compose process directly
  makeProcessCompose = { name, modules }: (evalModules {
    inherit pkgs name;
    modules = modules;
  }).config.outputs.package;
}
