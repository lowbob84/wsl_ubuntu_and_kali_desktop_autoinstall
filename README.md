# wsl_ubuntu_and_kali_desktop_autoinstall
Automatic install of WSL ubuntu desktop and kali linux desktop
Found on different Websites, Posts the way to go for install the gnome-desktop for ubuntu in WSL.
For kali linux i changed only the Destop variables and it worked

# Please don't hesitate to contact me if you find some issues or know how to expand the code 

## For x11 i used gwsl from Microsoft store, but other window Managers also should work  

## 1. Configuration of WSL and start desktop
1. Install gwsl form Microsoft store and start it
2. Install clean ubuntu, ubuntu-22.04 or kali-linux from microsoft Store 
3. Start WSL, create User and set password
4. su
5. copy script or make a new file with the code inside
6. chmod +x ./wsl_ubuntu_install.sh
7. ./wsl_ubuntu_install.sh
8. after the script is finished shutdown the WSL in Powershell. wsl --shutdown Ubuntu-22.04 or wsl --shutdown kali-linux
9. start ubuntu or kali-linux and start the desktop "start_kali_desktop" or "./start_ubuntu_dekstop.sh"

## Think not all Desktop variables are right for kali-linux but desktop is working

