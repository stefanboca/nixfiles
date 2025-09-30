{...}: {
  perSystem = {pkgs, ...}: {
    devShells = {
      default = pkgs.mkShellNoCC {
        packages = with pkgs; [
          age
          bat
          disko
          eza
          fd
          fish
          fzf
          git
          gnupg
          home-manager
          neovim
          nh
          nix
          parted
          ripgrep
          sbctl
          sops
          ssh-to-age
        ];

        env.NIX_CONFIG = "experimental-features = nix-command flakes";

        shellHook = ''
          exec fish
        '';
      };
    };
  };
}
