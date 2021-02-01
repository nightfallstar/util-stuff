#!/usr/bin/env bash

echo "Luna's Arch Installer"
echo "[atenção] este script não instala em modo uefi!"

ping -c 4 google.com
if ! [ $? = 0 ]
then
    echo "[erro] conecte-se a internet para rodar este script!"
    exit
fi

timedatectl set-ntp true

clear
read -p "[atenção] prestes a fazer tabela de partições. prosseguir? [s/N]: " ptablego
if ! [ $ptablego = 's' ] && ! [ $ptablego = 'S' ]
then
    echo "[atenção] abortando..."
    exit
fi

DA_PART=$(fdisk -l | grep da | awk '{ print $2 }' | sed 's/://g')

sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk $DA_PART
    o
    n
    p
    1

    +512M
    n
    p
    2

    +8G
    t
    2
    swap
    n
    p
    3


    a
    1
    w
    q
EOF

clear

echo "== TABELA DE PARTIÇÕES ==\n\n$(fdisk -l)" | less
read -p "[atenção] prestes a formatar partições. prosseguir? [s/N]: " formatptablego
if ! [ $formatptablego = 's' ] && ! [ $formatptablego = 'S' ]
then
    echo "[atenção] abortando..."
    exit
fi

mkfs.fat -F32 $(echo "$DA_PART 1" | sed 's/ //g')
mkswap $(echo "$DA_PART 2" | sed 's/ //g')
mkfs.ext4 $(echo "$DA_PART 3" | sed 's/ //g')

swapon $(echo "$DA_PART 2" | sed 's/ //g')

clear
read -p "[atenção] prestes a montar partições em /mnt. prosseguir? [s/N]: " mountptablego
if ! [ $mountptablego = 's' ] && ! [ $mountptablego = 'S' ]
then
    echo "[atenção] abortando..."
    exit
fi

mount $(echo "$DA_PART 3" | sed 's/ //g') /mnt
mkdir /mnt/boot
mount $(echo "$DA_PART 1" | sed 's/ //g') /mnt/boot

pacstrap /mnt base base-devel linux linux-firmware man-db man-pages texinfo zsh dosfstools os-prober mtools network-manager-applet networkmanager wpa_supplicant wireless_tools dialog sudo grub iw
genfstab -U /mnt >> /mnt/etc/fstab

read -p "[atenção] prestes a fazer chroot no sistema, lembre-se de rodar post_install.sh quando estiver lá. prosseguir? [s/N]: " chrootgo
if ! [ $chrootgo = 's' ] && ! [ $chrootgo = 'S' ]
then
    echo "[atenção] abortando..."
    exit
fi

cp -rfv post_install.sh /mnt/root/
chmod a+x /mnt/root/post_install.sh
arch-chroot /mnt /bin/bash

echo "[sucesso] se post_install.sh resultou em sucesso, então o sistema já deve estar pronto para uso."
read -p "[atenção] prestes a reiniciar o máquina. prosseguir? [s/N]: " rebootgo
if ! [ $rebootgo = 's' ] && ! [ $rebootgo = 'S' ]
then
    echo "[atenção] abortando..."
    exit
fi
reboot