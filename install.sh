#!/bin/bash

# User must run the script as root
if [[ $EUID -ne 0 ]]; then
	echo "Please run this script as root"
	exit 1
fi

distro=$(awk '/DISTRIB_ID=/' /etc/*-release | sed 's/DISTRIB_ID=//' | tr '[:upper:]' '[:lower:]')
fileLink='http://152.89.46.241/dl'
myIP=$(ip a s|sed -ne '/127.0.0.1/!{s/^[ \t]*inet[ \t]*\([0-9.]\+\)\/.*$/\1/p}')
networkInterfaceName=$(ip -o -4 route show to default | awk '{print $5}')

if [[ $distro != "ubuntu" ]]; then
	echo "distro not supported please use ubuntu"
	exit 1
fi

echo "This is foreignVPS or domesticVPS?"
echo "   1) foreignVPS"
echo "   2) domesticVPS"
read -r -p "Please select one [1-2]: " -e OPTION
case $OPTION in
1)
  iptables -I INPUT -p tcp -m tcp --dport 80 -j ACCEPT
  iptables -I INPUT -p tcp -m tcp --dport 443 -j ACCEPT
  iptables -I INPUT -p udp -m udp --dport 80 -j ACCEPT
  iptables -I INPUT -p udp -m udp --dport 443 -j ACCEPT
  read -r -p "do you want tunnel to domesticVPS?(y/n) " -e TUNNEL_OPTION
  if [[ "$TUNNEL_OPTION" == "y" || "$TUNNEL_OPTION" == "Y"  || "$TUNNEL_OPTION" == "yes" ]]; then
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
    sysctl -p
    iptables -t nat -I PREROUTING -p tcp --dport 80 -j DNAT --to-destination "$myIP"
    iptables -t nat -I PREROUTING -p udp --dport 80 -j DNAT --to-destination "$myIP"
    iptables -t nat -I PREROUTING -p tcp --dport 443 -j DNAT --to-destination "$myIP"
    iptables -t nat -I PREROUTING -p udp --dport 443 -j DNAT --to-destination "$myIP"
    iptables -t nat -I PREROUTING -p tcp --dport 22 -j DNAT --to-destination "$myIP"
    echo "Enter domesticVPS IP:"
    read -r domesticVPSIP
    iptables -t nat -A PREROUTING -j DNAT --to-destination "$domesticVPSIP"
    iptables -t nat -A POSTROUTING -j MASQUERADE -o "$networkInterfaceName"
    echo "tunnel is done"
  fi
  apt update -y && apt install iptables-persistent nginx -y
  wget $fileLink -O /var/www/html/dl
  iptables-save > /etc/iptables/rules.v4
  ip6tables-save > /etc/iptables/rules.v6
  echo "your server is ready and this is a file for download by domesticVPS:"
  echo "http://$myIP/dl"
  echo "copy this link and use in domesticVPS"
  ;;
2)
    apt update -y && apt upgrade -y && apt install wget cron -y
    echo "Enter Link to Download it:"
    read -r linkToDownload
    echo "#!/bin/bash
while true; do
  wget -qO- $linkToDownload &> /dev/null
done
" >/root/Downloader.sh
  echo "0 * * * * bash /root/Downloader.sh" >/etc/cron.d/at_cronjob
  chmod 0644 /etc/cron.d/at_cronjob
  crontab /etc/cron.d/at_cronjob
  ;;
*)
  echo "$(tput setaf 1)Invalid option$(tput sgr 0)"
  exit 1
  ;;
esac