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
sudo ./burpsuite.sh
rm ./burpsuite.sh
echo "Done!"
