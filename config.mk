# Copyright (C) 2025, lothrond <lothrond@proton.me>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#################################
### Base System Configuration ###
#################################

# Define base system Hostname:
HOSTNAME := fathership

# Define user name:
USER := steam

# Define base system timezone:
TZ := America/New_York

# Define base system locales:
LOCALE_A := en_US.UTF-8
LOCALE_B := UTF-8

# Define base system keyboard keymap:
KEYB := us

# Define device disk drive:
DRIVE := /dev/sda

# Define Arch Linux desktop:
#DESKTOP := gnome
DESKTOP := plasma

# Define default desktop login session:
GNOME_SESSION := gnome-flashback
PLASMA_SESSION := plasma

# Define graphics card:
#GRAPHICS := amd-graphics
#GRAPHICS := intel
GRAPHICS := nvidia

# Define X or Wayland installation.
# (install-wayland or install-x)
DESKTOP_SESSION_MGR := install-wayland

# Define amd graphics:
#AMD_BOARD := ?

# Define amd graphics driver packages:
#AMD_DRIVER := ?

# Define amd graphics kernel modules:
#AMD_KMOD := ?

# Define intel graphics:
#INTEL_BOARD := ?

# Define intel graphics driver packages:
#INTEL_DRIVER := ?

# Define intel graphics kernel modules:
#INTEL_KMOD := ?

# Define nvidia graphics:
NVIDIA_BOARD := Nvidia Geforce GTX 970

# Define nvidia graphics kernel modules:
NVIDIA_KMOD := nvidia nvidia_modeset nvidia_uvm nvidia_drm

# Define nvidia graphics driver packages:
#NVIDIA_DRIVER := nvidia-dkms
NVIDIA_DRIVER := nvidia

# Define linux kernel:
KERNEL := linux linux-firmware

# Define CPU microcode:
#MICROCODE := amd-ucode
MICROCODE := intel-ucode

# Define bootloader:
BOOTLOADER := grub
#BOOTLOADER := systemd

# Define bootloader ID:
BOOT_ID := Arch Linux

# Define Arch Linux bootloader bitmap image:
BOOT_BM := /usr/share/systemd/bootctl/arch-splash.bmp

# Define (silent) boot options:
BOOT_OPTS := quiet loglevel=3 systemd.show_status=false rd.udev.log_level=3 vt.global_cursor_default=0 bootsplash.bootfile=$(BOOT_BM) splash

# Define initramfs base system options:
INITRAMFS_OPTS := base systemd autodetect microcode modconf kms keyboard sd-vconsole block filesystems

# Define UUID of device disk drive:
BLKID := `blkid -s UUID | grep $(DRIVE)3 | cut -d '"' -f 2 | cut -d '"' -f 1`

# Define Arch Linux make operations:
MAKEOPTS := archlinux-system archlinux-desktop archlinux-silent archlinux-nopass

# Define additional make operations:
# (archlinux-dev archlinux-dvd archlinux-32 archlinux-steam archlinux-steamos)
OPTS := 

# Define

#############################
### Package Configuration ###
#############################

# Define base system packages.
# (This includes the kernel and kernel firmware.)
PKGS_BASE := base $(KERNEL) $(MICROCODE) $(BOOTLOADER)

# Define base system documentation:
PKGS_DOCS := man-db man-pages texinfo

# Define base system tools:
PKGS_TOOLS := dosfstools e2fsprogs efibootmgr git make nano sudo unzip wget

# Define base system networking packages:
PKGS_NET := dhcpcd iwd

# Define remote development tools:
PKGS_REMOTE := openssh screen tmux

# Define bluetooth packages:
PKGS_BLUEZ := bluez bluez-utils

# Define DVD/Blue-ray packages:
PKGS_DVD := vlc libbluray libdvdcss

# Define display server packages:
PKGS_X := xorg xdg-desktop-portal

# Define AMD graphics driver packages:
#PKGS_AMD_GRAPHICS :=

# Define AMD graphics driver 32 bit library support:
#PKGS_AMD_GRAPHICS_32 :=

# Define Intel graphics driver packages:
#PKGS_INTEL_GRAPHICS :=

# Define Intel graphics driver 32 bit library support:
#PKGS_INTEL_GRAPHICS_32 :=

# Define nvidia driver graphics packages:
PKGS_NVIDIA_GRAPHICS := $(NVIDIA_DRIVER) nvidia-utils nvidia-settings

# Define Nvidia graphics driver 32 bit library support:
PKGS_NVIDIA_GRAPHICS_32 := lib32-nvidia-utils

# Define Vulkan (gaming) packages:
PKGS_VULKAN := vkd3d

# Define Vulkan 32 bit gaming library support:
PKGS_VULKAN_32 := lib32-vkd3d

# Define KDE Plasma base desktop packages:
PKGS_PLASMA_DESKTOP := plasma plasma-pa plasma-nm sddm power-profiles-daemon kdeconnect unclutter

# Define KDE Plasma base desktop application packages:
PKGS_PLASMA_APPS := konsole kdialog kgpg kdf sweeper

# Define KDE Plasma base desktop file manager packages:
PKGS_PLASMA_FILES := dolphin ark ffmpegthumbs kdegraphics-thumbnailers kio-admin xdg-desktop-portal-kde

# Define GNOME base desktop packages:
PKGS_GNOME_DESKTOP := gnome gnome-flashback networkmanager power-profiles-daemon unclutter

# Define GNOME desktop application packages:
PKGS_GNOME_APPS := gnome-extra firewalld

# Define GNOME desktop file manager packages:
#PKGS_GNOME_FILES :=

# Define steam (gaming) packages:
PKGS_STEAM := steam ttf-liberation gamemode gamescope

# Define WINE (gaming) packages (also for steam):
PKGS_WINE := wine

# Define CLI development tools:
PKGS_DEV := base-devel linux-headers htop strace lm_sensors tree vim

# Define CLI development file management tools (ranger):
PKGS_RNGR := atool libcaca mediainfo highlight ranger

# Define CLI development shell (zsh):
PKGS_ZSH := zsh zsh-syntax-highlighting zsh-completions
