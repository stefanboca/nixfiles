{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkOption;
  inherit (lib.strings) concatStringsSep;
  inherit (lib.types) listOf str;

  toDefaultOpts = concatStringsSep " " cfg.defaultOpts;

  cfg = config.rum.programs.fzf;
in {
  options.rum.programs.fzf = {
    defaultOpts = mkOption {
      type = listOf str;
      default = [];
      example = [
        "--height 40%"
        "--border"
      ];
    };
  };

  config = mkIf cfg.enable {
    environment.sessionVariables.FZF_DEFAULT_OPTS = mkIf (cfg.defaultOpts != []) toDefaultOpts;
  };
}
