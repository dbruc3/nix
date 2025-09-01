{ config, pkgs, ... }:

let
  unstableTarball = fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
  };
in
{
  imports =
    [
      ./hardware-configuration.nix
    ];

  services.self-deploy = {
     enable = true;
     startAt = "hourly";
     repository = "https://github.com/dbruc3/nix.git";
     nixFile = "/etc/nixos/configuration.nix";
     nixAttribute = "";
     switchCommand = "switch";
  };
  
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nuc";
  networking.networkmanager.enable = true;
  
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  users.users.dan = {
    isNormalUser = true;
    description = "dan";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      unstable = import unstableTarball {
        config = config.nixpkgs.config;
      };
    };
  };

  environment.systemPackages = with pkgs; [
    vim
    tmux
    unstable.claude-code
    git
    tailscale
  ];

  services.openssh.enable = true;
  services.tailscale.enable = true;

  networking.firewall.enable = true;

  system.stateVersion = "25.05"; # Did you read the comment?
}
