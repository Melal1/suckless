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



echo -e "
-------------------------------------------------------------------------
                          Generating ssh key
-------------------------------------------------------------------------
"


fn_inputs() {
    echo -ne "Please enter a valid email: "
    read EMAIL

    #  Email validation
    local regex="^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"

    
    if [[ $EMAIL =~ $regex ]]; then
        echo "Your email address is '${EMAIL}'."
        echo -ne "Is that okay? (Y/n): "
        read confirmation

        
        if [[ $confirmation == [yY] ]]; then
            echo "Email confirmed: ${EMAIL}"
            
        elif [[ $confirmation == [nN] ]]; then
            echo "Okay.\n"
            fn_inputs  
        else
            echo "Invalid input. \nPlease enter 'y' for yes or 'n' for no.\n"
            fn_inputs  
        fi
    else
        echo -ne "Invalid email address.\nPlease try again.\n"
        fn_inputs  
    fi
}


fn_inputs















echo -ne "
-------------------------------------------------------------------------
                          Installing Display Server
-------------------------------------------------------------------------
"






# Var
source $HOME/suckless/Assest.conf


# Creating the repository folder 

mkdir $HOME/repo/










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
                          installing .xinitrc file
            ^note that you can edit ~/.xinitrc later
-------------------------------------------------------------------------
"

cp $HOME/repo/assests/autostart/.xinitrc $HOME/

