#!/bin/sh

wget https://launcher.mojang.com/v1/objects/c5f6fb23c3876461d46ec380421e42b289789530/server.jar 

mkdir uploadFolder/minecraft-server
mv server.jar uploadFolder/minecraft-server

cd uploadFolder/minecraft-server/
java -Xmx1024M -Xms1024M -jar server.jar nogui
sed -i.bak 's/eula=false/eula=true/' eula.txt
sed -i.bak 's/enable-rcon=false/enable-rcon=true/' server.properties
sed -i.bak "s/rcon.password=.*/rcon.password=$RCON_PASSWORD/" server.properties
sed -i.bak 's/enforce-whitelist=false/enforce-whitelist=true/' server.properties
sed -i.bak 's/spawn-protection=16/spawn-protection=0/' server.properties

java -Xmx1024M -Xms1024M -jar server.jar nogui

cd ..
tar czvf minecraft-server.tar.gz minecraft-server
