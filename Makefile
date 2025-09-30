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
#
###########################################################################

help:
	@echo Arch Linux - Makefile installation
	@echo
	@echo "[USAGE]: make archlinux"
	@echo "         make [ MAKEOPTS-OPTIONS ADDITIONAL-OPTIONS || OTHER-OPTION ]"
	@echo
	@echo "[MAKEOPTS-OPTIONS]:"
	@echo
	@echo " * The MAKEOPTS build variable defines the base system installation."
	@echo "   By default, this is defined as a plasma/gnome desktop, with a silent bootloader,"
	@echo "   with passwordless login for the desktop user account."
	@echo
	@echo "    archlinux-base     -  Make the base Arch linux system."
	@echo "    archlinux-system   -  Arch Linux base system configuration (made by archlinux-base)."
	@echo "    archlinux-desktop  -  Install Arch Linux desktop (including display server and graphics drivers)."
	@echo "    archlinux-nologin  -  Enable automatic login support for Arch Linux desktop."
	@echo "    archlinux-silent   -  Configure a silent Arch Linux bootloader."
	@echo
	@echo "[ADDITIONAL-OPTIONS]:"
	@echo
	@echo " * Any additional options can be specified with the OPTS build variable."
	@echo
	@echo "    archlinux-dev       -  Install additional Arch Linux development packages."
	@echo "    archlinux-dvd       -  Enable limited media playback support with VLC."
	@echo "    archlinux-firewall  -  Install personal system firewall."
	@echo "    archlinux-32        -  Enable Arch Linux 32 bit architecture support."
	@echo "    archlinux-steam     -  Install Arch Linux steam gaming packages."
	@echo "    archlinux-steamos   -  Configure a SteamOS desktop session."
	@echo "    archlinux-gaming    -  Configure additional performance for gaming."
	@echo "	   archlinux-dev       -  Install additional development packages."
	@echo "    archlinux-open      -  Allow remote development."
	@echo
	@echo "[OTHER-OPTIONS]:"
	@echo
	@echo " * Other options can be used to wipe/prepare the disk before installation,"
	@echo "   poweroff he system after installation, and show this help message."
	@echo
	@echo "    help               -  Show this help message"
	@echo "    clean              -  Quickly wipe device disk drive."
	@echo "    wipe               -  Completely wipe device disk drive."
	@echo
	@echo "(All build variables are defined in the config.mk makefile configuation.)"
	@echo
	@echo "[EXAMPLES]:"
	@echo
	@echo "   make archlinux"
	@echo "   make clean archlinux archlinux-dev"
	@echo "   make archlinux archlinux-steam archlinux-gaming archlinux-steamos"
	@echo
	@echo "Copyright (C) 2025, lothrond <lothrond@proton.me>"

###########################################################################

include config.mk

archlinux: archlinux-base

## Make base installation:
archlinux-base: partitions filesystems mount base other exit-chroot

## Make base system configuration:
archlinux-system: timezone locales keymap host net-sys init $(BOOTLOADER) pass

## Make development tools:
archlinux-dev: dev-pkgs remote-pkgs zsh-pkgs

## Make silent bootloader:
archlinux-silent: $(BOOTLOADER)-silent lastlogin kmsgs agetty

## Make third party kernel-based iptables network firewall:
archlinux-firewall: firewall

## Make desktop:
archlinux-desktop: user x $(GRAPHICS) $(GRAPHICS)-config $(DESKTOP) bluetooth

## Make automatic desktop login (no password entry):
archlinux-nopass: $(DESKTOP)-nopass

## Make (LIMITED) media playback support:
archlinux-dvd: dvd-br

## Make 32 bit architecture support:
archlinux-32: multilib $(GRAPHICS)-32

## Make steam client (and WINE):
archlinux-steam: steam-pkgs wine-pkgs

## Make additional (steam) gaming performance configurations:
archlinux-gaming: game-perf dri-lat

## Make SteamOS session configuration:
archlinux-steamos: gamescope-fx steamos-session steamos-$(DESKTOP)

## Make system with open sshd ports.
archlinux-open: open-ssh

## Clean/Wipe device disk drive.
clean: archlinux-clean
wipe: archlinux-wipe

############################################################
## BASE SYSTEM INSTALLATION (RUN IN ARCHISO ENVIRONMENT): ##
############################################################

# Create system disk partitioning layout.
PHONY: partitions
partitions:
	@echo -e "\n* Partioning $(DRIVE) ..."
	@parted $(DRIVE) --script mklabel gpt
	@parted $(DRIVE) --script mkpart 'EFI' 1MiB 4097MiB
	@parted $(DRIVE) --script set 1 esp on
	@parted $(DRIVE) --script mkpart 'swap' linux-swap 4097MiB 20481MiB
	@parted $(DRIVE) --script mkpart 'rootfs' ext4 20481MiB 51201MiB
	@parted $(DRIVE) --script mkpart 'user' ext4 51201MiB 100%
	@parted $(DRIVE) --script print

# Create filesystems on disk.
PHONY: filesystems
filesystems:
	@echo -e "\n* Making filesystems for $(DRIVE) ..."
	@mkfs.vfat -F 32 $(DRIVE)1
	@mkswap $(DRIVE)2
	@mkfs.ext4 $(DRIVE)3
	@mkfs.ext4 $(DRIVE)4

# Mount disk.
PHONY: mount
mount:
	@echo -e "\n* Mounting $(DRIVE) ..."
	@mount $(DRIVE)3 /mnt
	@mount --mkdir $(DRIVE)1 /mnt/boot
	@mount --mkdir $(DRIVE)4 /mnt/home
	@swapon $(DRIVE)2

# Install base system packages.
.PHONY: base
base:
	@echo -e "\n* Installing base system packages ..."
	@pacstrap -K /mnt $(PKGS_BASE) $(PKGS_NET) $(PKGS_TOOLS) $(PKGS_DOCS)

# Configure base system.
PHONY: other
other:
	@echo -e "\n* Generating fstab ..."
	@genfstab -U /mnt >> /mnt/etc/fstab
	@echo -e "\n* Copying over Makefile to chroot ..."
	@cp Makefile config.mk /mnt
	@echo -e "\n* Changing root to system ..."
	@arch-chroot /mnt make $(MAKEOPTS) $(OPTS)

## Run this command when your done with all other commands.

.PHONY: done
done:
	@echo -e "\n* Powering off ..."
	@umount -R /mnt
	@systemctl poweroff

###################################################################
## BASE SYSTEM CONFIGURATION (RUN INSIDE OF CHROOT ENVIRONMENT): ##
###################################################################

# Configure base system timezone.
PHONY: timezone
timezone:
	@echo -e "\n* Setting system timezone ..."
	@ln -sf /usr/share/zoneinfo/$(TZ) /etc/localtime
	@hwclock --systohc

# Configure base system locales.
PHONY: locales
locales:
	@echo -e "\n* Setting system locales ..."
	@echo "$(LOCALE_A) $(LOCALE_B)" > /etc/locale.gen
	@locale-gen
	@touch /etc/locale.conf
	@echo "LANG=$(LOCALE_A)" > /etc/locale.conf

# Configure base system keyboard keymap.
PHONY: keymap
keymap:
	@echo -e "\n* Setting system keyboard keymap ..."
	@touch /etc/vconsole.conf
	@echo "KEYMAP=$(KEYB)" > /etc/vconsole.conf

# Configure base system hostname.
PHONY: host
host:
	@echo -e "\n* Setting system hostname ..."
	@touch /etc/hostname
	@echo "$(HOSTNAME)" > /etc/hostname

# Configure base system network.
.PHONY: net-sys
net-sys:
	@echo -e "\n* Configuring base system network ..."
	@systemctl enable iwd
	@systemctl enable dhcpcd

# Configure base system firewall.
.PHONY: firewall
firewall:
	@echo -e "\n* Configuring third party kernel-based iptables firewall ..."
	@git clone https://github.com/lothrond/iptables-firewall-systemd
	@cd iptables-firewall-systemd
	@make install

# Configure base system initramfs.
.PHONY: init
init:
	@echo -e "\n* Generating base system (silent) initramfs ..."
	@echo "# vim:set ft=sh" > /etc/mkinitcpio.conf
	@echo "MODULES=()" >> /etc/mkinitcpio.conf
	@echo "BINARIES=()" >> /etc/mkinitcpio.conf
	@echo "FILES=()" >> /etc/mkinitcpio.conf
	@echo "HOOKS=($(INITRAMFS_OPTS))" >> /etc/mkinitcpio.conf
	@mkinitcpio -P

# Install GRUB bootloader.
.PHONY: grub
grub:
	@echo -e "\n* Installing GRUB bootloader ..."
	@grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id="$(BOOT_ID)"
	@grub-mkconfig -o /boot/grub/grub.cfg

# Install systemd bootloader.
.PHONY: systemd
systemd:
	@echo -e "\n* Installing systemd UEFI boot manager ..."
	@bootctl --esp-path=/boot install
	@touch /boot/loader/entries/systemd.conf
	@echo "title=$(BOOT_ID)" > /boot/loader/entries/systemd.conf
	@echo "linux=\vmlinuz-linux" >> /boot/loader/entries/systemd.conf
	@echo "initrd=\initramfs-linux.img" >> /boot/loader/entries/systemd.conf
	@echo "root=UUID=$(BLKID) options=$(BOOT_OPTS)" >> /boot/loader/entries/systemd.conf
	@touch /boot/loader/loader.conf
	@echo "default systemd.conf" > /boot/loader/loader.conf
	@echo "console-mode auto" >> /boot/loader/loader.conf
	@echo "editor no" >> /boot/loader/loader.conf
	@systemctl enable systemd-boot-update

# Configure base system password.
.PHONY: pass
pass:
	@echo -e "\n* Setting system root password ..."
	@passwd

# Exit build environment.
.PHONY: exit-chroot
exit-chroot:
	@echo -e "\nDone."
	@echo
	@echo "* Now exiting the chroot build environment ..."
	@echo
	@echo "(DRIVE STILL MOUNTED.)"
	@echo "Run \`make done\` or \`systemctl poweroff\` when done."
	@echo

###################################
## ADDITIONAL DEVELOPMENT TOOLS: ##
###################################

# Install additonal development tools.
.PHONY: dev-pkgs
dev-pkgs:
	@echo -e "\n* Installing additional development packages ..."
	@pacman -S $(PKGS_DEV) --noconfirm

# Install/Setup remote development tools.
.PHONY: remote-pkgs
remote-pkgs:
	@echo -e "\n* Installing remote development packages ..."
	@pacman -S $(PKGS_REMOTE) --noconfirm
	@systemctl enable sshd

# Install CLI development shell.
.PHONY: zsh-pkgs
zsh-pkgs:
	@echo -e "\n* Installing ZSH developer shell packages ..."
	@pacman -S $(PKGS_ZSH) --noconfirm

# Install CLI file management tools.
.PHONY: ranger-pkgs
ranger-pkgs:
	@echo -e "\n* Installing ranger packages ..."
	@pacman -S $(PKGS_RNGR) --noconfirm

# Enable remote development.
.PHONY: open-ssh
open-ssh:
	@echo -e "\n* Configuring remote development ..."
	@systemctl enable sshd

##################################
## CONFIGURE SILENT BOOTLOADER: ##
##################################

# Hide GRUB bootloader.
.PHONY: grub-silent-config
grub-silent-config:
	@echo -e "\n* Configuring silent boot for GRUB bootloader ..."
	@cp /etc/default/grub /root
	@echo "GRUB_DEFAULT=0" > /etc/default/grub
	@echo "GRUB_TIMEOUT=0" >> /etc/default/grub
	@echo -e "GRUB_RECORDFAIL_TIMEOUT=\$GRUB_TIMEOUT" >> /etc/default/grub
	@echo -e "GRUB_CMDLINE_LINUX=\"$(BOOT_OPTS)\"" >> /etc/default/grub
	@echo -e "GRUB_CMDLINE_LINUX_DEFAULT=\$GRUB_CMDLINE_LINUX" >> /etc/default/grub
	@echo "GRUB_DISABLE_RECOVERY=true" >> /etc/default/grub
	@echo "GRUB_GFXPAYLOAD_LINUX=keep" >> /etc/default/grub
	@echo "GRUB_GFXMODE=auto" >> /etc/default/grub
	@grub-mkconfig -o /boot/grub/grub.cfg
	@sed -i 's/echo/#echo/g' /boot/grub/grub.cfg

# Hide systemd bootloader.
.PHONY: systemd-silent
systemd-silent:
	@echo -e "\n* Systemd-boot is already silent ..."

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
OVERRIDE := -/usr/bin/agetty --skip-login --nonewline --noissue --autologin $(USER) --noclear %I '$$TERM'
.PHONY: agetty
agetty:
	@echo -e "\n* Hiding agetty messages ..."
	@mkdir /etc/systemd/system/getty@tty1.service.d || touch $(AGETTY_OVERRIDE)
	@echo -e "[Service]" >> $(AGETTY_OVERRIDE)
	@echo -e "ExecStart=" >> $(AGETTY_OVERRIDE)
	@echo -e "ExecStart=$(OVERRIDE)" >> $(AGETTY_OVERRIDE)

# Create pacman hook directory.
.PHONY: hook-dir
hook-dir:
	@echo -e "\n* Creating pacman hook directory ..."
	@mkdir /etc/pacman.d/hooks

# Create pacman hook to configure GRUB after upgrades.
.PHONY: grub-config-hook
grub-config-hook:
	@echo -e "\n* Creating pacman hook to configure GRUB after upgrades ..."
	@touch /etc/pacman.d/hooks/grub-config.hook
	@echo "[Trigger]" >> /etc/pacman.d/hooks/grub-config.hook
	@echo "Operation = Upgrade" >> /etc/pacman.d/hooks/grub-config.hook
	@echo "Type = Package" >> /etc/pacman.d/hooks/grub-config.hook
	@echo "Target = grub" >> /etc/pacman.d/hooks/grub-config.hook
	@echo "" >> /etc/pacman.d/hooks/grub-config.hook
	@echo "[Action]" >> /etc/pacman.d/hooks/grub-config.hook
	@echo "Description = Configure GRUB bootloader configuration file after upgrades..." >> /etc/pacman.d/hooks/grub-config.hook
	@echo "Depends = grub" >> /etc/pacman.d/hooks/grub-config.hook
	@echo "When = PostTransaction" >> /etc/pacman.d/hooks/grub-config.hook
	@echo "Exec = /usr/bin/grub-mkconfig -o /boot/grub/grub.cfg" >> /etc/pacman.d/hooks/grub-config.hook

# Create pacman hook to configure a silent GRUB after upgrades.
.PHONY: grub-silent-hook
grub-silent-hook:
	@echo -e "\n* Creating pacman hook to configure a silent GRUB after upgrades ..."
	@touch /etc/pacman.d/hooks/grub-silent.hook
	@echo "[Trigger]" >> /etc/pacman.d/hooks/grub-silent.hook
	@echo "Operation = Upgrade" >> /etc/pacman.d/hooks/grub-silent.hook
	@echo "Type = Package" >> /etc/pacman.d/hooks/grub-silent.hook
	@echo "Target = grub" >> /etc/pacman.d/hooks/grub-silent.hook
	@echo "" >> /etc/pacman.d/hooks/grub-silent.hook
	@echo "[Action]" >> /etc/pacman.d/hooks/grub-silent.hook
	@echo "Description = Configure GRUB bootloader configuration file after upgrades..." >> /etc/pacman.d/hooks/grub-silent.hook
	@echo "Depends = grub" >> /etc/pacman.d/hooks/grub-silent.hook
	@echo "When = PostTransaction" >> /etc/pacman.d/hooks/grub-silent.hook
	@echo "Exec = /usr/bin/sed -i '/^echo/d' /boot/grub/grub.cfg" >> /etc/pacman.d/hooks/grub-silent.hook

# Configure a silent GRUB bootloader.
.PHONY: grub-silent
grub-silent: grub-silent-config hook-dir grub-config-hook grub-silent-hook

#######################
## GRAPHICS DRIVERS: ##
#######################

.PHONY: vulkan-graphics
vulkan-graphics:
	@echo -e "\n Making Vulkan graphics libraries ..."
	@pacman -S $(PKGS_VULKAN) --noconfirm

.PHONY: vulkan-graphics-32
vulkan-graphics-32:
	@echo -e "\n Making Vulkan graphics 32 bit libraries ..."
	@pacman -S $(PKGS_VULKAN_32) --noconfirm

## AMD Graphics (WIP) ##
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

## Intel Graphics (WIP) ##
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

## Nvidia graphics ##

.PHONY: nvidia-graphics
nvidia-graphics:
	@echo -e "\n* Making Nvidia base graphics driver packages ..."
	@pacman -S $(PKGS_NVIDIA_GRAPHICS) --noconfirm

nvidia: nvidia-graphics vulkan-graphics

# Nvidia 32 bit architecture support.
.PHONY: nvidia-graphics-32
nvidia-graphics-32:
	@echo -e "\n* Making 32 bit Nvidia Graphics driver packages ..."
	@pacman -S $(PKGS_NVIDIA_GRAPHICS_32) --noconfirm

nvidia-32: nvidia-graphics-32 vulkan-graphics-32

# Configure nvidia X11 Xorg config.
.PHONY: nvidia-xconfig
nvidia-xconfig:
	@echo -e "\n* Creating Nvidia graphics X11 Xorg configuration ..."
	@touch /etc/X11/xorg.conf.d/20-nvidia.conf
	@echo 'Section "Device"' > /etc/X11/xorg.conf.d/20-nvidia.conf
	@echo '    Identifier "NVIDIA Card"' >> /etc/X11/xorg.conf.d/20-nvidia.conf
	@echo '    Driver "nvidia"' >> /etc/X11/xorg.conf.d/20-nvidia.conf
	@echo '    VendorName "NVIDIA Corporation"' >> /etc/X11/xorg.conf.d/20-nvidia.conf
	@echo "    BoardName \"$(NVIDIA_BOARD)\"" >> /etc/X11/xorg.conf.d/20-nvidia.conf
	@echo '    Option "RegistryDwords" "EnableBrightnessControl=1\"' >> /etc/X11/xorg.conf.d/20-nvidia.conf
	@echo 'EndSection' >> /etc/X11/xorg.conf.d/20-nvidia.conf
	@echo '' >> /etc/X11/xorg.conf.d/20-nvidia.conf

# Fix nvidia screen tearing issues.
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

# Enable the PAT feature for nvidia graphics.
.PHONY: nvidia-pat
nvidia-pat:
	@echo -e "\n* Enabling PAT for Nvidia graphics ..."
	@touch /etc/modprobe.d/nvidia.conf
	@echo "options nvidia NVreg_UsePageAttributeTable=1" >> /etc/modprobe.d/nvidia.conf

# Early Kernel module loading (KMS) for nvidia graphics.
.PHONY: nvidia-kms
nvidia-kms:
	@echo -e "\n* Setting early kernel mode settings for Nvidia graphics ..."
	@sed -i 's/MODULES=(*)/MODULES=($(NVIDIA_KMOD))/g' /etc/mkinitcpio.conf

nvidia-config: nvidia-xconfig nvidia-tearing nvidia-pat nvidia-kms

##############
## DESKTOP: ##
##############

# Create desktop user.
.PHONY: user
user:
	@echo -e "\n* Making user account ($(USER)) ..."
	@useradd -c "" -m -G audio,input,video,wheel $(USER)
	@passwd $(USER)

# Install X (X11) (xorg) display server.
.PHONY: x
x:
	@echo -e "\n* Making desktop display server packages ..."
	@pacman -S $(PKGS_X) --noconfirm

# Install bluetooth.
.PHONY: bluetooth
bluetooth:
	@echo -e "\n* Making desktop bluetooth packages ..."
	@pacman -S $(PKGS_BLUEZ) --noconfirm
	@systemctl enable bluetooth

# Install KDE Plasma dektop.
PHONY: plasma
plasma:
	@echo -e "\n* Making KDE plasma desktop environment packages ..."
	@pacman -S $(PKGS_PLASMA_DESKTOP) $(PKGS_PLASMA_APPS) $(PKGS_PLASMA_FILES) --noconfirm
	@systemctl enable sddm
	@systemctl enable power-profiles-daemon
	@systemctl enable NetworkManager
	@systemctl enable wpa_supplicant
	@systemctl disable iwd || echo "iwd not active ..."
	@systemctl stop iwd || echo "iwd not running ..."

# Install GNOME desktop.
.PHONY: gnome
gnome:
	@echo -e "\n* Making GNOME desktop environment packages ..."
	@pacman -S $(PKGS_GNOME_DESKTOP) $(PKGS_GNOME_APPS) --noconfirm
	@systemctl enable gdm
	@systemctl enable NetworkManager
	@systemctl enable wpa_supplicant
	@systemctl enable power-profiles-daemon
	@systemctl disable iwd || echo "iwd not active ..."
	@systemctl stop iwd || echo "iwd not running ..."

# Configure automatic login for KDE Plasma display manager.
# Also, configure no password entry.
.PHONY: plasma-nopass
plasma-nopass:
	@echo -e "\n* Making automatic login for KDE display manager service ..."
	@echo -e "[Autologin]" > /etc/sddm.conf
	@echo -e "User=$(USER)" >> /etc/sddm.conf
	@echo -e "Session=$(PLASMA_SESSION)" >> /etc/sddm.conf
	@echo -e "\n* Making automatic login for KDE Plasma desktop user accounts ..."
	@sed -i '2i auth        sufficient  pam_succeed_if.so user ingroup nopasswdlogin' /etc/pam.d/sddm
	@groupadd nopasswdlogin
	@gpasswd -a $(USER) nopasswdlogin
	@echo -e "\n* Making passwordless login for KDE plasma desktop login screen ..."
	@sed -i '2i auth        sufficient  pam_succeed_if.so user ingroup nopasswdlogin' /etc/pam.d/kde

# Configure automatic login for GNOME display manager.
# Also, configure no password entry.
GNOMEDM := /etc/gdm/nologin.conf
.PHONY: gnome-nopass
gnome-nopass:
	@echo -e "\n* Making automatic login for GNOME display manger service ..."
	@echo -e "# GDM config" > $(GNOMEDM)
	@echo -e "" >> $(GNOMEDM)
	@echo -e "[daemon]" >> /etc/gdm/custom.conf
	@echo -e "AutomaticLoginEnable=True" >> /etc/gdm/custom.conf
	@echo -e "AutomaticLogin=$(USER)" >> /etc/gdm/custom.conf
	@echo -e "Session=$(GNOME_SESSION)" >> /etc/gdm/custom.conf
	@echo -e "#WaylandEnable=false" >> $(GNOMEDM)
	@echo -e "" >> $(GNOMEDM)
	@echo -e "[security]" >> $(GNOMEDM)
	@echo -e "" >> $(GNOMEDM)
	@echo -e "[xdmcp]" >> $(GNOMEDM)
	@echo -e "" >> $(GNOMEDM)
	@echo -e "[chooser]" >> $(GNOMEDM)
	@echo -e "" >> $(GNOMEDM)
	@echo -e "[debug]" >> $(GNOMEDM)
	@echo -e "#Enable=true" >> $(GNOMEDM)
	@echo -e "\n* Making passwordless login for GNOME desktop user accounts ..."
	@sed -i '2i auth        sufficient  pam_succeed_if.so user ingroup nopasswdlogin' /etc/pam.d/gdm-password
	@groupadd nopasswdlogin
	@gpasswd -a $(USER) nopasswdlogin

#####################
## Media Playback: ##
#####################

# Install (VERY LIMITED) dvd/bluray playback (with vlc media player).
# (Please just supply your own KEYDB.cfg)
.PHONY: dvd-br
dvd-br:
	@echo -e "\n* Making Media playback packages ..."
	@pacman -S $(PKGS_VLC) --noconfirm
	@pacman -S $(PKGS_DVD) --noconfirm

############
## STEAM: ##
############

# Enable 32 bit architecture support.
.PHONY: multilib
multilib:
	@echo -e "\n* Making 32 bit architecture support ..."
	@sed -i "92i [multilib]" /etc/pacman.conf
	@sed -i "93i Include = /etc/pacman.d/mirrorlist" /etc/pacman.conf
	@pacman -Sy

# Increase VM max heap count for better performance.
.PHONY: vm-max
vm-max:
	@echo -e "\n* Increasing VM Max heap count ..."
	@touch /etc/sysctl.d/80-gamecompatibility.conf
	@echo "" > /etc/sysctl.d/80-gamecompatibility.conf

# Install steam client packages.
.PHONY: steam-pkgs
steam-pkgs:
	@echo -e "\n* Making steam client packages ..."
	@pacman -S $(PKGS_STEAM) --noconfirm

# Install WINE packages.
.PHONY: wine-pkgs
wine-pkgs:
	@echo -e "\n* Making WINE packages ..."
	@pacman -S $(PKGS_WINE) --noconfirm

# Set up faster vulkan shader processing.
.PHONY: vulkan-shader-proc
vulkan-shader-proc:
	@echo -e "\n* Making vulkan shader processing faster ..."
	@touch /home/$(USER)/.steam/steam/steam_dev.cfg
	@echo "@ShaderBackgroundProcessingThreads $(SHADER_THREADS)" > .steam/steam/steam_dev.cfg
	@echo "unShaderBackgroundProcessingThreads $(SHADER_THREADS)" >> .steam/steam/steam_dev.cfg

####################
## STEAMOS (WIP): ##
####################

# Create custom gamescope wrapper ..."
.PHONY: gamescope-fx
gamescope-fx:
	@echo -e "\n* Making gamescope-fx ..."
	@touch /usr/bin/gamescope-fx
	@echo -e '#!/bin/bash' > /usr/bin/gamescope-fx
	@echo -e 'set -e' >> /usr/bin/gamescope-fx
	@echo -e 'export INTEL_DEBUG="--rt-notrace"' >> /usr/bin/gamescope-fx
	@echo -e 'export mesa_glthread=true' >> /usr/bin/gamescope-fx
	@echo -e 'export ENABLE_GAMESCOPE_WSI=0' >> /usr/bin/gamescope-fx
	@echo -e 'export SDL_MINIMIZE_ON_FOCUS_LOSS=0' >> /usr/bin/gamescope-fx
	@echo -e "DISRES=$(STEAMOS_DISPLAY)" >>/usr/bin/gamescope-fx
	@echo -e 'SET_OPTIONS="$(STEAMOS_GAMESCOPE)"' >> /usr/bin/gamescope-fx
	@echo -e 'SET_DISPLAY="-f -h $(STEAMOS_DISPLAY) -H $(STEAMOS_DISPLAY)"' >> /usr/bin/gamescope-fx
	@echo -e "gamescope $(GAMESCOPE_CMD)"'" $@"' >> /usr/bin/gamescope-fx
	@chmod 755 /usr/bin/gamescope-fx

# Create SteamOS desktop session (WIP).
.PHONY: steamos-session
steamos-session:
	@echo -e "\n* Making SteamOS desktop session ..."
	@echo "[Desktop Entry]" > /usr/share/wayland-sessions/steamos.desktop
	@echo "Name=Steam OS Mode" >> /usr/share/wayland-sessions/steamos.desktop
	@echo "Comment=Start Steam in Big Picture Mode" >> /usr/share/wayland-sessions/steamos.desktop
	@echo "Exec=/usr/bin/gamescope-fx -e -- /usr/bin/steam $(STEAMOS_CLIENTCMD)" >> /usr/share/wayland-sessions/steamos.desktop
	@echo "Type=Application" >> /usr/share/wayland-sessions/steamos.desktop

PHONY: steamos-plasma
steamos-plasma:
	@echo -e "\n [edit /etc/sddm.conf later and change Session to steamos]"
	@echo -e "[Only do this after you run steam and login first]"
	@echo -e "(This is done to allow adding multiple steam drives, etc.)"

# Create automatic login for steamos destop session on GNOME.
.PHONY: steamos-gnome
steamos-gnome:
	@touch /var/lib/AccountsService/users/$(USER)
	@echo "[User]" > /var/lib/AccountsService/users/$(USER)
	@echo "XSession=steamos" >> /var/lib/AccountsService/users/$(USER)
	@chmod 644 -R /var/lib/AccountsService

#############
## Gaming: ##
#############

# Install LED control packages.
.PHONY: led-pkgs
led-pkgs:
	@echo -e "\n* Installing LED control packages ..."
	@pacman -S $(LED_PKGS) --noconfirm

# Game/Performance tweaks.
.PHONY: game-perf
game-perf:
	@echo -e "\n* Setting up gaming performance tweaks ..."
	@touch /etc/tmpfiles.d/consistent-response-time-for-gaming.conf
	@echo "#    Path                  Mode UID  GID  Age Argument" > /etc/tmpfiles.d/consistent-response-time-for-gaming.conf
	@echo "w /proc/sys/vm/compaction_proactiveness - - - - 0" >> /etc/tmpfiles.d/consistent-response-time-for-gaming.conf
	@echo "w /proc/sys/vm/watermark_boost_factor - - - - 1" >> /etc/tmpfiles.d/consistent-response-time-for-gaming.conf
	@echo "w /proc/sys/vm/min_free_kbytes - - - - 1048576" >> /etc/tmpfiles.d/consistent-response-time-for-gaming.conf
	@echo "w /proc/sys/vm/watermark_scale_factor - - - - 500" >> /etc/tmpfiles.d/consistent-response-time-for-gaming.conf
	@echo "w /proc/sys/vm/swappiness - - - - 10" >> /etc/tmpfiles.d/consistent-response-time-for-gaming.conf
	@echo "w /sys/kernel/mm/lru_gen/enabled - - - - 5" >> /etc/tmpfiles.d/consistent-response-time-for-gaming.conf
	@echo "w /proc/sys/vm/zone_reclaim_mode - - - - 0" >> /etc/tmpfiles.d/consistent-response-time-for-gaming.conf
	@echo "w /sys/kernel/mm/transparent_hugepage/enabled - - - - madvise" >> /etc/tmpfiles.d/consistent-response-time-for-gaming.conf
	@echo "w /sys/kernel/mm/transparent_hugepage/shmem_enabled - - - - advise" >> /etc/tmpfiles.d/consistent-response-time-for-gaming.conf
	@echo "w /sys/kernel/mm/transparent_hugepage/defrag - - - - never" >> /etc/tmpfiles.d/consistent-response-time-for-gaming.conf
	@echo "w /proc/sys/vm/page_lock_unfairness - - - - 1" >> /etc/tmpfiles.d/consistent-response-time-for-gaming.conf
	@echo "w /proc/sys/kernel/sched_child_runs_first - - - - 0" >> /etc/tmpfiles.d/consistent-response-time-for-gaming.conf
	@echo "w /proc/sys/kernel/sched_autogroup_enabled - - - - 1" >> /etc/tmpfiles.d/consistent-response-time-for-gaming.conf
	@echo "w /proc/sys/kernel/sched_cfs_bandwidth_slice_us - - - - 3000" >> /etc/tmpfiles.d/consistent-response-time-for-gaming.conf
	@echo "w /sys/kernel/debug/sched/base_slice_ns  - - - - 3000000" >> /etc/tmpfiles.d/consistent-response-time-for-gaming.conf
	@echo "w /sys/kernel/debug/sched/migration_cost_ns - - - - 500000" >> /etc/tmpfiles.d/consistent-response-time-for-gaming.conf
	@echo "w /sys/kernel/debug/sched/nr_migrate - - - - 8" >> /etc/tmpfiles.d/consistent-response-time-for-gaming.conf

# Reduce DRI latency
.PHONY: dri-lat
dri-lat:
	@echo -e "\n* Reducing DRI latency ..."
	@touch /etc/drirc
	@echo '<driconf>' > /etc/drirc
	@echo '	<device>' >> /etc/drirc
	@echo '		<application name="Default">' >> /etc/drirc
	@echo '			<option name="vblank_mode" value="0" />' >> /etc/drirc
	@echo '		</application>' >> /etc/drirc
	@echo '	</device>' >> /etc/drirc
	@echo '</driconf>' >> /etc/drirc

#################
## Clean/Wipe: ##
#################

# Quickly clean device disk drive.
.PHONY: archlinux-clean
archlinux-clean:
	@echo -e "\n* Cleaning device disk drive ..."
	@umount -R /mnt | swapoff $(DRIVE)2 | wipefs -af $(DRIVE) && mkfs.ext4 $(DRIVE)
	@echo -e "\n*Done."

# Completely wipe device disk drive.
.PHONY: archlinux-wipe
archlinux-wipe:
	@echo -e "\n* Wiping device disk drive ..."
	@umount -R /mnt | swapoff $(DRIVE)2 | wipefs -af $(DRIVE) && dd if=/dev/zero of=$(DRIVE) status=progress
	@echo -e "\n*Done."
