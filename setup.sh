#!/bin/bash


echo -e "
-------------------------------------------------------------------------

  ▄▄▄▄███▄▄▄▄      ▄████████  ▄█          ▄████████  ▄█      
▄██▀▀▀███▀▀▀██▄   ███    ███ ███         ███    ███ ███      
███   ███   ███   ███    █▀  ███         ███    ███ ███      
███   ███   ███  ▄███▄▄▄     ███         ███    ███ ███      
███   ███   ███ ▀▀███▀▀▀     ███       ▀███████████ ███      
███   ███   ███   ███    █▄  ███         ███    ███ ███      
███   ███   ███   ███    ███ ███▌    ▄   ███    ███ ███▌    ▄
 ▀█   ███   █▀    ██████████ █████▄▄██   ███    █▀  █████▄▄██
                             ▀                      ▀        
-------------------------------------------------------------------------
          Suckless Setup Script 
	  Run this script after a clean install 
------------------------------------------------------------------------
"

sleep 2
sudo rm -rf 2-Setup.sh
# Var
source $HOME/suckless/Assest.conf


echo -e "
-------------------------------------------------------------------------
                          Generating ssh key
-------------------------------------------------------------------------
"






fn_inputs() {
    echo -ne "\nPlease enter a valid email: "
    read EMAIL

    # Email validation
    local regex="^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$"

    if [[ $EMAIL =~ $regex ]]; then
        echo -e "\nYour email address is '${EMAIL}'."
        echo -n "Is that okay? (y/n): "
        read confirmation

        
        if [[ $confirmation == [yY] ]]; then
            echo -e "\nEmail confirmed: ${EMAIL}"
            # Generate SSH key
            ssh-keygen -t ed25519 -f "${ssh_PATH}/id_ed25519" -C "${EMAIL}" -q -N ""
            echo -e "\nSsh key generated .\nPlease copy it form ~/.ssh/ and put it on github"
            sleep 2
        elif [[ $confirmation == [nN] ]]; then
            echo -e "\nOkay. Please enter your email again."
            fn_inputs  
        else
            echo -e "Invalid input. \nPlease enter 'y' for yes or 'n' for no.\n"
            fn_inputs  
        fi
    else
        echo -ne "\nInvalid email address.\nPlease try again.\n"
        fn_inputs  
    fi
}

fn_inputs

eval "$(ssh-agent -s)"




echo -ne "
-------------------------------------------------------------------------
                          Installing Display Server
-------------------------------------------------------------------------
"

 PKG=("xorg" "xorg-xinit" ) 

for pkg in "${PKG[@]}"; do
    echo 'Installing "$pkg" ....' 
    sudo pacman -S "$pkg" --noconfirm --needed


    
done

sudo pacman -S "${DPN[@]}" --noconfirm --needed




echo -ne "
-------------------------------------------------------------------------
                          Installing Suckless Programs
-------------------------------------------------------------------------
"


cd $HOME/suckless/dmenu 
sudo make clean install 

cd $HOME/suckless/dwm
sudo make clean install 

# Creating the repository folder 

mkdir $HOME/repo/



echo -ne "
-------------------------------------------------------------------------
                          Installing Additional Packages 
-------------------------------------------------------------------------
"

fn_dpen() {
echo -ne "Do you want to install Audio Server (Pipewire) ? (y/n) "
read An

if [[ "$An" == "y" ]] ; then 


  echo -ne "
-------------------------------------------------------------------------
                          Installing Audio Server
-------------------------------------------------------------------------
"
echo sudo pacman -S "${pipewire[@]}" --noconfirm --needed



	
elif [[ "$An" == "n" ]] ; then 
	echo "okay skipping ..."
else 
	echo -ne  "
       dotfiles/2-Setup/S
	Invalid option , please choose (y/n)
       
	"
	fn_dpen
fi 

}

fn_dpen



  echo -ne "
-------------------------------------------------------------------------
                          Installing Fonts
-------------------------------------------------------------------------
"
git clone git@github.com:Melal1/assests.git $HOME/repo/assests

sudo cp -r $HOME/repo/assests/font-assests/fonts/* /usr/share/fonts/





  echo -ne "
-------------------------------------------------------------------------
                          Applying Fontconfig File
            ^note that you can edit ~/.config/fontconfig/fonts.conf later
-------------------------------------------------------------------------
"

sleep 1


mkdir $HOME/fontconfig/

cp $HOME/repo/assests/font-assests/fonts.conf $HOME/fontconfig/

fc-cache -fv

  echo -ne "
-------------------------------------------------------------------------
                          Copying Wallpapers
            ^note that you can find wallpapers ~/Pictures/Wallpapers
-------------------------------------------------------------------------
"
sleep 1
mkdir -r $HOME/Pictures/Wallpapers
cp $HOME/repo/assests/wallpapers/*  $HOME/Pictures/Wallpapers

  echo -ne "
-------------------------------------------------------------------------
                          installing .xinitrc file
            ^note that you can edit ~/.xinitrc later
-------------------------------------------------------------------------
"
rm -rf $HOME/.xinitrc



cat << 'REALEND' > $HOME/.xinitrc 

export PATH="$HOME/.local/bin:$PATH" &
feh --bg-scale $HOME/Pictures/Wallpapers/1.jpg &
exec dwm


REALEND




 echo -ne "
-------------------------------------------------------------------------
                          Adding keyboard layouts 
                          Default(ar,en) you can edit this on /etc/X11/xorg.conf.d/00-keyboard.conf
                          Default key to change layout is win + space
-------------------------------------------------------------------------
"
localectl set-x11-keymap us,ara ,pc101 qwerty grp:win_space_toggle