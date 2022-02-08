#!/bin/sh

DOMAIN=$(cat scripts/adres.txt)

if [ ! -d temp ]
then
mkdir temp
fi

if [ ! -d status ]
then
mkdir status
fi

cd temp
curl -s "https://server.armaforces.com:8888/status" > current.json
cat current.json | jq '.modsetName' | sed 's/\"//g' | grep -v "null" | sed 's/\ /%20/g' > current.txt
cd ..
dos2unix -q temp/current.txt

#gamedig --type arma3 --host $DOMAIN --port 2302 > temp/temp.txt
>temp/temp.txt
#port2302="`cat temp/temp.txt | grep -v error | sed -e 's/^.*\"name\":\"\(.*\)\",\"map.*$/\1/'`"
port2302="`cat temp/current.json | jq '.status' | grep -v "Stopped"`"
echo -n "$port2302" > status/2302

#cat temp/temp.txt | grep -v error | sed -e 's/^.*\"map\":\"\(.*\)\",\"password.*$/\1/' > temp/map.txt
#cat temp/temp.txt | grep -v error | sed -e 's/^.*\"game\":\"\(.*\)\",\"steamappid.*$/\1/' > temp/mission.txt
#cat temp/temp.txt | grep -v error | sed -e 's/^.*\"players\":\[\(.*\)\],\"bots.*$/\1/' > temp/tempplayers.txt
cat temp/current.json | jq '.map' > temp/map.txt
cat temp/current.json | jq '.name' > temp/mission.txt
cat temp/current.json | jq '.name' > status/2302name
cat temp/current.json | jq '.players' > temp/tempplayers.txt
cat temp/current.json | jq '.playersMax' > temp/tempplayersMax.txt

IEFES="$IFS"
IFS='{}'
>temp/tempplayers2.txt
for each in `cat temp/tempplayers.txt`
do
echo "$each" >> temp/tempplayers2.txt
done
IFS="$IEFES"

cat temp/tempplayers2.txt | grep -v error | sed -e 's/^.*\"name\":\"\(.*\)\",\"score.*$/\1/' | grep -v "," > temp/tempplayers3.txt

echo "Host: $DOMAIN
Port: 2302
Nazwa: `cat temp/mission.txt`
Mapa: `cat temp/map.txt`
Modset: `cat temp/current.txt`
Gracze: `cat temp/tempplayers.txt`/`cat temp/tempplayersMax.txt`" > status/2302info.txt

#gamedig --type arma3 --host $DOMAIN --port 2310 > temp/temp.txt
>temp/temp.txt
port2310="`cat temp/temp.txt | grep -v error | sed -e 's/^.*\"name\":\"\(.*\)\",\"map.*$/\1/'`"
echo -n "$port2310" > status/2310

cat temp/temp.txt | grep -v error | sed -e 's/^.*\"map\":\"\(.*\)\",\"password.*$/\1/' > temp/map.txt
cat temp/temp.txt | grep -v error | sed -e 's/^.*\"game\":\"\(.*\)\",\"steamappid.*$/\1/' > temp/mission.txt
cat temp/temp.txt | grep -v error | sed -e 's/^.*\"players\":\[\(.*\)\],\"bots.*$/\1/' > temp/tempplayers.txt

IEFES="$IFS"
IFS='{}'
>temp/tempplayers2.txt
for each in `cat temp/tempplayers.txt`
do
echo "$each" >> temp/tempplayers2.txt
done
IFS="$IEFES"

cat temp/tempplayers2.txt | grep -v error | sed -e 's/^.*\"name\":\"\(.*\)\",\"score.*$/\1/' | grep -v "," > temp/tempplayers3.txt

echo "Host: $DOMAIN
Port: 2310 
Nazwa: `cat status/2310`
Mapa: `cat temp/map.txt`
Misja: `cat temp/mission.txt`
Modset: `cat temp/current.txt`
Gracze:
`cat temp/tempplayers3.txt`" > status/2310info.txt
rm temp/current.txt
