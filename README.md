Arch Linux Makefile installation 
---

# Whats in this repo?
This repository is a way to install archlinux via Makefile in an archiso environment.

#### NEEDS INTEL GRAPHICS AND AMD GRAPHICS SUPPORT.

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

### ChromeOS devices:

The `Chromebook Recovery Utility` extension needs to be installed.

Rename the `archlinux-x86_64.iso` to a `.bin` file:

    mv archlinux-x86_64.iso archlinux-x86_64.bin

Then, open `chrome` and open the `Chromebook Recovery Utility`.
Click the gear icon in the top right corner, and click `use local image`.
Plug in a USB drive and On the next screen, make sure to select the correct drive, etc.

# With an archiso
## Arch Linux build environment setup
Boot the archiso installation medium.

* Setup root password with `passwd`
* Setup network with `iwctl`
* Update system repositories with `pacman -Sy`
* Make sure `git` and `make` are installed with `pacman -S git make`

Obtain this repository:

	git clone https://github.com/lothrond/arch-mk.git

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
	make archlinux-gaming
	make archlinux-steamos

Other make options:

	make wipe
	make clean

(Run `make help` for more information)

## Configuring  Arch Linux

There is a `config.mk` file with all the needed configurations for the system.
This includes defaults based off of my own system.

Edit this file as needed before all make operations.

## Building Arch Linux

### Base system

Make the base system by running:

	make archlinux

you will be prompted for a root and desktop user password.

### Steam gaming

(Editing the `OPTS` variable in `config.mk` before making the base system can also be done instead.)

Make a steam gaming setup by then running:

	make archlinux-32 archlinux-steam archlinux-gaming

And a complete SteamOS session with:

	make archlinux-steamos

See `make` or `make help` for more information and additional make options.

### Media playback

The user will not be able to dycrypt encrypted CD/DVD/Blueray disks,
and will need to supply their own `KEYDB.cfg` file.

#### Copyright (C) 2025, lothrond <lothrond AT proton DOT me>
