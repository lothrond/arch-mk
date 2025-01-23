
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
## Arch Linux build environment setup:
Boot the archiso installation medium.

* Setup root password with `passwd`
* Setup network with `iwctl`
* Update system repositories with `pacman -Sy`
* Make sure `git` and `make` are installed with `pacman -S git make`

Obtain this repository:

	git clone https://github.com/lothrond/archbuild.git

Change into working directory, and make sure to edit `config.mk` as needed.

The mian build options are:

	make help
	make archlinux-base
	make archlinux-dev
	make archlinux-system
	make archlinux-desktop

Gaming and SteamOS build options:

	make archlinux-steam
	make archlinux-steamos

Start The build by running:

	make base

Once complete, you will be inside the chroot build environment.

## Building Arch Linux

### Base system

First, configure base system with:

	make archlinux-system

Once complete, you will be prompted for a root password.

Additional developer tools can be installed with:

	make archlinux-dev

It is then recommended at this point,
to reboot into the base system for all other build options.
(after removing the archiso installation medium).

You can use `make done` To poweroff the system.

### Desktop

Once inside the base system environment run:

	archlinux-desktop

To build the desktop environment.

### Gaming (steam)

To install steam client packages, and system WINE packages:

	make archlinux-steam

Additionally, to configure a SteamOS environment:

	make archlinux-steamos

See `make` or `make help` for more information.

#### Copyright (C) 2025, lothrond <lothrond@proton.me>
