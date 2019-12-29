#!/bin/bash

#run docker with local mapping for import database
#docker run -d -p 8080:80 -p 8443:443 -p 8022:22 -v `pwd`/:/var/www/html -v `pwd`/database:/var/lib/phpMyAdmin/upload -t otherdata/centos-docker-lamp:latest

#docker run local just for php without import database
#docker run -d -p 8080:80 -p 8443:443 -p 8022:22 -v `pwd`/:/var/www/html -t otherdata/centos-docker-lamp:latestC

#exclui diretorio git e arquivo sh do deploy e manda para o servidor
#find .  ! -path '*/.git*' ! -path '*deploy*' -exec echo "jandrei-".{} \;

#find . ! -path '*/.git/*' ! -path '*deploy*' -exec curl -v -u unaux_24986242:asdasdasdasdasdasqweqwe --ftp-create-dirs -T {} ftp://ftp.unaux.com/htdocs/{} \;


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
       --exclude .git/ \
       --exclude deploy.sh \
       --exclude .gitignore \
       --exclude-glob composer.* \
       --exclude-glob *.sh" || exit $?
