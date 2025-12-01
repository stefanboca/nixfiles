{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkAfter mkIf;
  inherit (lib.options) mkEnableOption mkOption mkPackageOption;
  inherit (lib.strings) concatStringsSep;
  inherit (lib.types) listOf str;

  toml = pkgs.formats.toml {};

  toFlags = concatStringsSep " " cfg.flags;

  cfg = config.rum.programs.atuin;
in {
  options.rum.programs.atuin = {
    enable = mkEnableOption "atuin";

    package = mkPackageOption pkgs "atuin" {nullable = true;};

    flags = mkOption {
      type = listOf str;
      default = [];
      example = [
        "--disable-up-arrow"
      ];
    };

    settings = mkOption {
      inherit (toml) type;
      default = {};
      example = {
        auto_sync = true;
        sync_frequency = "5m";
        sync_address = "https://api.atuin.sh";
        search_mode = "prefix";
      };
    };

    integrations = {
      fish.enable = mkEnableOption "atuin integration with fish";
      zsh.enable = mkEnableOption "atuin integration with zsh";
      nushell.enable = mkEnableOption "atuin integration with nushell";
    };
  };

  config = mkIf cfg.enable {
    packages = mkIf (cfg.package != null) [cfg.package];

    xdg.config.files."atuin/config.toml" = mkIf (cfg.settings != {}) {
      source = toml.generate "alacritty.toml" cfg.settings;
    };

    rum.programs.fish.config = mkIf cfg.integrations.fish.enable (
      mkAfter "${getExe cfg.package} init fish ${toFlags} | source"
    );
    rum.programs.zsh.initConfig = mkIf cfg.integrations.zsh.enable (
      mkAfter ''eval "${getExe cfg.package} init zsh ${toFlags}"''
    );
    rum.programs.nushell.extraConfig = mkIf cfg.integrations.nushell.enable (
      mkAfter ''
        source ${pkgs.runCommand "atuin-init-nu" {} ''${getExe cfg.package} init nushell ${toFlags} >> "$out"''}
      ''
    );
  };
}
