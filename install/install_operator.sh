#!/bin/bash
#set -x -e

echo "|||__________________________________________________|||"
echo "|||                                                  |||"
echo "|||        ELAGABAL NEON OPERATOR INSTALLING         |||"
echo "|||                      DEVNET                      |||"
echo "|||      AUTOMATED ANSIBLE SCRIPT FOR COMMUNITY      |||"
echo "|||__________________________________________________|||"

install_operator () {

  echo -e "\e[1m\e[32mYour Solana RPC instant is localhost\e[0m?"
  select yrpc in "Yes" "No"; do
      case $yrpc in
          Yes ) rpc_var=localhost; echo $rpc_var; break;;  
          No ) echo -e "\e[1m\e[32mEnter solana RPC endpoints:\e[0m" 
          read rpc_var; echo -e $rpc_var;  break;;
      esac
  done
  
  echo -e "\e[1m\e[32mEnter name of your operator:\e[0m"
  read neonevm_user
  echo Your operator name is $neonevm_user
  echo -e "\e[1m\e[32mTo install the operator, a Postgres database is required - enter the name of the database:\e[0m"
  read postgres_db
  echo Postgres Data Base name $postgres_db
  echo -e "\e[1m\e[32mEnter the password for the database:\e[0m"
  read -s postgres_password
  
    echo -e "\e[1m\e[32mDelete Ansible after install?\e[0m"
  select dl in "Yes" "No"; do
    case $dl in
        Yes ) deletea=yes break;;  
        No ) deletea=no break;;
    esac
  done

  if [[ $(which apt | wc -l) -gt 0 ]]
  then
  pkg_manager=apt
  elif [[ $(which yum | wc -l) -gt 0 ]]
  then
  pkg_manager=yum
  fi

  echo -e "\e[1m\e[32mUpdating packages...\e[0m"
  $pkg_manager update

  echo -e "\e[1m\e[32mInstalling ansible, curl, unzip...\e[0m"
  $pkg_manager install -y ansible curl unzip --yes

<<<<<<< HEAD
  ansible-galaxy collection install ansible.posix
  ansible-galaxy collection install community.general

  echo "Docker Uninstall old versions "

#  $pkg_manager remove -y docker docker-engine docker.io containerd runc

  echo "Installing Docker"

  $pkg_manager install -y \
    apt-transport-https \
    ca-certificates \
    software-properties-common \
    curl \
    gnupg \
    lsb-release

  echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"

  $pkg_manager update
  $pkg_manager install -y docker.io
  
    # Linux post-install
  groupadd docker
  usermod -aG docker $USER
  systemctl enable docker
  systemctl start docker

  echo "Downloading Neon operator manager"
=======
  echo -e "\e[1m\e[32mDownloading Neon operator manager\e[0m"
>>>>>>> 07cefe8a632253f4888ed66c037956e1679baabc
  cmd="https://github.com/ElagabalxNode/neon-manager/archive/refs/heads/main.zip"
  ver="main"
  echo "starting $cmd"
  curl -fsSL "$cmd" --output neon_manager.zip
  echo "Unpacking"
  unzip ./neon_manager.zip -d .

  mv neon-manager-$ver* neon_manager
  rm ./neon_manager.zip
  cd ./neon_manager || exit
  
  #shellcheck disable=SC2154
  #echo "pwd: $(pwd)"
  #ls -lah ./

<<<<<<< HEAD
  file=/etc/neon_manager/neon_manager.conf
  if [ -f "$file" ]; then
    echo "$file exists."
    rm -rf /etc/neon_manager/neon_manager.conf
    echo "rewrite config"
  else 
    echo "$file does not exist."
    echo "create new config"
  fi

#  ansible-playbook --connection=local --inventory ./inventory/devnet.yaml --limit local playbooks/pb_config.yaml --extra-vars "{ \
#  'neonevm_solana_rpc': '$rpc_var', \
#  'postgres_db': 'neon-db', \
#  'neonevm_user': '$neonevm_user', \
#  'postgres_user': '$neonevm_user', \
#  'postgres_password': 'neon-proxy-pass' \
#  }"

#https://api.devnet.rpcpool.com/2bf91f35-4ee9-4b22-9b76-cbb725b5a110

  ansible-playbook --connection=local --inventory ./inventory/devnet.yaml --limit local playbooks/install.yml --extra-vars "{ \
=======
  echo -e "\e[1m\e[32mInstall NeonEVM Operator\e[0m"
  ansible-playbook --connection=local --i ./inventory/all.yaml --limit local playbooks/install.yml --extra-vars "{ \
>>>>>>> 07cefe8a632253f4888ed66c037956e1679baabc
  'neonevm_solana_rpc': '$rpc_var', \
  'postgres_db': 'neon-db', \
  'neonevm_user': '$neonevm_user', \
  'postgres_password': 'neon-proxy-pass' \
  }"

  echo -e "\e[1m\e[32mUninstall ansible\e[0m"

  if [[ $deletea="yes" ]];
  then
  $pkg_manager remove ansible --yes
  fi
  
}


while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare ${param}="$2"
        echo $1 $2 // Optional to see the parameter:value result
   fi

  shift
done

echo -e "\e[1m\e[32mThis script will bootstrap a NEON operator. Proceed?\e[0m"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) install_operator break;;  
        No ) echo "\e[1m\e[32mAborting install. No changes will be made."; exit;;
    esac
done
