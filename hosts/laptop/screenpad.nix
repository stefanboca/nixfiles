{ pkgs, ... }:

let
  toggleScript =
    pkgs.writeShellScriptBin "toggle-screenpad-backlight" # bash
      ''
        FILE="/sys/class/backlight/asus_screenpad/bl_power"
        [ "$(cat $FILE)" = "0" ] && echo 4 > $FILE || echo 0 > $FILE
      '';
in
{
  environment.systemPackages = [ toggleScript ];
}
