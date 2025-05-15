{ ... }:

{
  # TODO: double check

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/00626c1f-4272-4958-a9b3-90d9338534ee";
    fsType = "btrfs";
    options = [ "subvol=/rootfs" ];
  };
  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/00626c1f-4272-4958-a9b3-90d9338534ee";
    fsType = "btrfs";
    options = [
      "subvol=/home"
      "compress=zstd:1"
    ];
  };
  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/00626c1f-4272-4958-a9b3-90d9338534ee";
    fsType = "btrfs";
    options = [
      "subvol=/nix"
      "compress=zstd:1"
      "noatime"
    ];
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/2602-4870";
    fsType = "vfat";
    options = [ "umask=0077" ];
  };

  # disko.devices.disk.main = {
  #   # TODO: s/main/primary
  #   type = "disk";
  #   device = "/dev/sda"; # TODO: change to /dev/nvme0n1
  #   content = {
  #     type = "gpt";
  #     partitions = {
  #       ESP = {
  #         type = "EF00";
  #         start = "1M";
  #         end = "4G";
  #         content = {
  #           type = "filesystem";
  #           format = "vfat";
  #           mountpoint = "/boot";
  #           mountOptions = [ "umask=0077" ];
  #         };
  #       };
  #       root = {
  #         size = "100%";
  #         content = {
  #           type = "btrfs";
  #           # mountpoint = "/partition-root";
  #           # Subvolume name is different from mountpoint
  #           subvolumes = {
  #             "/rootfs" = {
  #               mountpoint = "/";
  #             };
  #             "/home" = {
  #               mountOptions = [ "compress=zstd:1" ];
  #               mountpoint = "/home";
  #             };
  #             "/nix" = {
  #               mountOptions = [
  #                 "compress=zstd:1"
  #                 "noatime"
  #               ];
  #               mountpoint = "/nix";
  #             };
  #           };
  #         };
  #       };
  #     };
  #   };
  # };
}
