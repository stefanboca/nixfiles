{ ... }:

{
  home.shell.enableFishIntegration = true;

  programs.fish = {
    enable = true;
    preferAbbrs = true;
  };
}
