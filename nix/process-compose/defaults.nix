# A module representing the default values for all processes in process-compose-flake.
{ name, lib, config, ... }:
let
  inherit (lib)
    mkOption
    types;
in
{
  options.defaults = {
    enable = mkOption {
      type = types.bool;
      description = ''
        Whether to enable default settings for processes in this configuration.
      '';
      default = true;
    };

    processSettings = mkOption {
      type = types.deferredModule;
      description = ''
        Default settings that will be applied to all processes in this configuration.

        Individual process settings can override these defaults. When setting defaults,
        use `lib.mkDefault` to ensure individual process settings take precedence.

        Example:
        ```nix
        defaults.processSettings = {
          availability.restart = lib.mkDefault "on_failure";
          availability.max_restarts = lib.mkDefault 3;
          namespace = lib.mkDefault "myapp";
        };
        ```
      '';
      apply = settings:
        if config.defaults.enable then
          settings
        else
          { };
      default = { };
    };
  };
}
