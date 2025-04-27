{ pkgs, ... }:

{
  users.users.root = {
    shell = pkgs.fish;
    password = "temporarypassword"; # FIXME:
  };
}
