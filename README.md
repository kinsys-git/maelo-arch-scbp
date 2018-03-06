# How to setup Arch Linux on the Samsung Chromebook Pro

# Instructions

TL;DR for linux veterans at the bottom.

**0. Plan your formatting**

Arch can be installed on the Chromebook Pro in a variety of ways:
- On a microSD Card
- Directly to the hard drive
- Dual booting with ChromeOS
- On an external USB drive
- Partitionining ChromeOS between 

I would personally recommend installing it to the hard drive and completely blowing away ChromeOS, or dual booting with ChromeOS. I would also recommend setting up a large SD card for home directory mounting.

It should be noted that dual booting with ChromeOS requires the use of [CHRX](https://github.com/reynhout/chrx). Run CHRX once to partition the disk, and then don't run it again to get started.

After a reboot you will be prepped to hop onto the live CD.

**1. Install custom firmware**

Ensure your device is in developer mode.

Open the crosh shell and use the following command to install RW_LEGACY:
```
cd; curl -LO https://mrchromebox.tech/firmware-util.sh && sudo bash firmware-util.sh
```

**2. Create a bootable Arch Linux disk and boot into Arch**

Download Arch from here: https://www.archlinux.org/download/ (Pick a mirror close to your location, and then choose the .iso file)

Create an Arch Linux USB drive, or you can install it to your SD Card if you do not plan on installing Arch or any partitions to your SD card:

Windows: Use Rufus - https://rufus.akeo.ie/

Linux or ChromeOS: Use the dd command-
```
dd if=(ARCH ISO LOCATION) of=(DRIVE - not partition - that you will be installing arch from.) status=progress
```
Reboot your device with the device still plugged in.

At the white dev mode screen, hit CTRL-L and ESC when prompted. Select the device you installed the Arch installer on.

**3. Install Arch Linux**

You can use this guide here to install Arch Linux: https://wiki.archlinux.org/index.php/installation_guide

Alternatively, I have a nifty install script located here: https://github.com/maelodic/arch

In a nutshell, for an easy install process-

-Connect to wifi:
```
wifi-menu
```

-Finish formatting your disk(s) (You can use fdisk and mkfs for this.) If you want to dual boot and used CHRX, remove partitions 6 and 7, create partition 6 as a 1 MB partition with BIOS Boot flag, and do not format it. Then create partition 7 with the rest of the available space, and format it.

-Run these commands, following the prompts through it for an easy install with supplimentary software installs:
```
wget https://raw.githubusercontent.com/maelodic/arch/master/install.sh 
chmod +x install.sh 
./install.sh
```

**4. Recompile the Kernel**

(The remainder of these steps can be skipped by using my install script - running these commands. If you need a working headphone jack, please scroll down to the "BONUS" section near the bottom)
```
sudo pacman -Sy git wget rsync svn bc alsa-utils --noconfirm --needed
wget https://raw.githubusercontent.com/maelodic/maelo-arch-scbp/master/standalone.sh --no-cache
chmod +x standalone.sh
sudo ./standalone.sh
```

If you want to do it yourself:

Grab the files needed to perform all the steps:
```
sudo pacman -S rsync bc wget git alsa-utils
```

Clone the GalliumOS skylake files:
```
git clone https://github.com/galliumos/galliumos-skylake
```

Merge the directories into your system:
```
cd galliumos-skylake
sudo rsync -a usr/ /usr/
sudo rsync -a bin/ /bin/
sudo rsync -a etc/ /etc/
sudo cp debian/galliumos-skylake.service /etc/systemd/system/galliumos-skylake.service
```

Link the audio drivers so that Arch can use them:
```
cd /usr/share/alsa/ucm/
ln -s sklnau8825adi/ Google-Caroline-1.0-Caroline/
cd Google-Caroline-1.0-Caroline/
ln -s sklnau8825adi.conf Google-Caroline-1.0-Caroline.conf
cd ~
```

Download and use my version of galliumos-init-skylake:
```
wget https://raw.githubusercontent.com/maelodic/maelo-arch-scbp/master/galliumos-init-skylake
chmod +x galliumos-init-skylake
sudo chown root.root galliumos-init-skylake
sudo mv galliumos-init-skylake /usr/bin/galliumos-init-skylake
```

Enable the audio service:
```
sudo systemctl enable galliumos-skylake
```

Compile the GalliumOS kernel with their configuration and patches:
```
cd ~
git clone -b v4.14.14-galliumos https://github.com/galliumos/linux
cd linux
cp galliumos/config .config
chmod +x galliumos/diffs/apply_all.sh
sh galliumos/diffs/apply_al.sh
make -j4
make -j4 modules_install
make -j4 install
cp /root/tmp/linux/arch/x86/boot/bz* /boot/vmlinuz-galliumos
```

Grab the GalliumOS preset make the ramfs, and reconfigure grub:
```
sudo wget -P /etc/mkinitcpio.d/ https://raw.githubusercontent.com/maelodic/maelo-arch-scbp/master/galliumos.preset
mkinitcpio -p galliumos
grub-mkconfig -o /boot/grub/grub.cfg
```

And then reboot. At the grub menu, choose Advanced and then the GalliumOS kernel. Everything should work out of the box.


**BONUS**
To enable use of the headphone jack, grab the following and place them in your home folder:
```
wget -P ~/ https://raw.githubusercontent.com/maelodic/maelo-arch-scbp/master/headphones.sh
wget -P ~/ https://raw.githubusercontent.com/maelodic/maelo-arch-scbp/master/speakers.sh
chmod +x ~/headphones.sh
chmod +x ~/speakers.sh
```

To switch to headphone output, run "~/headphones.sh"    
To switch back to speakers, run "~/speakers.sh"

**TL;DR For Linux veterans**

Open the standalone.sh script and read through it. Basically just replacing the atmel_mxt_ts.c input driver file with one that has a few edits, and then compiling the GalliumOS kernel. Running the standalone.sh script in any WM will produce a working kernel, which will need to be selected in the GRUB Advanced menu. You can change the default entry to boot into the kernel by changing vmlinuz-linux > vmlinuz-galliumos.

Standalone script requires the following packages (that aren't included with the base install):
```
svn
rsync
wget
bc
git
alsa-utils
```

CHRX requires older GPT format, so after running CHRX, delete mmcblk0p6 and mmcblk0p7, make mmcblk0p6 1 MB unformatted with the BIOS Boot flag, and then make mmcblk0p7 ext4 and mount / to it including the boot folder.

Audio requires alsa-utils for the command to run. The included script creates the galliumos-skylake service which will run the command at boot. Try to run the following and make sure you get no output for the startup to work if you use my script, otherwise follow the audio part of the guide above:
```
sudo galliumos-init-skylake
```

The headphones and speakers scripts will switch audio output from headphones and speakers respectively. There's no jack detection, but you can use any audio type right now on the Samsung Chromebook Pro.
