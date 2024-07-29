#!/bin/bash
#
# Creates the "tools" VM for the System Development and Operations course
#
# Assumes you have bash, multipass and jq
#

set -e # Bail on the first sign of trouble

#
# Always a handy routine to have around
#
die()
{
    echo "Dying because $1" >&2 # Prints to stderr
    exit -1
}

#
# Validate dependencies
#
if which multipass >/dev/null; then echo "Found multipass OK"; else die "Could not find multipass installed"; fi
if which jq >/dev/null; then echo "Found jq OK"; else die "Could not find jq installed"; fi

#
# Create VM and run setup script
#
vm_name="sdotools"
# Check if VM already exists
if multipass info "${vm_name}" 2>/dev/null; then die "VM ${vm_name} already exists"; fi
echo "Starting ${vm_name} VM"
multipass launch --cpus 4 --memory 4G --disk 40G --name "${vm_name}" 22.04
# Ideally would use cloud-init but it doesn't work great in multipass,
# so we need to manually copy in a shell script
multipass transfer run-inside-vm-to-setup.sh "${vm_name}":/tmp/setup.sh
multipass exec "${vm_name}" -- chmod +x /tmp/setup.sh
echo "Running setup script in VM"
multipass exec "${vm_name}" -- /tmp/setup.sh
# Validate tools in VM
multipass transfer validate-tools-installed.sh "${vm_name}":/tmp/setup
multipass exec "${vm_name}" -- chmod +x /tmp/setup/validate-tools-installed.sh
multipass exec "${vm_name}" -- /tmp/setup/validate-tools-installed.sh

#
# Print VM information including IP address (so you can talk to it)
#
vm_ip_address="$(multipass info "${vm_name}" --format json | jq '.info.'"${vm_name}"'.ipv4[0]' -r)"
echo "sdotools VM IP address is ${vm_ip_address}"
echo 'You can list listening UDP and TCP sockets on the VM by saying `multipass exec '"${vm_name}"' -- ss -l -n -p -t -u`'
echo "If the VM has a web app running on port 5001, you can access it in a web browser by going to http://${vm_ip_address}:5001/"
echo 'Copy files into the VM by saying `multipass transfer local/path/to/file '"${vm_name}"':target/path/inside/vm`'
echo 'Mount files (e.g. your source code) into the VM by saying `multipass mount "$PWD" '"${vm_name}"':/work` -- replace $PWD with some directory you would like to share between the host and the VM'
echo 'Get a shell into the VM by saying `multipass shell '"${vm_name}"'`'
echo "Happy hacking :-)"
