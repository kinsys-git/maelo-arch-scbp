#!/bin/bash
#
# 	Modified - forked from https://github.com/i3-Arch/Arch-Installer
#
#		Made to install archlinux
############################################

#Version
Version="1.0-BETA"

# COLORS
red=$(tput setaf 1)
white=$(tput setaf 7)
blue=$(tput setaf 6)
yellow=$(tput setaf 3)

allvariables() {
	clear
	printf "${yellow}Choose your ${blue}hostname: ${white} "
	read hostresponse
	export hostresponse
	sleep 1

	clear
	printf "${yellow}Enter your ${blue}Time Zone${white}\n\n "
	printf "${white}(1)${yellow}for ${blue}Eastern \n "
	printf "${white}(2)${yellow}for ${blue}Central \n "
	printf "${white}(3)${yellow}for ${blue}Mountain\n "
	printf "${white}(4)${yellow}for ${blue}Pacific\n "
	printf ""
	printf "\n${white}Choice: "
	read timezoneresponse
	export timezoneresponse
	sleep 1

	clear
	printf "${yellow}Would you like to use ${blue}default locale${yellow} or choose your own? \n\n "
	printf "${yellow}Default locale is ${blue}en_US.UTF-8 UTF-8 \n\n "
	printf "${white}(Y)${yellow} for ${blue}default locale\n"
	printf "${white}(N)${yellow} for ${blue}choose your own \n"
	printf "${white}Choice: "
	read inputscuzlocale
	export inputscuzlocale
	sleep 1

	clear
	printf "\n\n${yellow}Would you like to install ${blue}Intel Graphics Drivers? "	
	printf "\n${white}[${yellow}Y${white}|${red}N${white}] "
	printf "\n\n${white}Answer: "
	read intelstuff
	export intelstuff
	if [ "$intelstuff" == Y -o "$intelstuff" == y ]
		then
		sleep 1
	else
		printf "\n\n ${yellow}Would you like to install ${blue}AMD Graphics Drivers? \n"
		printf "\n${white}[${yellow}Y${white}|${red}N${white}] "
		printf "\n\n${white}Answer: "
		read amdstuff
		export amdstuff
		if [ "$amdstuff" == Y -o "$amdstuff" == y ]
			then
			sleep 1
		fi
	fi

	clear
	printf "\033[1m\n\n ${yellow}Would you like to setup ${blue}pacaur? \n"
	printf "\033[1m\n\n ${yellow}It's an ${blue}AUR helper${yellow} with cower backend \n\n"
	printf "\033[1m\n\n${white}[${blue}Y${white}|${yellow}N${white}]\n\n"
	printf "\033[1m\n\n${white}Answer: "
	read thatquestion
	export thatquestion
	sleep 1

	clear
	printf "\n\n ${yellow} Enter the ${blue}username ${yellow}you want to create \n "
	printf "\n\n ${red} Do not enter ${yellow}Test${red} as a username.\n \033"
	printf "\n${white}Username: "
	read namebro
	if [ "$namebro" == Test ]
		then
			printf "\n${red}ERROR: ${white}Test\n"
			printf "\n${white}TRY AGAIN: "
			read namebro
	fi
	printf "\n\n ${yellow}Would you like to add this user to ${blue}sudoers?"
	printf "\n\n ${white}[${yellow}Y${white}|${red}N${white}] "
	printf "\033[1m\n\n ${white}Answer: "
	read anot
	export namebro
	export anot
	sleep 1
	
	clear
	printf "\n${yellow} CHOOSE YOUR ${blue}BOOTLOADER \n "
	printf "\n${white}(1) ${yellow}For ${blue}Grub \n "
	printf "\n${white}(2) ${yellow}For ${blue}SysLinux \n "
	printf "\n${white}CHOICE: "
	read bootloadchoice
	if [ "$bootloadchoice" -eq 1 ]
		then
		sleep 1
	elif [ "$bootloadchoice" -eq 2 ]
		then
		sleep 1
	else
		printf "${red}Not Understood ${white}|${yellow} Setting up grub by default "
	sleep 1
	fi
	export bootloadchoice
}

mirrors() {
		sed -i '1iServer = https://mirrors.kernel.org/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist
		pacman -Syy reflector --noconfirm
		echo "Updating mirrors"
		reflector --protocol https --sort rate --save /etc/pacman.d/mirrorlist --verbose
}

checkdat() {
	if [ "$(id -u)" -eq 0 ]	
		then
		printf "\033[1m\n ${yellow}Maelo ${blue}Arch\n"
		sed -i '37iILoveCandy' /etc/pacman.conf
		sleep 3
	else
		printf "${red} You Need To Be ROOT \n"
		printf "${yellow} You really need to look at the ReadMe on github "
		exit
	fi
}


disk() {
	clear
	printf " ${yellow} Listing ${blue}Block Devices${white} \n\n "
	lsblk |grep -v "loop*" |grep -v "arch_root*"
	printf " \n${yellow} Which ${blue}drive ${yellow}would you like to install to?:${yellow} i.e. ${blue}/dev/sda \n  "
	printf " ${red} WARNING:${blue} Partitioning ${yellow}and${blue} formatting ${yellow} your drive ${red}WILL ${yellow} wipe any data on the drives/partitions. "
	printf " ${red} DO NOT ${yellow}proceed if you do not know what you are doing. "
	printf " \n\n${white} Drive: "
	read yourdrive
	export yourdrive
	printf " ${yellow} \n Partition with ${blue} cfdisk ${yellow} or ${blue} fdisk ? \n "
	printf " \n${white}Tool Choice: "
	read toolchoice
	if [ "$toolchoice" == cfdisk -o "$toolchoice" == CFDISK ]
		then
		cfdisk $yourdrive
	else
		fdisk $yourdrive
	fi
}

# If you don't know how to partition properly, you don't need this OS.
ASKme() {
	clear
	printf "\n${yellow}How would you like to ${blue}partition ${yellow}your disk? \n\n\n"
	printf "  ${white}(1)${blue}boot ${yellow}and ${blue}root${yellow} partitions \n "
	printf " ${white}(2)${blue}boot, root, ${yellow}and ${blue}home${yellow} partitions \n  "
	printf " ${white}(3)${blue}boot, root, home, ${yellow}and${blue} swap${yellow} partitions \n \n "
	printf " ${white}Your Selection: "
	read thechoiceman
	export thechoiceman
}

SMALLpart() {
	printf " ${yellow}\n Enter your ${blue}Boot Partition: ${yellow}i.e. ${blue}/dev/sda1 \n "
    printf " \n${white}Boot Partition: "    
	read bootpart
	export bootpart
    	mkfs.ext4 "$bootpart" -L bootfs
	printf " ${yellow}\n Enter your ${blue}Root Partition:${yellow} i.e. ${blue}/dev/sda2 \n "
    printf " ${white}\n Root Partition: "
	read rewtpart
    	export rewtpart
    	if [ "$encRyesno" == N -o "$encRyesno" == n ]
		then
		mkfs.ext4 "$rewtpart" -L rootfs
	fi
}

HALFpart() {
	printf " ${yellow}\n Enter your ${blue}Boot Partition: ${yellow}i.e. ${blue}/dev/sda1 \n "
    printf " \n${white}Boot Partition: "    
	read bootpart
	export bootpart
    mkfs.ext4 "$bootpart" -L bootfs
	printf " ${yellow}\n Enter your ${blue}Root Partition:${yellow} i.e. ${blue}/dev/sda2 \n "
    printf " ${white}\n Root Partition: "
	read rewtpart
        export rewtpart
        if [ "$encRyesno" == N -o "$encRyesno" == n ]
		then
		mkfs.ext4 "$rewtpart" -L rootfs
	fi
	printf " ${yellow}\n Enter your ${blue}Home Partition:${yellow} i.e. ${blue}/dev/sda3 \n "
    printf " ${white}\n Home Partition: "
	read homepart
        export homepart
        if [ "$encHyesno" == N -o "$encHyesno" == n ]
		then
		mkfs.ext4 "$homepart"
	fi
}

FULLpart() {
	printf " ${yellow}\n Enter your ${blue}Boot Partition:${yellow} i.e. ${blue}/dev/sda1 \n "
    printf " ${white}\n Boot Partition: "
	read bootpart
	export bootpart
	mkfs.ext4 "$bootpart" -L bootfs
	printf " ${yellow}\n Enter your ${blue}Root Partition:${yellow} i.e. ${blue}/dev/sda2 \n "
    printf " ${white}\n Root Partition: "
	read rewtpart
	export rewtpart
   	if [ "$encRyesno" == N -o "$encRyesno" == n ]
		then
		mkfs.ext4 "$rewtpart" -L rootfs
	fi	
	printf " ${yellow}\n Enter your ${blue}Home Partition:${yellow} i.e. ${blue}/dev/sda3 \n "
    printf " ${white}\n Home Partition: "
	read homepart
	export homepart
   	if [ "$encHyesno" == N -o "$encHyesno" == n ]
		then
		mkfs.ext4 "$homepart"
	fi	
	printf " ${yellow}\n Enter your ${blue}Swap Partition:${yellow} i.e. ${blue}/dev/sda4 \n "
    printf " ${white}\n Swap Partition: "
	read swappart
	export swappart
	mkswap -U 13371337-0000-4000-0000-133700133700 $swappart
	swapon $swappart
	export FULLpart=696
}

doiencrypt() {
	clear
	printf " ${blue}Encrypt Root? \n "
	printf " ${white}[${yellow}Y${white}/${red}N${white}]: "
	read encRyesno
	export encRyesno
	if [ "$encRyesno" == Y -o "$encRyesno" == y ]
		then
		printf "\n\n Root will be encrypted! \n"
	elif [ "$encRyesno" == N -o "$encRyesno" == n ]
		then
		printf "\n\n Not Encrypting: Moving on \n"
	else
		printf "\n\n Not Encrypting: 'Y' or 'N' not entered \n\n"
	fi
	if [ "$thechoiceman" -eq 2 -o "$thechoiceman" -eq 3 ]
		then
		printf "${blue} Encrypt Home? \n "
	printf " ${white}[${yellow}Y${white}/${red}N${white}]: "
		read encHyesno
		export encHyesno
		if [ "$encHyesno" == Y -o "$encHyesno" == y ]
			then
			printf "\n\n Home will be encrypted! \n"
		elif [ "$encHyesno" == N -o "$encHyesno" == n ]
			then
			printf "\n Not Encrypting: Moving on\n\n"
		else
			printf "\n Not encrypting: 'Y' or 'N' not entered \n\n"
		fi
	fi
	if [ "$thechoiceman" -eq 3 ]
		then
		printf "${blue} Encrypt Swap? \n "
		printf " ${white}[${yellow}Y${white}/${red}N${white}]: "
		read encSyesno
		export encSyesno
		if [ "$encSyesno" == Y -o "$encSyesno" == y ]
			then
			printf "${blue} Swap will be encrypted! \n "
		elif [ "$encSyesno" == N -o "$encSyesno" == n ]
			then
			printf "\n Not Encrypting: Moving on \n\n"
		else
			printf "\n Not Encrypting: 'Y' or 'N' not entered \n\n"
		fi
	fi
}


luksencrypt() {
	if [ "$encRyesno" == Y -o "$encRyesno" == y ]
		then
		cryptsetup -y -v -s 512 luksFormat $rewtpart
		cryptsetup open $rewtpart cryptrewt
		mkfs -t ext4 /dev/mapper/cryptrewt
	fi
	if [ "$encHyesno" == Y -o "$encHyesno" == y ]
		then
		cryptsetup -y -v -s 512 luksFormat $homepart
		cryptsetup open $homepart crypthome
		mkfs -t ext4 /dev/mapper/crypthome
	fi
}

pkgmntchroot() {
	clear
	printf " ${yellow} Setting up ${blue}install... ${white}\n "
	if [ "$encRyesno" == Y -o "$encRyesno" == y ]
		then
		mount -t ext4 /dev/mapper/cryptrewt /mnt
	else
		mount $rewtpart /mnt
	fi
	mkdir /mnt/home
	mkdir /mnt/boot
	mkdir -pv /mnt/var/lib/pacman
	mount $bootpart /mnt/boot
	if [ "$encHyesno" == Y -o "$encHyesno" == y ]
		then
		mount -t ext4 /dev/mapper/crypthome /mnt/home
	fi
	if [ "$thechoiceman" -eq 2 -o "$thechoiceman" -eq 3 ]
		then
		if [ "$encHyesno" != Y -o "$encHyesno" != y ]
			then
			mount $homepart /mnt/home
		fi
	fi
	pacstrap /mnt base base-devel grub os-prober rsync wget wpa_supplicant
	rsync -rav /etc/pacman.d/gnupg/ /mnt/etc/pacman.d/gnupg/
	if [ "$encRyesno" == Y -o "$encRyesno" == y ]
	   then
	   sed -i 's/block filesystems/block keymap encrypt filesystems/g' /mnt/etc/mkinitcpio.conf
	fi
	genfstab -p -U /mnt >> /mnt/etc/fstab
}

CALLpart() {
	if [ "$thechoiceman" -eq 3 ]
    	   then
    	   FULLpart
	elif [ "$thechoiceman" -eq 2 ]
	   then
	   HALFpart
	elif [ "$thechoiceman" -eq 1 ]
	   then
	   SMALLpart
	else
	    printf "${red}\n\nUnkown Selection\n\n"
	    printf "${yellow}\n\Only Setting up ${blue}BOOT ${yellow}and ${blue}ROOT\n"
	    sleep 3
	    SMALLpart
	fi
}


sixfour() {
	if [ "$(uname -m)" = x86_64 ]
		then
		sed -i'' '93,94 s/^#//' /mnt/etc/pacman.conf
	fi
}

candy() { 
		sed -i '37iILoveCandy' /mnt/etc/pacman.conf
}

postsetup() {
	cd /mnt/root
	wget https://raw.githubusercontent.com/maelodic/maelo-arch-install-kde/master/chrootsetup.sh
	chmod +x chrootsetup.sh
	arch-chroot /mnt /bin/bash /root/chrootsetup.sh
}

main() {
	checkdat			## Check if ROOT
	allvariables		## Gains all user input early
	ASKme				## ASK NUMBER OF PARTITIONS
	doiencrypt			## Do I Encrypt?
	disk 				## PARTITION WITH CFDISK or FDISK
	CALLpart 	 		## CALL PARTITIONING IF STATEMENT
	luksencrypt			## Setup LUKS
	mirrors				## Sets up optimal mirrors for downloading.
	pkgmntchroot 	 	## Setup packages and mounts
	sixfour				## If 64bit uncomment multilib
	candy				## Choose if you want pacman art when updating
	postsetup			## Runs additional setup with chroot hook
	umount -R /mnt	2> /dev/null	## UNMOUNT 
	clear
	printf "\n${yellow} All ${blue}done! \n "
	printf "\n${white} Reboot now? (y/N) \n "
	read rebchoice
	if [ "$rebchoice" == Y -o "$rebchoice" == y ]
		then
		reboot now
	fi 

}

main

# EOF
