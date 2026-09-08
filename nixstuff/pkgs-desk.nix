
{ pkgs, noctalia, ... }:

{
  environment.systemPackages = with pkgs; [
    wofi
    quickshell
    bibata-cursors
    brightnessctl
    hyprpaper
    hyprpicker
    hyprsunset
    qt6.qtmultimedia
    noctalia.packages.${pkgs.system}.default
  ];

}
