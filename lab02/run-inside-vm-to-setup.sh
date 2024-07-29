#!/bin/bash
#
# Set up the SDO tools VM
#

set -e # Bail on the first sign of trouble
# Operate somewhere where hopefully you won't blat anything with random files
cd /tmp
mkdir setup
cd setup

#
# Normal APT packages - the easy ones
#
echo "Installing normal APT packages"
sudo apt update
sudo apt install make git python-is-python3 curl jq unzip -y
make --version
git --version
python --version
curl --version
jq --version
unzip -v | head -n 1
echo "Installed them packages"

#
# Terraform
#
echo "Installing Terraform"
terraform_binary_url="https://releases.hashicorp.com/terraform/1.3.9/terraform_1.3.9_linux_$(dpkg --print-architecture).zip"
curl "$terraform_binary_url" > /tmp/terraform.zip
unzip /tmp/terraform.zip -d /tmp
sudo mv /tmp/terraform /usr/local/bin
echo "Installed Terraform $(terraform --version)"

#
# AWS CLI
#
# https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
echo "Installing AWS CLI"
case "$(dpkg --print-architecture)" in
    "arm64")
	cpu_arch_for_aws_download="aarch64"
	;;
    "amd64")
	cpu_arch_for_aws_download="x86_64"
	;;
    *)
	die "Unsupported architecture $(dpkg --print-architecture)"
esac
curl "https://awscli.amazonaws.com/awscli-exe-linux-${cpu_arch_for_aws_download}.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
sudo ./aws/install
echo "Installed AWS CLI $(aws --version)"

#
# Ansible
#
# https://docs.ansible.com/ansible/latest/installation_guide/installation_distros.html#installing-ansible-on-ubuntu
echo "Installing Ansible"
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible -y
echo "Installed Ansible $(ansible --version | head -n 1)"

#
# NodeJS + NPM
#
# https://www.digitalocean.com/community/tutorials/how-to-install-node-js-on-ubuntu-22-04
echo "Installing NodeJS and NPM"
curl -sL https://deb.nodesource.com/setup_18.x | sudo bash
sudo apt install nodejs -y
echo "Installed NodeJS $(node --version) and NPM $(npm --version)"

#
# Docker
#
# https://docs.docker.com/engine/install/ubuntu/
echo "Installing Docker"
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release -y
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo usermod -aG docker $USER
echo "Installed $(docker --version)"

# ???
echo "I rannnn" > /tmp/setup/hey.txt

