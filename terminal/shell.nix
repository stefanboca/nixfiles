{ lib, pkgs, ... }:

{
  home.sessionVariables.LESS = "-FRXS";

  programs.pay-respects.enable = true;

  home.shell.enableFishIntegration = true;
  programs.fish = {
    enable = true;
    preferAbbrs = true;

    functions = {
      # disable greeting
      fish_greeting = "";
      # Vi bindings that inherit emacs bindings in insert mode
      fish_user_key_bindings = ''
        fish_default_key_bindings -M insert
        fish_vi_key_bindings --no-erase insert
      '';

      # jj integration for tide
      _tide_item_jj = ''
        command -q jj && jj --ignore-working-copy root &>/dev/null || return 1
        _tide_print_item jj $tide_jj_icon' ' (jj log -r@ --ignore-working-copy --no-pager --no-graph --color always -T shell_prompt)
      '';
      _tide_item_git_no_jj = ''command -q jj && jj --ignore-working-copy root &>/dev/null && return 1 || _tide_item_git'';
    };

    shellAbbrs = {
      # NOTE: (roughly) sorted in order of laziness, least to greatest
      sc = "sudo systemctl --system";
      scu = "systemctl --user";

      nsn = "nix search nixpkgs";

      se = "sudoedit";
      lj = "lazyjj";
      nv = "neovide";
      n = "nvim";
      o = "open";

      sl = "eza -l";
      sa = "eza -la";
      s = "eza";

      j = "jj";

      # TODO: remove on nixos
      dnfl = "dnf5 list";
      dnfli = "dnf5 list --installed";
      dnfmc = "dnf5 makecache";
      dnfp = "dnf5 info";
      dnfs = "dnf5 search";
      dnfrq = "dnf5 repoquery";

      dnfu = "sudo dnf5 upgrade";
      dnfi = "sudo dnf5 install";
      dnfri = "sudo dnf5 reinstall";
      dnfsw = "sudo dnf5 swap";
      dnfr = "sudo dnf5 remove";
      dnfc = "sudo dnf5 clean all";
    };

    plugins = [
      {
        name = "autopair";
        src = pkgs.fishPlugins.autopair.src;
      }
      {
        name = "git-abbr";
        src = pkgs.fishPlugins.git-abbr.src;
      }
      # text expansions such as .., !! and others
      {
        name = "puffer";
        src = pkgs.fishPlugins.puffer.src;
      }
      # prompt
      {
        name = "tide";
        src = pkgs.fishPlugins.tide.src;
      }
    ];

    interactiveShellInit = ''
      ${pkgs.any-nix-shell}/bin/any-nix-shell fish | source # use fish for nix shells
    '';
  };

  # TODO: theme
  home.activation.configure-fish = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run --quiet ${pkgs.fish}/bin/fish -c "
      set -U fish_key_bindings fish_user_key_bindings # needed for autopairs to work for some reason

      # setup tide prompt
      tide configure --auto --style=Lean --prompt_colors='True color' --show_time='24-hour format' --lean_prompt_height='Two lines' --prompt_connection=Solid --prompt_connection_andor_frame_color=Lightest --prompt_spacing=Sparse --icons='Few icons' --transient=No
      set -U tide_left_prompt_items pwd git_no_jj jj newline character
    "'';
}
