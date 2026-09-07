
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    wofi
    quickshell
    bibata-cursors
    brightnessctl
    hyprpaper
  ];
}
