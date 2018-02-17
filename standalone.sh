#!/bin/bash

scbp() {
        cd /root
        mkdir tmp/
        cd tmp/
        svn checkout https://github.com/maelodic/maelo-arch-scbp/trunk/usr/
        svn checkout https://github.com/maelodic/maelo-arch-scbp/trunk/etc/
        svn checkout https://github.com/maelodic/maelo-arch-scbp/trunk/lib/
        cp -RT usr/ /usr/
        cp -RT etc/ /etc/
        cp -RT lib/ /lib/
	git clone https://github.com/galliumos/linux
	wget https://raw.githubusercontent.com/maelodic/maelo-arch-scbp/master/atmel_mxt_ts.c
        cp atmel_mxt_ts.c linux/drivers/touchpad/atmel_mxt_ts.c
	cd linux
	yes "" | make localmodconfig >/dev/null
	make
	make install
	make modules_install
	cp arch/x86/boot/bzimage /boot/vmlinuz
	cp arch/x86/boot/bzimage /boot/vmlinuz-linux
        systemctl enable caroline-audio
        mkinitcpio -p linux
        grub-mkconfig -o /boot/grub/grub.cfg
        cd ..
        rm -rf tmp/
        pacaur -S xkeyboard-config-chromebook --noconfirm --noedit	
}

main() {
	scbp
}

#EOF
