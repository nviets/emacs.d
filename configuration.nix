{ config, pkgs, lib, ... }:
{
  # NixOS wants to enable GRUB by default
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  # !!! Otherwise (even if you have a Raspberry Pi 2 or 3), pick this:
  boot.kernelPackages = pkgs.linuxPackages_latest;
  
  # !!! This is only for ARMv6 / ARMv7. Don't enable this on AArch64, cache.nixos.org works there.
  nix.binaryCaches = lib.mkForce [ "http://nixos-arm.dezgeg.me/channel" ];
  nix.binaryCachePublicKeys = [ "nixos-arm.dezgeg.me-1:xBaUKS3n17BZPKeyxL4JfbTqECsT+ysbDJz29kLFRW0=%" ];

  # !!! Needed for the virtual console to work on the RPi 3, as the default of 16M doesn't seem to be enough.
  # If X.org behaves weirdly (I only saw the cursor) then try increasing this to 256M.
  boot.kernelParams = ["cma=32M"];
    
  # File systems configuration for using the installer's partition layout
  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-label/NIXOS_BOOT";
      fsType = "vfat";
    };
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };
  
  time.timeZone = "America/Chicago";
  
  hardware.enableRedistributableFirmware = true;
  
  networking = {
    hostName = "pi";
    wireless.enable = true;
    #usePredictableInterfaces = false;
    #interfaces.eth0.ip4 = [{
    #  address = "";
    #  prefixLength = "";
    #}];
    #defaultGateway = "";
    #naeservers = [""];
  };
  
  environment.systemPackages = with pkgs; [tmux vim htop wget];
  
  users.users.nathan = {
    isNormalUser = true;
    home = "/home/nathan";
    uid = 7777;
    shell = pkgs.fish;
    extraGroups = [ "networkmanager" "wheel" ];
  };
  
  services.openssh.enable = true;
  
  system.stateVersion = "19.03";
    
  # !!! Adding a swap file is optional, but strongly recommended!
  # swapDevices = [ { device = "/swapfile"; size = 1024; } ];
}
