#!/bin/bash

#run docker with local mapping for import database
#docker run -d -p 8080:80 -p 8443:443 -p 8022:22 -v `pwd`/:/var/www/html -v `pwd`/database:/var/lib/phpMyAdmin/upload -t otherdata/centos-docker-lamp:latest

#docker run local just for php without import database
#docker run -d -p 8080:80 -p 8443:443 -p 8022:22 -v `pwd`/:/var/www/html -t otherdata/centos-docker-lamp:latestC

#Como executar esse shell
#env ftp_user=usuario ftp_password=senhaxyz ./deploy.sh hml
#env ftp_user=usuario ftp_password=senhaxyz ./deploy.sh prd

if [ $# -eq 0 ]; then
    echo "Informe hml para deploy em /projeto ou prd para deploy em /"
    exit 1
fi

BASE_DIR=$(pwd)
SERVER_DIR=$1

echo "Parametro informado = $SERVER_DIR"

if [ "$SERVER_DIR" == "hml" ]; then 
    echo "Deploy em homologacao /projeto" 
    SERVER_DIR="htdocs/projeto"
else 
    if [ "$SERVER_DIR" == "prd" ]; then 
        echo "Deploy em producao /" 
        SERVER_DIR="htdocs"
    else 
        echo "hml or prd deve ser informado no primeiro parametro"
        exit 1 
    fi
fi

ftp_host="ftp.unaux.com"
remote_dir=$SERVER_DIR
local_dir=$BASE_DIR;

# user specific parameters must be set in calling environment to allow several ftp users to use it and to avoid password storage
if [[ -z "${ftp_user}" ]]; then
  echo "'ftp_user' must be set"
  exit 1;
fi

if [[ -z "${ftp_password}" ]]; then
  echo "'ftp_password' must be set"
  exit 1;
fi

echo "Iniciando deploy em $ftp_host/$remote_dir"
#descomente o #debug para debug para ver mais informacoes durante o upload
lftp -c "
#debug;
set ftp:use-feat false;
set ftp:ssl-allow off;
open ftp://${ftp_user}:${ftp_password}@${ftp_host}
mkdir -p ${remote_dir};
lcd ${local_dir};
cd ${remote_dir};
mirror --only-newer \
       --ignore-time \
       --reverse \
       --parallel=5 \
       --verbose \
       --exclude .git \
       --exclude deploy.sh \
       --exclude error_log \
       --exclude readme* \
       --exclude pro \
       --exclude security \
       --exclude service \
       --exclude LogPagSeguro \
       --exclude cgi \
       --exclude database \
       --exclude devops \
       --exclude manutencao \
       --exclude .gitignore \
       --exclude-glob composer.* \
       --exclude-glob *.sh" || SAIDA=$?

echo "Finalizando deploy em $ftp_host/$remote_dir"
exit $SAIDA
