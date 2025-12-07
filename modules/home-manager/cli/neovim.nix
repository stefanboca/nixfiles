{
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}: let
  cfg = config.cli;
in {
  imports = [
    "${modulesPath}/programs/neovide.nix"
  ];

  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
      EDITOR = "snv";
      VISUAL = "snv";
    };
    home.packages = [pkgs.snv];

    programs.neovide = {
      enable = true;
      settings = {
        fork = true;
        frame = "none";
        title-hidden = true;
      };
    };
  };
}
