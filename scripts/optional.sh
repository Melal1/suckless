# my home dirs & device config

echo -e "
-------------------------------------------------------------------------
                       Editing XDG user directories 
-------------------------------------------------------------------------
"
rm $HOME/.config/user-dirs.dirs
cat << 'xDirs' > "$HOME/.config/user-dirs.dirs"
XDG_DOWNLOAD_DIR="$HOME/Downloads"
XDG_REPO_DIR="$HOME/repo"
XDG_DOCUMENTS_DIR="$HOME/Documents"
XDG_AUDIO_DIR="$HOME/Audio"
XDG_PICTURES_DIR="$HOME/Pictures"
XDG_VIDEOS_DIR="$HOME/Videos"
xDirs

xdg-user-dirs-update

cat << 'EOF' >  "$HOME/10-monitor.conf"
Section "Monitor"
    Identifier   "DisplayPort-0"
        Option  "PreferredMode"  "2560x1440_180"
        Option  "RightOf" "HDMI-A-0"
	Modeline "2560x1440_180"  706.00  2560 2568 2600 2670  1440 1443 1448 1470 +hsync -vsync
	Option 	"Primary" "true"
EndSection

Section "Monitor"
    Identifier   "HDMI-A-0"
        Option  "LeftOF" "DisplayPort-0"
	Option	"Rotate" "left"
	Modeline "1920x1080_75"  174.50  1920 1968 2000 2080  1080 1083 1088 1119 +hsync -vsync
        Option  "PreferredMode"  "1920x1080_75"
EndSection
EOF

cat << 'EOF1' > "$HOME/20-amdgpu.conf" 
Section "Device"
        Identifier      "AMD Graphics"
        Driver          "amdgpu"
        Option          "TearFree" "true"
EndSection
EOF1


sudo mv "$HOME/20-amdgpu.conf" "$HOME/10-monitor.conf" -t "/etc/X11/xorg.conf.d/"
