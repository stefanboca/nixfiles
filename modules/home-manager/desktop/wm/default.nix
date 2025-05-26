{ inputs, ... }:

{
  imports = [
    inputs.centerpiece.hmModules."x86_64-linux".default
    ./niri.nix
  ];

  programs.centerpiece = {
    enable = true;
    config = {
      plugin = {
        brave_bookmarks.enable = false;
        brave_history.enable = false;
        brave_progressive_web_apps.enable = false;
        firefox_bookmarks.enable = false;
        firefox_history.enable = false;
        git_repositories.enable = false;
        sway_windows.enable = false;
      };
    };
    services.index-git-repositories.enable = false;
  };
}
