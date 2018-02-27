#!/bin/bash

scbp() {
        if [[ $EUID -ne 0 ]]; then
   		echo "This script must be run as root" 
		exit 1
	fi
	mkdir /root/tmp
	cd /root/tmp
	git clone -b braswell https://github.com/maelodic/maelo-arch-scbp/
	cd /root/tmp/maelo-arch-scbp
	chmod +x usr/bin/*
        rsync -a usr/ /usr/
        rsync -a etc/ /etc/
        rsync -a lib/ /lib/
	git clone https://github.com/galliumos/linux
	wget -P /root/tmp/ https://raw.githubusercontent.com/maelodic/maelo-arch-scbp/master/galliumos.preset
	cp /root/tmp/galliumos.preset /etc/mkinitcpio.d/galliumos.preset
	cd /root/tmp/linux
	make localmodconfig
	make -j4
	make -j4 modules_install
	make -j4 install
	cp /root/tmp/linux/arch/x86/boot/bz* /boot/vmlinuz-galliumos
        systemctl enable galliumos-braswell
        mkinitcpio -p galliumos
        grub-mkconfig -o /boot/grub/grub.cfg
        cd ..
        rm -rf /root/tmp/
}

main() {
	scbp
}

main

#EOF
