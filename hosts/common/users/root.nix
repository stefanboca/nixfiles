{config, ...}: {
  users.users.root = {
    hashedPasswordFile = config.sops.secrets.root-pw.path;

    openssh.authorizedKeys.keys = [(builtins.readFile ../../../home/stefan/keys/id_ed25519.pub)];
  };

  sops.secrets.root-pw.neededForUsers = true;
}
