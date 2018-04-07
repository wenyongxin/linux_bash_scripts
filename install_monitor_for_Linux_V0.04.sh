#!/bin/sh


#基础的全局变量
Interface="eth|em|xn"
#配置现在源站地址
SOURCE_SOFT="http://8.8.8.8"
PHP=/usr/bin/php
DE=/var/www/html/cacti/cli/add_device.php
GR=/var/www/html/cacti/cli/add_graphs.php
TR=/var/www/html/cacti/cli/add_tree.php
sshpass=/usr/local/bin/sshpass
rdesktop=/usr/local/bin/rdesktop
ssh=/usr/bin/ssh
scp=/usr/bin/scp
#date=`date +%F`
file_name="install-agent.V1.6.sh"
password_list="abc def zhi jkl"
port_list="22"

#proxy的地址
proxy_areo(){
hk="中国/香港 8.8.8.8"
cn="腾讯云 8.8.8.8"
far="台湾远传 8.8.8.8"
hit="台湾中华 8.8.8.8"
eval proxy=\$$proxy
proxy_areo=`echo $proxy | awk '{print $1}'`
proxy_ip=`echo $proxy | awk '{print $2}'`
}

if [ -s ./ip_pass.txt ];then
        cat /dev/null > ./ip_pass.txt
	echo -e "\033[49;32;1m ip_pass.txt is Clear \033[0m"
else
        echo -e "\033[49;34;1m ip_pass.txt is Empty \033[0m"
fi

ssh_cmd(){
	if [ "$system" == "w" ];then
		if [ -z "$ssh_port" ];then
			$rdesktop -z -a 16 -u administrator -p "$password" "$address" -r disk:myshare=/var/www/data/windows -0 > /dev/null 2>&1
		else
			$rdesktop -z -a 16 -u administrator -p "$password" "$address:$ssh_port" -r disk:myshare=/var/www/data/windows -0 > /dev/null 2>&1
		fi
	else
	if [ "$system" == "c" ];then
		#获取系统类型 redhat or centos
		system_info=`$sshpass -p "$password" $ssh -o StrictHostKeyChecking=no -p "$ssh_port" root@"$address" 'cat /etc/redhat-release' | awk '{print $1}'`
		echo $address $system_info
		if [ "$system_info" == "Red" ];then
			$sshpass -p "$password" $ssh -o StrictHostKeyChecking=no -p "$ssh_port" root@"$address" 'rpm -ivh $SOURCE_SOFT/client/redhat/wget-1.12-5.el6_6.1.x86_64.rpm > /dev/null 2>&1 && echo -e "\033[49;32;1m '$address' wget is install \033[0m"'
			$sshpass -p "$password" $ssh -o StrictHostKeyChecking=no -p "$ssh_port" root@"$address" 'wget $SOURCE_SOFT/client/redhat/update_yum.sh > /dev/null 2>&1'
			$sshpass -p "$password" $ssh -o StrictHostKeyChecking=no -p "$ssh_port" root@"$address" 'bash update_yum.sh '$address''
		else 
			$sshpass -p "$password" $ssh -o StrictHostKeyChecking=no -p "$ssh_port" root@"$address" 'yum -y install wget > /dev/null 2>&1 && echo -e "\033[49;32;1m '$address' wget is install \033[0m"'
		fi
	elif [ "$system" == "u" ];then
		$sshpass -p "$password" $ssh -o StrictHostKeyChecking=no -p "$ssh_port" root@"$address" 'apt-get -y install wget > /dev/null 2>&1 && echo -e "\033[49;32;1m '$address' wget is install \033[0m"'
	elif [ "$system" == "f" ];then
		$sshpass -p "$password" $ssh -o StrictHostKeyChecking=no -p "$ssh_port" root@"$address" 'pkg_add $SOURCE_SOFT/client/pack_freebsd/libidn-1.27.tbz && echo "'$address' libidn is install"'
		[ $? -eq 0 ] && $sshpass -p "$password" $ssh -o StrictHostKeyChecking=no -p "$ssh_port" root@"$address" 'pkg_add $SOURCE_SOFT/client/pack_freebsd/gettext-0.18.3.tbz && echo "'$address' gettext is install"'
		[ $? -eq 0 ] && $sshpass -p "$password" $ssh -o StrictHostKeyChecking=no -p "$ssh_port" root@"$address" 'pkg_add $SOURCE_SOFT/client/pack_freebsd/libiconv.tbz && echo  "'$address' libiconv is install"'
		[ $? -eq 0 ] && $sshpass -p "$password" $ssh -o StrictHostKeyChecking=no -p "$ssh_port" root@"$address" 'pkg_add $SOURCE_SOFT/client/pack_freebsd/wget.tbz && echo "'$address' wget is install"'
	elif [ "$system" == "s" ];then
		$sshpass -p "$password" $ssh -o StrictHostKeyChecking=no -p "$ssh_port" root@"$address" 'zypper install -y wget > /dev/null 2>&1 && echo -e "\033[49;32;1m '$address' wget is install \033[0m"'
	elif [ "$system" == "e" ];then
		echo -e "\033[49;32;1m '$address' wget is install \033[0m"
	fi
	$sshpass -p "$password" $ssh -o StrictHostKeyChecking=no -p "$ssh_port" root@"$address" 'wget -P /root/ -q -N $SOURCE_SOFT/'$file_name' && echo -e "\033[49;32;1m '$address' '$file_name' is down \033[0m"'
	$sshpass -p "$password" $ssh -o StrictHostKeyChecking=no -p $ssh_port root@"$address" 'chmod a+x '/root/$file_name''
	$sshpass -p "$password" $ssh -o StrictHostKeyChecking=no -p $ssh_port root@"$address" ''/root/$file_name' '$system' '$address' '$proxy_ip''
#	$sshpass -p "$password" $scp -o StrictHostKeyChecking=no -P"$ssh_port" root@$address:/root/$address.log ./$date/ && echo -e "\033[49;32;1m $address monitor is OK \033[0m"
	$sshpass -p "$password" $ssh -o StrictHostKeyChecking=no -p $ssh_port root@"$address" 'rm -rf '/root/$address.log''
	fi
}

esxi_cmd(){
	$sshpass -p "$password" $ssh -o StrictHostKeyChecking=no -p22 root@"$address" 'esxcli system snmp set --enable true'
	$sshpass -p "$password" $ssh -o StrictHostKeyChecking=no -p22 root@"$address" 'esxcli system snmp set --communities efun'
	/usr/local/nagios/libexec/check_snmp -H $address -C efun -o sysUpTime.0 > /dev/null 2>&1 
	if [ $? -eq 0 ]; then
                echo -e "\033[49;32;1m SNMP  is OK \033[0m $address"
        else
                echo -e "\033[49;31;1m SNMP  is problem \033[0m $address"
        fi
}

file_cmd(){
	ssh_cmd
}

file_cmd_auto(){
	ssh_port=`cat ip_pass.txt | grep $address | awk '{print $2}'`
	password=`cat ip_pass.txt | grep $address | awk '{print $3}'`
	ssh_cmd
}

selinux(){
	$sshpass -p "$password" $ssh -o StrictHostKeyChecking=no -p "$ssh_port" root@"$address" 'setenforce 0'
        $sshpass -p "$password" $ssh -o StrictHostKeyChecking=no -p "$ssh_port" root@"$address" 'sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config > /dev/null 2>&1 && echo -e "\033[49;32;1m '$address' SElinux is stop \033[0m"'
        $sshpass -p "$password" $ssh -o StrictHostKeyChecking=no -p "$ssh_port" root@"$address" '/etc/init.d/snmpd restart > /dev/null 2>&1 && echo -e "\033[49;32;1m '$address' snmp alread restart \033[0m"'
}

selinux_auto(){
        ssh_port=`cat ip_pass.txt | grep $address | awk '{print $2}'`
        password=`cat ip_pass.txt | grep $address | awk '{print $3}'`
	selinux
}

cacti_windows(){
        $PHP $DE --description=$address --ip=$address --template=7 --avail=snmp --version=2 --community="efun" > /dev/null 2>&1 && echo -e "\033[49;32;1m $address \033[0m host is create" 
        HOST_ID=`$PHP $GR --list-hosts | grep -w $address | awk '{print $1}'`
	Interface_num=`snmpwalk -v 2c -c efun $address .1.3.6.1.2.1.4.20.1.2 | grep -v "127.0.0.1" | awk '{print $NF}'`
	for INI in $Interface_num
	do
		name=`snmpwalk -v 2c -c efun $address .1.3.6.1.2.1.2.2.1.2.$INI | awk -F "STRING: " '{print $NF}'`
                $PHP $GR --graph-type=ds --graph-template-id=2 --host-id=$HOST_ID --snmp-query-id=1 --snmp-query-type-id=13 --snmp-field=ifDescr --snmp-value="$name" > /dev/null 2>&1 && echo -e "\033[49;32;1m $address \033[0m $name is OK"
	done
}

cacti(){
        $PHP $DE --description=$address --ip=$address --template=3 --avail=snmp --version=2 --community="efun" > /dev/null 2>&1 && echo -e "\033[49;32;1m $address \033[0m host is create" 
        HOST_ID=`$PHP $GR --list-hosts | grep -w $address | awk '{print $1}'`
        $PHP $GR --host-id=$HOST_ID --graph-type=cg --graph-template-id=4 > /dev/null 2>&1 && echo -e "\033[49;32;1m $address \033[0m CPU is OK"
        $PHP $GR --host-id=$HOST_ID --graph-type=cg --graph-template-id=11 > /dev/null 2>&1 && echo -e "\033[49;32;1m $address \033[0m Load Average is OK"
        $PHP $GR --host-id=$HOST_ID --graph-type=cg --graph-template-id=13 > /dev/null 2>&1 && echo -e "\033[49;32;1m $address \033[0m Memory usage is OK"
        for INT in $(snmpwalk -v 2c -c efun $address ifDescr | awk -F ":" '{print $NF}' | grep -E $Interface)
        do
                $PHP $GR --graph-type=ds --graph-template-id=2 --host-id=$HOST_ID --snmp-query-id=1 --snmp-query-type-id=13 --snmp-field=ifDescr --snmp-value="$INT" > /dev/null 2>&1 && echo -e "\033[49;32;1m $address \033[0m $INT is OK"
       done
}

cacti_create(){
                HOST_ID=`$PHP $GR --list-hosts | grep -w $address | awk '{print $1}' | wc -l`
                if [ $HOST_ID -eq 0 ];then
                        if [ "$system" == "w" ];then
                                cacti_windows
                        else
                                cacti
                        fi
                else
                        echo -e "\033[49;31;1m $address \033[0m alread create it,please check it."
                fi
}

monitor_test(){
	cat /dev/null > /home/nagios/.ssh/known_hosts && echo "echo known_hosts is Empty"
	rv=`zabbix_get -s proxyIP -k efun.route.ping[$proxy_ip,$address]`
	if [ "$rv" == "1" ]; then
                echo -e "\033[49;32;1m Zabbix_Agent  is OK \033[0m $address"
        else
                echo -e "\033[49;31;1m Zabbix_Agent  is problem \033[0m $address"
        fi
	/usr/local/nagios/libexec/check_snmp -H $address -C efun -o sysUpTime.0 > /dev/null 2>&1
	if [ $? -eq 0 ]; then
                echo -e "\033[49;32;1m SNMP  is OK \033[0m $address"
		cacti_create
		echo "alread create cacti ok"
        else
                echo -e "\033[49;31;1m SNMP  is problem \033[0m $address"
		if [ "$system" == "c" ] && [ "$Auto" == "1" ];then
			selinux_auto
			if [ $? -eq 0 ];then
				cacti_create
			else
				echo "please check $address snmp"
			fi
		elif [ "$system" == "c" ];then
			selinux
			if [ $? -eq 0 ];then
				cacti_create
			else
				echo "please check $address snmp"
			fi
		fi
		
		
        fi
}

verify(){
echo -e "\033[49;32;1m ========= 信息匹配中 ======== \033[0m"
for address in $file;do
	{
        for p in $port_list;do
		{
                /usr/local/nagios/libexec/check_tcp -H $address -p $p -t 1 >/dev/null 2>&1
		if [ $? -eq 0 ];then
			PORT=$p
			for pass in $password_list;do
				{
				$sshpass -p "$pass" $ssh -o StrictHostKeyChecking=no -p $PORT root@$address 'id' > /dev/null 2>&1
				if [ $? -eq 0 ]; then
					PASSWORD=$pass
					echo "IPAddress:"$address  "SSH_Port:"$PORT "PassWord:"$PASSWORD
					echo $address $PORT $PASSWORD >> ip_pass.txt
					break
				fi
				}&
			done
			wait
		fi
		}&
        done
	wait
	}&
done
wait
[ -s ip_pass.txt ]
if [ $? -eq 1 ];then
	exit
fi
echo -e "\033[49;32;1m ========================= \033[0m"
}

USAGE="\033[49;32;1m`basename $0` [-s]<ssh port> [-p]<password> [-o]<system> [-H/-f]<ip address/filename> [-pn]<proxy name> [-a]<auto install> [-i]<insert cacti>\033[0m"
if [ $# -eq 0 ];then
echo ""
echo "Wrong Syntax: `basename $0` $*"
echo ""
echo "-----------------------------------------------------------------------------------------------------------------------"
echo -e "|\033[49;31;1m password: \033[0m 被监控端主机的密码"
echo -e "|\033[49;31;1m system: \033[0m 传递参数" "Centos (c) Ubuntu (u) Debian (d) Freebsd (f) Ecool (e) SUSE (s) ESXI (sx) Windows (w)"
echo -e "|\033[49;31;1m ip address: \033[0m 这里可以输入多个IP地址，IP地址以空格分开"
echo -e "|\033[49;31;1m filename: \033[0m 存放IP地址的文本本件"
echo -e "|\033[49;31;1m proxy: \033[0m 选择对应的proxy名称" "国内腾讯云 (cn) 香港 (hk) 台湾远传 (far) 台湾中华 (hit) 韩国 (kr) 东南亚 (sea) 欧洲 (eu) 美洲 (amr) 悉尼 (xn)"
echo "-----------------------------------------------------------------------------------------------------------------------"
echo
echo "例如:"
echo "手动输入密码、端口号及IP地址:"
echo "$0 -s 22 -p A123456 -o c -pn sea -H 172.16.5.240 172.16.5.241"
echo "手动输入密码、端口号及IP文件列表:"
echo "$0 -s 22 -p A123456 -o c -pn sea -f ip.txt"
echo -e "\033[49;31;5m ************************************************************************************************** \033[0m"
echo "从IP列表中读取自动匹配端口号与密码:"
echo "$0 -o c -pn sea -f ip.txt -a"
echo "从IP信息中读取自动匹配端口号与密码:"
echo "$0 -o c -pn sea -H 172.16.5.240 172.16.5.242 172.16.5.243 -a"
echo -e "\033[49;31;5m ************************************************************************************************** \033[0m"
echo "ESXI手动输入IP地址添加监控"
echo "$0 -p A123456 -o ex -H 172.16.5.240 172.16.5.220"
echo "ESXI从ip列表中读取添加监控"
echo "$0 -p A123456 -o ex -f ip.txt"
echo -e "\033[49;31;5m ************************************************************************************************** \033[0m"
echo "自动检索端口号与密码批量修改Selinux状态"
echo "$0 -o c -f ip.txt -a -i"
echo "手动输入端口号与密码批量修改Selinux状态"
echo "$0 -s 22 -p 0new0rd -o c -H 172.16.5.241 172.16.5.242 -i"
echo "--------------------------------------------------------------------------------------------------"
echo -e "Usage: $USAGE"
echo ""
exit 0
fi

while [ $# -gt 0 ]
do 
	case "$1" in
		-s)
			shift
			ssh_port=$1
	;;
		-p)
			shift
			password=$1
	;;
		-o)
			shift
			system=$1
	;;
		-f)
			shift
			file=`cat $1`
			Auto=0
	;;
		-H)
			shift
			file=`echo $* | awk -F "-" '{print $1}'`
			Auto=0
	;;
		-pn)
			shift
			proxy=$1
			proxy_areo
	;;
		-a)
			verify	
			Auto=1
	;;
		-i)
			Insert=1
	;;
	esac
	shift
done


#if [ -d $date ];then
#	echo $date Directory Alread Create
#else
#	mkdir $date
#fi

if [ "$system" == sx ];then
	for address in $file;do
		esxi_cmd
	done
elif [ "$Insert" == "1" ];then
	for address in $file;do
	{
		monitor_test
	}&
	done
	wait
else
	for address in $file;do
		if [ "$Auto" == "1" ];then
		{
			file_cmd_auto
		}&
		else
		{	
			file_cmd
		}&
		fi
	done
	wait
	for address in $file;do
		{
			monitor_test
		}&
	done
	wait
fi
