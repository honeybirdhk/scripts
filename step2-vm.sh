#!/bin/bash
sudo apt install --yes docker-compose
docker-compose --version
git clone https://github.com/Azure-Samples/azure-voting-app-redis.git
cd azure-voting-app-redis
sudo docker-compose up -d
sudo docker images
sudo docker ps

ipadd=$(ifconfig | grep 'inet ' | head -1 | cut -d " " -f 10)

echo "You can open a browser to http://<external ip>:8080"
echo "#########"
echo "#"
echo "#"
echo "#"
echo "After successfull, plese clean up the resource by \$sudo docker-compose down"
echo "#"
echo "#"
echo "#"
echo "#########"
