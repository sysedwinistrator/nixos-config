# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./host
      ./services
    ];

  config = {
    lab = {
      all_hosts = [
        {
          name = "aristotle";
          ip = "192.168.3.6";
          kubernetes_roles = ["node"];
        }
        {
          name = "socrates";
          ip = "192.168.3.7";
          kubernetes_roles = ["master" "node"];
        }
        {
          name = "plato";
          ip = "192.168.3.8";
          kubernetes_roles = ["node"];
        }
      ];
        
      current_host = builtins.elemAt (builtins.filter (x: x.name == config.host.name) config.lab.all_hosts) 0;
      other_hosts = builtins.filter (x: x.name != config.host.name) config.lab.all_hosts;
    };

    # Enable SysRQ key
    boot.kernel.sysctl = {
      "kernel.sysrq" = 1;
    };

    networking.hostName = config.host.name;
    networking.hostId = config.host.hostId;

    # Set your time zone.
    time.timeZone = "Europe/Berlin";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      wget
      curl
      nmap
      arp-scan
      tmux
      htop
      git
      rsync
      iotop
    ];

    # Enable the OpenSSH daemon.
    services.openssh.enable = true;

    # root ssh access
    users.users.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM+ResginDO3aOjCVc+5JIbvnxaw58LEwRhTSsv6JHJ4 edwin@dhyana"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJNW41pUgA356Qnuia0EX9939R5DFlZb+6MHi95Vm+oK cepheus"
    ];

    # share cache over HTTP
    services.nix-serve = {
      enable = true;
      secretKeyFile = "/etc/nixos/secrets/cache-priv-key.pem";
    };
    nix.settings = {
      substituters = 
      (let
        ips = builtins.catAttrs "ip" config.lab.other_hosts;
      in
        builtins.map (x: "http://${x}:5000/") ips
      );
      trusted-public-keys = [
        (builtins.readFile /etc/nixos/cache-pub-key.pem)
      ];
    };

    networking.firewall.enable = false;

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "22.05"; # Did you read the comment?
  };
  options.lab = {
    all_hosts = lib.mkOption {
      type = with lib.types; listOf attrs;
      default = [];
    };
    current_host = lib.mkOption {
      type = with lib.types; attrs;
    };
    other_hosts = lib.mkOption {
      type = with lib.types; listOf attrs;
    };
  };
}

