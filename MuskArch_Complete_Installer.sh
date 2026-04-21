cat > MuskArch_Complete_Installer.sh << 'ENDOFSCRIPT'
#!/bin/bash
# ============================================================
# MuskArch v2.0 - Complete Automated Installer
# For: NVMe (nvme0n1p1 = EFI, nvme0n1p2 = Root)
# "Built for maximum efficiency. Elon approved."
# ============================================================

set -e

echo "🚀 MuskArch v2.0 Complete Installer Starting..."
echo "Target: /dev/nvme0n1 (EFI=p1, Root=p2)"
echo ""

# === 1. Verify mounts ===
if ! mountpoint -q /mnt; then
    echo "❌ ERROR: /mnt is not mounted!"
    echo "Please run these commands first:"
    echo "  mount /dev/nvme0n1p2 /mnt"
    echo "  mount /dev/nvme0n1p1 /mnt/boot"
    exit 1
fi

echo "✅ Mounts verified."

# === 2. Install base system + essentials ===
echo "📦 Installing base system + Elon essentials..."
pacstrap /mnt \
    base linux linux-firmware \
    base-devel git vim neovim zsh \
    networkmanager sudo \
    hyprland waybar wofi \
    kitty alacritty \
    firefox-developer-edition \
    neofetch htop btop \
    ripgrep fd exa bat \
    starship zoxide fzf \
    docker docker-compose \
    code

# === 3. Generate fstab ===
echo "📝 Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

# === 4. Capture UUID for bootloader (BEFORE chroot) ===
echo "🔍 Capturing root partition UUID..."
ROOT_UUID=$(blkid -s UUID -o value /dev/nvme0n1p2)
echo "Root UUID: $ROOT_UUID"

# === 5. Chroot and configure (no bootloader entry yet) ===
echo "🔧 Entering chroot and applying Elon configuration..."
arch-chroot /mnt /bin/bash << 'CHROOT_EOF'

# Timezone
ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
hwclock --systohc

# Locale
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Hostname
echo "muskarch" > /etc/hostname
echo "127.0.0.1   localhost" >> /etc/hosts
echo "::1         localhost" >> /etc/hosts
echo "127.0.1.1   muskarch.localdomain muskarch" >> /etc/hosts

# Create Elon user
useradd -m -G wheel,audio,video,docker -s /bin/zsh elon
echo "elon:tesla123" | chpasswd
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# Enable services
systemctl enable NetworkManager
systemctl enable docker

# Bootloader (systemd-boot) - install only
bootctl install

echo "✅ Chroot configuration complete!"
CHROOT_EOF

# === 6. Create bootloader entry from HOST (with correct UUID) ===
echo "📝 Creating systemd-boot entry with correct UUID..."
mkdir -p /mnt/boot/loader/entries
cat > /mnt/boot/loader/entries/muskarch.conf << EOF
title   MuskArch v2.0
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=UUID=${ROOT_UUID} rw
EOF

echo "✅ Bootloader entry created successfully!"

echo ""
echo "🎉 MuskArch v2.0 installation COMPLETE!"
echo ""
echo "Next steps:"
echo "1. umount -R /mnt"
echo "2. reboot"
echo "3. Login as 'elon' (password: tesla123)"
echo ""
echo "Welcome to the future. Now go build something that matters."
echo " - Elon Musk (and your new OS)"
ENDOFSCRIPT