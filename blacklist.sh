#!/bin/sh

echo "Wybierz modsety, ktore maja byc niesubskrybowane"

PEWDE="$PWD"
cd ../scripts

if [ ! -d ../temp ]
then
mkdir ../temp
fi

while [ ! "$SWATCH" = "z" ]
do
NUMBA=0
STARE="`pwd`"
cd ../temp
curl -s "https://server.armaforces.com:8888/status" > current.json
cat current.json | jq '.modsetName' | sed 's/\"//g' | grep -v "null" | sed 's/\ /%20/g' > current.txt
cd "$STARE"
dos2unix -q ../temp/current.txt
echo "
Na serwerze: $(cat ../temp/current.txt)
"
#bimbam=$(curl -s https://server.armaforces.com:8888/modsets/downloadable.json | grep -v "\[" | grep -v "\]" | sed -e 's/^[ \t]*//' | tr --delete , | tr --delete , | tr -d '"' | grep -v "modlist_cache"; cat ../temp/current.txt)
curl -s "https://boderator.armaforces.com/api/missions?includeArchive=true&fromDateTime=$(date +"%Y-%m-%d")" > ../temp/missions.json
bimbam=$(cat ../temp/missions.json | jq '.[]  | .modlist' | sed 's/\"//g' | sed 's/.*\///g'; cat ../temp/current.txt; echo "Default")
IEFES="$IFS"
IFS='
'
for each in $(echo  "$bimbam" | sort | uniq)
do
IFS="$IEFES"
NUMBA=$((NUMBA+1))
ISACTIVE=$(cat ../cfg/blacklist.txt | grep -w "$each")

if [ "$ISACTIVE" = "" ]
then
echo "$NUMBA.	Pobieranie	$each"
else
echo "$NUMBA.	Pomijanie	$each"
fi

done

echo -n "
1-$NUMBA	- przelacz pomijanie/pobieranie.
z	- zapisz i zakoncz
Wybor: "
read SWATCH

if [ ! "$SWATCH" = "z" ]
then
NUMBA=0
STARE="`pwd`"
cd ../temp
curl -s "https://server.armaforces.com:8888/status" > current.json
cat current.json | jq '.modsetName' | sed 's/\"//g' | grep -v "null" | sed 's/\ /%20/g' > current.txt
cd "$STARE"
dos2unix -q ../temp/current.txt
#bimbam=$(curl -s https://server.armaforces.com:8888/modsets/downloadable.json | grep -v "\[" | grep -v "\]" | sed -e 's/^[ \t]*//' | tr --delete , | tr --delete , | tr -d '"' | grep -v "modlist_cache"; cat ../temp/current.txt)
curl -s "https://boderator.armaforces.com/api/missions?includeArchive=true&fromDateTime=$(date +"%Y-%m-%d")" > ../temp/missions.json
bimbam=$(cat ../temp/missions.json | jq '.[]  | .modlist' | sed 's/\"//g' | sed 's/.*\///g'; cat ../temp/current.txt; echo "default")
IEFES="$IFS"
IFS='
'
for each in $(echo  "$bimbam" | sort | uniq)
do
IFS="$IEFES"
NUMBA=$((NUMBA+1))
if [ "$SWATCH" = "$NUMBA" ]
then
if [ "`cat ../cfg/blacklist.txt | grep -w "$each"`" = "" ]
then
echo "$each" >> ../cfg/blacklist.txt
elif [ "`cat ../cfg/blacklist.txt | grep -w "$each"`" = "$each" ]
then
cat ../cfg/blacklist.txt | grep -v -w "$each" > ../temp/blacklist.txt
cat ../temp/blacklist.txt > ../cfg/blacklist.txt
rm ../temp/blacklist.txt
fi
fi
done
fi

done

cd "$PWD"

echo "Zapisano. Aby kontynuowac nacisnij ENTER..."
read
