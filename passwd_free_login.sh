#!/bin/bash

if [[ $1 == "--help" || $1 == "-h" || $1 == "" ]];then
  echo -e "\n\t./$(basename $0) \$IP \$USER : ssh/scp the IP without password"
  echo -e "\t./$(basename $0) \$IP \$USER --update : 当本机的ip,mac地址等发生变化后，执行此语句, 重新添加新的key到远端"
  echo -e "\t./$(basename $0) \$IP \$USER --allowKeyAuth : 若配置了免密成功后,登录仍需要输入密码,则远端要允许public key认证方式才能免密连接\n"
  exit
fi

function config_pubkey_auth(){
  sshd_config_file=/etc/ssh/sshd_config
  if [ -f $sshd_config_file ];then
    line=$(grep -nE "^[^#]*PubkeyAuthentication +[no|No|NO]" $sshd_config_file | cut -d: -f1 | head -1)
    if [[ ${line} != "" ]];then
       sed -i "${line} c PubkeyAuthentication yes" $sshd_config_file
       echo "将$1的文件$sshd_config_file第${line}行 PubkeyAuthentication no 修改为: PubkeyAuthentication yes"
    else
      sed -i "$ a PubkeyAuthentication yes" $sshd_config_file
      echo "$1的文件$sshd_config_file末尾添加: PubkeyAuthentication yes"
    fi
    service sshd restart
  else
    echo "$sshd_config_file: No such file on $1"
  fi
}

function checkip(){
  num="([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])"
  checkip=$(echo $serverip | grep -oE "^${num}\.${num}\.${num}\.${num}$")
  if [[ ${checkip} != $serverip ]];then
    echo "$serverip: ip format is not valid"
    exit 1
  fi
  ping -c 1 -W 3 $serverip > /dev/null
  if [[ $? != 0 ]];then
    echo "cannot connect to $serverip"
    exit 1
  fi
}

serverip=$1
user=$2
checkip
if [[ "${user}" == "" ]];then
  echo "Please input remote user name, for example: root"
  exit 1
fi
if [[ "${3}" != "" && ( "${3}" != "--update" || "${3}" != "--allowKeyAuth") ]];then
  echo "Please input correct flags from: [--update, --allowKeyAuth]"
  exit 1
fi

if [[ "${3}" == "--allowKeyAuth" ]];then
  ssh ${user}@${serverip} << EOF
    $(declare -f config_pubkey_auth); config_pubkey_auth ${serverip}; exit
EOF
  exit
fi


if [[ ! -f ~/.ssh/id_rsa.pub ]];then
  ssh-keygen -t rsa
fi


if [[ "${3}" != "--update" ]];then
  ssh-copy-id ${user}@${serverip} #添加自己的 ~/.ssh/id_rsa.pub 到远端的 ~/.ssh/authorized_keys
else
  ssh-copy-id -f ${user}@${serverip}
fi


