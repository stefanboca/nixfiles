{ config, ... }:

{
  # TODO: nixify spotify
  xdg.desktopEntries."com.spotify.Client.adblock" = {
    type = "Application";
    name = "Spotify (Adblock)";
    genericName = "Online music streaming service";
    comment = "Access all of your favorite music";
    icon = "com.spotify.Client";
    exec = "/usr/bin/flatpak run --branch=stable --arch=x86_64 --file-forwarding --env=LD_PRELOAD=${config.home.homeDirectory}/.var/app/com.spotify.Client/libspotifyadblock.so com.spotify.Client @@u %U @@";
    terminal = false;
    mimeType = [ "x-scheme-handler/spotify" ];
    categories = [
      "Audio"
      "Music"
      "AudioVideo"
    ];
    settings = {
      Keywords = "Music;Player;Streaming;Online";
      StartupWMClass = "Spotify";
      "X-GNOME-UsesNotifications" = "true";
      "X-Flatpak-Tags" = "proprietary";
      "X-Flatpak" = "com.spotify.Client";
    };
  };
}
