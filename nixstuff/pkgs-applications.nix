

{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gimp
    thunar
  ];

  programs.firefox.enable = true;
}
