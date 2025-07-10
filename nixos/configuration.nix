# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Seoul";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ko_KR.UTF-8";
    LC_IDENTIFICATION = "ko_KR.UTF-8";
    LC_MEASUREMENT = "ko_KR.UTF-8";
    LC_MONETARY = "ko_KR.UTF-8";
    LC_NAME = "ko_KR.UTF-8";
    LC_NUMERIC = "ko_KR.UTF-8";
    LC_PAPER = "ko_KR.UTF-8";
    LC_TELEPHONE = "ko_KR.UTF-8";
    LC_TIME = "ko_KR.UTF-8";
  };


  nix.settings.experimental-features = [ "nix-command" "flakes"];
  programs.ccache.enable=true;


  # Enable ollama
  services.ollama = {
  enable = true;
#  acceleration = "cuda";
   host = "0.0.0.0";
   environmentVariables = {};
  };
  services.open-webui.enable = true;

  # Enable nix command

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable docker
  virtualisation.docker.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.datamind = {
    isNormalUser = true;
    description = "datamind";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    fd
    wget
    kitty
    ghostty
    fzf
    rustup
    gcc
    vscode
    go
    xorg.xauth
    ollama
    kubernetes-helm
    docker
    jdk
    python312
    python312Packages.pip
    gcc
    gcc-unwrapped
    libgcc
    gnumake
    cmake
    extra-cmake-modules
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };


  programs.git.enable = true;
  programs.zsh.enable=true;
  users.defaultUserShell = pkgs.zsh;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
  enable = true;
  ports = [ 22 ];
  settings = {
    PasswordAuthentication = true;
    PubkeyAuthentication=true;
    AllowUsers = ["datamind"]; # Allows all users by default. Can be [ "user1" "user2" ]
    PermitRootLogin = "prohibit-password"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
    X11Forwarding=true;
    X11DisplayOffset = 10;
  };
}; 


   
  networking.firewall.allowedTCPPorts = [
    22
    6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
    2379 # k3s, etcd clients: required if using a "High Availability Embedded etcd" configuration
    2380 # k3s, etcd peers: required if using a "High Availability Embedded etcd" configuration
    3000 # hoader
    11434 # ollama
    8080 # airflow
    18080 # test
   # 5432 # postgres
   # 8080 # minikube
   # 8443 # minikube
  ];


  networking.firewall.allowedUDPPorts = [
     8472 # k3s, flannel: required if using multi-node for inter-node networking
  ];
  services.k3s.enable = true;
  services.k3s.role = "server";
  services.k3s.extraFlags = toString [
     "--debug" # Optionally add additional args to k3s
  ];

  # 
  services.postgresql = {
  enable = true;
  package = pkgs.postgresql_16;
  
  # 기본 데이터베이스 생성
  ensureDatabases = [ "mytestdb" ];
  
  enableTCPIP = true;
  settings = {
    port = 5432;
  };
  
  # 개발 환경용 인증 설정 
  authentication = pkgs.lib.mkOverride 10 ''
    local all all trust
    # 로컬호스트 연결은 md5
    host all all 127.0.0.1/32 md5
    host all all ::1/128 md5
    # 모든 외부 연결
    # host all all 0.0.0.0/0 md5
  '';
  
  };

 

  # Open ports in the firewall.
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

  #How to disable suspend on close laptop lid on NixOS?
  services.logind.lidSwitch = "ignore";
}
