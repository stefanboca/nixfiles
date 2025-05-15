{ ... }:

{
  # TODO: double check

  # fileSystems."/" = {
  #   device = "/dev/disk/by-uuid/bd86b4f9-f7a4-4fac-bea5-2f7bdbaaaa32";
  #   fsType = "btrfs";
  #   options = [ "subvol=root" ];
  # };
  #
  # fileSystems."/home" = {
  #   device = "/dev/disk/by-uuid/bd86b4f9-f7a4-4fac-bea5-2f7bdbaaaa32";
  #   fsType = "btrfs";
  #   options = [ "subvol=home" ];
  # };
  #
  # fileSystems."/boot" = {
  #   device = "/dev/disk/by-uuid/c8e28de4-6d7c-475b-987c-e874ac1430c2";
  #   fsType = "ext4";
  # };
  #
  # fileSystems."/boot/efi" = {
  #   device = "/dev/disk/by-uuid/E5FC-833C";
  #   fsType = "vfat";
  #   options = [
  #     "fmask=0077"
  #     "dmask=0077"
  #   ];
  # };

  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/sdb"; # TODO: change
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          type = "EF00";
          start = "1M";
          end = "4G";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "btrfs";
            mountpoint = "/";
            # Subvolume name is different from mountpoint
            subvolumes = {
              "/rootfs" = {
                mountpoint = "/";
              };
              "/home" = {
                mountOptions = [ "compress=zstd:1" ];
                mountpoint = "/home";
              };
              "/nix" = {
                mountOptions = [
                  "compress=zstd:1"
                  "noatime"
                ];
                mountpoint = "/nix";
              };
            };
          };
        };
      };
    };
  };
}
