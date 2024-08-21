#!/bin/bash

# Var
source $HOME/suckless/Assest.conf


# Creating the repository folder 

mkdir $HOME/repo/


echo -ne "
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

git clone 

cd $HOME/suckless/dmenu 
sudo make clean install 

cd $HOME/suckless/dwm
sudo make clean install 





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
git clone https://github.com/Melal1/assests.git $HOME/repo/assests

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
                          installing .xinitrc file
            ^note that you can edit ~/.xinitrc later
-------------------------------------------------------------------------
"

cp $HOME/repo/assests/autostart/.xinitrc $HOME/