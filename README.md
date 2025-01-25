
Arch Linux Makefile installation 
---

# Whats in this repo?
This repository is a way to install archlinux via Makefile in an archiso environment.

# Without an archiso

## Downloading archiso:
Start by downloading an archlinux archiso medium.
A helper script is available @ https://github.com/lothrond/archlinux-dl.

Clone that repository, change into the working directory and either run:

	bash archlinux-dl.sh

directly, or:

	make install && archlinux-dl

to install to your system for later use.

## Installing archiso to installation medium:

### CD
The CD/DVD drive is usually `/dev/sr0` or `/dev/sr1` etc.

Identify the name of the CD/DVD drive

### USB
Identify the device label of the USB:

	lsblk -f

Now:

	dd if=/path/to/liveISO of=/path/to/USB bs=1M status=progress

# With an archiso
## Arch Linux build environment setup
Boot the archiso installation medium.

* Setup root password with `passwd`
* Setup network with `iwctl`
* Update system repositories with `pacman -Sy`
* Make sure `git` and `make` are installed with `pacman -S git make`

Obtain this repository:

	git clone https://github.com/lothrond/archbuild.git

Change into working directory, and make sure to edit `config.mk` as needed.

## Arch Linux build options

The mian build options are:

	make help
	make archlinux-base
	make archlinux-dev
	make archlinux-system
	make archlinux-desktop
	make archlinux-nologin

Gaming and SteamOS build options:

	make archlinux-steam
	make archlinux-steamos

## Building Arch Linux

### Base system

Make base system packages by running:

	make archlinux-base

Once complete, you will be inside the chroot build environment.

Make the base system configuration with:

	make archlinux-system

Once complete, you will be prompted for a root password.

Additional developer tools can be made with:

	make archlinux-dev

### Desktop

To make the desktop environment, run:

	archlinux-desktop

#### Automatic login

After making the desktop environment, for automatic login support, run:

	make archlinux-nologin

This will also allow the user to still have a lock screen
for the desktop environment, without requiring a password to unlock the desktop session.

### Gaming (Steam)

To make steam client and WINE packages, with additional system configuration, run:

	make archlinux-steam

Additionally, to make a SteamOS desktop session, run:

	make archlinux-steamos

See `make` or `make help` for more information.

#### Copyright (C) 2025, lothrond <lothrond@proton.me>
