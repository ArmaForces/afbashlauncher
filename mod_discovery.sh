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
    cat "$each".json | jq '.mods[] | select(.type=="required") | {itemId:.itemId, name:.name}' > ../required.json
    cat ../required.json >> ../../../temp/mody.json
    cat "$each".json | jq '.mods[] | select(.type=="optional" or .type=="client_side") | {itemId:.itemId, name:.name}' > ../optional.json
    cat ../optional.json >> ../../../temp/dopuszczone.json
    cat "$each".json | jq '.dlcs[] | {appId:.appId, directory:.directory}' > ../dlcs.json
    cat "$each".json | jq '.mods[] | select(.source=="directory") | .directory' | sed 's/\"//g' > ../extra.txt
    cat "$each".json | jq '.dlcs[] | .appId' > "$each".dlcs_appId
    ## na potem
    cp "$each".dlcs_appId ../dlcs_appId.txt
    cat "$each".json | jq '.dlcs[] | .directory' > "$each".dlcs_directory
    cat "$each".json | jq '.mods[] | .itemId' | sed 's/null/local/g' > "$each".itemId
    ## na potem
    cat "$each".itemId | grep -v local > ../itemId.txt
    cat "$each".json | jq '.mods[] | .directory' > "$each".directory
    cat "$each".json | jq '.mods[] | .name' > "$each".name
    cat "$each".json | jq '.mods[] | .status' | sed 's/null/\"null\"/g' 1> "$each".status
    paste "$each".name "$each".directory | sed 's/\tnull//g' | sed 's/^[^\t]*\t//g' > "$each".rename
    cat "$each".json | jq '.mods[] | .type' > "$each".type
    cat "$each".type | sed 's/server_side/True/g' | sed 's/required/False/g' | sed 's/client_side/False/g' |  sed 's/optional/False/g' > "$each".is_serverside
    cat "$each".type | sed 's/client_side/True/g' | sed 's/optional/True/g' | sed 's/required/False/g' | sed 's/server_side/False/g' > "$each".is_optional
    cat "$each".itemId | sed 's/^/\"/' | sed 's/$/\";/' > "$each".1column
    cat "$each".rename | sed 's/$/\;/' > "$each".2column
    cat "$each".is_serverside | sed 's/$/\;/' > "$each".3column
    cat "$each".is_optional | sed 's/$/\;/' > "$each".4column
    echo "\"id\";" > "$each".11column
    cat "$each".1column >> "$each".11column
    echo "\"name\";" > "$each".22column
    cat "$each".2column >> "$each".22column
    echo "\"is_serverside\";" > "$each".33column
    cat "$each".3column >> "$each".33column
    echo "\"is_optional\";" > "$each".44column
    cat "$each".4column >> "$each".44column
    echo "\"is_map\"" > "$each".55column
    cat "$each".status >> "$each".55column
    paste "$each".11column "$each".22column "$each".33column "$each".44column "$each".55column -d '' | grep -v "disabled" > "$each"_orig.csv

    for eacha in `cat "$each".dlcs_directory`
    do
        echo "\"local\";\"$eacha\";\"True\";\"False\";\"null\"" >> "$each"_orig.csv
    done

    cat "$each"_orig.csv | grep -v '"True";"False";"null"' > "$each".csv
    cat "$each"_orig.csv | grep '"local"' >> "$each".csv

    if [ "$1" = "-d" ]
    then
        echo "@hurrdurr" >> "$each.csv"
    fi

    cd ..

    if [ ! -f "$each.json" ] || [ "`cat cache/$each.json`" != "`cat $each.json`" ]
    then
        FLAG="1"
        cat ../../cfg/blacklist.txt | grep -v -w "$each" > ../../temp/temp_blacklist.txt
        cat ../../temp/temp_blacklist.txt > ../../cfg/blacklist.txt
        rm ../../temp/temp_blacklist.txt
        echo "
Nowa wersja $each!!!
        "
        if [ -f "$each.csv" ]
        then
            rm "$each.csv"
        fi
        if [ -f "$each.json" ]
        then
            rm "$each.json"
        fi
        #wget -N -q "https://server.armaforces.com:8888/modsets/$each.csv"
        cp cache/"$each.csv" "$each.csv"
        cp cache/"$each.json" "$each.json"

        >dopuszczone.csv
        >mody.csv
        >extra.txt


        cat $each.csv | grep id | grep name > $each.txt

##############IEFESYYYYYYYYYYYY#####################
OLDIFS=$IFS
if [ -n "`cat $each.csv | grep -v "\#TYPE" | grep id | grep name | grep ","`" ]
then
    IFS=','
elif [ -n "`cat $each.csv | grep -v "\#TYPE" | grep id | grep name | grep ";"`" ]
then
    IFS=';'
fi
#####################################################

while read aa ab ac ad ae af  #determinuj kolumny
do
    #aa
    if [ -n "`echo "$aa" | grep -v serverside | grep id`" ]
    then
        id_column="aa"
    elif [ -n "`echo "$aa" | grep name`" ]
    then
        name_column="aa"
    elif [ -n "`echo "$aa" | grep is_optional`" ]
    then
        is_optional_column="aa"
    fi
    #ab
    if [ -n "`echo "$ab" |  grep -v serverside | grep id`" ]
    then
        id_column="ab"
    elif [ -n "`echo "$ab" | grep name`" ]
    then
        name_column="ab"
    elif [ -n "`echo "$ab" | grep is_optional`" ]
    then
        is_optional_column="ab"
    fi
    #ac
    if [ -n "`echo "$ac" |  grep -v serverside | grep id`" ]
    then
        id_column="ac"
    elif [ -n "`echo "$ac" | grep name`" ]
    then
        name_column="ac"
    elif [ -n "`echo "$ac" | grep is_optional`" ]
    then
        is_optional_column="ac"
    fi
    #a4
    if [ -n "`echo "$ad" |  grep -v serverside | grep id`" ]
    then
        id_column="ad"
    elif [ -n "`echo "$ad" | grep name`" ]
    then
        name_column="ad"
    elif [ -n "`echo "$ad" | grep is_optional`" ]
    then
        is_optional_column="ad"
    fi
    #a5
    if [ -n "`echo "$ae" |  grep -v serverside | grep id`" ]
    then
        id_column="ae"
    elif [ -n "`echo "$ae" | grep name`" ]
    then
        name_column="ae"
    elif [ -n "`echo "$ae" | grep is_optional`" ]
    then
        is_optional_column="ae"
    fi
    #a6
    if [ -n "`echo "$af" |  grep -v serverside | grep id`" ]
    then
        id_column="af"
    elif [ -n "`echo "$af" | grep name`" ]
    then
        name_column="af"
    elif [ -n "`echo "$af" | grep is_optional`" ]
    then
        is_optional_column="af"
    fi


done < $each.txt

rm $each.txt

while read aa ab ac ad ae af
do
    eval "id=\$$id_column"
    eval "name=\$$name_column"
    eval "is_optional=\$$is_optional_column"
    if [ ! -z $(echo $id | grep "\#TYPE") ]
    then
        echo -n ""
    elif [ "$name" = "\"name\"" ] || [ "$id" = "id" ]
    then
        echo -n ""
    elif [ "$id" = "\"local\"" ] || [ "$id" = "local" ]
    then
        echo $name | tr -d '"' >> extra.txt
    else
        if [ "$is_optional" = "\"True\"" ] || [ "$is_optional" = "True" ]
        then
            echo "\"$(echo $id | tr -d '"')\";\"$(echo $name | tr -d '"')\"" | grep -v "\"id\";\"name\"" | grep -v "\"id\",\"name\"" | grep -v "id;\"name\"" | grep -v "id,\"name\"" | grep -v "id;name" >> dopuszczone.csv
        else
            echo "\"$(echo $id | tr -d '"')\";\"$(echo $name | tr -d '"')\"" | grep -v "\"id\";\"name\"" | grep -v "\"id\",\"name\"" | grep -v "id;\"name\"" | grep -v "id,\"name\"" | grep -v "id;name" >> mody.csv
        fi
    fi
done < $each.csv


IFS=$OLDIFS


    fi
    rm -rf cache

    cd "$STARTPWD" ########nie ruszaj!
done

cat ../temp/mody.json | jq '. | =sort_by(.itemId)'


if [ "$FLAG" = "1" ]
then
    PEDEU="$PWD"
    cd ../scripts
    sh blacklist.sh
    cd "$PEDEU"
fi

if [ "$FLAG" = "1" ] || [ ! "`cat ../cfg/blacklist.txt`" = "`cat ../cfg/old_blacklist.txt`" ]
then

    cat ../cfg/blacklist.txt > ../cfg/old_blacklist.txt
    echo "
Stan modow sie zmienil. Parsuje nowe listy.
    "
    curl -s "https://server.armaforces.com:8888/status" > ../temp/current.json
    cat ../temp/current.json | jq '.modsetName' | sed 's/\"//g' | grep -v "null" | sed 's/\ /%20/g' > ../temp/current.txt

#bimbam=$(curl -s https://server.armaforces.com:8888/modsets/downloadable.json | grep -v "\[" | grep -v "\]" | sed -e 's/^[ \t]*//' | tr --delete , | tr --delete , | tr -d '"' | grep -v "modlist_cache"; cat ../temp/current.txt)
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
        cat "../profile/$each/dopuszczone.csv" | grep -v "\"id\";\"name\"" | grep -v "\"id\",\"name\"" >> ../temp/dopuszczone.csv
        cat "../profile/$each/mody.csv" | grep -v "\"id\";\"name\"" | grep -v "\"id\",\"name\"" >> ../temp/mody.csv
    fi

done

>../profile/dopuszczone.csv
>../profile/mody.csv

cat ../temp/mody.csv | sort | uniq >> ../profile/mody.csv
cat ../temp/dopuszczone.csv | sort | uniq >> ../profile/dopuszczone.csv

rm ../temp/mody.csv
rm ../temp/dopuszczone.csv
fi

if [ -f ../cfg/dodatkowemody.csv ]
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
    cat ../profile/dopuszczone.csv > ../cfg/dodatkowemody.csv
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
IEFES=$IFS
IFS=';'
while read id name
do
    echo $(echo $id | tr -d '"') >> ../temp/todownload3.txt
done < ../profile/mody.csv
while read id name
do
    echo $(echo $id | tr -d '"') >> ../temp/todownload3.txt
done < ../cfg/dodatkowemody.csv
IFS=$IEFES

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

#ls ../mods | grep -v links > ../temp/extratoparse.txt

#TAKICHUJ=$(../profile/$2/extra.txt)

#for each in $TAKICHUJ
#do
#echo "$each ################################################"
#if [ "`cat ../temp/extratoparse.txt | grep "$each"`" = "" ]
#then
#echo "$each" >> ../temp/todownloadextra.txt
#fi
#done


if [ -s ../temp/todownload2.txt ]
then
    HOWMANY=0
    for each in `cat ../temp/todownload2.txt`
    do
        HOWMANY=$((HOWMANY + 1))
    done
    echo ""
    echo "Musisz uzupelnic $HOWMANY brakujacych modow. Jezeli niektore to dodatkowe mody, ktorych nie uzywasz, usun odpowiednie linijki z pliku dodatkowemody.txt zlokalizowanego w folderze scripts."
    echo ""
    echo "Moze zostac otwartych wiele kart przegladarki. Po ile kart na raz chcesz otworzyc?"
    echo ""
    echo "0 i mniej lub $HOWMANY i wyzej - wszystkie na raz (domyslnie)"
    echo "1 - $((HOWMANY - 1)) na tyle podzielone listy."
    echo ""
    HOWMUCH="0"
    while [ -z $(echo "$HOWMUCH" | grep -E "^[[:digit:]]{1,}$") ]
    do
        echo -n "Ile: "
        read HOWMUCH
    done
    COUNT=0
    if [ "$HOWMUCH" = "" ] || [ "$HOWMUCH" -le "0" ] || [ "$HOWMUCH" -eq "$HOWMANY" ]
    then
        HOWMUCH=$((HOWMANY + 1))
    fi
    for each in `cat ../temp/todownload2.txt`
    do
        echo "start https://steamcommunity.com/sharedfiles/filedetails/?id=$each" >> ../temp/otwo.bat
        COUNT=$((COUNT + 1))
        if [ "$((COUNT % HOWMUCH))" = "0" ]
        then
            echo "echo Pozostalo $COUNT z $HOWMANY modow do zasubskrybowania" >> ../temp/otwo.bat
            echo "pause" >> ../temp/otwo.bat
        fi
    done
    echo "echo Poczekaj az zostana pobrane mody. Po zakonczeniu nacisnij ENTER." >> ../temp/otwo.bat
    echo "pause" >> ../temp/otwo.bat
    echo ""
    #echo "Zostana otwarte strony Steam Workshop. Aby kontynuowac nacisnij ENTER."
    echo "Zostana pobrane mody. Aby kontynuowac nacisnij ENTER."
    read -r
    MOJPWD=$(pwd)
    cd ../bin
    #for each in `cat ../temp/todownload2.txt`
    #do
    #WorkshopControl -s -w 107410 $each
    LISTOFMODS=$(cat ../temp/todownload2.txt | sed ':a;N;$!ba;s/\n/ /g')
    WorkshopControl -s -w 107410 $LISTOFMODS
    #done
    cd "$MOJPWD"
    echo "Poczekaj az mody sie pobiora. Aby kontynuowac nacisnij ENTER..."
    read -r
fi

#if [ -s ../temp/todownloadextra.txt ]
#then
#for each in `cat ../temp/todownloadextra.txt`
#do
#echo $each
#LINK=$(cat ../mods/links/$each)
#echo "start $LINK" >> ../temp/otwo.bat
#done
#fi

#if [ -s ../temp/otwo.bat ]
#then
#awk 'sub("$", "\r")' ../temp/otwo.bat > ../start.bat
#fi

echo "Zrobione!
"
