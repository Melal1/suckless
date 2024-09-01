#!/bin/bash

set -e  # Exit on command failure
sudo pacman -Syyu --noconfirm --needed
# Source configuration from Assest.conf
source "$HOME/suckless/Assest.conf"

# Display the banner
echo -e "$Banner"

# Function to determine what type of terminal to download
fn_vr() {
    echo -ne "\nAre you on a virtual machine? (y/N): "
    read -r VIR

    # Check user input and adjust terminal settings accordingly
    if [[ "$VIR" =~ ^[yY]$ ]]; then
        # Modify dwm config to use rxvt-unicode if on a VM
        sed -i 's/static const char \*termcmd\[\]  = { "", NULL };/static const char \*termcmd\[\]  = { "rxvt-unicode", NULL };/' "$HOME/suckless/dwm/config.def.h"
        DPN+=("rxvt-unicode")
    elif [[ "$VIR" =~ ^[nN]$ || -z "$VIR" ]]; then
        # Modify dwm config to use kitty if not on a VM
        sed -i 's/static const char \*termcmd\[\]  = { "", NULL };/static const char \*termcmd\[\]  = { "kitty", NULL };/' "$HOME/suckless/dwm/config.def.h"
        DPN+=("kitty")
    else
        echo -e "Invalid input. Please enter 'y' for yes or 'n' for no.\n"
        fn_vr  # Recursively prompt for valid input
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
                       Installing Suckless Programs
-------------------------------------------------------------------------
"

# Install Suckless programs (with my configs)
chmod +wr "$HOME/suckless"
cd "$HOME/suckless/dmenu" || exit
sudo make clean install 

cd "$HOME/suckless/dwm" || exit
sudo make clean install 

# Create the repository folder
mkdir -p "$HOME/repo/"

echo -e "
-------------------------------------------------------------------------
                       Installing AUR Helper
-------------------------------------------------------------------------
"

# Clone and install AUR helper paru
cd "$HOME/repo/"
git clone https://aur.archlinux.org/paru.git
cd "$HOME/repo/paru"
makepkg -si --noconfirm
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
2. Zen Browser
3. Chromium

Enter the number of your choice (1/2/3): "
    read -r BROWSER_CHOICE

    if [[ "$BROWSER_CHOICE" == "1" ]]; then
        DPN+=("firefox")
    elif [[ "$BROWSER_CHOICE" == "2" ]]; then
        paru -S zen-browser-bin --noconfirm --needed
    elif [[ "$BROWSER_CHOICE" == "3" ]]; then
       DPN+=("chromium")
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
    sudo pacman -Fy &>/dev/null  # Update file database
    if pacman -Fq "$package" &>/dev/null; then
        return 0  # Package exists
    else
        return 1  # Package does not exist
    fi
}

# Function to prompt for additional packages and add them to DPN array
fn_add_additional_packages() {
    local packages=()
    
    while true; do
        echo -ne "Enter the names of additional packages to add (space-separated): "
        read -r -a input_packages  # Read space-separated package names into an array

        if [ ${#input_packages[@]} -eq 0 ]; then
            echo "No packages entered. Exiting."
            exit 1
        fi

        # Check each package
        for pkg in "${input_packages[@]}"; do
            echo "Checking if '$pkg' exists in the repositories..."
            if package_exists "$pkg"; then
                echo "Package '$pkg' found."
                packages+=("$pkg")  # Add valid package to the list
            else
                echo "Package '$pkg' does not exist in the repositories. Please enter a valid package name."
            fi
        done

        # If we have valid packages, break the loop
        if [ ${#packages[@]} -gt 0 ]; then
            break
        fi
    done

    echo -e "\nAdding valid packages to the DPN array...\n"

    # Add valid packages to the existing DPN array
    for pkg2 in "${packages[@]}"; do
        if [[ ! " ${DPN[@]} " =~ " ${pkg2} " ]]; then
            DPN+=("$pkg2")
            echo "Added '$pkg2' to the DPN array."
        else
            echo "'$pkg2' is already in the DPN array."
        fi
    done

    # Display updated DPN array
    echo -e "\nUpdated DPN array:"
    for pkg3 in "${DPN[@]}"; do
        echo "$pkg3"
    done
}

fn_add_additional_packages


# Install additional packages defined in the DPN array
for pkg4 in "${DPN[@]}"; do

    echo -ne"--------------------------------------"
    echo "Installing $pkg4..."
    echo "--------------------------------------"
    sudo pacman -S "$pkg4" --noconfirm --needed
    sleep 1  # Short delay between installations
done

echo -e "
-------------------------------------------------------------------------
                       Setting Up Git and Generating SSH Key
-------------------------------------------------------------------------
"

fn_ssh

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

# Clone and install fonts
git clone https://github.com/Melal1/assests.git "$HOME/repo/assests"
sudo cp -r "$HOME/repo/assests/font-assests/fonts/"* /usr/share/fonts/

echo -e "
-------------------------------------------------------------------------
                       Applying Fontconfig File
            ^Note: You can edit ~/.config/fontconfig/fonts.conf later
-------------------------------------------------------------------------
"

# Apply font configuration
sleep 1
mkdir -p "$HOME/.config/fontconfig/"
cp "$HOME/repo/assests/font-assests/fonts.conf" "$HOME/.config/fontconfig/"
fc-cache -fv

echo -e "
-------------------------------------------------------------------------
                       Copying Wallpapers
            ^Note: Wallpapers are located in ~/Pictures/Wallpapers
-------------------------------------------------------------------------
"

# Copy wallpapers to the Pictures directory
sleep 1
mkdir -p "$HOME/Pictures/Wallpapers"
cp "$HOME/repo/assests/wallpapers/"* "$HOME/Pictures/Wallpapers"

echo -e "
-------------------------------------------------------------------------
                       Adding Keyboard Layouts 
            ^Default layouts (ar, en). Edit /etc/X11/xorg.conf.d/00-keyboard.conf later
            ^Default key to change layout is win + space
-------------------------------------------------------------------------
"

# Set keyboard layouts and layout switch key combination
localectl set-x11-keymap us,ara ,pc101 qwerty grp:win_space_toggle

echo -e "
-------------------------------------------------------------------------
                       Installing .xinitrc File
            ^Note: You can edit ~/.xinitrc later
-------------------------------------------------------------------------
"

# Install .xinitrc for starting dwm and other programs
rm -rf "$HOME/.xinitrc"
cat << 'REALEND' > "$HOME/.xinitrc"
export PATH="$HOME/.local/bin:$PATH" &
feh --bg-scale "$HOME/Pictures/Wallpapers/1.jpg" &
exec dwm
REALEND

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
        cleanup_fn  # Recursively prompt for valid input
    fi
}

cleanup_fn

echo -e "
-------------------------------------------------------------------------
                       Setup is finished 
                     You can reboot now ~
-------------------------------------------------------------------------
"
