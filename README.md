# Install GalliumOS files for Braswell Systems on Arch Linux

#Instructions

Login to your Arch Linux install and ensure you run this from a Window Manager or with one already installed, for some reaason, sound and input both break without it.

This only works with GRUB.

Connect to the internet

Ensure that you have these packages installed:
bc
wget
svn
git

Run this:

wget https://raw.githubusercontent.com/maelodic/maelo-arch-scbp/braswell/standalone.sh ; chmod +x standalone.sh ; sudo ./standalone.sh

When you are prompted during the configuration page, just hold enter for a couple seconds

Reboot your PC, go into advanced settings, and select the GalliumOS kernel.

And that's it.
