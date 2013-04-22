# Description

This Battery monitor is coded with vala and gtk3. It polls with acpi to get the battery info and uses to libnotify to tell you when you are running low.

## Setup

`valabattery` depends on `acpi`, `libnotify` and `gtk3`, and valac/vala to compile it.

### Install it using your preferred AUR helper

Link to AUR package [valabattery-git](https://aur.archlinux.org/packages.php?ID=57261)

Just install it with your prefered AUR helper , for example yaourt.

`yaourt -S valabattery-git`

## Usage

Once installed you will have a launcher in /usr/bin/valabattery and binary and icons in /opt/valabattery
There will also be a configuration file in /etc/valabattery.conf which is commented to explain the options.

Happy battery monitoring :D

## Screenshot

Want to see it in live action on AwesomeWM ? check "Screenshot":https://github.com/gulafaran/valabattery/blob/master/screenshot.png

## Roadmap
1. Customization of the notifications.
2. a simple GUI to make the customizations.

### THIS IS A WORK IN PROGRESS
### therefore I do not necessarily need to improve this as it does what i wanted it to do
