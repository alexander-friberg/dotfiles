{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    config = {
      user.name = "Alexander Friberg";
      user.email = "alexander.friberg.dev@proton.me";
      init.defaultBranch = "main";
      core.editor = "nvim";
    };
  };
}
