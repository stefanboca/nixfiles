{
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
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = ["umask=0077"];
          };
        };
        root = {
          size = "100%";
          content = {
            type = "btrfs";
            mountpoint = "/partition-root";
            swap.swapfile.size = "32G";
            subvolumes = {
              "/rootfs" = {
                mountpoint = "/";
              };
              "/home" = {
                mountpoint = "/home";
                mountOptions = ["compress=zstd:1"];
              };
              "/nix" = {
                mountpoint = "/nix";
                mountOptions = ["compress=zstd:1" "noatime"];
              };
            };
          };
        };
      };
    };
  };

  services.btrbk.instances = {
    main.settings = {
      timestamp_format = "long";
      snapshot_preserve_min = "4d";
      snapshot_preserve = "30d";
      snapshot_create = "onchange";
      volume."/partition-root" = {
        snapshot_dir = "snapshots";
        subvolume.home = {};
        subvolume.rootfs = {};
      };
    };
  };
}
