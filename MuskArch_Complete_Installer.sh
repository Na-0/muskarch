cat > MuskArch_Complete_Installer.sh << 'ENDOFSCRIPT'
#!/bin/bash
# ============================================================
# MuskArch v2.0 - Complete Automated Installer (NVMe版)
# ============================================================

set -e

echo "🚀 MuskArch v2.0 インストール開始..."

# マウント確認
if ! mountpoint -q /mnt; then
    echo "❌ /mnt がマウントされていません！"
    echo "以下のコマンドを実行してください："
    echo "mount /dev/nvme0n1p2 /mnt"
    echo "mkdir -p /mnt/boot"
    echo "mount /dev/nvme0n1p1 /mnt/boot"
    exit 1
fi

echo "✅ マウント確認OK"

# パッケージインストール
echo "📦 ベースシステム + Elon必須ツールをインストール中..."
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

# fstab生成
genfstab -U /mnt >> /mnt/etc/fstab

# chrootで設定
echo "🔧 設定を適用中..."
arch-chroot /mnt /bin/bash << 'CHROOT'
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

cat > /boot/loader/entries/muskarch.conf << 'EOF'
title   MuskArch v2.0
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=UUID=$(blkid -s UUID -o value /dev/nvme0n1p2) rw
EOF

mkdir -p /home/elon/.config
cat > /home/elon/.config/starship.toml << 'EOF'
format = "[username][ directory][git_branch][character]"
[username]
style_user = "bold cyan"
show_always = true
[directory]
style = "bold blue"
[git_branch]
symbol = "🚀 "
style = "bold purple"
[character]
success_symbol = "[➜](bold green)"
error_symbol = "[✗](bold red)"
EOF

mkdir -p /home/elon/.config/hypr
cat > /home/elon/.config/hypr/hyprland.conf << 'EOF'
monitor=,preferred,auto,1
input { kb_layout = us follow_mouse = 1 }
general { gaps_in = 5 gaps_out = 10 border_size = 2 col.active_border = rgba(00f5ffaa) }
decoration { rounding = 8 blur { enabled = true size = 4 } }
bind = SUPER, Return, exec, kitty
bind = SUPER, Q, killactive,
bind = SUPER, D, exec, wofi --show drun
bind = SUPER, F, fullscreen,
workspace = 1, name:Work
workspace = 2, name:Code
workspace = 3, name:xAI
workspace = 4, name:SpaceX
workspace = 5, name:Memes
EOF

chown -R elon:elon /home/elon
CHROOT

echo ""
echo "🎉 MuskArch v2.0 インストール完了！"
echo "次のコマンドを実行してください："
echo "umount -R /mnt && reboot"
ENDOFSCRIPT