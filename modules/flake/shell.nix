{ ... }:

{
  perSystem =
    {
      config,
      self',
      inputs',
      pkgs,
      system,
      ...
    }:
    {
      devShells = {
        default = pkgs.mkShellNoCC {
          packages = with pkgs; [
            age
            bat
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
