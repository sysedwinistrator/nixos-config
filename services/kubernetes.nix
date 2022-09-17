{ config, lib, pkgs, ...}:

let
  master = builtins.filter (x: builtins.elem "master" x.kubernetes_roles) config.lab.all_hosts;
  api = "https://${master.ip}:${config.services.kubernetes.apiserver.securePort}";
in
{
  config = lib.mkIf (config.lab.current_host.kubernetes_roles != []) {
    fileSystems = lib.mkIf config.host.zfs {
      "/var/lib/containerd" = {
        device = "${config.host.zfsDataSet}/containerd";
        fsType = "zfs";
        options = [ "zfsutils" ];
      };
      "/var/lib/etcd" = lib.mkIf (builtins.elem "master" config.lab.current_host.kubernetes_roles) {
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

      roles = config.lab.current_host.kubernetes_roles;
      masterAddress = master.ip;
      apiserverAddress = api;

      # master configuration
      apiserver = lib.mkIf (builtins.elem "master" config.lab.current_host.kubernetes_roles) {
        advertiseAddress = master.ip;
      };

      # node configuration
      kubelet.kubeconfig.server = lib.mkIf (builtins.elem "node" config.lab.current_host.kubernetes_roles) api;
    };
  };
}
