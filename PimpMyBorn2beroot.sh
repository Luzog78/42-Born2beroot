#!/bin/bash

################################################################################
#      A big thanks to julthoma (Julien Thomas) for this fabulous idea !       #
#                                                                              #
# Here is the link to his github repository:                                   #
#   > https://github.com/CleSucre/Born2beroot                                  #
#     (commit: f0bb8371b0ce505f5c2eca9053f3f8d7c1d26116)                       #
#     (datetime: Nov 13, 2023, 2:10 AM GMT+1)                                  #
#                                                                              #
#          The following script is a modified version of his script.           #
#             This version installs the whole Born2beroot project,             #
#                          including the bonus part !                          #
#                (except the partitionning for obvious reasons)                #
#                                                                              #
# Enjoy !                                                                      #
#                                        ~ ysabik (Yanis Sabik) - Nov 19, 2023 #
################################################################################

# PS: For the setup, to remember it, you can use `Born2beroot!` as password.
#     > It's following the password policy
#     > It's easy to remember
#     > It's easy to type
#     > You can use it absolutely everywhere... (except for your bank account)

# PS2: If the github repo ever goes down, you can try to use the pastebin:
#      > https://pastebin.com/raw/eJ22qPTS
MONITORING_URL="https://raw.githubusercontent.com/Luzog78/42-Born2beroot/main/monitoring.sh"

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run with administrative privileges (sudo)."
    exit 1
fi

# Prompt the user for the desired username
read -p "Enter the desired username: " USERNAME

# Update system
read -p "Update the system ? (y/n): " ACTION

if [ "$ACTION" == "y" ]; then
	echo "Executing system update..."
	apt update -y
	apt upgrade -y
	echo "System updated."
elif [ "$ACTION" == "n" ]; then
	echo "Skipping system update."
fi

# Install sudo
read -p "Install sudo ? (y/n): " ACTION

if [ "$ACTION" == "y" ]; then
	echo "Installing sudo..."
	apt install sudo -y
	echo "Sudo installed."
elif [ "$ACTION" == "n" ]; then
	echo "Skipping system update."
fi

# Setup users and groups
read -p "Setup users and groups and adding $USERNAME to sudo users ? (y/n): " ACTION

if [ "$ACTION" == "y" ]; then
	echo "Executing users and groups setup..."
	usermod -aG sudo $USERNAME
	echo "$USERNAME	ALL=(ALL) ALL" | sudo tee -a "/etc/sudoers"
	groupadd user42
	sudo usermod -aG user42 $USERNAME
	echo "Users and groups setup completed."
elif [ "$ACTION" == "n" ]; then
	echo "Skipping users and groups setup."
fi

# Install wget and vim
read -p "Install git, vim and Oh my zsh ? (y/n): " ACTION

if [ "$ACTION" == "y" ]; then
	echo "Installing wget and vim..."
	apt install git -y
	apt install vim -y
	apt install zsh -y
	echo "git, zsh and vim installed."
elif [ "$ACTION" == "n" ]; then
	echo "Skipping git, zsh and vim installation."
fi

# Install wget and vim
read -p "Install wget ? (y/n): " ACTION

if [ "$ACTION" == "y" ]; then
	echo "Installing wget..."
	apt install wget -y
	echo "wget installed."
elif [ "$ACTION" == "n" ]; then
	echo "Skipping wget installation."
fi

# Install and configure openssh-server
read -p "Setup ssh server ? (y/n): " ACTION

if [ "$ACTION" == "y" ]; then
	echo "Installing and configuring ssh server..."
	apt update -y
	apt install openssh-server -y
	service ssh restart
	sed -i 's/#Port 22/Port 4242/' /etc/ssh/sshd_config
	sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
	service ssh restart
	echo "ssh server installed and configured."
elif [ "$ACTION" == "n" ]; then
	echo "Skipping ssh server installation and configuration."
fi

# Install and configure ufw
read -p "Setup firewall ? (y/n): " ACTION

if [ "$ACTION" == "y" ]; then
	echo "Installing and configuring firewall..."
	apt install ufw -y
	ufw default deny incoming
	ufw default allow outgoing
	ufw allow 4242
	ufw enable
elif [ "$ACTION" == "n" ]; then
	echo "Skipping firewall installation and configuration."
fi

# Install password quality checking library (libpam-pwquality)
read -p "Install libpam-pwquality ? (y/n): " ACTION

if [ "$ACTION" == "y" ]; then
	echo "Installing libpam-pwquality..."
	apt install libpam-pwquality -y
	sed -i 's/password [success=2 default=ignore] pam_unix.so obscure sha512/password [success=2 default=ignore] pam_unix.so obscure sha512 minlen=10/' /etc/pam.d/common-password

	#TODO: check if the following lines are correct

	sed -i 's/password	requisite			pam_pwquality.so retry=3/password	requisite			pam_pwquality.so retry=3 minlen=10 lcredit=-1 ucredit=-1 dcredit=-1 maxrepeat=3 usercheck=1 difok=7 enforce_for_root/' /etc/pam.d/common-password
	sed -i 's/PASS_MAX_DAYS	99999/PASS_MAX_DAYS	30/' /etc/login.defs
	sed -i 's/PASS_MIN_DAYS	0/PASS_MIN_DAYS	2/' /etc/login.defs
	# PASS_WARN_AGE is already set to 7
	sed -i 's/Defaults	secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"/Defaults	secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"/' /etc/sudoers
	echo 'Defaults	badpass_message="Password is wrong, please try again!"' | sudo tee -a "/etc/sudoers"
	mkdir /var/log/sudo
	echo "Defaults	timestamp_timeout=5" | sudo tee -a "/etc/sudoers"
	echo "Defaults	passwd_tries=3" | sudo tee -a "/etc/sudoers"
	echo 'Defaults	logfile="/var/log/sudo/sudo.log"' | sudo tee -a "/etc/sudoers"
	echo "Defaults	log_input, log_output" | sudo tee -a "/etc/sudoers"
	echo 'Defaults	iolog_dir="/var/log/sudo/out"' | sudo tee -a "/etc/sudoers"
	echo "Defaults	requiretty" | sudo tee -a "/etc/sudoers"
	chage -M 30 -m 2 -W 7 $USERNAME
	chage -M 30 -m 2 -W 7 root
	echo "libpam-pwquality installed."
elif [ "$ACTION" == "n" ]; then
	echo "Skipping libpam-pwquality installation."
fi

# Setup crontab script
read -p "Setup monitoring script with crontab ? (y/n): " ACTION

if [ "$ACTION" == "y" ]; then
	echo "Setting up monitoring script with crontab..."
	apt install -y net-tools
	crontab -u root -l > crontmp
	echo "*/10 * * * * bash /usr/local/bin/monitoring.sh | wall" > crontmp
	crontab -u root crontmp
	rm crontmp
	wget -O monitoring_raw.sh $MONITORING_URL
	cat monitoring_raw.sh | sed 's/\r$//' > monitoring.sh
	rm monitoring_raw.sh
	mv monitoring.sh /usr/local/bin/monitoring.sh
	echo "Monitoring script setup completed."
elif [ "$ACTION" == "n" ]; then
	echo "Skipping monitoring script setup."
fi

# Setup bonus part
read -p "Setup wordpress ? (y/n): " ACTION

if [ "$ACTION" == "y" ]; then
	echo "Setting up wordpress..."
	apt update -y
	ufw allow 80
	apt install lighttpd wget tar -y
	wget http://wordpress.org/latest.tar.gz
	tar -xvf latest.tar.gz
	rm -rf /var/www/html
	mv wordpress /var/www/html
	chmod -R 755 html
	rm -rf latest.tar.gz
	apt install mariadb-server
	mysql_secure_installation
	read -p "Please renter database root password: " DB_PASSWD
	read -p "Enter password for the database word press: " DB_PASSWD_WP
	mysql -u root --password=DB_PASSWD -e "CREATE DATABASE wordpress_db;"
	mysql -u root --password=DB_PASSWD -e "CREATE USER '$USERNAME'@'localhost' IDENTIFIED BY '$DB_PASSWD_WP';"
	mysql -u root --password=DB_PASSWD -e "GRANT ALL ON wordpress_db.* TO '$USERNAME'@'localhost' IDENTIFIED BY '$DB_PASSWD_WP' WITH GRANT OPTION;"
	mysql -u root --password=DB_PASSWD -e "FLUSH PRIVILEGES;"
	apt install php-cgi php-mysql
	cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
	sed -i "s/define( 'DB_NAME', 'database_name_here' );/define('DB_NAME', 'wordpress_db');/" /var/www/html/wp-config.php
	sed -i "s/define( 'DB_USER', 'username_here' );/define('DB_USER', '$USERNAME');/" /var/www/html/wp-config.php
	sed -i "s/define( 'DB_PASSWORD', 'password_here' );/define('DB_PASSWORD', '$DB_PASSWD_WP');/" /var/www/html/wp-config.php
	lighty-enable-mod fastcgi
	lighty-enable-mod fastcgi-php
	service lighttpd force-reload
	echo "Wordpress setup completed, connect to localhost:80 to continue."
elif [ "$ACTION" == "n" ]; then
	echo "Skipping wordpress setup."
fi

# phpMyAdmin
read -p "Install phpMyAdmin ? (y/n): " ACTION

if [ "$ACTION" == "y" ]; then
	echo "Installing phpMyAdmin..."
	apt install phpmyadmin
	ln -s /usr/share/phpmyadmin/ /var/www
	echo "phpMyAdmin installed."
elif [ "$ACTION" == "n" ]; then
	echo "Skipping reboot."
fi

# Rebooting
read -p "Reboot ? (y/n): " ACTION

if [ "$ACTION" == "y" ]; then
	echo "Rebooting..."
	reboot
elif [ "$ACTION" == "n" ]; then
	echo "Skipping reboot."
fi

echo "Installation completed."
