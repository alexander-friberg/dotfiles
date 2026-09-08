
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    kitty
    tmux
    fzf
    fd
    ripgrep
    curl
    zoxide
    starship
    eza
    unzip
    superfile
  ];

  programs.zsh.ohMyZsh.enable = true;
  programs.zoxide.enable = true;
  programs.starship.enable = true;
}
