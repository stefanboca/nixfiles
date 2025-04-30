{ ... }:

{
  # TODO: double check
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/bd86b4f9-f7a4-4fac-bea5-2f7bdbaaaa32";
    fsType = "btrfs";
    options = [ "subvol=root" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/bd86b4f9-f7a4-4fac-bea5-2f7bdbaaaa32";
    fsType = "btrfs";
    options = [ "subvol=home" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/c8e28de4-6d7c-475b-987c-e874ac1430c2";
    fsType = "ext4";
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/E5FC-833C";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

}
