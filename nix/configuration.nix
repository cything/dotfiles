{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/root/.config/sops/age/keys.txt";
  sops.secrets = {
    "borg/yt" = { };
    "restic/azure-yt" = { };
    "azure" = { };
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    cleanTmpDir = true;
    kernelPackages = pkgs.linuxPackages_latest;
  };

  networking = {
    hostName = "ytnix";
    # nftables.enable = true;
    wireless.iwd = {
      enable = true;
      settings = {
        Rank = {
          # disable 2.4 GHz cause i have a shitty wireless card
          # that interferes with bluetooth otherwise
          BandModifier2_4GHz = 0.0;
        };
      };
    };
    networkmanager = {
      enable = true;
      dns = "none";
      wifi.backend = "iwd";
    };
    nameservers = [ "127.0.0.1" "::1" ];
    resolvconf.enable = true;
    firewall = {
      trustedInterfaces = [ "wgnord" ];
    };
  };
  programs.nm-applet.enable = true;
  time.timeZone = "America/Toronto";

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    wireplumber.extraConfig.bluetoothEnhancements = {
      "wireplumber.settings" = {
        "bluetooth.autoswitch-to-headset-profile" = false;
      };
      "monitor.bluez.properties" = {
        "bluez5.enable-sbc-xq" = true;
        "bluez5.enable-msbc" = true;
        "bluez5.enable-hw-volume" = true;
        "bluez5.roles" = [ "a2dp_sink" "a2dp_source" ];
      };
    };
  };

  services.libinput.enable = true;

  users.users.yt = {
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" "docker" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      firefox
      ungoogled-chromium
      librewolf
      bitwarden-desktop
      bitwarden-cli
      aerc
      delta
      fzf
      zoxide
      eza
      fastfetch
      discord
      nwg-look
      element-desktop-wayland
      kdePackages.gwenview
      kdePackages.okular
      kdePackages.qtwayland
      mpv
      yt-dlp
      anki-bin
      signal-desktop
      cosign
      azure-cli
      pavucontrol
      btop
      stockfish
      cutechess
    ];
  };

  environment.systemPackages = with pkgs; [
    tmux
    vim
    wget
    neovim
	  git
	  python3
	  grim
	  slurp
	  wl-clipboard
	  mako
    tree
    kitty
    rofi-wayland
    rofimoji
    cliphist
    borgbackup
    jq
    brightnessctl
    alsa-utils
    nixd
    veracrypt
    bluetuith
    libimobiledevice
    pass-wayland
    htop
    file
    dnsutils
    age
    compsize
    wgnord
    wireguard-tools
    traceroute
    sops
    restic
    nyx
  ];

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  system.stateVersion = "24.05";

  services.gnome.gnome-keyring.enable = true;
  programs.gnupg.agent.enable = true;

  services.displayManager.defaultSession = "hyprland";
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  programs.waybar.enable = true;
  programs.zsh.enable = true;
  # security.sudo.wheelNeedsPassword = false;

  fonts.packages = with pkgs; [
    nerdfonts
  ];
  nixpkgs.config = {
    allowUnfree = true;
    chromium = {
      enableWideVine = true;
      commandLineArgs = "--enable-features=UseOzonePlatform --ozone-platform=wayland --force-dark-mode --enable-features=WebUIDarkMode";
    };
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  programs.hyprland = {
    enable = true;
    # withUWSM = true;
  };

  services.borgbackup.jobs.ytnixRsync = {
    paths = [ "/root" "/home" "/var/lib" "/var/log" "/opt" "/etc" ];
    exclude = [
      ".git"
      "**/.cache"
      "**/node_modules"
      "**/cache"
      "**/Cache"
      "/var/lib/docker"
      "/home/**/Downloads"
      "**/.steam"
      "**/.rustup"
      "**/.docker"
      "**/borg"
    ];
    repo = "de3911@de3911.rsync.net:borg/yt";
    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat /run/secrets/borg/yt";
    };
    environment = {
      BORG_RSH = "ssh -i /home/yt/.ssh/id_ed25519";
      BORG_REMOTE_PATH = "borg1";
    };
    compression = "auto,zstd";
    startAt = "daily";
    extraCreateArgs = [ "--stats" ];
    # warnings are often not that serious
    failOnWarnings = false;
  };
  
  services.restic.backups.ytazure = {
    paths = [ "/root" "/home" "/var/lib" "/var/log" "/opt" "/etc" ];
    exclude = [
      ".git"
      "**/.cache"
      "**/node_modules"
      "**/cache"
      "**/Cache"
      "/var/lib/docker"
      "/home/**/Downloads"
      "**/.steam"
      "**/.rustup"
      "**/.docker"
      "**/borg"
    ];
    passwordFile = "/run/secrets/restic/azure-yt";
    environmentFile = "/run/secrets/azure";
    repository = "azure:yt-backup:/";
    extraOptions = [
      "azure.access-tier=Archive"
    ];
    package = pkgs.restic.overrideAttrs {
      src = pkgs.fetchFromGitHub {
        owner = "restic";
        repo = "restic";
        rev = "1133498ef80762608f959df41d303f7246fff04f";
        hash = "sha256-RmCEZ5T99uNNDwrQ3CofXBf4UzNjelVzyZyvx5aZO0A=";
      };
      vendorHash = "sha256-TstuI6KgAFEQH90PCZMN6s4dUab2GyPKqOtqMfIV8wA=";
    };
  };

  services.btrbk.instances.local = {
    onCalendar = "hourly";
    settings = {
      snapshot_preserve = "8w 12m";
      snapshot_preserve_min = "2d";
      snapshot_dir = "/snapshots";
      subvolume = {
        "/home" = {};
        "/" = {};
      };
    };
  };

  programs.steam.enable = true;

  services.logind = {
    lidSwitch = "hibernate";
    suspendKey = "ignore";
    powerKey = "hibernate";
  };

  xdg.mime.defaultApplications = {
    "application/pdf" = "okular.desktop";
    "image/*" = "gwenview.desktop";
    "*/html" = "librewolf.desktop";
  };

  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
    ];
  };
  # preference changes don't work in thunar without this
  programs.xfconf.enable = true;
  # mount, trash and stuff in thunar
  services.gvfs.enable = true;
  # thumbnails in thunar
  services.tumbler.enable =true;

  virtualisation = {
    libvirtd.enable = true;
    docker.enable = true;
  };
  programs.virt-manager.enable = true;

  services.dnscrypt-proxy2 = {
    enable = true;
    settings = {
      ipv6_servers = true;
      require_dnssec = true;
      sources.public-resolvers = {
        urls = [
          "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
          "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
        ];
        cache_file = "/var/lib/dnscrypt-proxy2/public-resolvers.md";
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
      };
    };
  };

  nix.registry.nixpkgs.flake = inputs.nixpkgs;

  nix.gc = {
    automatic = true;
    dates = "19:00";
    persistent = true;
    options = "--delete-older-than 60d";
  };
}
