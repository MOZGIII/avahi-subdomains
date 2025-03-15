{ pkgs, config, lib, ... }:

let

  cfg = config.services.avahi-subdomains;

in {
  options.services.avahi-subdomains = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to run the avahi-subdomains service.
      '';
    };

    subdomains = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = ''
        A list of subdomains to serve, without the domain suffix.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.avahi.enable = true;
    services.avahi.publish.enable = true;
    services.avahi.publish.addresses = true;
    services.avahi.publish.userServices = true;

    environment.systemPackages = [ pkgs.avahi-subdomains ];

    systemd.services = {
      avahi-subdomains = {
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        after = [ "avahi-daemon.service" ];
        serviceConfig = {
          Type = "exec";
          ExecStart = "${pkgs.avahi-subdomains}/bin/avahi-subdomains";
          ConfigurationDirectory = "avahi-subdomains";
        };
        restartTriggers =
          [ environment.etc."avahi-subdomains/subdomains".source ];
      };
    };

    environment.etc."avahi-subdomains/subdomains".text = cfg.subdomains;
  };
}
