{ pkgs, lib, config, ... }:

{
  options.hello = {
    enable = lib.mkEnableOption "hello";
    name = lib.mkOption {
      type = lib.types.str;
      default = "hello";
      description = "Process name";
    };
    package = lib.mkPackageOption pkgs "hello" {};
    greeting = lib.mkOption {
      type = lib.types.str;
      default = "Hello";
      description = "The greeting to use";
    };
  };
  config.settings = lib.mkIf config.hello.enable {
    processes.${config.hello.name}.command = ''
      set -x
      ${lib.getExe config.hello.package} -g ${config.hello.greeting}
    '';
  };
}