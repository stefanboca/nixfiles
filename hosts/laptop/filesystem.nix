{lib, ...}: {
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
            extraArgs = "--label main";
            mountpoint = "/partition-root";
            swap.swapfile.size = "64G";
            subvolumes = {
              "/rootfs" = {
                mountpoint = "/";
              };
              "/var" = {
                mountpoint = "/var";
                mountOptions = ["compress=zstd"];
              };
              "/home" = {
                mountpoint = "/home";
                mountOptions = ["compress=zstd"];
              };
              "/nix" = {
                mountpoint = "/nix";
                mountOptions = ["compress=zstd" "noatime"];
              };
            };
          };
        };
      };
    };
  };

  services = {
    beesd.filesystems."main" = {
      spec = "LABEL=main";
      hashTableSizeMB = 512;
      extraOptions = ["--throttle-factor" "1"];
    };
    btrbk.instances = {
      main.settings = {
        timestamp_format = "long";
        snapshot_preserve_min = "4d";
        snapshot_preserve = "14d 4w 3m";
        snapshot_create = "onchange";
        volume."/partition-root" = {
          snapshot_dir = "snapshots";
          subvolume = {
            home = {};
            rootfs = {};
            var = {};
          };
        };
      };
    };
  };

  systemd.services."beesd@main".wantedBy = lib.mkForce [];
}
