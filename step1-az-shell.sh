#!/bin/bash
myDockerGroup="peter-myDockerGroup-1"
myDockerVM="peter-myDockerVM-1"

az group create \
	--name $myDockerGroup \
	--location eastus

echo "#include https://get/docker.com" > cloud-init.txt

az vm create \
	--resource-group $myDockerGroup \
	--name $myDockerVM \
	--image UbuntuLTS \
	--admin-username ierg4350vm \
	--generate-ssh-keys \
	--custom-data cloud-init.txt

az vm open-port \
	--port 80 \
	--resource-group $myDockerGroup \
	--name $myDockerVM


publicip=$(az vm list-ip-addresses \
	-g $myDockerGroup \
	-n $myDockerVM \
	| grep ipAddress \
	| tr ":" " " \
	| sed -r 's/.{26}//;s/..$//') 


nsgname=$(az network nsg list \
	--resource-group $myDockerGroup | \
	grep networkSecurityGroup | grep id | head -1 | cut -d ":" -f2 | cut -d "/" -f9)

az network nsg rule create \
	--nsg-name $nsgname \
	--name allow_8080 \
	--priority 1010 \
	--resource-group $myDockerGroup \
	--access Allow \
	--destination-port-ranges 8080 \
	--direction Inbound \
	--protocol Tcp


ssh -oStrictHostKeyChecking=no ierg4350vm@$publicip
