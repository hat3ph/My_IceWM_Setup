#!/bin/bash

# optional components installation
my_icewm_install=yes # set no if just want to install icewm
my_icewm_config=yes # set no if just want an empty icewm setup
firefox_deb=yes # install firefox using the deb package
icewm_themes=yes # set no if do not want to install extra icewm themes
theming=yes # set yes to install custom theming
rofi_power_menu_config=yes # set yes to install rofi-power-menu
audio=yes # set no if do not want to use pipewire audio server
thunar=yes # set no if do not want to install thunar file manager
login_mgr=yes # set no if do not want to install SDDM login manager
nm=yes # set no if do not want to use network-manager for network interface management
nano_config=no # set no if do not want to configure nano text editor

install () {
	# install IceWM and other packages
	if [[ $my_icewm_install == "yes" ]]; then
		sudo apt-get update && sudo apt-get upgrade -y
		sudo apt-get install icewm xorg xinit x11-utils rsyslog logrotate lxterminal lxappearance papirus-icon-theme \
			xdg-utils xdg-user-dirs policykit-1 libnotify-bin dunst nano less software-properties-gtk xscreensaver \
			policykit-1-gnome dex gpicview geany gv flameshot feh -y
		echo "icewm-session" > $HOME/.xinitrc
  		# enable acpid
    		#sudo apt-get install acpid -y
      		#sudo systemctl enable acpid
	fi

	# install theming
	if [[ $theming == "yes" ]]; then

		# copy wallpapers
  		mkdir -p $HOME/Pictures/wallpapers
   		cp ./wallpapers/* $HOME/Pictures/wallpapers/
		
		# install Nordic gtk theme https://github.com/EliverLara/Nordic
		mkdir -p $HOME/.themes
		wget -P /tmp https://github.com/EliverLara/Nordic/releases/download/v2.2.0/Nordic.tar.xz
		tar -xvf /tmp/Nordic.tar.xz -C $HOME/.themes

		mkdir -p $HOME/.config/gtk-3.0
		cp ./config/gtk2 $HOME/.gtkrc-2.0
		#sed -i "s/administrator/"$USER"/g" $HOME/.gtkrc-2.0
		cp ./config/gtk3 $HOME/.config/gtk-3.0/settings.ini

		# add additional geany colorscheme
		mkdir -p $HOME/.config/geany/colorschemes
		git clone https://github.com/geany/geany-themes.git /tmp/geany-themes
		cp -r /tmp/geany-themes/colorschemes/* $HOME/.config/geany/colorschemes/

		# install dracula themes
		git clone https://github.com/dracula/lxterminal.git /tmp/lxterminal
		mkdir -p $HOME/.config/lxterminal/
		cp /tmp/lxterminal/lxterminal.conf $HOME/.config/lxterminal/

  		mkdir -p $HOME/.icons
    	wget -P /tmp https://github.com/dracula/gtk/releases/download/v4.0.0/Dracula-cursors.tar.xz
      	tar -xvf /tmp/Dracula-cursors.tar.xz -C $HOME/.icons

		mkdir -p $HOME/.themes
		wget -P /tmp https://github.com/dracula/gtk/releases/download/v4.0.0/Dracula.tar.xz
  		tar -xvf /tmp/Dracula.tar.xz -C $HOME/.themes
	fi

	# install rofi and power menu
 	if [[ $rofi_power_menu_config == "yes" ]]; then
		sudo apt-get install rofi -y
		mkdir -p $HOME/.local/bin
		cp ./bin/power.sh $HOME/.local/bin
		chmod +x $HOME/.local/bin/power.sh
	fi

 	# copy my icewm configuration
	if [[ $my_icewm_config == "yes" ]]; then
		if [[ -d $HOME/.icewm ]]; then mv $HOME/.icewm $HOME/.icewm_`date +%Y_%d_%m_%H_%M_%S`; fi
		#mkdir -p $HOME/{Documents,Downloads,Music,Pictures,Videos}
		mkdir -p $HOME/.icewm
		cp -r ./icewm/* $HOME/.icewm/
		chmod +x $HOME/.icewm/startup
	fi
 
 	# install extra IceWM themes
  	if [[ $icewm_themes == "yes" ]]; then
		mkdir -p $HOME/.icewm/themes

		git clone https://github.com/Brottweiler/win95-dark.git /tmp/win95-dark
		cp -r /tmp/win95-dark $HOME/.icewm/themes 
		rm $HOME/.icewm/themes/win95-dark/.gitignore
		sudo rm -r $HOME/.icewm/themes/win95-dark/.git
  
		git clone https://github.com/Vimux/icewm-theme-icepick.git /tmp/icewm-theme-icepick
		cp -r /tmp/icewm-theme-icepick/IcePick $HOME/.icewm/themes
  
		git clone https://github.com/Brottweiler/Arc-Dark.git /tmp/Arc-Dark
		cp -r /tmp/Arc-Dark $HOME/.icewm/themes
		sudo rm -r $HOME/.icewm/themes/Arc-Dark/.git

		tar -xvf ./config/DraculIce.tar.gz -C $HOME/.icewm/themes
		if [[ -n "$(uname -a | grep Ubuntu)" ]]; then
			cp $HOME./icewm/themes/DraculIce/taskbar/start_ubuntu.svg $HOME./icewm/themes/DraculIce/taskbar/start.xpm
		else
			cp ./config/debian.xpm $HOME./icewm/themes/DraculIce/taskbar/start.xpm
		fi
	fi

	# configure nano with line number
	if [[ $nano_config == "yes" ]]; then
		if [[ -f $HOME/.nanorc ]]; then mv $HOME/.nanorc $HOME/.nanorc_`date +%Y_%d_%m_%H_%M_%S`; fi
		cp /etc/nanorc $HOME/.nanorc
		sed -i 's/# set const/set const/g' $HOME/.nanorc
	fi

	# use pipewire with wireplumber or pulseaudio-utils
	if [[ $audio == "yes" ]]; then
		# install pulseaudio-utils to audio management for Ubuntu 22.04 due to out-dated wireplumber packages
		if [[ ! $(cat /etc/os-release | awk 'NR==3' | cut -c12- | sed s/\"//g) == "22.04" ]]; then
			sudo apt-get install pipewire pipewire-pulse wireplumber pavucontrol-qt pnmixer -y
		else
			sudo apt-get install pipewire pipewire-media-session pulseaudio pulseaudio-utils pavucontrol pnmixer -y
		fi
		mkdir -p $HOME/.config/pnmixer
		cp ./config/pnmixer $HOME/.config/pnmixer/config
	fi

	# optional to install thunar file manager
	if [[ $thunar == "yes" ]]; then
		sudo apt-get install thunar gvfs gvfs-backends thunar-archive-plugin thunar-media-tags-plugin avahi-daemon -y
		mkdir -p $HOME/.config/xfce4
		echo "TerminalEmulator=lxterminal" > $HOME/.config/xfce4/helpers.rc
	fi

	# optional to install SDDM or lxDM login manager
	if [[ $login_mgr == "yes" ]]; then
		if [[ -n "$(uname -a | grep Ubuntu)" ]]; then
			sudo apt-get install sddm -y
		else
			sudo apt-get install lxdm -y
		fi
	fi

	# install firefox without snap
	# https://www.omgubuntu.co.uk/2022/04/how-to-install-firefox-deb-apt-ubuntu-22-04
	if [[ $firefox_deb == "yes" ]]; then
		if [[ -n "$(uname -a | grep Ubuntu)" ]]; then
			sudo install -d -m 0755 /etc/apt/keyrings
			wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | \
				sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
			echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | \
				sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null
			echo -e "Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000" | \
				sudo tee /etc/apt/preferences.d/mozilla
			sudo apt-get update && sudo apt-get install firefox -y
		else
			sudo apt-get install firefox-esr -y
			sed -i 's/firefox/firefox-esr/g' $HOME/.icewm/{menu,toolbar}
		fi
  	fi

	# optional install NetworkManager
	if [[ $nm == yes ]]; then
		sudo apt-get install network-manager network-manager-gnome -y
		if [[ -n "$(uname -a | grep Ubuntu)" ]]; then
			for file in `find /etc/netplan/* -maxdepth 0 -type f -name *.yaml`; do
				sudo mv $file $file.bak
			done
			echo -e "# Let NetworkManager manage all devices on this system\nnetwork:\n  version: 2\n  renderer: NetworkManager" | \
			sudo tee /etc/netplan/01-network-manager-all.yaml
		else
			sudo cp /etc/NetworkManager/NetworkManager.conf /etc/NetworkManager/NetworkManager.conf.bak
			sudo sed -i 's/managed=false/managed=true/g' /etc/NetworkManager/NetworkManager.conf
			sudo mv /etc/network/interfaces /etc/network/interfaces.bak
			head -9 /etc/network/interfaces.bak | sudo tee /etc/network/interfaces
			sudo systemctl disable networking.service
		fi
	fi

	# disable unwanted services
 	if [[ -n "$(uname -a | grep Ubuntu)" ]]; then
 		sudo systemctl disable systemd-networkd-wait-online.service
  		sudo systemctl disable multipathd.service
	fi
}

printf "\n"
printf "Start installation!!!!!!!!!!!\n"
printf "88888888888888888888888888888\n"
printf "My IceWM Install        : $my_icewm_install\n"
printf "My Custom IceWM Config  : $my_icewm_config\n"
printf "Firefox as DEB packages : $firefox_deb\n"
printf "Extra IceWM themes      : $icewm_themes\n"
printf "Pipewire Audio          : $audio\n"
printf "Thunar File Manager     : $thunar\n"
printf "Rofi power menu         : $rofi_power_menu_config\n"
printf "Custom theming          : $theming\n"
printf "Login Manager           : $login_mgr\n"
printf "NetworkManager          : $nm\n"
printf "Nano's configuration    : $nano_config\n"
printf "88888888888888888888888888888\n"

while true; do
read -p "Do you want to proceed with above settings? (y/n) " yn
	case $yn in
		[yY] ) echo ok, we will proceed; install; echo "Remember to reboot system after the installation!";
			break;;
		[nN] ) echo exiting...;
			exit;;
		* ) echo invalid response;;
	esac
done
