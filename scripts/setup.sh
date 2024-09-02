#!/bin/bash

set -e  # Exit on command failure

# Source configuration from Assest.conf
source "$HOME/suckless/Assest.conf"
# Create the repository folder
mkdir -p "$HOME/repo/"

# Enable Paralleldownloads and Colors 
sudo sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
sudo sed -i 's/^#Color/Color/' /etc/pacman.conf

# Update system packages
sudo pacman -Syyu --noconfirm --needed

echo -e "$Banner"

# Function to determine what type of terminal to download
fn_vr() {
    echo -ne "\nAre you on a virtual machine? (y/N): "
    read -r VIR

    if [[ "$VIR" =~ ^[yY]$ ]]; then
        # Modify dwm config to use rxvt-unicode if on a VM (don't use gpu ac)
        sed -i 's/static const char \*termcmd\[\]  = { "", NULL };/static const char \*termcmd\[\]  = { "urxvt", NULL };/' "$HOME/suckless/dwm/config.def.h"
        DPN+=("rxvt-unicode")
    elif [[ "$VIR" =~ ^[nN]$ || -z "$VIR" ]]; then
        # Modify dwm config to use kitty if not on a VM
        sed -i 's/static const char \*termcmd\[\]  = { "", NULL };/static const char \*termcmd\[\]  = { "kitty", NULL };/' "$HOME/suckless/dwm/config.def.h"
        DPN+=("kitty")
    else
        echo -e "Invalid input. Please enter 'y' for yes or 'n' for no.\n"
        fn_vr 
    fi
}

fn_vr

sleep 1

# Alert about removing the setup script from archinstall script
echo -e "Removing 2-Setup script..."

# Function to set up Git and generate an SSH key
fn_ssh() {
    echo -ne "\nPlease enter a valid email: "
    read -r EMAIL

    # Validate email address format
    local regex="^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$"

    if [[ $EMAIL =~ $regex ]]; then
        echo -e "\nYour email address is '${EMAIL}'."
        echo -n "Is that okay? (y/n): "
        read -r confirmation

        # Confirm email address and proceed
        if [[ $confirmation =~ ^[yY]$ ]]; then
            echo -e "\nEmail confirmed: ${EMAIL}"
            # Generate SSH key
            ssh-keygen -t ed25519 -f "${ssh_PATH}/id_ed25519" -C "${EMAIL}" -q -N ""
            if [[ $? -ne 0 ]]; then
                echo "Error generating SSH key."
                exit 1
            fi
            echo -e "\nSSH key generated. Please copy it from ~/.ssh/ and add it to GitHub."
            # Configure Git with the user's details
            git config --global user.name "$(whoami)"
            git config --global user.email "${EMAIL}"
            # Start the SSH agent
            eval "$(ssh-agent -s)"
            sleep 1
        elif [[ $confirmation =~ ^[nN]$ ]]; then
            echo -e "\nOkay. Please enter your email again."
            fn_ssh  # Recursively prompt for a valid email
        else
            echo -e "Invalid input. Please enter 'y' for yes or 'n' for no.\n"
            fn_ssh  # Recursively prompt for a valid response
        fi
    else
        echo -ne "\nInvalid email address.\nPlease try again.\n"
        fn_ssh  # Recursively prompt for a valid email
    fi
}

echo -e "
-------------------------------------------------------------------------
                       Installing Display Server
-------------------------------------------------------------------------
"

# Install display server packages
PKG=("xorg" "xorg-xinit")

for pkg in "${PKG[@]}"; do
    echo "Installing $pkg..."
    sudo pacman -S "$pkg" --noconfirm --needed
done

echo -e "
-------------------------------------------------------------------------
                       Installing AUR Helper
-------------------------------------------------------------------------
"

fn_aur() {
    while true; do
        echo -ne "Do you want to install the paru-bin version? (Y/n): "
        read AURn

        if [[ "$AURn" =~ ^[yY]$ || -z "$AURn" ]]; then 
            echo "Downloading paru-bin"
            aur="paru-bin"
            break
        elif [[ "$AURn" =~ ^[nN]$ ]]; then 
            aur="paru"
            echo "Downloading paru"
            break
        else 
            echo "Invalid choice, Please enter Y or n."
        fi
    done
}

fn_aur

# Ensure repository directory exists
repo_dir="$HOME/repo/"
mkdir -p "$repo_dir"

# Clone and install AUR helper paru
cd "$repo_dir" || { echo "Failed to change directory to $repo_dir"; exit 1; }
git clone "https://aur.archlinux.org/$aur.git"
if [[ $? -ne 0 ]]; then
    echo "Error cloning AUR repository."
    exit 1
fi

cd "$aur" || { echo "Failed to change directory to $aur"; exit 1; }
makepkg -si --noconfirm
if [[ $? -ne 0 ]]; then
    echo "Error installing AUR package."
    exit 1
fi

echo -e "
-------------------------------------------------------------------------
                       Determine web browser
-------------------------------------------------------------------------
"

# Function to select the preferred web browser
fn_browser() {
    echo -ne "
Please choose your preferred web browser:
1. Firefox
2. Zen Browser (AUR)
3. Chromium
4. Skip 
Enter the number of your choice (1/2/3): "
    read -r BROWSER_CHOICE

    if [[ "$BROWSER_CHOICE" == "1" ]]; then
        PerBrowser="firefox"   
        DPN+=("firefox")
    elif [[ "$BROWSER_CHOICE" == "2" ]]; then
        paru -S zen-browser-bin --noconfirm --needed
        PerBrowser="zen-browser"   
    elif [[ "$BROWSER_CHOICE" == "3" ]]; then
        DPN+=("chromium")
        PerBrowser="chromium"   
    elif [[ "$BROWSER_CHOICE" == "4" ]]; then 
        echo -e "Skipping ... \n"
    else
        echo -e "Invalid option. Please choose '1', '2', or '3'.\n"
        fn_browser  
    fi
}

fn_browser

echo -e "
-------------------------------------------------------------------------
                       Installing Additional Packages
-------------------------------------------------------------------------
"

# Function to check if a package exists in the repositories
package_exists() {
    local package="$1"
    if pacman -Sp "$package" &>/dev/null; then
        return 0  # Package exists
    else
        return 1  # Package does not exist
    fi
}

# Function to prompt for additional packages and add them to DPN array
fn_add_additional_packages() {
    local packages=()
    local all_valid=true
    local package_check=false  

    while true; do
        echo -ne "Enter the names of additional packages to add (space-separated): "
        read -r -a input_packages  # Read space-separated package names into an array

        if [ ${#input_packages[@]} -eq 0 ]; then
            echo "No packages entered. Skipping validation and package addition."
            break  
        fi

        package_check=true  
        all_valid=true  # reset

        # Check each package
        for pkg in "${input_packages[@]}"; do
            echo "Checking if '$pkg' exists in the repositories..."
            if package_exists "$pkg"; then
                echo "Package '$pkg' found."
                packages+=("$pkg")  
            else
                echo "Package '$pkg' does not exist in the repositories."
                sleep 1
                all_valid=false  
            fi
        done

        if $all_valid; then
            break  
        else
            echo "Please enter only valid package names."
        fi
    done

    if $package_check; then
        echo -e "\nAdding valid packages to the DPN array...\n"

        for pkg2 in "${packages[@]}"; do
            if [[ ! " ${DPN[@]} " =~ " ${pkg2} " ]]; then
                DPN+=("$pkg2")
                echo "Added '$pkg2' to the download list."
            else
                echo "'$pkg2' is already in the download list."
            fi
        done

        # Display updated DPN array
        echo -e "\nUpdated download list:"
        for pkg3 in "${DPN[@]}"; do
            echo "$pkg3"
        done
        sleep 2
    fi
}

fn_add_additional_packages

# Install additional packages defined in the DPN array
for pkg4 in "${DPN[@]}"; do
    echo -ne"--------------------------------------"
    echo "Installing $pkg4..."
    echo "--------------------------------------"
    sudo pacman -S "$pkg4" --noconfirm --needed
done

# Clone assets repository
git clone https://github.com/Melal1/assests.git "$HOME/repo/assests"
if [[ $? -ne 0 ]]; then
    echo "Error cloning assets repository."
    exit 1
fi

echo -e "
-------------------------------------------------------------------------
                       Installing Suckless Programs
-------------------------------------------------------------------------
"

# Install Suckless programs (with my configs)
chmod +wr "$HOME/suckless"
cd "$HOME/suckless/dmenu" || { echo "Failed to change directory to $HOME/suckless/dmenu"; exit 1; }
sudo make clean install 
if [[ $? -ne 0 ]]; then
    echo "Error installing dmenu."
    exit 1
fi

cd "$HOME/suckless/dwm" || { echo "Failed to change directory to $HOME/suckless/dwm"; exit 1; }
sudo make clean install 
if [[ $? -ne 0 ]]; then
    echo "Error installing dwm."
    exit 1
fi

echo -e "
-------------------------------------------------------------------------
                       Setting Up Git and Generating SSH Key
-------------------------------------------------------------------------
"
fn_ssh

echo -e "
-------------------------------------------------------------------------
                       Installing Gnome-Keyring
-------------------------------------------------------------------------
"

cd /etc/pam.d/
sudo patch -i $HOME/repo/assests/diff/pam.diff
if [[ $? -ne 0 ]]; then
    echo "Error applying PAM patch."
    sleep 3
    exit 1
fi
cd $HOME


if [[ "$BROWSER_CHOICE" == "4" ]]; then 

    echo -e "
    -------------------------------------------------------------------------
                           Installing clipmenu 
                           You skipped browser section so don't forget to export 
                           your preferred browser to make sure clipmenu-url works !!
    -------------------------------------------------------------------------
    "
    sleep 2
    else
    echo -e "
    -------------------------------------------------------------------------
                           Installing clipmenu 
    -------------------------------------------------------------------------
    "   
fi


sudo cat << 'CLEND' > "/usr/bin/clipmenu-url"
#!/usr/bin/env bash

files=($XDG_RUNTIME_DIR/clipmenu.6.$USER/*)

newest=${files[0]}
for f in "${files[@]}"; do
	if [[ $f -nt $newest ]]; then
		newest=$f
	fi
done
if url=$(grep --max-count=1 --only-matching --perl-regexp "http(s?):\/\/[^ \"\(\)\<\>\]]*" "$newest"); then
	xdg-open $url
fi

CLEND

sudo chmod +x /usr/bin/clipmenu-url

echo -e "
-------------------------------------------------------------------------
                       Installing Audio Server
-------------------------------------------------------------------------
"

# Function to install Pipewire audio server
fn_dpen() {
    echo -ne "Do you want to install the Audio Server (Pipewire)? (Y/n): "
    read -r An

    if [[ "$An" =~ ^[yY]$ || -z "$An" ]]; then
        echo -e "
-------------------------------------------------------------------------
                       Installing Audio Server
-------------------------------------------------------------------------
"
        sudo pacman -S "${pipewire[@]}" --noconfirm --needed
        if [[ $? -ne 0 ]]; then
            echo "Error installing Pipewire."
            exit 1
        fi
    elif [[ "$An" =~ ^[nN]$ ]]; then
        echo "Okay, skipping..."
    else
        echo -e "Invalid option, please choose 'y' or 'n'.\n"
        fn_dpen  # Recursively prompt for valid input
    fi 
}

fn_dpen

echo -e "
-------------------------------------------------------------------------
                       Installing Fonts
-------------------------------------------------------------------------
"

#  install fonts
git clone https://github.com/Melal1/assests.git "$HOME/repo/assests"
if [[ $? -ne 0 ]]; then
    echo "Error cloning assets repository for fonts."
    exit 1
fi
sudo cp -r "$HOME/repo/assests/font-assests/fonts/"* /usr/share/fonts/
if [[ $? -ne 0 ]]; then
    echo "Error copying fonts."
    exit 1
fi

echo -e "
-------------------------------------------------------------------------
                       Applying Fontconfig File
            ^Note: You can edit ~/.config/fontconfig/fonts.conf later
-------------------------------------------------------------------------
"

# Apply font configuration
mkdir -p "$HOME/.config/fontconfig/"
cp "$HOME/repo/assests/font-assests/fonts.conf" "$HOME/.config/fontconfig/"
if [[ $? -ne 0 ]]; then
    echo "Error copying fontconfig file."
    exit 1
fi
fc-cache -fv
if [[ $? -ne 0 ]]; then
    echo "Error applying fontconfig file."
    exit 1
fi

echo -e "
-------------------------------------------------------------------------
                       Copying Wallpapers
            ^Note: Wallpapers are located in ~/Pictures/Wallpapers
-------------------------------------------------------------------------
"

# Copy wallpapers to the Pictures directory
mkdir -p "$HOME/Pictures/Wallpapers"
cp "$HOME/repo/assests/wallpapers/"* "$HOME/Pictures/Wallpapers"
if [[ $? -ne 0 ]]; then
    echo "Error copying wallpapers."
    exit 1
fi

echo -e "
-------------------------------------------------------------------------
                       Adding Keyboard Layouts 
            ^Default layouts (ar, en). Edit /etc/X11/xorg.conf.d/00-keyboard.conf later
            ^Default key to change layout is win + space
-------------------------------------------------------------------------
"

# Set keyboard layouts and layout switch key combination
localectl set-x11-keymap us,ara ,pc101 qwerty grp:win_space_toggle
if [[ $? -ne 0 ]]; then
    echo "Error setting keyboard layouts."
    exit 1
fi

echo -e "
-------------------------------------------------------------------------
                       Installing .xinitrc File
            ^Note: You can edit ~/.xinitrc later
-------------------------------------------------------------------------
"

# Install .xinitrc for starting dwm and other programs
rm -rf "$HOME/.xinitrc"

cat << EOF > "$HOME/.xinitrc"
export PATH="\$HOME/.local/bin:\$PATH" &
clipmenud &
feh --bg-scale "\$HOME/Pictures/Wallpapers/1.jpg" &
BROWSER=$PerBrowser
exec dwm
EOF


# Function to clean up installed dependency repositories
cleanup_fn() {
    echo -e "Would you like to clean up the installed dependency repositories? (Y/n): "
    read -r cleanup_choice

    if [[ "$cleanup_choice" =~ ^[yY]$ || -z "$cleanup_choice" ]]; then
        # Remove specified directories
        sudo rm -rf "$HOME/repo/paru"
        sudo rm -rf "$HOME/repo/assests"
        sudo rm -rf "$HOME/2-Setup.sh"
        sudo rm -rf /var.conf
        echo -e "Cleanup complete."
    elif [[ "$cleanup_choice" =~ ^[nN]$ ]]; then
        echo -e "Okay...\nNote that all repository dependencies are stored in '$HOME/repo'."
    else
        echo -e "Invalid option. Please choose 'y' or 'n'."
        cleanup_fn  
    fi
}

cleanup_fn

echo -e "
-------------------------------------------------------------------------
                       Setup is finished 
                     You can reboot now ~
-------------------------------------------------------------------------
"
