
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    kitty
    tmux
    git
    fzf
    zoxide
    starship
    eza
    unzip
  ];

  programs.zsh.ohMyZsh.enable = true;
  programs.zoxide.enable = true;
}
