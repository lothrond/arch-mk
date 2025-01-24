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

help:
	@echo Arch Linux - Makefile installation
	@echo
	@echo "[USAGE]: make [ OPTION ]"
	@echo
	@echo "[OPTIONS]:"
	@echo
	@echo "    help               -  Show this help message"
	@echo "    archlinux-base     -  Install Arch Linux base system."
	@echo "    archlinux-dev      -  Install additional Arch Linux development packages."
	@echo "    archlinux-system   -  Arch Linux base system configuration."
	@echo "    archlinux-silent   -  Configure a silent Arch Linux boot process"
	@echo "    archlinux-desktop  -  Install Arch Linux desktop (including display server and graphics drivers)."
	@echo "    archlinux-32       -  Enable Arch Linux 32 bit architecture support."
	@echo "    archlinux-steam    -  Install Arch Linux steam gaming packages."
	@echo "    archlinux-steamos  -  Configure Arch Linux SteamOS environment."
	@echo
	@echo " Use only one of these options at a time."
	@echo
	@echo "[EXAMPLES]:"
	@echo
	@echo ' * Run `make archlinux-base` to setup the build process.'
	@echo "   Once completed, you will be inside an arch linux build chroot."
	@echo
	@echo ' * Run `make archlinux-system` to start building the base system.'
	@echo "   You will be prompted for a root password at the end."
	@echo
	@echo ' * Run `make archlinux-desktop` Inside of the base system, to build the desktop environment.'
	@echo "   You will also create a desktop user account, and be prompted for a user password."
	@echo
	@echo " root@archiso: make archlinux-base"
	@echo " [root@chroot]: make archlinux-system"
	@echo " root: make archlinux-desktop"
	@echo
	@echo "Copyright (C) 2025, lothrond <lothrond@proton.me>"

############################################################

include config.mk

## Build base installation:
archlinux-base: partitions filesystems mount base other

## Build base system configuration:
archlinux-system: timezone locales keymap host init $(BOOTLOADER) pass

## Build development tools:
archlinux-dev: dev-pkgs remote-pkgs

## Build silent bootloader:
archlinux-silent: grub-silent lastlogin kmsgs agetty fsck

## Build desktop:
archlinux-desktop: user x $(GRAPHICS) $(GRAPHICS)-config $(DESKTOP) bluetooth user-nopasswd user-nologin plasma-nologin

## Enable 32 bit architecture support.
archlinux-32: multilib $(GRAPHICS)-32

## Build steam client:
archlinux-steam: steam-pkgs wine-pkgs

## Build SteamOS configuration:
archlinux-steamos: steamos-session $(DESKTOP)-autologin

############################################################
## BASE SYSTEM INSTALLATION (RUN IN ARCHISO ENVIRONMENT): ##
############################################################

PHONY: partitions
partitions:
	@echo -e "\n* Partioning $(DRIVE)"
	@parted $(DRIVE) --script mklabel gpt
	@parted $(DRIVE) --script mkpart 'EFI' 1MiB 4097MiB
	@parted $(DRIVE) --script set 1 esp on
	@parted $(DRIVE) --script mkpart 'swap' linux-swap 4097MiB 20481MiB
	@parted $(DRIVE) --script mkpart 'rootfs' ext4 20481MiB 51201MiB
	@parted $(DRIVE) --script mkpart 'user' ext4 51201MiB 100%
	@parted $(DRIVE) --script print

PHONY: filesystems
filesystems:
	@echo -e "\n* Making filesystems for $(DRIVE)"
	@mkfs.vfat -F 32 $(DRIVE)1
	@mkswap $(DRIVE)2
	@mkfs.ext4 $(DRIVE)3
	@mkfs.ext4 $(DRIVE)4

PHONY: mount
mount:
	@echo -e "\n* Mounting $(DRIVE)"
	@mount $(DRIVE)3 /mnt
	@mount --mkdir $(DRIVE)1 /mnt/boot
	@mount --mkdir $(DRIVE)4 /mnt/home
	@swapon $(DRIVE)2

.PHONY: base
base:
	@echo -e "\n* Installing base system packages to $(DRIVE)"
	@pacstrap -K /mnt $(PKGS_BASE) $(PKGS_NET) $(PKGS_TOOLS) $(PKGS_DOCS)

PHONY: other
other:
	@echo -e "\n* Generating fstab ..."
	@genfstab -U /mnt >> /mnt/etc/fstab
	@echo -e "Copying over Makefile to chroot ..."
	@cp Makefile config.mk /mnt
	@echo "Changing root to system ..."
	@arch-chroot /mnt

## This command is to be run after all other commands.

done:
	@echo -e "\nDone."
	@echo
	@echo "Remove installation medium, and power on into your new system."
	@echo "Powering off ..."
	@umount -R /mnt
	@systemctl poweroff

###################################################################
## BASE SYSTEM CONFIGURATION (RUN INSIDE OF CHROOT ENVIRONMENT): ##
###################################################################

PHONY: timezone
timezone:
	@echo -e "\n* Setting systemtimezone ..."
	@ln -sf /usr/share/zoneinfo/$(TZ) /etc/localtime
	@hwclock --systohc

PHONY: locales
locales:
	@echo -e "\n* Setting system locales ..."
	@echo "$(LOCALE_A) $(LOCALE_B)" > /etc/locale.gen
	@locale-gen
	@touch /etc/locale.conf
	@echo "LANG=$(LOCALE_A)" > /etc/locale.conf

PHONY: keymap
keymap:
	@echo -e "\n* Setting system keyboard keymap ..."
	@touch /etc/vconsole.conf
	@echo "$(KEYB)" > /etc/vconsole.conf

PHONY: host
host:
	@echo -e "\n* Setting system hostname ..."
	@touch /etc/hostname
	@echo "$(HOSTNAME)" > /etc/hostname

.PHONY: init
init:
	@echo -e "\n* Generating system initramfs ..."
	@mkinitcpio -P

.PHONY: grub
grub:
	@echo -e "\n* Installing GRUB bootloader ..."
	@grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id="$(GRUB_ID)"
	@grub-mkconfig -o /boot/grub/grub.cfg

.PHONY: pass
pass:
	@echo -e "\n* Setting system root password ..."
	@passwd

.PHONY: exit-chroot
exit-chroot:
	@echo
	@echo -e "* Exiting build chroot environment ..."
	@echo -e "Once you are in the liveiso installer,"
	@echo -e "Run \`make done\` to reboot into the the new system."
	@echo -e "(Don't forget to remove the installation medium.)"
	@echo
	@exit

###################################
## ADDITIONAL DEVELOPMENT TOOLS: ##
###################################

.PHONY: dev-pkgs
dev-pkgs:
	@echo -e "\nInstalling additional development packages ..."
	@pacman -S $(PKGS_DEV)

.PHONY: remote-pkgs
remote-pkgs:
	@echo -e "\nInstalling remote development packages ..."
	@pacman -S $(PKGS_REMOTE)

##################################
## CONFIGURE SILENT BOOTLOADER: ##
##################################

# Hide GRUB bootloader.
.PHONY: grub-silent
grub-silent:
	@echo -e "\n* Configuring silent boot for GRUB bootloader ..."
	@cp /etc/default/grub /root
	@echo 'GRUB_DEFAULT=0' > /etc/default/grub
	@echo 'GRUB_TIMEOUT=0' >> /etc/default/grub
	@echo 'GRUB_RECORDFAIL_TIMEOUT=$GRUB_TIMEOUT' >> /etc/default/grub
	@echo 'GRUB_CMDLINE_LINUX="quiet loglevel=3 systemd.show_status=false rd.udev.log_level=3 vt.global_cursor_default=0"' >> /etc/default/grub
	@echo 'FRAMEBUFFER_CONSOLE_DEFERRED_TAKEOVER=y' >> /etc/default/grub
	@echo 'GRUB_CMDLINE_LINUX_DEFAULT=$GRUB_CMDLINE_LINUX' >> /etc/default/grub
	@echo 'GRUB_DISABLE_RECOVERY=true' >> /etc/default/grub
	@echo 'GRUB_GFXPAYLOAD_LINUX=keep' >> /etc/default/grub
	@echo 'GRUB_GFXMODE=auto' >> /etc/default/grub
	grub-mkconfig -o /boot/grub/grub.cfg

# Hide last login message.
.PHONY: lastlogin
lastlogin:
	@echo -e "\n* Removing last login massage ..."
	touch ~/.hushlogin

# Hide kernel messages.
.PHONY: kmsgs
kmsgs:
	@echo -e "\n* Removing kernel messages ..."
	@echo "kernel.printk = 3 3 3 3" > /etc/sysctl.d/20-quiet-printk.conf

# Hide agetty messages.
AGETTY_OVERRIDE := /etc/systemd/system/getty@tty1.service.d/skip-prompt.conf

.PHONY: agetty
agetty:
	@echo -e "\n* Hiding agetty messages ..."
	@mkdir /etc/systemd/system/getty@tty1.service.d || touch $(AGETTY_OVERRIDE)
	@echo "[Service]" >> $(AGETTY_OVERRIDE)
	@echo "ExecStart=" >> $(AGETTY_OVERRIDE)
	@echo "ExecStart=-/usr/bin/agetty --skip-login --nonewline --noissue --autologin username --noclear %I $TERM" >> $(AGETTY_OVERRIDE)

# Hide fsck messages.
.PHONY: fsck
fsck:
	@echo -e "\n* Hiding fsck messages ..."
	@cp /etc/mkinitcpio.conf /root
	@echo '# vim:set ft=sh' > /etc/mkinitcpio.conf
	@echo 'MODULES=()' >> /etc/mkinitcpio.conf
	@echo 'BINARIES=()' >> /etc/mkinitcpio.conf
	@echo 'FILES=()' >> /etc/mkinitcpio.conf
	@echo 'HOOKS=(base systemd autodetect microcode modconf kms keyboard sd-vconsole block filesystems)' >> /etc/mkinitcpio.conf
	@mkinitcpio -P

#################################
## CONFIGURE GRAPHICS DRIVERS: ##
#################################

## CUDA/Vulkan graphics:

.PHONY: cuda-graphics
cuda-graphics:
	@echo -e "Installing CUDA graphics driver ..."
	@pacman -S (NVIDIA_DRIVER)

.PHONY: cuda-graphics-32
cuda-graphics-32:
	@echo "\n Installing CUDA graphics 32 bit libraries ..."
	@pacman -S lib32-$(NVIDIA_DRIVER)-utils

.PHONY: vulkan-graphics
vulkan-graphics:
	@echo -e "\n Installing Vulkan graphics libraries ..."
	@pacman -S $(PKGS_VULKAN)

.PHONY: vulkan-graphics-32
vulkan-graphics-32:
	@echo -e "\n Installing Vulkan graphics 32 bit libraries ..."
	@pacman -S $(PKGS_VULKAN_32)

## AMD Graphics:
#
#.PHONY: amd-graphics
#amd-graphics:
#
#amd: amd-graphics
#
# AMD 32 bit architecture support:
#
#.PHONY: amd-graphics-32
#amd-graphics-32:
#
#amd-32: amd-graphics-32 vulkan-graphics-32

## Intel Graphics:
#
#.PHONY: intel-graphics
#intel-graphics:
#
#intel: intel-graphics
#
# Intel 32 bit architecture support:
#
#.PHONY: intel-graphics-32
#intel-graphics-32:
#
#intel-32: intel-multilib vulkan-32

## Nvidia graphics:
.PHONY: nvidia-graphics
nvidia-graphics:
	@echo -e 'Installing Nvidia base graphics driver packages ...'
	@pacman -S $(PKGS_NVIDIA_GRAPHICS)

nvidia: nvidia-graphics cuda-graphics vulkan-graphics

# Nvidia 32 bit architecture support:
.PHONY: nvidia-graphics-32
nvidia-graphics-32:
	@echo -e "\n Installing 32 bit Nvidia Graphics driver packages ..."
	@pacman -S $(PKGS_NVIDIA_GRAPHICS_32)

nvidia-32: nvidia-graphics-32 cuda-graphics-32 vulkan-grahics-32

# Configure Nvidia X11 Xorg config:
.PHONY: nvidia-xconfig
nvidia-xconfig:
	@echo -e "\n* Creating Nvidia graphics X11 Xorg configuration ..."
	@mkdir /etc/X11/xorg.conf.d | touch /etc/X11/xorg.conf.d/20-nvidia.conf
	@echo 'Section "Device"' >> /etc/X11/xorg.conf.d/20-nvidia.conf
	@echo '    Identifier "NVIDIA Card"' >> /etc/X11/xorg.conf.d/20-nvidia.conf
	@echo '    Driver "nvidia"' >> /etc/X11/xorg.conf.d/20-nvidia.conf
	@echo '    VendorName "NVIDIA Corporation"' >> /etc/X11/xorg.conf.d/20-nvidia.conf
	@echo "    BoardName \"$(NVIDIA_BOARD)\"" >> /etc/X11/xorg.conf.d/20-nvidia.conf
	@echo '    Option "RegistryDwords" "EnableBrightnessControl=1\"'' >> /etc/X11/xorg.conf.d/20-nvidia.conf
	@echo 'EndSection' >> /etc/X11/xorg.conf.d/20-nvidia.conf
	@echo '' >> /etc/X11/xorg.conf.d/20-nvidia.conf

# Fix screen tearing issues:
.PHONY: nvidia-tearing
nvidia-tearing:
	@echo -e "\n* Fixing screen tearing issues for Nvidia graphics graphics ..."
	@echo 'Section "Screen"' >> /etc/X11/xorg.conf.d/20-nvidia.conf
	@echo '    Identifier     "Screen0"' >> /etc/X11/xorg.conf.d/20-nvidia.conf
	@echo '    Device         "Device0"' >> /etc/X11/xorg.conf.d/20-nvidia.conf
	@echo '    Monitor        "Monitor0"' >> /etc/X11/xorg.conf.d/20-nvidia.conf
	@echo '    Option         "ForceFullCompositionPipeline" "on"' >> /etc/X11/xorg.conf.d/20-nvidia.conf
	@echo '    Option         "AllowIndirectGLXProtocol" "off"' >> /etc/X11/xorg.conf.d/20-nvidia.conf
	@echo '    Option         "TripleBuffer" "on"' >> /etc/X11/xorg.conf.d/20-nvidia.conf
	@echo 'EndSection' >> /etc/X11/xorg.conf.d/20-nvidia.conf

# Enabling the following will enable the PAT feature for Nvidia Graphics:
.PHONY: nvidia-pat
nvidia-pat:
	@echo -e "\n* Enabling PAT for Nvidia graphics ..."
	@touch /etc/modprobe.d/nvidia.conf
	@echo "options nvidia NVreg_UsePageAttributeTable=1" >> /etc/modprobe.d/nvidia.conf

# Early Kernel module loading (KMS) for NVIDIA graphics:
.PHONY: nvidia-kms
nvidia-kms:
	@echo -e "\n* Setting early kernel mode settings for Nvidia graphics ..."
	@sed -i 's/MODULES=()/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/g' /etc/mkinitcpio.conf

nvidia-config: nvidia-xconfig nvidia-tearing nvidia-pat nvidia-kms

##############
## DESKTOP: ##
##############

# Create user:
.PHONY: user
user:
	@echo "\n* Creating user account ..."
	@useradd -c "" -m -G audio,input,video,bluetooth,wheel $(USER)

# Create desktop user.
.PHONY: desktop-user
desktop-user:
	@echo -e "\n* Creating desktop user account ..."
	@adduser -c "" -m -G audio,input,video,bluetooth,$(USER) desktop

.PHONY: x
x:
	@echo -e "\nInstalling display server packages ..."
	@pacman -S $(PKGS_X)

.PHONY: bluetooth
bluetooth:
	@echo -e "\n Installing desktop bluetooth packages ..."
	@pacman -S $(PKGS_BLUEZ)
	@systemctl enable bluetooth

PHONY: plasma
plasma:
	@echo -e "\nInstalling KDE plasma desktop environment packages ..."
	@pacman -S $(PKGS_PLASMA_DESKTOP) $(PKGS_PLASMA_APPS) $(PKGS_PLASMA_FILES)
	@systemctl enable NetworkManager
	@systemctl enable power-profiles-daemon

.PHONY: gnome:
gnome:
	@echo -e "\n* Installing GNOME desktop environment packages ..."
	@pacman -S $(PKGS_GNOME_DESKTOP)

# Configure passwordless login for user account:
.PHONY: user-nopasswd
user-nopasswd:
	@echo -e "\n* Building automatic login for user accounts ..."
	@sed -i '2i auth        sufficient  pam_succeed_if.so user ingroup nopasswdlogin' /etc/pam.d/sddm

# Configure passwordless login for KDE Plasma login screen:
.PHONY: plasma-nopasswd
plasma-nopasswd:
	@echo -e "\n* Building passwordless login for KDE login screen ..."
	@sed -i '2i auth        sufficient  pam_succeed_if.so user ingroup nopasswdlogin' /etc/pam.d/kde

# Configure automatic login for KDE Plasma display manager:
.PHONY: plasma-nologin
plasma-nologin:
	@echo -e "\n Building automatic login for KDE display manager service ..."
	@touch /etc/sddm.conf
	@echo "[Autologin]" > /etc/sddm.conf
	@echo "User=$(USER)" >> /etc/sddm.conf
	@echo "Session=$(DESKTOP_SESSION)" >> /etc/sddm.conf

# Configure automatic login for GNOME display manager:
.PHONY: gnome-nologin
gnome-nologin:
	@echo -e "\n Building automatic login for GNOME display manger service ..."
	@touch /etc/gdm3/auto.conf
	@echo "[Autologin]" > /etc/gdm3/auto.conf
	@echo "User=$(USER)" >> /etc/gdm3/auto.conf
	@echo "Session=$(SESSION)" >> /etc/gdm3/auto.conf

###################
## STEAM GAMING: ##
###################

# Enable 32 bit architecture support.
.PHONY: multilib
multilib:
	@echo -e "\n Enabling 32 bit architecture support ..."
	@sed -i 's/#[multilib]/[multilib]/g' /etc/pacman.conf
	@sed -i 's/#Include = /etc/pacman.d/mirrorlist/Include = /etc/pacman.d/mirrorlist/g' /etc/pacman.conf
	@pacman -Sy

# Increase VM max heap count for better performance:
.PHONY: vm-max
vm-max:
	@echo -e "\n Increasing VM Max heap count ..."
	@touch /etc/sysctl.d/80-gamecompatibility.conf
	@echo "" > /etc/sysctl.d/80-gamecompatibility.conf

# Install steam client packages:
.PHONY: steam-pkgs
steam-pkgs:
	@echo -e "\n Installing steam client packages ..."
	@pacman -S $(PKGS_STEAM)

# Install WINE packages.
.PHONY: wine-pkgs
wine-pkgs:
	@echo -e "\n Installing system WINE packages ..."
	@pacman -S $(PKGS_WINE)

###############
## STEAM OS: ##
###############

## Create SteamOS desktop session:
.PHONY: steamos-session
steamos-session:
	@touch /usr/share/wayland-sessions/steamos.desktop
	@echo "[Desktop Entry]" > /usr/share/wayland-sessions/steamos.desktop
	@echo "Name=Steam OS Mode" >> /usr/share/wayland-sessions/steamos.desktop
	@echo "Comment=Start Steam in Big Picture Mode" >> /usr/share/wayland-sessions/steamos.desktop
	@echo "Exec=/usr/bin/gamescope -e -- /usr/bin/steam -tenfoot" >> /usr/share/wayland-sessions/steamos.desktop
	@echo "Type=Application" >> /usr/share/wayland-sessions/steamos.desktop
