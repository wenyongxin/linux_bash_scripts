install-agent.V1.6.sh

该脚本能够自动安装zabbix-agent与snmp的应用。
执行方法： bash install-agent.V1.6.sh c 8.8.8.8 本机IP地址

该脚本的处理架构适合于zabbix-server、zabbix-proxy、zabbix-agent三点连成一线的架构。

该脚本可应用到  centos/redhat、ubunut、debian、freebsd、suse、ecool等系统。

-------------------------------------------------------------------------------------------

install_monitor_for_Linux_V0.04.sh

用途：用于Linux、windows系统的zabbix监控程序安装，能够实现多线程批量同时安装

Linux：
基于Linux ssh功能实现的远程批量安装脚本，所使用的工具为sshpass，能够实现免验证、自动输入密码功能。

Windows：
基于windows的远程桌面功能。所使用的rdesktop，能够实现调用远程桌面以及网络磁盘的功能。

该脚本内置cacti的批量添加主机的功能，是基于该工具的php内置功能二次开发。

-------------------------------------------------------------------------------------------


