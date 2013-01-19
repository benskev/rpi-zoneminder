#!/bin/bash -ex 
#use bash, be verbose

myip=$(hostname -I)

#Check for Root

LUID=$(id -u)
if [[ $LUID -ne 0 ]]; then
echo "$0 must be run as root"
exit 1
fi


#Set Hostname to zoneminder

HOSTNAME=zoneminder
echo "$HOSTNAME" > /etc/hostname
sed -i "s|127.0.1.1 \(.*\)|127.0.1.1 $HOSTNAME|" /etc/hosts

#Install function

install()
{
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get -y \
        -o DPkg::Options::=--force-confdef \
        -o DPkg::Options::=--force-confold \
        install $@
}

#Preseed configuration dpkg UNUSED FOR NOW
#debconf-set-selections << END
#[EXAMPLE] sun-java6-jdk shared/accepted-sun-dlj-v1-1 boolean true
#[EXAMPLE] sun-java6-jre shared/accepted-sun-dlj-v1-1 boolean true
#[EXAMPLE] sun-java6-bin shared/accepted-sun-dlj-v1-1 boolean true
#END

#update repos; install from repos
install zoneminder

#floppy link for apache conf for zoneminder
ln -s /etc/zm/apache.conf /etc/apache2/conf.d/zoneminder.conf

#Restart apache2
service apache2 restart

#Because Tuxradar says so
chmod 4755 /usr/bin/zmfix
zmfix -a
adduser www-data video

#function: clean up after apt
cleanup_apt()
    {
        rm -r /var/cache/apt/*
        mkdir /var/cache/apt/archives
        mkdir /var/cache/apt/archives/partial
    }

#Clean up after apt
cleanup_apt()

#PostInstall config:

# nullmailer
dpkg-reconfigure nullmailer

#Set mysql root user password: 
read -p "Do you want to reconfigure MySQL [y/n]? " cfgMySQL;
if [$cfgMySql == "y"]; then
read -p "Please enter your current MySQL root user password: " cfgMySQLoRtPw;
read -p "Please enter your new MySQL root user password: " cfgMySQLnRtPw1;
read -p "Please enter your new MySQL root user password: " cfgMySQLnRtPw2;
if [ $cfgMySQLnRtPw1 == $cfgMySQLRtPw2 ]; then
mysqladmin -u root $cfgMySQLoRtPw $cfgMySQLnRtPw1
fi
read -p "Please enter your current MySQL admin user password: " cfgMySQLoRtPw;
read -p "Please enter your new MySQL admin user password: " cfgMySQLnRtPw1;
read -p "Please enter your new MySQL admin user password: " cfgMySQLnRtPw2;
if [ $cfgMySQLnRtPw1 == $cfgMySQLRtPw2 ]; then
mysqladmin -u admin $cfgMySQLoRtPw $cfgMySQLnRtPw1
fi
fi

echo "Zoneminder is now available at http://$myip/zm"



