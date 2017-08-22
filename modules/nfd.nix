{config, lib, pkgs, ...}:
let cfg = config.services.nfd;
ndnConfig = ''
      general {
        user nfd
        group nfd
      }
      log {
        default_level INFO
      }
      tables {
        strategy_choice {
        /               /localhost/nfd/strategy/best-route
        /localhost      /localhost/nfd/strategy/multicast
        /localhost/nfd  /localhost/nfd/strategy/best-route
        /ndn/broadcast  /localhost/nfd/strategy/multicast
        }
      }
      face_system {
        unix { path /var/run/nfd.sock }
        tcp {
          listen yes
          port 6363
          enable_v4 yes
          enable_v6 yes
        }

        udp {
          port 6363
          enable_v4 yes
          enable_v6 yes

          idle_timeout 600

          keep_alive_interval 25

          mcast yes
          mcast_port 56363
          mcast_group 224.0.23.170

          whitelist { * }
          blacklist { }
        }
        ether {
        }
        websocket {
          listen yes
          port 9696
          enable_v4 yes
          enable_v6 yes
        }
      }
      authorizations {
        authorize {
          certfile any
          privileges {
            faces
            fib
            strategy-choice
          }
        }
      }
      rib {
        localhost_security {
          trust-anchor { type any }
        }
      }
    '';
nfdUid = 281;
nfdGid = 281;
in
{
  options = {
    services.nfd = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to run NFD.
        '';
      };
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.nfd;
        example = pkgs.literalExample "pkgs.nfd";
        description = ''
          NFD package to use.
        '';
      };
    };
  };
  config = lib.mkIf cfg.enable {
    users.users.nfd = {
      name = "nfd";
      uid = nfdUid; #config.ids.uids.nfd;
      group = "nfd";
      home = "/var/lib/ndn/nfd";
      createHome = true;
      description = "NFD user";
    };
    users.extraGroups.nfd.gid = nfdGid; #config.ids.gids.nfd;
    systemd.services.nfd = {
      description = "Named Data Networking Forwarding Daemon";
      documentation = [ "http://named-data.net/doc/NFD/current/" ];
      path = [ cfg.package ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      preStart = ''
        if [ ! -d /var/lib/ndn/nfd/.ndn ]; then
          ${pkgs.su}/bin/su -s ${pkgs.stdenv.shell} nfd -c "
          chmod 755 /var/lib/ndn
          echo tpm=tpm-file > /var/lib/ndn/nfd/.ndn/client.conf
          ${pkgs.ndn-cxx}/bin/ndnsec-keygen /localhost/daemons/nfd | ndnsec-install-cert -"
        fi
      '';
      script = ''
        ${cfg.package}/bin/nfd --config ${pkgs.writeText "ndn.conf" ndnConfig}
      '';
      serviceConfig = {
        Environment="HOME=${config.users.users.nfd.home}";
        Restart="on-failure";
        ProtectSystem="full";
        PrivateTmp="yes";
        PrivateDevices="yes";
        ProtectHome="yes";
      };
    };
  };
}
