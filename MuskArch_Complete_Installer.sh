cat > MuskArch_Complete_Installer.sh << 'EOF'
#!/bin/bash
set -e
echo "MuskArch v2.0 インストール開始..."

if ! mountpoint -q /mnt; then
    echo "エラー: /mnt がマウントされていません"
    exit 1
fi

pacstrap /mnt base linux linux-firmware base-devel git vim neovim zsh networkmanager sudo hyprland waybar wofi kitty

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt /bin/bash << 'CHROOT'
ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "muskarch" > /etc/hostname
useradd -m -G wheel -s /bin/zsh elon
echo "elon:tesla123" | chpasswd
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
systemctl enable NetworkManager
bootctl install
cat > /boot/loader/entries/muskarch.conf << 'BOOT'
title   MuskArch v2.0
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=UUID=$(blkid -s UUID -o value /dev/nvme0n1p2) rw
BOOT
CHROOT

echo "インストール完了！ umount -R /mnt && reboot"
EOF

chmod +x MuskArch_Complete_Installer.sh
echo "スクリプト作成完了！"