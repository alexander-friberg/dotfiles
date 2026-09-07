
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    neovim
    python3
    go
    tree-sitter
    gcc
    bun
    typescript
    typescript-language-server
    nodejs
  ];

  programs.zoxide.enable = true;
}
