#!/bin/bash

if [[ $1 == "--help" || $1 == "-h" || $1 == "" ]];then
  echo -e "\t1) ./minio_upload.sh File \t\t\tupload to local  minio when local is Controller"
  echo -e "\t2) ./minio_upload.sh File Controllerip \t\tupload to remote minio"
  echo -e "\t2) ./minio_upload.sh File Controllerip y \t'y' means configing that connect to Controller without password, run only once"
  exit
fi

file=$1
controllerip=$2
nopasswd=$3

function upload(){
    minio_pod=$(kubectl get po | grep "minio" | awk '{print $1}')
    if [[ ${minio_pod} == "" ]];then
       echo "minio pod is not found"
       exit
    fi
    filename=$(basename $1)
    if [[ $2 == "local" ]];then
      filepath=$1
    else
      filepath=/root/${filename}
    fi
    kubectl cp $filepath ${minio_pod}:/opt/bitnami/minio-client/bin -c minio
    kubectl exec -it ${minio_pod} -c minio -- bash -c "bin/mc cp /opt/bitnami/minio-client/bin/$filename local/agent-update/ && rm -rf /opt/bitnami/minio-client/bin/$filename"
}

function ssh_upload(){
    scp $1 root@$2:/root/
    ssh root@$2 << EOF
    $(declare -f upload); upload $1; rm -f /root/$1; exit
EOF
}

function passwd_free_login(){
  echo "正在配置免密连接$1..."
  if [[ ! -f ~/.ssh/id_rsa.pub ]];then
     ssh-keygen -t rsa
  fi
  ssh-copy-id root@$1
}

if ! [ -f $file ];then
  echo "$file: No such file or it is a Directory"
  exit
fi

if [[ $controllerip != "" ]];then
  if [[ $nopasswd == "y" ]];then
    passwd_free_login $controllerip
  fi
  ssh_upload $file $controllerip
else
  upload $file "local"
fi
