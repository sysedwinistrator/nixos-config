{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  config = lib.mkIf config.host.cgit.enable {
    services.lighttpd = {
      enable = true;
      cgit = {
        enable = true;
        configText = ''
          scan-path=${config.host.cgit.scanpath}
        '';
      };
    };
    users.users.git = {
      isSystemUser = true;
      description = "git user";
      home = "/srv/git";
      group = "git";
      shell = "${pkgs.git}/bin/git-shell";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOCVqtVszoP/AmcF5ckUCEx8zF/rHsW+LfdNEDSM/91Z argocd"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM+ResginDO3aOjCVc+5JIbvnxaw58LEwRhTSsv6JHJ4 edwin@dhyana"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIONjh1AZbJtlKuLdKZw7Gt3rBtcp0JnVPpVM0voW/Sy0 edwin@MacBook-Pro-von-Edwin.local"
      ];
    };
    users.groups.git = {};
  };
  options = {
    host.cgit.enable = mkOption {
      type = types.bool;
      default = false;
    };
    host.cgit.scanpath = mkOption {
      type = types.str;
    };
  };
}
