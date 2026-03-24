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
            # Subvolume name is different from mountpoint
            subvolumes = {
              "/rootfs" = {
                mountpoint = "/";
                swap.swapfile.size = "32G";
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
}
