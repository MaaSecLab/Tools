#!/usr/bin/env bash

#Update the system before installing packages
sudo apt update && sudo apt upgrade -y

#Network scanning packages 
sudo apt install nmap netcat nikto openvas hydra wireshark tcpdump

#Steganography packages
# removed unavailable packages
#sudo apt install steghide zsteg stegsave binwalk ropper -y
sudo apt install steghide binwalk -y

#Binary file analysis, wine is used for indows emulation, could add disassembler to this too 
sudo apt install wine binutils strace ltrace -y

#Password cracking 
sudo apt install john hashcat openssl python3-cryptography

#Web application pen-testing
sudo snap install zaproxy -y

#sqlmap is used for sql ingjections and dirb to find directories on a web server
sudo apt install burpsuite sqlmap dirb -y

#python for scripting and a few other misc. tools 
sudo apt install python3 pwncat tmux git wget curl jq htop -y

#python packages that are usefule for exploitation 
sudo apt install python3-pwntools python3-requests python3-pycryptodome python3-paramiko -y

echo "Done!"
