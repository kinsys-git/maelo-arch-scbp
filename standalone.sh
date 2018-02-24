#!/bin/bash

scbp() {
        if [[ $EUID -ne 0 ]]; then
   		echo "This script must be run as root" 
		exit 1
	fi
	
	cd /root
        mkdir tmp/
        cd tmp/
        svn checkout https://github.com/galliumos/galliumos-skylake/trunk/usr/
        svn checkout https://github.com/galliumos/galliumos-skylake/trunk/etc/
        svn checkout https://github.com/galliumos/galliumos-skylake/trunk/lib/
        rsync -a usr/ /usr/
        rsync -a etc/ /etc/
        rsync -a lib/ /lib/
	ln -s /usr/share/alsa/ucm/sklnau8825adi /usr/share/alsa/ucm/Google-Caroline-1.0-Caroline
	ln -s /usr/share/alsa/ucm/sklnau8825adi.conf /usr/share/alsa/ucm/Google-Caroline-1.0-Caroline/Google-Caroline-1.0-Caroline.conf
	git clone https://github.com/galliumos/linux
	wget https://raw.githubusercontent.com/maelodic/maelo-arch-scbp/master/atmel_mxt_ts.c
        cp atmel_mxt_ts.c linux/drivers/touchpad/atmel_mxt_ts.c
        wget https://raw.githubusercontent.com/maelodic/maelo-arch-scbp/master/galliumos-init-skylake
	chmod +x galliumos-init-skylake
	wget https://raw.githubusercontent.com/maelodic/maelo-arch-scbp/master/galliumos.preset
	cp galliumos.preset /etc/mkinitcpio.d/galliumos.preset
	cp galliumos-init-skylake /usr/bin/galliumos-init-skylake
	cd linux
	make localmodconfig -j4
	make -j4
	make -j4 modules_install
	make -j4 install
	cp arch/x86/boot/bzimage /boot/vmlinuz-galliumos
        systemctl enable galliumos-skylake
        mkinitcpio -p galliumos
        grub-mkconfig -o /boot/grub/grub.cfg
        cd ..
        rm -rf tmp/
}

main() {
	scbp
}

main

#EOF
