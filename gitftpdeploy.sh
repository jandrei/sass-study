#!/bin/bash

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

git config git-ftp.user $ftp_user
git config git-ftp.url $ftp_host
git config git-ftp.password $ftp_password
git config git-ftp.syncroot $local_dir
git config git-ftp.remote-root $remote_dir

git-ftp push