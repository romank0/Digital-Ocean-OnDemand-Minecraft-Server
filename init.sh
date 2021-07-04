#!/bin/bash

if [ "$RCON_PASSWORD" == "" ]; then
  echo "specify RCON_PASSWORD env variable"
  exit 1
fi

SERVER_JAR_URL=$1

if [ "$SERVER_JAR_URL" == "" ]; then

  SERVER_JAR_URL=$(curl -s 'https://www.minecraft.net/en-us/download/server' -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36'    -H 'accept-language: en-GB,en-US;q=0.9,en;q=0.8'   --compressed | grep server.jar | sed -e 's/.*<a href=["'"'"']//' -e 's/["'"'"'].*$//')

  if [ "$SERVER_JAR_URL" == "" ]; then
    echo "specify server jar url as a parameter"
    exit 1
  fi
fi

wget $SERVER_JAR_URL 

mkdir -p uploadFolder/minecraft-server
mv server.jar uploadFolder/minecraft-server

cd uploadFolder
docker-compose run jre java -Xmx1024M -Xms1024M -jar server.jar nogui
cd minecraft-server
sed -i.bak 's/eula=false/eula=true/' eula.txt
sed -i.bak 's/enable-rcon=false/enable-rcon=true/' server.properties
sed -i.bak "s/rcon.password=.*/rcon.password=$RCON_PASSWORD/" server.properties
sed -i.bak 's/enforce-whitelist=false/enforce-whitelist=true/' server.properties
sed -i.bak 's/white-list=false/white-list=true/' server.properties
sed -i.bak 's/spawn-protection=16/spawn-protection=0/' server.properties
sed -i.bak 's/enable-command-block=false/enable-command-block=true/' server.properties 
sed -i.bak 's/allow-flight=false/allow-flight=true/' server.properties 

echo "allow-cheats=true" >> server.properties

cd ..
docker-compose run jre java -Xmx1024M -Xms1024M -jar server.jar nogui

tar czvf minecraft-server.tar.gz minecraft-server
