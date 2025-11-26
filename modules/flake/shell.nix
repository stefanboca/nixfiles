{...}: {
  perSystem = {pkgs, ...}: {
    devShells = {
      default = pkgs.mkShellNoCC {
        packages = with pkgs; [
          # keep-sorted start
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
          # keep-sorted end
        ];

        env.NIX_CONFIG = "experimental-features = nix-command flakes";

        shellHook = ''
          exec fish
        '';
      };
    };
  };
}
