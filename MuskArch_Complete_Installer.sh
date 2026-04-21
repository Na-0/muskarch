# 1. 既存のスクリプトを削除
rm -f MuskArch_Complete_Installer.sh

# 2. neofetchを削除した修正版スクリプトを作成
cat > MuskArch_Complete_Installer.sh << 'ENDOFSCRIPT'
#!/bin/bash
# ============================================================
# MuskArch v2.1 - Fixed Version (neofetch removed)
# ============================================================

set -e

echo "🚀 MuskArch v2.1 Complete Installer Starting..."
echo "Target: /dev/nvme0n1 (EFI=p1, Root=p2)"
echo ""

if ! mountpoint -q /mnt; then
    echo "❌ ERROR: /mnt is not mounted!"
    exit 1
fi

echo "✅ Mounts verified."

echo "📦 Installing base system + Elon essentials..."
pacstrap /mnt \
    base linux linux-firmware \
    base-devel git vim neovim zsh \
    networkmanager sudo \
    hyprland waybar wofi \
    kitty alacritty \
    firefox-developer-edition \
    fastfetch htop btop \
    ripgrep fd exa bat \
    starship zoxide fzf \
    docker docker-compose \
    code

echo "📝 Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

echo "🔍 Capturing root partition UUID..."
ROOT_UUID=$(blkid -s UUID -o value /dev/nvme0n1p2)
echo "Root UUID: $ROOT_UUID"

echo "🔧 Entering chroot..."
arch-chroot /mnt /bin/bash << 'CHROOT_EOF'
ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "muskarch" > /etc/hostname
useradd -m -G wheel,audio,video,docker -s /bin/zsh elon
echo "elon:tesla123" | chpasswd
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
systemctl enable NetworkManager
systemctl enable docker
bootctl install
echo "✅ Chroot done!"
CHROOT_EOF

echo "📝 Creating bootloader entry..."
mkdir -p /mnt/boot/loader/entries
cat > /mnt/boot/loader/entries/muskarch.conf << EOF
title   MuskArch v2.1
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=UUID=${ROOT_UUID} rw
EOF

echo ""
echo "🎉 MuskArch v2.1 installation COMPLETE!"
echo "Next: umount -R /mnt && reboot"
ENDOFSCRIPT

chmod +x MuskArch_Complete_Installer.sh
./MuskArch_Complete_Installer.sh