#!/bin/bash
#
# Print out version numbers of installed tools
#

set -e # Bail on the first sign of trouble

echo "Validating that we have the tools we need for SDO..."
make --version
git --version
python --version
curl --version
jq --version
unzip -v | head -n 1
terraform --version
aws --version
ansible --version
node --version
npm --version
docker --version
docker run hello-world
echo "OK"
