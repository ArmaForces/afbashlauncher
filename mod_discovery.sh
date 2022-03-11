#!/bin/sh

####warunki poczatkowe

ARMA3UNIXPATH=$(sh ../scripts/collect_variables.sh ARMA3UNIXPATH)
DOMAIN=$(sh ../scripts/collect_variables.sh DOMAIN)
MODPATH=$(sh ../scripts/collect_variables.sh MODPATH)
STARTPWD="$PWD"


if [ ! -f ../cfg/blacklist.txt ]
then
    >../cfg/blacklist.txt
fi

if [ ! -f ../cfg/oldmissions.txt ]
then
    >../cfg/oldmissions.txt
fi

if [ ! -f ../cfg/old_blacklist.txt ]
then
    >../cfg/old_blacklist.txt
fi

if [ ! -d ../temp ]
then
    mkdir ../temp
fi

####koniec warunkow poczatkowych

echo "
Aktualizacja modow z modlist.armafoces.com
"

cd ../temp
#obsolete
#wget -q https://server.armaforces.com:8888/current.txt
curl -s "https://server.armaforces.com:8888/status" > current.json
cat current.json | jq '.modsetName' | sed 's/\"//g' | grep -v "null" | sed 's/\ /%20/g' > current.txt

cd "$STARTPWD"
dos2unix -q ../temp/current.txt

cat ../cfg/blacklist.txt | grep -v -w "`cat ../temp/current.txt`" > ../temp/temp_blacklist.txt
cat ../temp/temp_blacklist.txt > ../cfg/blacklist.txt
rm ../temp/temp_blacklist.txt

#bimbam=$(curl -s https://server.armaforces.com:8888/modsets/downloadable.json | grep -v "\[" | grep -v "\]" | sed -e 's/^[ \t]*//' | tr --delete , | tr --delete , | tr -d '"' | grep -v "modlist_cache"; cat ../temp/current.txt)
curl -s "https://boderator.armaforces.com/api/missions?includeArchive=true&fromDateTime=$(date +"%Y-%m-%d")" > ../temp/missions.json
bimbam=$(cat ../temp/missions.json | jq '.[]  | .modlist' | sed 's/\"//g' | sed 's/.*\///g' | grep -v "null"; cat ../temp/current.txt; echo "Default")
IEFES="$IFS"
IFS='
'

## tego nie rusz
if [ ! "$(echo "$bimbam" | sort | uniq)" = "$(cat ../cfg/oldmissions.txt)" ]
then
    FLAG="1"
    echo -n "$(echo "$bimbam" | sort | uniq)" > ../cfg/oldmissions.txt
    for each in $bimbam
    do
        cat ../cfg/blacklist.txt | grep -v -w "$each" > ../temp/temp_blacklist.txt
        cat ../temp/temp_blacklist.txt > ../cfg/blacklist.txt
        rm ../temp/temp_blacklist.txt
    done
fi
# dotąd

if [ "$FLAG" = "1" ]
then
    PEDEU="$PWD"
    cd ../scripts
    sh blacklist.sh
    cd "$PEDEU"
fi

for each in $(echo  "$bimbam" | sort | uniq)
do
    IFS="$IEFES"

    echo "Sprawdzam $each"


    if [ ! -d ../profile/$each ]
    then
        mkdir ../profile/$each
    fi
    cd ../profile/$each

    if [ ! -d cache ]
    then
        mkdir cache
    fi
    cd cache

    curl -s "https://armaforces.com/api/mod-lists/by-name/$each" > "$each".json
    cat "$each".json | jq '.mods[] | select(.type=="required") | select(.status == "disabled"|not) | {itemId:.itemId, name:.name}' > ../mody.json
    cat "$each".json | jq '.mods[] | select(.type=="optional" or .type=="client_side") | select(.status == "disabled"|not) | {itemId:.itemId, name:.name}' > ../dopuszczone.json
    cat "$each".json | jq '.dlcs[] | .appId' > ../dlcs_appId.txt
    cat "$each".json | jq '.mods[] | select(.status == "disabled"|not) | select(.source=="directory") | .directory' | sed 's/\"//g' > ../extra.txt
    cat "$each".json | jq '.dlcs[] | .directory' | sed 's/\"//g' >> ../extra.txt

    cd ..

    rm -rf cache

    cd "$STARTPWD" ########nie ruszaj!
done

    cat ../cfg/blacklist.txt > ../cfg/old_blacklist.txt
    curl -s "https://server.armaforces.com:8888/status" > ../temp/current.json
    cat ../temp/current.json | jq '.modsetName' | sed 's/\"//g' | grep -v "null" | sed 's/\ /%20/g' > ../temp/current.txt

curl -s "https://boderator.armaforces.com/api/missions?includeArchive=true&fromDateTime=$(date +"%Y-%m-%d")" > ../temp/missions.json
bimbam=$(cat ../temp/missions.json | jq '.[]  | .modlistName' | sed 's/\"//g' | sed 's/.*\///g' | grep -v "null"; cat ../temp/current.txt; echo "Default")
IEFES="$IFS"
IFS='
'
for each in $(echo  "$bimbam" | sort | uniq)
do
    IFS="$IEFES"
    if [ -n "`cat ../cfg/blacklist.txt | grep -w $each`" ]
    then
        echo "
        Modset $each jest na czarnolisto. Pomijam...
        "
    else
        cat "../profile/$each/dopuszczone.json" | jq >> ../temp/dopuszczone.json
        cat "../profile/$each/mody.json" | jq >> ../temp/mody.json
    fi

done

cat ../temp/dopuszczone.json | jq -s 'sort_by(.itemId)|unique_by(.itemId)' > ../profile/dopuszczone.json
cat ../temp/mody.json | jq -s 'sort_by(.itemId)|unique_by(.itemId)' > ../profile/mody.json

rm ../temp/mody.json
rm ../temp/dopuszczone.json

if [ -f ../cfg/dodatkowemody.json ]
then
    echo ""
    echo "Wykryto plik z modami dodatkowymi!"
    echo "Aby zmienic zmodyfikuj zawartosc pliku dodatkowemody.txt w folderze scripts. Mody niewymienione w pliku profile/twojprofil/dopuszczone.txt beda automatycznie pomijane."
    echo "Stosuje..."
    echo ""
else
    echo ""
    echo "#######    Nie wykryto pliku z dodatkowymi modami!!!    #######"
    echo "Stworzono plik z dodatkowymi modami. Znajduja sie tu wszystkie mody dopuszczone przez serwer. Mozesz juz teraz wyedytowac plik dodatkowemody.txt zlokalizowany w folderze scripts jezeli sobie jakichs nie zyczysz."
    echo "Mody niewymienione w pliku profile/twojprofil/dopuszczone.txt beda automatycznie pomijane przy starcie Army."
    echo ""
    echo "Skrypt sprawdza czy posiadasz zainstalowane mody. Jezeli jakichs nie posiadasz zasubskrybuje je w Steam Workshop."
    pwd
    cat ../profile/dopuszczone.json > ../cfg/dodatkowemody.json
    sh changemods.sh cock
    echo "Nacisnij ENTER aby kontynuowac"
    read -r
fi

echo "
Szukam modow do pobrania. Czekaj...
"

echo "@echo off" > ../start.bat
ls "$MODPATH" | tr " " "\n" > ../temp/toparse.txt
>../temp/todownload3.txt

cat ../profile/mody.json | jq '.[]|.itemId'  > ../temp/todownload3.txt
cat ../cfg/dodatkowemody.json | jq '.[]|.itemId'  >> ../temp/todownload3.txt

cat ../temp/todownload3.txt | sort | uniq > ../temp/temp3.txt
>../temp/todownload.txt
cat ../temp/todownload.txt
for each in `cat ../temp/temp3.txt`
do
    if [ "`cat ../temp/toparse.txt | grep "$each"`" = "" ]
    then
        echo "$each" >> ../temp/todownload.txt
    fi
done
rm ../temp/temp3.txt
rm ../temp/todownload3.txt

cat ../temp/todownload.txt | sort | uniq | sed ':a;N;$!ba;s/\n/ /g' > ../temp/todownload2.txt


if [ -s ../temp/todownload2.txt ]
then
    HOWMANY=0
    for each in `cat ../temp/todownload2.txt`
    do
        HOWMANY=$((HOWMANY + 1))
    done
    echo ""
    echo "Musisz uzupelnic $HOWMANY brakujacych modow. Niektore to mody opcjonalne. Mozesz za pomoca skryptu armaforces_zmien_mody_dodatkowe wyrzucic niepotrzebne mody. Nacisnij ENTER aby kontynuowac:"
    read -r
    cd ../bin
    LISTOFMODS=$(cat ../temp/todownload2.txt | sed ':a;N;$!ba;s/\n/ /g')
    WorkshopControl -s -w 107410 $LISTOFMODS
    cd "$MOJPWD"
    echo "Poczekaj az mody sie pobiora. Aby kontynuowac nacisnij ENTER..."
    read -r
fi

echo "Zrobione!
"
