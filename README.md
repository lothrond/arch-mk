Arch Linux Makefile installation 
---

# Whats in this repo?
This repository is a way to install archlinux via Makefile in an archiso environment.

# Without an archiso

## Downloading archiso:
Start by downloading an archlinux archiso medium.
A helper script is available @ https://github.com/lothrond/arch-dl.

Clone that repository, change into the working directory and either run:

	bash archlinux-dl.sh

directly, or:

	make install && archlinux-dl

to install to your system for later use.

## Installing archiso to installation medium:

### CD
The CD/DVD drive is usually `/dev/sr0` or `/dev/sr1` etc.

Identify the name of the CD/DVD drive: 

	dmesg | grep dvd | grep sr

Look for `[sr0]` or `[sr1]` etc.

Then, with something like `wodim` installed:

	wodim -eject -tao  speed=2 dev=/dev/sr0 -v -data archiso-x86_64.iso

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

	git clone https://github.com/lothrond/arch-mk.git

Change into working directory, and make sure to edit `config.mk` as needed.

## Arch Linux make options

The main make option is:

	make archlinux

This will run:

	make archlinux-base
	make archlinux-system
	make archlinux-desktop
	make archlinux-nologin
	make archlinux-dev

Additional make options:

	make archlinux-32
	make archlinux-steam
	make archlinux-steamos

Other make options:

	make wipe
	make clean

(Run `make help` for more information)

## Building Arch Linux

### Base system

Make the base system by running:

	make archlinux

you will be prompted for a root and desktop user password.

See `make` or `make help` for more information.

#### Copyright (C) 2025, lothrond <lothrond AT proton DOT me>
