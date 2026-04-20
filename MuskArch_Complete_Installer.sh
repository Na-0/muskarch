# 1. 壊れたファイルを削除
rm -f MuskArch_Complete_Installer.sh

# 2. よりシンプルなバージョンのスクリプトを作成
cat > MuskArch_Complete_Installer.sh << 'EOF'
#!/bin/bash
set -e
echo "🚀 MuskArch v2.0 インストール開始..."

if ! mountpoint -q /mnt; then
    echo "❌ /mnt がマウントされていません"
    exit 1
fi

pacstrap /mnt base linux linux-firmware base-devel git vim neovim zsh networkmanager sudo \
    hyprland waybar wofi kitty alacritty firefox-developer-edition neofetch htop btop \
    ripgrep fd exa bat starship zoxide fzf docker docker-compose code

genfstab -U /mnt >> /mnt/etc/fstab

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
systemctl enable NetworkManager docker
bootctl install
cat > /boot/loader/entries/muskarch.conf << 'BOOT'
title   MuskArch v2.0
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=UUID=$(blkid -s UUID -o value /dev/nvme0n1p2) rw
BOOT
mkdir -p /home/elon/.config
cat > /home/elon/.config/starship.toml << 'STAR'
format = "[username][ directory][git_branch][character]"
[username] style_user = "bold cyan" show_always = true
[directory] style = "bold blue"
[git_branch] symbol = "🚀 " style = "bold purple"
[character] success_symbol = "[➜](bold green)" error_symbol = "[✗](bold red)"
STAR
mkdir -p /home/elon/.config/hypr
cat > /home/elon/.config/hypr/hyprland.conf << 'HYPR'
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
HYPR
chown -R elon:elon /home/elon
CHROOT

echo "🎉 インストール完了！ umount -R /mnt && reboot"
EOF

# 3. 実行権限を付ける
chmod +x MuskArch_Complete_Installer.sh

echo "✅ スクリプト作成完了！"
echo "今すぐ実行: ./MuskArch_Complete_Installer.sh"