#!/bin/bash
sudo modprobe atmel_mxt_ts &
sudo reflector --protocol https --sort rate --save /etc/pacman.d/mirrorlist --verbose &
