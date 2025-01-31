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

# Define base system timezone:
TZ := America/New_York

# Define base system locales:
LOCALE_A := en_US.UTF-8
LOCALE_B := UTF-8

# Define base system keyboard keymap:
KEYB := US

# Define base system Hostname:
HOSTNAME := train

# Define user name:
USER := steam

# Define GRUB bootloader ID:
GRUB_ID := Arch Linux

# Define device drive:
DRIVE := /dev/sda

# Define Arch Linux desktop:
#DESKTOP := plasma
DESKTOP := gnome

# Define default desktop login session:
#DESKTOP_SESSION := plasma
#DESKTOP_SESSION := steamos
#DESKTOP_SESSION := plasmax11
DESKTOP_SESSION := gnome-flashback

# Define graphics card:
#GRAPHICS := amd-graphics
#GRAPHICS := intel
GRAPHICS := nvidia

# Define AMD graphics:
#AMD_BOARD :=

# Define Intel graphics:
#INTEL_BOARD :=

# Define Nvidia graphics:
NVIDIA_BOARD := Nvidia Geforce GTX 970

# Define Linux kernel:
KERNEL := linux linux-firmware

# Define CPU microcode:
#MICROCODE := amd-ucode
MICROCODE := intel-ucode

# Define bootloader (Don't change. (Probably.)):
BOOTLOADER := grub

# Define base system packages.
# (This includes the kernel and kernel firmware.)
PKGS_BASE := base $(KERNEL) $(MICROCODE) $(BOOTLOADER)

# Define base system documentation:
PKGS_DOCS := man-db man-pages texinfo

# Define base system tools:
PKGS_TOOLS := dosfstools e2fsprogs efibootmgr git make nano sudo

# Define base system networking packages:
PKGS_NET := dhcpcd iwd

# Define remote development tools:
PKGS_REMOTE := openssh screen tmux

# Define bluetooth packages:
PKGS_BLUEZ := bluez bluez-utils

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

# Define Nvidia graphics driver packages:
#NVIDIA_DRIVER := nvidia-dkms
NVIDIA_DRIVER := nvidia
PKGS_NVIDIA_GRAPHICS := $(NVIDIA_DRIVER) nvidia-utils

# Define Nvidia graphics driver 32 bit library support:
PKGS_NVIDIA_GRAPHICS_32 := lib32-nvidia-utils

# Define Vulkan (gaming) packages:
PKGS_VULKAN := vkd3d

# Define Vulkan 32 bit gaming library support:
PKGS_VULKAN_32 := lib32-vkd3d

# Define KDE Plasma base desktop packages:
PKGS_PLASMA_DESKTOP := plasma plasma-pa plasma-nm sddm power-profiles-daemon

# Define KDE Plasma base desktop application packages:
PKGS_PLASMA_APPS := konsole kdialog kgpg kdf sweeper

# Define KDE Plasma base desktop file manager packages:
PKGS_PLASMA_FILES := dolphin ark ffmpegthumbs kdegraphics-thumbnailers kio-admin xdg-desktop-portal-kde

# Define GNOME base desktop packages:
PKGS_GNOME_DESKTOP := gnome networkmanager

# Define GNOME desktop application packages:
PKGS_GNOME_APPS := gnome-extra firewalld

# Define GNOME desktop file manager packages:
#PKGS_GNOME_FILES :=

# Define steam (gaming) packages:
PKGS_STEAM := steam ttf-liberation gamemode gamescope

# Define WINE (gaming) packages (also for steam):
PKGS_WINE := wine-staging

# Define CLI development tools:
PKGS_DEV := base-devel htool atool libcaca mediainfo highlight ranger tree vim

# Define CLI development shell (zsh):
PKGS_ZSH := zsh zsh-syntax-highlighting zsh-completions
