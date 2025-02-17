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
	@echo "[USAGE]: make [ OPTION ]"
	@echo
	@echo "[OPTIONS]:"
	@echo
	@echo "    help               -  Show this help message"
	@echo "    clean              -  Quickly wipe device disk drive."
	@echo "    wipe               -  Completely wipe device disk drive."
	@echo "    archlinux-base     -  Make the base Arch linux system."
	@echo "    archlinux-dev      -  Install additional Arch Linux development packages."
	@echo "    archlinux-system   -  Arch Linux base system configuration (made by archlinux-base)."
	@echo "    archlinux-silent   -  Configure a silent Arch Linux bootloader."
	@echo "    archlinux-lqx      -  Install custom liqourix linux kernel."
	@echo "    archlinux-desktop  -  Install Arch Linux desktop (including display server and graphics drivers)."
	@echo "    archlinux-nologin  -  Enable automatic login support for Arch Linux desktop."
	@echo "    archlinux-dvd      -  Enable CD/DVD and bluray disk support with VLC."
	@echo "    archlinux-32       -  Enable Arch Linux 32 bit architecture support."
	@echo "    archlinux-steam    -  Install Arch Linux steam gaming packages."
	@echo "    archlinux-steamos  -  Configure a SteamOS Arch Linux."
	@echo
	@echo "[EXAMPLES]:"
	@echo
	@echo ' * Run `make archlinux-base` to setup the build process.'
	@echo "   Once completed, you will be inside an arch linux build chroot."
	@echo
	@echo "(All other make options are executed in the chroot build environment.)"
	@echo
	@echo ' * Run `make archlinux-system` to start making the base system.'
	@echo "   You will be prompted for a root password at the end."
	@echo
	@echo ' * Run `make archlinux-desktop` To make the desktop environment.'
	@echo "   You will also create a desktop user account, and be prompted for a user password."
	@echo
	@echo " root@archiso: make archlinux-base"
	@echo " [root@chroot]: make archlinux-desktop archlinux-nologin archlinux-silent archlinux-dev"
	@echo
	@echo "Copyright (C) 2025, lothrond <lothrond@proton.me>"

###########################################################################

include config.mk

archlinux: archlinux-base

## Build base installation:
archlinux-base: partitions filesystems mount base other exit-chroot

## Build base system configuration:
archlinux-system: timezone locales keymap host net-sys init $(BOOTLOADER) pass

## Build development tools:
archlinux-dev: dev-pkgs remote-pkgs zsh-pkgs

## Build silent bootloader:
archlinux-silent: $(BOOTLOADER)-silent lastlogin kmsgs agetty

## Configure third party kernel-based iptables network firewall:
#archlinux-firewall: firewall

## Custom (Gaming) kernel:
archlinux-lqx: lqx

## Build desktop:
archlinux-desktop: user x $(GRAPHICS) $(GRAPHICS)-config $(DESKTOP) bluetooth

## Enable automatic desktop login (no password for lock screen):
archlinux-nologin: $(DESKTOP)-nologin $(DESKTOP)-nopasswd

## Ebable CD/DVD and bluray disk suport:
#archlinux-dvd: (wip)

## Enable 32 bit architecture support:
archlinux-32: multilib $(GRAPHICS)-32

## Build steam client:
archlinux-steam: steam-pkgs wine-pkgs

## Build SteamOS configuration:
archlinux-steamos: steamos-session

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
	@arch-chroot /mnt make $(ARCH_MAKEOPTS)

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
	@echo "$(KEYB)" > /etc/vconsole.conf

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
	@git cone https://github.com/lothrond/iptables-firewall-systemd
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

###########################
## Liqourix Linux kernel ##
###########################

.PHONY: lqx
lqx:
	@echo -e "\n* Making liqourix kernel ..."
	@curl -s 'https://liquorix.net/install-liquorix.sh' | sudo bash
	@echo -e "\n* Reboot before installing new graphics drivers ..."

###################################
## ADDITIONAL DEVELOPMENT TOOLS: ##
###################################

# Make additonal development tools.
.PHONY: dev-pkgs
dev-pkgs:
	@echo -e "\n* Making additional development packages ..."
	@pacman -S $(PKGS_DEV) --noconfirm

# Make remote development tools.
.PHONY: remote-pkgs
remote-pkgs:
	@echo -e "\n* Making remote development packages ..."
	@pacman -S $(PKGS_REMOTE) --noconfirm

# Make development shell.
.PHONY: zsh-pkgs
zsh-pkgs:
	@echo -e "\n* Making ZSH developer shell packages ..."
	@pacman -S $(PKGS_ZSH) --noconfirm

##################################
## CONFIGURE SILENT BOOTLOADER: ##
##################################

# Hide GRUB bootloader.
.PHONY: grub-silent
grub-silent:
	@echo -e "\n* Configuring silent boot for GRUB bootloader ..."
	@cp /etc/default/grub /root
	@echo "GRUB_DEFAULT=0" > /etc/default/grub
	@echo "GRUB_TIMEOUT=0" >> /etc/default/grub
	@echo 'GRUB_RECORDFAIL_TIMEOUT=$GRUB_TIMEOUT' >> /etc/default/grub
	@echo -e "GRUB_CMDLINE_LINUX=\"$(BOOT_OPTS)\"" >> /etc/default/grub
	@echo -e 'GRUB_CMDLINE_LINUX_DEFAULT=$GRUB_CMDLINE_LINUX' >> /etc/default/grub
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

## AMD Graphics ##
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

## Intel Graphics ##
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

# Nvidia 32 bit architecture support:
.PHONY: nvidia-graphics-32
nvidia-graphics-32:
	@echo -e "\n* Making 32 bit Nvidia Graphics driver packages ..."
	@pacman -S $(PKGS_NVIDIA_GRAPHICS_32) --noconfirm

nvidia-32: nvidia-graphics-32 vulkan-graphics-32

# Configure nvidia X11 Xorg config:
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

# Fix nvidia screen tearing issues:
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

# Enable the PAT feature for nvidia graphics:
.PHONY: nvidia-pat
nvidia-pat:
	@echo -e "\n* Enabling PAT for Nvidia graphics ..."
	@touch /etc/modprobe.d/nvidia.conf
	@echo "options nvidia NVreg_UsePageAttributeTable=1" >> /etc/modprobe.d/nvidia.conf

# Early Kernel module loading (KMS) for nvidia graphics:
.PHONY: nvidia-kms
nvidia-kms:
	@echo -e "\n* Setting early kernel mode settings for Nvidia graphics ..."
	@sed -i 's/MODULES=(*)/MODULES=($(NVIDIA_KMOD))/g' /etc/mkinitcpio.conf

nvidia-config: nvidia-xconfig nvidia-tearing nvidia-pat nvidia-kms

##############
## DESKTOP: ##
##############

# Create desktop user:
.PHONY: user
user:
	@echo -e "\n* Making desktop user account ..."
	@useradd -c "" -m -G audio,input,video,wheel $(USER)
	@passwd $(USER)

# Make the (X11) (xorg) display server.
.PHONY: x
x:
	@echo -e "\n* Making desktop display server packages ..."
	@pacman -S $(PKGS_X) --noconfirm

# Make bluetooth.
.PHONY: bluetooth
bluetooth:
	@echo -e "\n* Making desktop bluetooth packages ..."
	@pacman -S $(PKGS_BLUEZ) --noconfirm
	@systemctl enable bluetooth

# Make KDE Plasma dektop.
PHONY: plasma
plasma:
	@echo -e "\n* Making KDE plasma desktop environment packages ..."
	@pacman -S $(PKGS_PLASMA_DESKTOP) $(PKGS_PLASMA_APPS) $(PKGS_PLASMA_FILES) --noconfirm
	@systemctl enable NetworkManager
	@systemctl enable power-profiles-daemon

# Make GNOME desktop.
.PHONY: gnome
gnome:
	@echo -e "\n* Making GNOME desktop environment packages ..."
	@pacman -S $(PKGS_GNOME_DESKTOP) $(PKGS_GNOME_APPS) --noconfirm
	@systemctl enable NetworkManager
	@systemctl enable power-profiles-daemon

# Configure automatic login for KDE Plasma display manager:
# Also, configure passwordless login for KDE Plasma login screen:
.PHONY: plasma-nologin
plasma-nologin:
	@echo -e "\n* Making automatic login for KDE display manager service ..."
	@touch /etc/sddm.conf
	@echo "[Autologin]" > /etc/sddm.conf
	@echo "User=$(USER)" >> /etc/sddm.conf
	@echo "Session=$(DESKTOP_SESSION)" >> /etc/sddm.conf
	@echo -e "\n* Making passwordless login for KDE plasma desktop login screen ..."
	@sed -i '2i auth        sufficient  pam_succeed_if.so user ingroup nopasswdlogin' /etc/pam.d/kde

# Configure passwordless login for KDE Plasma user account:
.PHONY: plasma-nopasswd
plasma-nopasswd:
	@echo -e "\n* Making automatic login for KDE Plasma desktop user accounts ..."
	@sed -i '2i auth        sufficient  pam_succeed_if.so user ingroup nopasswdlogin' /etc/pam.d/sddm
	@groupadd nopasswdlogin
	@gpasswd -a $(USER) nopasswdlogin

# Configure automatic login for GNOME display manager:
.PHONY: gnome-nologin
gnome-nologin:
	@echo -e "\n* Making automatic login for GNOME display manger service ..."
	@echo "[Autologin]" >> /etc/gdm/custom.conf
	@echo "User=$(USER)" >> /etc/gdm/custom.conf
	@echo "Session=$(DESKTOP_SESSION)" >> /etc/gdm/custom.conf

# Configure passwordless login for GNOME desktop user account:
.PHONY: gnome-nopasswd
gnome-nopasswd:
	@echo -e "\n* Making automatic login for GNOME desktop lockscreen ..."
	@sed -i '2i auth        sufficient  pam_succeed_if.so user ingroup nopasswdlogin' /etc/pam.d/gdm-password
	@groupadd nopasswdlogin
	@gpasswd -a $(USER) nopasswdlogin

###################
## STEAM GAMING: ##
###################

# Enable 32 bit architecture support.
.PHONY: multilib
multilib:
	@echo -e "\n* Making 32 bit architecture support ..."
	@sed -i "92i [multilib]" /etc/pacman.conf
	@sed -i "93i Include = /etc/pacman.d/mirrorlist" /etc/pacman.conf
	@pacman -Syu

# Increase VM max heap count for better performance:
.PHONY: vm-max
vm-max:
	@echo -e "\n* Increasing VM Max heap count ..."
	@touch /etc/sysctl.d/80-gamecompatibility.conf
	@echo "" > /etc/sysctl.d/80-gamecompatibility.conf

# Make steam client packages:
.PHONY: steam-pkgs
steam-pkgs:
	@echo -e "\n* Making steam client packages ..."
	@pacman -S $(PKGS_STEAM) --noconfirm

# Make WINE packages.
.PHONY: wine-pkgs
wine-pkgs:
	@echo -e "\n* Making WINE packages ..."
	@pacman -S $(PKGS_WINE) --noconfirm

###############
## STEAM OS: ##
###############

# Create SteamOS desktop session.
.PHONY: steamos-session
steamos-session:
	@echo -e "\n* Making SteamOS desktop session ..."
	@touch /usr/share/wayland-sessions/steamos.desktop
	@echo "[Desktop Entry]" > /usr/share/wayland-sessions/steamos.desktop
	@echo "Name=Steam OS Mode" >> /usr/share/wayland-sessions/steamos.desktop
	@echo "Comment=Start Steam in Big Picture Mode" >> /usr/share/wayland-sessions/steamos.desktop
	@echo "Exec=/usr/bin/gamescope -e -- /usr/bin/steam -tenfoot" >> /usr/share/wayland-sessions/steamos.desktop
	@echo "Type=Application" >> /usr/share/wayland-sessions/steamos.desktop

# Create SteamOS desktop user.
.PHONY: desktop-user
desktop-user:
	@echo -e "\n* Making SteamOS desktop user account ..."
	@adduser -c "" -m -G audio,input,video,$(USER) desktop

################
## Clean/Wipe ##
################

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
