#!/bin/sh
timedatectl set-ntp true
echo -e "n\np\n\n\n\nw" | fdisk /dev/sda
mkfs.ext4 /dev/sda1
mount /dev/sda1 /mnt
sed -i 's,arch.mirror.constant.com,mirror.isoc.org.il/pub/archlinux,g' /etc/pacman.d/mirrorlist
pacstrap /mnt base grub sudo bash-completion linux-headers xorg-fonts-100dpi xorg-server xorg-apps lxde ttf-dejavu virtualbox-guest-utils
genfstab -U /mnt >> /mnt/etc/fstab  
arch-chroot /mnt grub-install --target=i386-pc /dev/sda 
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg 
arch-chroot /mnt ln -sf /usr/share/zoneinfo/Asia/Jerusalem /etc/localtime 
arch-chroot /mnt hwclock --systohc
arch-chroot /mnt useradd -m -G wheel,video,audio vm
echo -e 'a\na' | arch-chroot /mnt passwd vm
arch-chroot /mnt sed -i 's,#en_US.UTF-8,en_US.UTF-8,g' /etc/locale.gen 
arch-chroot /mnt locale-gen
echo 'LANG=en_US.UTF-8' > /mnt/etc/locale.conf
echo 'a' > /mnt/etc/hostname
arch-chroot /mnt systemctl enable dhcpcd
arch-chroot /mnt systemctl enable lxdm
arch-chroot /mnt sed -i 's,# %wheel ALL=(ALL) ALL,%wheel ALL=(ALL) ALL,g' /etc/sudoers 
echo -e 'pacman -S --noconfirm --needed base-devel git && cd /home/vm && sudo -u vm git clone https://aur.archlinux.org/trizen.git && cd trizen && sudo -u vm makepkg -s && pacman -U --noconfirm  *.pkg.tar.xz && cd /home/vm && rm -rf trizen' > b
mv b /mnt
arch-chroot /mnt sh b
rm /mnt/b
reboot