<?php

function isProjeto(){ 
    $host = $_SERVER['HTTP_HOST'];
    $uri = $_SERVER['REQUEST_URI'];

    return strpos($uri, '/projeto') !== false;
}
function isLocalHost(){ 
    $host = $_SERVER['HTTP_HOST'];
    $uri = $_SERVER['REQUEST_URI'];
    return strpos($host, 'localhost') !== false; 
}
function isLocalHost2(){ 
    $host = $_SERVER['HTTP_HOST'];
    $uri = $_SERVER['REQUEST_URI'];
    return strpos($host, '127.0.0.1') !== false; 
}


if (isLocalHost() || isLocalHost2()){
    define("TIPO_CONEXAO", "Localhost: Conectar em DESENV");
}else if (isProjeto()){
    define("TIPO_CONEXAO", "SITE: Conectar em HOMOLOGACAO");
}else{
    define("TIPO_CONEXAO", "SITE: Conectar em PRODUCAO");
}

echo TIPO_CONEXAO;

?>
