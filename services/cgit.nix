{ config, lib, pkgs, ...}:

with lib;

{
  config = lib.mkIf config.host.cgit.enable {
    services.lighttpd = {
      enable = true;
      cgit = {
        enable = true;
        configText =
          ''
            scan-path=${config.host.cgit.path}
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
      ];
    };
  };
  options = {
    host.cgit.enable = mkOption {
      type = types.bool;
      default = false;
    };
    host.cgit.scanpath = mkOption {
      type = types.path;
    };
  };
}
