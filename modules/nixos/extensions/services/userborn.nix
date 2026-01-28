{
  config,
  lib,
  ...
}: let
  inherit (builtins) attrValues filter;
  inherit (lib.lists) flatten;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkOption;
  inherit (lib.strings) concatLines;
  inherit (lib.trivial) pipe;
  inherit (lib.types) bool;

  rangesToText = userRangesToText:
    pipe config.users.users [
      attrValues
      (filter (user: user.isNormalUser))
      (map userRangesToText)
      flatten
      concatLines
    ];

  subuidText = rangesToText (user: map (subuid: "${user.name}:${toString subuid.startUid}:${toString subuid.count}") user.subUidRanges);
  subgidText = rangesToText (user: map (subgid: "${user.name}:${toString subgid.startGid}:${toString subgid.count}") user.subGidRanges);

  cfg = config.services.userborn;
in {
  options.services.userborn = {
    subUid = mkOption {
      type = bool;
      default = true;
    };

    subGid = mkOption {
      type = bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    environment.etc."subuid" = mkIf cfg.subUid {
      text = subuidText;
      mode = "0444";
    };

    environment.etc."subgid" = mkIf cfg.subGid {
      text = subgidText;
      mode = "0444";
    };
  };
}
