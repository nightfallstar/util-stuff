#!/usr/bin/env bash

echo "Luna's Arch Installer - parte 2"
echo "[atenção] este script não instala em modo uefi!"

DA_PART=$(fdisk -l | grep da | awk '{ print $2 }' | sed 's/://g')

ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc
sed -i '/pt_BR.UTF-8 UTF-8/s/^#//g' /etc/locale.gen
sed -i '/en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen
locale-gen
echo LANG=pt_BR.UTF-8 >> /etc/locale.conf
echo KEYMAP=br-abnt2 >> /etc/vconsole.conf

clear
read -p "[atenção] qual será o nome do computador? " computername
echo $computername >> /etc/hostname

echo "127.0.0.1 localhost.localdomain localhost" >> /etc/hosts
echo "::1 localhost.localdomain localhost" >> /etc/hosts
echo "127.0.1.1 $computername.localdomain $computername" >> /etc/hosts

clear
echo "[atenção] insira a senha para usuário root a seguir."
passwd

clear
read -p "[atenção] qual será o nome do primeiro usuário? " ftusername
useradd -m -g users -G wheel $ftusername

clear
echo "[atenção] insira a senha para usuário $ftusername a seguir."
passwd $ftusername

echo "$ftusername ALL=(ALL) ALL" >> /etc/sudoers

grub-install --target=i386-pc --recheck $DA_PART
cp /usr/share/locale/en@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager

echo "[sucesso] a segunda parte foi concluída. você pode sair do chroot agora para continuar a primeira parte."