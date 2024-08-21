#!/bin/bash
source $HOME/dotfiles/2-Setup/Suckless/Assest.conf



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

cd $HOME/dotfiles/2-Setup/Suckless/dmenu 
sudo make clean install 

cd $HOME/dotfiles/2-Setup/Suckless/dwm
sudo make clean install 


cd $HOME/dotfiles/2-Setup/Suckless/dwm
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




  echo -ne "
-------------------------------------------------------------------------
                          Applying Fontconfig File
            ^note that you can edit ~/.config/fontconfig/fonts.conf later
-------------------------------------------------------------------------
"





