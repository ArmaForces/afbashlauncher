#!/bin/sh
cd ..
DOMAIN=$(cat scripts/adres.txt)
while [ true ]
do
sh scripts/gamedig.sh

echo "

"

if [ -z "`cat status/2302`" ]
then
echo "Host: $DOMAIN
Port: 2302
OFFLINE"
else
cat status/2302info.txt
sleep 5
fi

sh scripts/gamedig.sh

echo "

"

if [ -z "`cat status/2310`" ]
then
echo "Host: $DOMAIN
Port: 2310
OFFLINE"
else
cat status/2310info.txt
sleep 5
fi

sh scripts/gamedig.sh

echo "

"



done
