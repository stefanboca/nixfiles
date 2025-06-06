{ ... }:

{
  # TODO: double check

  # fileSystems."/" = {
  #   device = "/dev/disk/by-uuid/00626c1f-4272-4958-a9b3-90d9338534ee";
  #   fsType = "btrfs";
  #   options = [ "subvol=rootfs" ];
  # };
  #
  # fileSystems."/boot" = {
  #   device = "/dev/disk/by-uuid/2602-4870";
  #   fsType = "vfat";
  #   options = [ "umask=0077" ];
  # };
  #
  # fileSystems."/home" = {
  #   device = "/dev/disk/by-uuid/00626c1f-4272-4958-a9b3-90d9338534ee";
  #   fsType = "btrfs";
  #   options = [ "subvol=home" ];
  # };
  #
  # fileSystems."/nix" = {
  #   device = "/dev/disk/by-uuid/00626c1f-4272-4958-a9b3-90d9338534ee";
  #   fsType = "btrfs";
  #   options = [ "subvol=nix" ];
  # };

  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/nvme0n1";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          type = "EF00";
          priority = 1;
          start = "1M";
          end = "4G";
          size = "100%";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        root = {
          start = "4G";
          size = "100%";
          content = {
            type = "btrfs";
            mountpoint = "/partition-root";
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
