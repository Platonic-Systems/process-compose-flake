{ pkgs, lib, config, ... }:

{
  options.hello = {
    enable = lib.mkEnableOption "hello";
    name = lib.mkOption {
      type = lib.types.str;
      default = "hello";
      description = "Process name";
    };
    package = lib.mkPackageOption pkgs "hello" { };
    greeting = lib.mkOption {
      type = lib.types.str;
      default = "Hello";
      description = "The greeting to use";
    };
  };
  config =
    let cfg = config.hello;
    in lib.mkIf cfg.enable {
      settings.processes.${cfg.name}.command = ''
        set -x
        ${lib.getExe cfg.package} -g "${cfg.greeting}"
      '';
    };
}
