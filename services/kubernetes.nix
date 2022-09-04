{ config, lib, pkgs, ...}:

let
  master = builtins.filter (x: builtins.elem "master" x.kubernetes_roles) config.all_hosts;
  api = "https://${master.ip}:${config.services.kubernetes.apiserver.securePort}";
in
{
  config = lib.mkIf config.services.kubernetes.roles ? null != null {
    fileSystems = lib.mkIf config.host.zfs {
      "/var/lib/containerd" = {
        device = "${config.host.zfsDataSet}/containerd";
        fsType = "zfs";
        options = [ "zfsutils" ];
      };
      "/var/lib/etcd" = lib.mkIf config.services.kubernetes.roles == "master" {
        device = "${config.host.zfsDataSet}/etcd";
        fsType = "zfs";
        options = [ "zfsutils" ];
      };
    };
    services.kubernetes = {
      # We use kube-proxy instead
      flannel.enable = false;
      proxy.enable = false;

      easyCerts = true;
      addons.dns.enable = true;

      roles = config.current_host.kubernetes_roles;
      masterAddress = master.ip;
      apiserverAddress = api;

      # master configuration
      apiserver = lib.mkIf config.services.kubernetes.roles == "master" {
        advertiseAddress = master.ip;
      };

      # node configuration
      kubelet.kubeconfig.server = lib.mkIf config.services.kubernetes.roles == "node" api;
    };
  };
}
