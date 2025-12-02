{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkAfter mkIf mkMerge;
  inherit (lib.options) mkEnableOption mkOption mkPackageOption;
  inherit (lib.types) package;

  database-packages = pkgs.callPackage inputs.nix-index-database {};

  command-not-found = pkgs.writeShellScript "nix-index-command-not-found" ''
    source ${cfg.package}/etc/profile.d/command-not-found.sh
    command_not_found_handle "$@"
  '';

  cfg = config.rum.programs.nix-index;
in {
  options.rum.programs.nix-index = {
    enable = mkEnableOption "nix-index";
    package = mkPackageOption pkgs "nix-index" {nullable = true;};

    database = {
      cache.enable = mkEnableOption "database";
      package = mkOption {
        type = package;
        default = database-packages.nix-index-database;
      };
      comma = {
        enable = mkEnableOption "wrapping comma with database and putting it in path";
        package = mkOption {
          type = package;
          default = database-packages.comma-with-db;
        };
      };
    };

    integrations = {
      fish.enable = mkEnableOption "nix-index integration with fish";
      zsh.enable = mkEnableOption "nix-index integration with zsh";
      nushell.enable = mkEnableOption "nix-index integration with nushell";
    };
  };

  config = mkIf cfg.enable {
    packages = mkMerge [
      (mkIf (cfg.package != null) [cfg.package])
      (mkIf cfg.database.comma.enable [cfg.database.comma.package])
    ];

    xdg.cache.files."nix-index/files" = mkIf cfg.database.cache.enable {source = cfg.database.package;};

    rum.programs.fish.functions = mkIf cfg.integrations.fish.enable {
      __fish_command_not_found_handler = pkgs.writers.writeFish "__fish_command_not_found_handler.fish" "
        function __fish_command_not_found_handler --on-event fish_command_not_found
            ${command-not-found} $argv
        end
      ";
    };
    rum.programs.zsh.initConfig = mkIf cfg.integrations.zsh.enable (
      mkAfter ''source ${cfg.package}/etc/profile.d/command-not-found.sh''
    );
    rum.programs.nushell.extraConfig = mkIf cfg.integrations.nushell.enable (
      mkAfter ''source ${cfg.package}/etc/profile.d/command-not-found.nu''
    );
  };
}
