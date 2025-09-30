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
USER := deck

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
#GRAPHICS := intel-graphics
GRAPHICS := nvidia

# Define X or Wayland installation.
# (install-wayland or install-x)
DESKTOP_SESSION_MGR := install-wayland

# Define amd graphics (WIP):
#AMD_BOARD := ?

# Define amd graphics driver packages (WIP):
#AMD_DRIVER := ?

# Define amd graphics kernel modules (WIP):
#AMD_KMOD := ?

# Define intel graphics (WIP):
#INTEL_BOARD := ?

# Define intel graphics driver packages (WIP):
#INTEL_DRIVER := ?

# Define intel graphics kernel modules (WIP):
#INTEL_KMOD := ?

# Define nvidia graphics:
NVIDIA_BOARD := Nvidia Geforce GTX 970

# Define nvidia graphics kernel modules:
NVIDIA_KMOD := nvidia nvidia_modeset nvidia_uvm nvidia_drm

# Define nvidia graphics driver packages:
# (nvidia nvidia-dkms nvidia-lts)
NVIDIA_DRIVER := nvidia-lts

# Define linux kernel:
KERNEL := linux-lts linux-lts-headers

# Define linux kernel firmware:
KERNEL_FW := linux-firmware-nvidia linux-firmware-intel linux-firmware-atheros

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
BOOT_OPTS := quiet loglevel=3 tsc=reliable clocksource=tsc systemd.show_status=false rd.udev.log_level=3 vt.global_cursor_default=0 bootsplash.bootfile=$(BOOT_BM) splash

# Define initramfs base system options:
INITRAMFS_OPTS := base systemd autodetect microcode modconf kms keyboard sd-vconsole block filesystems

# Define UUID of device disk drive:
BLKID := `blkid -s UUID | grep $(DRIVE)3 | cut -d '"' -f 2 | cut -d '"' -f 1`

# Define Arch Linux make operations:
MAKEOPTS := archlinux-system archlinux-desktop archlinux-silent archlinux-nopass

# Define additional make operations:
# (archlinux-dev archlinux-dvd archlinux-32 archlinux-steam archlinux-gaming archlinux-steamos archlinux-open)
OPTS := 

#############################
### SteamOS configuration ###
#############################

# Define resolution for compositor (gamescope):
# (Only the width needs defined)
STEAMOS_DISPLAY := 1080

# Define SteamOS compositor (gamescope) command line:
STEAMOS_GAMESCOPE := --expose-wayland --hdr-enabled --rt --force-composition --synchonous-x11 

# Define SteamOS client (steam) command line:
STEAMOS_CLIENTCMD := -steamdeck -cef-force-gpu

# Define gamescope-fx command line:
# (Needs to be set seperate. Don't change.)
GAMESCOPE_CMD := -f -h $(STEAMOS_DISPLAY) -H $(STEAMOS_DISPLAY) $(STEAMOS_GAMESCOPE)

# (Currently not in use, with later plans?)
# Define the number of CPU threads for vulkan shader processing (for steam):
SHADER_THREADS := 4

#############################
### Package Configuration ###
#############################

# Define base system packages.
# (This includes the kernel and kernel firmware.)
PKGS_BASE := base $(KERNEL) $(KERNEL_FW) $(MICROCODE) $(BOOTLOADER)

# Define base system documentation:
PKGS_DOCS := man-db man-pages texinfo

# Define base system tools:
PKGS_TOOLS := dosfstools e2fsprogs efibootmgr git make ntfs-3g nano sudo unzip wget

# Define base system networking packages:
PKGS_NET := dhcpcd iwd

# Define remote development tools:
PKGS_REMOTE := openssh screen tmux

# Define bluetooth packages:
PKGS_BLUEZ := bluez bluez-utils

# Define DVD/Blue-ray packages:
PKGS_DVD := libbluray libdvdcss

# Define vlc media player packages:
PKGS_VLC := vlc vlc-plugin-ffmpeg vlc-plugins-all vlc-plugins-extra

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
PKGS_NVIDIA_GRAPHICS := $(NVIDIA_DRIVER) nvidia-lts nvidia-utils nvidia-settings

# Define Nvidia graphics driver 32 bit library support:
PKGS_NVIDIA_GRAPHICS_32 := lib32-nvidia-utils libvdpau-va-gl

# Define Vulkan (gaming) packages:
PKGS_VULKAN := vkd3d

# Define Vulkan 32 bit gaming library support:
PKGS_VULKAN_32 := lib32-vkd3d

# Define KDE Plasma base desktop packages:
PKGS_PLASMA_DESKTOP := plasma plasma-pa plasma-nm sddm power-profiles-daemon kdeconnect

# Define KDE Plasma base desktop application packages:
PKGS_PLASMA_APPS := konsole kdialog kgpg kdf sweeper

# Define KDE Plasma base desktop file manager packages:
PKGS_PLASMA_FILES := dolphin ark ffmpegthumbs kdegraphics-thumbnailers kio-admin xdg-desktop-portal-kde

# Define GNOME base desktop packages:
PKGS_GNOME_DESKTOP := gnome gnome-flashback networkmanager power-profiles-daemon

# Define GNOME desktop application packages:
PKGS_GNOME_APPS := gnome-extra firewalld

# Define GNOME desktop file manager packages:
#PKGS_GNOME_FILES :=

# Define steam (gaming) packages:
PKGS_STEAM := steam ttf-liberation gamemode gamescope

# Define WINE (gaming) packages (also for steam):
PKGS_WINE := wine

# Define LED control packages:
PKGS_LED := openrgb i2c-tools

# Define CLI development tools:
PKGS_DEV := base-devel htop strace lm_sensors tree vim

# Define CLI development file management tools (ranger):
PKGS_RNGR := atool libcaca mediainfo highlight ranger

# Define CLI development shell (zsh):
PKGS_ZSH := zsh zsh-syntax-highlighting zsh-completions
