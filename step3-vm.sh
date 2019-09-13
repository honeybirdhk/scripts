#!/bin/bash
acrname="ierg4350"
myResourceGroup="myRecourseGroup"
myAKSCluster="myAKSCluster"

cd ~/azure-voting-app-redis
sudo docker-compose down
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

az login
az group create --name $myResourceGroup --location eastus

az acr create --resource-group $myResourceGroup \
	--name $acrname \
	--sku Basic

sudo apt install -y gnupg2 pass
gpg2 --full-generate-key
gpg2 -k
pass init “[uid]”

sudo az acr login --name $acrname
acrloginserver=$(az acr list --resource-group $myResourceGroup \
	--query "[].{acrLoginServer:loginServer}" \
	--output table | grep azure)

sudo docker tag azure-vote-front $acrloginserver/azure-vote-front:v1
sudo docker images
sudo docker push $acrloginserver/azure-vote-front:v1
echo "wait for few minutes......"
az acr repository list --name $acrname --output table
az acr repository show-tags --name $acrname \
	--repository azure-vote-front \
	--output table

result=$(az ad sp create-for-rbac --skip-assignment)
appid=$(echo $result | grep appId | cut -d ',' -f 1 | cut -d ':' -f 2 | tr -d \")
password=$(echo $result | grep password | cut -d ',' -f 4 | cut -d ':' -f 2 | tr -d \")

acrid=$(az acr show --resource-group $myResourceGroup --name $acrname --query "id" --output tsv)
az role assignment create --assignee $appid --scope $acrid --role acrpull
az aks create --resource-group $myResourceGroup \
	--name $myAKSCluster \
	--node-count 2 \
	--service-principal $appid \
	--client-secret $password \
	--generate-ssh-keys
echo "wait for few minues.....\n"
sudo az aks install-cli
sudo az aks get-credentials --resource-group $myResourceGroup --name $myAKSCluster
sudo kubectl get nodes
