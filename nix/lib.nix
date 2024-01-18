{ lib, ... }:

rec {
  # Lookup an environment in process-compose environment list
  lookupEnv = name: envList:
    let
      env = parseEnvList envList;
    in
    lib.getAttr name env;

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
}
