#!/bin/bash
# 
# Script Name		: confgit.sh
# Author		: Felix Torrealba
# Created		: 20th Marz 2018
# Last Modified		: 20st Sept 2018
# Version		: 1.1
# Asunto		: Facilitar la configuracion del usuario git

##################################### VARS #####################################
rsa_command="ssh-keygen -b 4096 -t rsa -b 4096 -f ~/.ssh/id_rsa -q -P ''"
package=''
str1=/tmp/aux1
str2=/tmp/aux2
am='root'

dpkg --get-selections git 2>/dev/null | grep -o install > $str1
dpkg --get-selections sshpass 2>/dev/null | grep -o install > $str2
user='git'
patch_p=/opt/publico
###################################### Functions ###############################
function installPackage()                                                        # Install sshpass
{
    # git
    if ! grep --quiet 'install' $str1 ; then
        echo Paquete sshpass, no instalado
        sleep 2
        echo Procensando instalacion de sshpass ...
        sleep 2
        apt-get install sshpass -y
    fi
    # sshpass
    if ! grep --quiet 'install' $str2 ; then
        echo Paquete sshpass, no instalado
        sleep 2
        echo Procensando instalacion de sshpass ...
        sleep 2
        apt-get install sshpass -y
    fi
}

function whoiam()
{
    read -p "Quien eres(root):" am
}

function whatishost()
{
    read -p "Indique la ip del equipo anfitrion:" host
}

function clonar()
{
    whatishost
    sleep 0.8
    cd $patch_p
    sudo -u $am -H sh -c "git clone "${user}@${host}:${patch_p}/vencert""
}

function linkGitHost()
{
    installPackage
    whoiam
    whatishost
    sleep 1
    sudo -u $am -H sh -c "ssh -o \"StrictHostKeyChecking no\" -o PasswordAuthentication=no ${user}@${host} 2>/dev/null"
    sudo -u $am -H sh -c "sshpass -p '1z2x3c4v' ssh-copy-id ${user}@${host}"
}

function validateAccessRoot()                                                               
{
    if [ ! "root" == `whoami` ]; then
      echo No eres Root 
      sleep 2
      echo Saliendo ...
      sleep 2
      exit
    fi
}

function create()                                                               
{
    if [ ! -n `getent passwd git` ] && [ -d $patch_p ]; then
        echo Usuario git ya fue creado anteriormente!
        sleep 2.2
        echo Adios!
        sleep 0.8
        exit 1
    elif [ -n `getent passwd git` ] && [ ! -d $patch_p ]; then
        createUserGit; createDirPublico;
    elif [  -n `getent passwd git` ]; then
        createUserGit;
    else
        createDirPublico
    fi
}

function createUserGit()                                                        # Crear Usuario git
{
    am='git'
    echo Creando Usuario git ...
    sleep 0.8
    # Create User git
    groupadd $am && useradd -g git -d /home/$am -c 'git' -s /bin/bash $am \
    && mkdir /home/$am && chown git /home/$am && chgrp $am /home/$am \
    && echo -e "1z2x3c4v\n1z2x3c4v" | passwd $am
    echo Usuario $am ha sido creado.  
    sleep 0.8
    createKeyRSA
}

function createKeyRSA()
{
    echo Generando llave RSA
    sleep 0.8
    sudo -u $am -H sh -c "$rsa_command"
    echo Llave RSA del Usuario $am creada satisfactoriamente.
    sleep 0.8
}

function createDirPublico()                                                        # Crear Usuario git
{
    echo Creando Directorio Publico ...
    sleep 0.8
    # Create Directory'git 
    mkdir /opt/publico && chmod -R 777 /opt/publico && chown git /opt/publico \
    && chgrp git /opt/publico
    echo Directorio Publico ha sido creado.
    sleep 0.8
}

function customGit()                                                            # Personaliza Usuario git
{
    whoiam
    cd /home/$whoiam
    
    createKeyRSA
    
    read -p "Indique su nombre completo, ejemplo Sara Connor:" nom
    read -p "Indique su correo, ejemplo sconnor@skynet.com:" mail

    # Agregar nombre
    sudo -u $am -H sh -c "git config --global user.name \"$nom\""
    
    # Agregar Correo
    sudo -u $am -H sh -c "git config --global user.email \"$mail\""    
    
    #Colores
    sudo -u $am -H sh -c "git config --global color.ui true"
    sudo -u $am -H sh -c "git config --global user.ui true"
    
    echo Se ha configurado git para el usuario $am con la siguiente informacion
    sleep 0.8
    echo Nombre:" $nom $ape" - Correo:" $mail"
    sleep 1
}

function menu()                                                                  # Personaliza Usuario git
{
    title="********************* Configurar Cuenta git VENCERT *********************"
    prompt="Escoja una opcion:"
    options=("Todo en Uno" "Instalar Dependencias" "Configurar git" "Casar Host" "Clonar")

    echo "$title"
    PS3="$prompt "
    select opt in "${options[@]}" "Salir"; do 

        case "$REPLY" in

        1 ) echo "Seleccionaste $opt al presionar $REPLY"; sleep 0.8
        validateAccessRoot; create; customGit; linkGitHost; clonar
        sleep 0.8
        ;;
        2 ) echo "Seleccionaste $opt al presionar $REPLY"; sleep 0.8
        installPackage
        sleep 0.8
        ;;
        3 ) echo "Seleccionaste $opt al presionar $REPLY"; sleep 0.8
        customGit
        ;;
        4) echo "Seleccionaste $opt al presionar $REPLY"; sleep 0.8
        linkGitHost
        ;;
        5) echo "Seleccionaste $opt al presionar $REPLY"; sleep 0.8
        clonar
        ;;
        $(( ${#options[@]}+1 )) ) echo "Adios!"; sleep 0.8; 
        rm $str 2>/dev/null
        unset str; 
        break;;
        *) echo "Opcion Invalida. Intente una vez mas.";continue;;

        esac
    done
}
################################### End Functions ##############################

# Inicia
menu
