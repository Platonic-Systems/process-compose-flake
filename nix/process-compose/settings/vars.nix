{ lib, ... }:
let
  inherit (lib) types;
  inherit (types) nullOr attrsOf anything;
in
lib.mkOption {
  # maybe YAML/JSON limited or smarter coerce to string?
  type = nullOr (attrsOf anything);
  description = ''
    Variables used by process-compose to expand Go Template configs on various values.

    Includes processes.process.command, working_dir, log_location, etc.
    See https://f1bonacc1.github.io/process-compose/configuration#variables
  '';
  default = null;
  example = {
    THIS = "THAT";
    A_NUMBER = 8888;
    OK = "SUCCESS";
  };
}
