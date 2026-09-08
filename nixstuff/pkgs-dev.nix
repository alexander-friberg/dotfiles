
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    neovim
    gh
    tree-sitter
    python3
    git
    gcc
    gnumake
    nodejs
    docker
    docker-compose
  ];

}
