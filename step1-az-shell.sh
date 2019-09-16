#!/bin/bash
myResourceGroup="myResourceGroup"
myDockerVM="myDockerVM"

az group create \
	--name $myResourceGroup \
	--location eastus

echo "#include https://get/docker.com" > cloud-init.txt

az vm create \
	--resource-group $myResourceGroup \
	--name $myDockerVM \
	--image UbuntuLTS \
	--admin-username ierg4350vm \
	--generate-ssh-keys \
	--custom-data cloud-init.txt

az vm open-port \
	--port 80 \
	--resource-group $myResourceGroup \
	--name $myDockerVM


publicip=$(az vm list-ip-addresses \
	-g $myResourceGroup \
	-n $myDockerVM \
	| grep ipAddress \
	| tr ":" " " \
	| sed -r 's/.{26}//;s/..$//') 


nsgname=$(az network nsg list \
	--resource-group $myResourceGroup | \
	grep networkSecurityGroup | grep id | head -1 | cut -d ":" -f2 | cut -d "/" -f9)

az network nsg rule create \
	--nsg-name $nsgname \
	--name allow_8080 \
	--priority 1010 \
	--resource-group $myResourceGroup \
	--access Allow \
	--destination-port-ranges 8080 \
	--direction Inbound \
	--protocol Tcp


ssh -oStrictHostKeyChecking=no ierg4350vm@$publicip
