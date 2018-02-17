#!/bin/bash

# COLORS
red=$(tput setaf 1)
white=$(tput setaf 7)
blue=$(tput setaf 6)
yellow=$(tput setaf 3)

# Set Your Hostname
hostname() {
	echo "$hostresponse" > /etc/hostname
}

# Set Time Zone
timelocale() {
	if [  "$timezoneresponse" -eq 1 ]
		then
		$(ln -s /usr/share/zoneinfo/US/Eastern /etc/localtime) ;
	elif [ "$timezoneresponse" -eq 2 ]
		then
		$(ln -s /usr/share/zoneinfo/US/Central /etc/localtime) ;
	elif [ "$timezoneresponse" -eq 3 ]
		then
		$(ln -s /usr/share/zoneinfo/US/Mountain /etc/localtime) ;
	elif	[ "$timezoneresponse" -eq 4 ]
		then
		$( ln -s /usr/share/zoneinfo/US/Pacific /etc/localtime) ;
	else
		sleep 1
	fi

	if [ "$inputscuzlocale" == y -o "$inputscuzlocale" == Y ]
		then
		echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
	else
		clear
		printf "${yellow}Time to setup a ${blue}locale. ${yellow}Press any key to continue."
		read
		nano /etc/locale.gen
	fi
	printf "${blue}NOW GENERATING LOCALES...\n "
	locale-gen
}

encrypthomeswap() {
	if [ "$encHyesno" == Y -o "$encHyesno" == y ]
		then
		echo "crypthome   ${homepart}" >> /etc/crypttab
	fi
	if [ "$FULLpart" -eq 696 ]
		then
		if [ "$encSyesno" == Y -o "$encSyesno" == y ]
			then
			echo "swap	$swappart	/dev/urandom	swap,cipher=aes-xts-plain64,size=256" >> /etc/crypttab
			sed -i '14,16d' /etc/fstab
			echo "/dev/mapper/swap	none	swap	defaults	0 0" >> /etc/fstab
		fi
	fi

}

# Install Grub
grubinst() {										
	if  [ "$encRyesno" == Y -o "$encRyesno" == y ]
		then
		sed -i "s|quiet|cryptdevice=${rewtpart}:cryptrewt root=/dev/mapper/cryptrewt|" /etc/default/grub
	    	echo "GRUB_ENABLE_CRYPTODISK=y" >> /etc/default/grub
		mkinitcpio -p linux
	fi
	grub-install --target=i386-pc $yourdrive
	sleep 5
	grub-mkconfig -o /boot/grub/grub.cfg
	sed -i '118,152d' /boot/grub/grub.cfg
}

# Install Syslinux
syslinuxinst() {
	pacman -Syy syslinux --noconfirm
	if [ "$encRyesno" == Y -o "$encRyesno" == y ]
		then
		sed -i '54s@.*@	APPEND cryptdevice='"$rewtpart"':cryptrewt root=/dev/mapper/cryptrewt rw @' /boot/syslinux/syslinux.cfg	
		mkinitcpio -p linux
	else
		sed -i '54s@.*@  APPEND root='"$rewtpart"' rw @' /boot/syslinux/syslinux.cfg
	fi	
	sed -i '57,61d' /boot/syslinux/syslinux.cfg
	syslinux-install_update -i -a -m
}

# Choose Your Bootloader
BOOTload() {
	if [ "$bootloadchoice" -eq 1 ]
		then
		grubinst
	elif [ "$bootloadchoice" -eq 2 ]
		then
		syslinuxinst
	else
		grubinst
	fi
}	

localeStuff() {
	locale > /etc/locale.conf  # set systemwide locale's
}

intelinside() {
	if [ "$intelstuff" == Y -o "$intelstuff" == y ]
		then
		pacman -Syy intel-dri xf86-video-intel --noconfirm --needed
	
	else
		if [ "$amdstuff" == Y -o "$amdstuff" == y ]
			then
			pacman -Syy ati-dri xf86-video-ati --noconfirm --needed
		fi
	fi
}

usersetup() {
		$(useradd -m -G adm,disk,audio,network,video "$namebro")
		if [ "$anot" == Y -o "$anot" == y -o "$anot" == yes -o "$anot" == YES ]
			then
			printf "$namebro ALL=(ALL) ALL" >> /etc/sudoers	
			printf "\n$namebro ALL=(ALL) NOPASSWD: /usr/bin/reflector\n" >> /etc/sudoers
		fi
}

bobthebuilder() {  
	if [ "$thatquestion" == Y -o "$thatquestion" == y ]
		then
		printf "\033[1m\n\n ${blue}Setting up pacaur for future use \n\n"
		pacman -Syy expac yajl git perl-error --noconfirm --needed
		su "$namebro" -c "mkdir /home/$namebro/build-dir"
		su "$namebro" -c "cd /home/$namebro/build-dir && wget https://aur.archlinux.org/cgit/aur.git/snapshot/cower.tar.gz && tar xzvf cower.tar.gz"
		su "$namebro" -c "cd /home/$namebro/build-dir/cower && makepkg -s --skippgpcheck"
		pacman -U /home/"$namebro"/build-dir/cower/*.xz --noconfirm
		su "$namebro" -c "cd /home/$namebro/build-dir && wget https://aur.archlinux.org/cgit/aur.git/snapshot/pacaur.tar.gz && tar xzvf pacaur.tar.gz"
		su "$namebro" -c "cd /home/$namebro/build-dir/pacaur && makepkg -s"
		pacman -U /home/"$namebro"/build-dir/pacaur/*.xz --noconfirm
		rm -rf /home/$namebro/build-dir
	else
		sleep 2
	fi
}

setupskel() {
	pacman -Syy svn --noconfirm --needed
	cd /etc/skel
	svn checkout https://github.com/maelodic/maelo-arch-install-kde/trunk/dotfiles
	ln -s /etc/skel/dotfiles/config /etc/skel/.config
	ln -s /etc/skel/dotfiles/local /etc/skel/.local
	ln -s /etc/skel/dotfiles/kde4 /etc/skel/.kde4
}	

installsoftware() {
	pacman -Syy dmidecode reflector packagekit-qt5 python-pyqt5 qt5-declarative git python-dbus python-yaml wmctrl xdotool python-gobject dialog plasma-meta kde-applications-meta sddm xorg-server xorg-font-util xorg-xinit xterm ttf-dejavu xf86-video-vesa xf86-input-synaptics firefox vim plasma-nm latte-dock plasma5-applets-active-window-control qt5-graphicaleffects --noconfirm --needed
	systemctl enable sddm.service
	systemctl enable NetworkManager
}

userandrootpasswd() {
		clear
		printf "\n\n ${yellow} Set a Password for${blue} $namebro${white}: \n\n "
		passwd "$namebro"
		clear
		printf "\n\n ${yellow} Set a Password for${blue} root${white}: \n\n "
		passwd
}

scbp() {
	cd /root
	mkdir tmp/
	cd tmp/
	svn checkout https://github.com/maelodic/maelo-arch-scbp/trunk/usr/
	svn checkout https://github.com/maelodic/maelo-arch-scbp/trunk/boot/
	svn checkout https://github.com/maelodic/maelo-arch-scbp/trunk/etc/
	svn checkout https://github.com/maelodic/maelo-arch-scbp/trunk/lib/
	cp -RT usr/ /usr/
	cp -RT boot/ /boot/
	cp -RT etc/ /etc/
	cp -RT lib/ /lib/
	pacaur -S xkeyboard-config-chromebook --noconfirm --noedit
	systemctl enable caroline-audio
	mkinitcpio -p linux
	grub-mkconfig -o /boot/grub/grub.cfg
	cd ..
	rm -rf tmp/
}

# Main Function
main() {
	hostname			#Set hostname
	timelocale			#Set time locale
	encrypthomeswap		#Encrypt swap if specified
	BOOTload			#Set bootloader
	localeStuff			#Copy local file over
	intelinside			#Install visual drivers
	setupskel			#Set up UI customizations
	usersetup			#Set up the user
	bobthebuilder		#Build out pacaur
	installsoftware		#Install all software
	scbp			#Samsung Chromebook Pro specific
	userandrootpasswd	#Set the user and root passwords
	rm chrootsetup.sh
}

main

#EOF
