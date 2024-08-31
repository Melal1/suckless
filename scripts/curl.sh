#!/bin/bash
# This script is meant to reach by bash <(curl -L tunyurl.com/suckst)
cd ~
echo "Cloning the Suckless config Project"
git clone https://github.com/Melal1/suckless.git
echo "Executing Setup Script"
cd $HOME/suckless/scripts/
exec ./setup.sh