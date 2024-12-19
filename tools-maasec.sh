#!/usr/bin/env bash

#Update the system before installing packages
sudo apt update && sudo apt upgrade -y

#Network scanning packages
# E: Package 'netcat' has no installation candidate
# netcat might already exist; check "which nc"
# sudo apt install nmap netcat nikto openvas hydra wireshark tcpdump -y
sudo apt install nmap nikto openvas hydra tcpdump -y

# install wireshark in non-interactive mode
# accepts all defaults
sudo DEBIAN_FRONTEND=noninteractive apt install -y wireshark

#Steganography packages
# removed unavailable packages
#sudo apt install steghide zsteg stegsave binwalk ropper -y
sudo apt install steghide binwalk -y

#Binary file analysis, wine is used for indows emulation, could add disassembler to this too 
sudo apt install wine binutils strace ltrace -y

#Password cracking 
sudo apt install john hashcat openssl python3-cryptography -y

#Web application pen-testing
sudo snap install zaproxy -y

#sqlmap is used for sql ingjections and dirb to find directories on a web server
sudo apt install sqlmap dirb -y

#python for scripting and a few other misc. tools
# E: Unable to locate package pwncat
#sudo apt install python3 pwncat tmux git wget curl jq htop -y
sudo apt install python3 tmux git wget curl jq htop -y

#python packages that are usefule for exploitation 
sudo apt install python3-pwntools python3-requests python3-pycryptodome python3-paramiko -y

# Installation of BurpSuite
echo "Installing BurpSuite!"
wget -O burpsuite.sh "https://portswigger-cdn.net/burp/releases/download?product=community&version=2024.11.1&type=Linux"
chmod +x burpsuite.sh
yes "" | sudo ./burpsuite.sh
rm ./burpsuite.sh
echo "Done!"


# Certain packages that might be needed for the aircrack-ng installation, needs testing.
sudo apt-get autoconf -y
sudo apt install automake libtool shtool pkg-config ethtool rfkill build-essential -y

AC_URL="https://download.aircrack-ng.org/aircrack-ng-1.7.tar.gz"
AC_FILENAME="aircrack-ng-1.7.tar.gz"
AC_DIRNAME="aircrack-ng-1.7"

#Download the aircrack file
wget "$AC_URL" -O "$AC_FILENAME"
#Unzip 
tar -zxvf "$AC_FILENAME"
cd "$AC_DIRNAME" || exit
# Configuration and installation using aircrack's makefiles
autoreconf -i
./configure --with-experimental
make
make install
#Update dynamic linker cache
ldconfig
cd ..
#Remove waste
rm -f "$AC_FILENAME"
rm -rf "$AC_DIRNAME"

echo "Aircrack-ng installation completed successfully!"
