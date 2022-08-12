#!/bin/bash
#set -x -e

echo "|||__________________________________________________|||"
echo "|||                                                  |||"
echo "|||        ELAGABAL NEON OPERATOR INSTALLING         |||"
echo "|||                      DEVNET                      |||"
echo "|||      AUTOMATED ANSIBLE SCRIPT FOR COMMUNITY      |||"
echo "|||__________________________________________________|||"

install_operator () {

  echo "Enter solana RPC endpoints: " 
  read rpc_var
  neonevm_user="neon-proxy"
  echo $neonevm_user

  rm -rf sv_manager/

  if [[ $(which apt | wc -l) -gt 0 ]]
  then
  pkg_manager=apt
  elif [[ $(which yum | wc -l) -gt 0 ]]
  then
  pkg_manager=yum
  fi

  echo "Updating packages..."
  $pkg_manager update

  echo "Installing ansible, curl, unzip..."
  $pkg_manager install ansible curl unzip --yes

  ansible-galaxy collection install ansible.posix
  ansible-galaxy collection install community.general  

  echo "Installing Docker"

  $pkg_manager install -y \
    gnupg \
    ca-certificates \
    lsb-release \
    software-properties-common

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  
  echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  # Linux post-install
  groupadd docker
  usermod -aG docker $USER
  systemctl enable docker

  #echo "Downloading Neon operator manager"
  #cmd="https://github.com/ElagabalxNode/1/archive/refs/heads/main.zip"
  #ver="main"
  #echo "starting $cmd"
  #curl -fsSL "$cmd" --output neon_manager.zip
  #echo "Unpacking"
  #unzip ./neon_manager.zip -d .

  #mv neon_manager-$ver* neon_manager
  #rm ./neon_manager.zip
  #cd ./neon_manager || exit
  
  #shellcheck disable=SC2154
  #echo "pwd: $(pwd)"
  #ls -lah ./

  file=/etc/neon_manager/neon_manager.conf
  if [ -f "$file" ]; then
    echo "$file exists."
    rm -rf /etc/neon_manager/neon_manager.conf
    echo "rewrite config"
  else 
    echo "$file does not exist."
    echo "create new config"
  fi

  ansible-playbook --connection=local --inventory ./inventory/devnet.yaml --limit local playbooks/pb_config.yaml --extra-vars "{ \
  'neonevm_solana_rpc': '$rpc_var', \
  'postgres_db': 'neon-db', \
  'neonevm_user': '$neonevm_user', \
  'postgres_user': '$neonevm_user', \
  'postgres_password': 'neon-proxy-pass' \
  }"

  ansible-playbook --connection=local --inventory ./inventory/devnet.yaml --limit local playbooks/install.yml --extra-vars "@/etc/neon_manager/neon_manager.conf" 

  echo "See your logs by: docker logs neonevm "

}


while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare ${param}="$2"
        echo $1 $2 // Optional to see the parameter:value result
   fi

  shift
done

sv_manager_version=${sv_manager_version:-latest}


echo "This script will bootstrap a NEON operator. Proceed?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) install_operator break;;  
        No ) echo "Aborting install. No changes will be made."; exit;;
    esac
done