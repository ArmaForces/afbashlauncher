#!/bin/bash
echo "@echo off" > ../start.bat
cd ../scripts
>../cfg/dousuniecia.html

ARMA3UNIXPATH=$(reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\bohemia interactive\arma 3" /v main | grep "Arma 3" | sed 's/.*REG_SZ\ \ \ \ //' | sed 's/\\/\//g')
ARMA3ORIGPATH=$(echo "$ARMA3UNIXPATH" | sed 's/[/][/]*/\\/g')

sh blacklist.sh
sh mod_discovery.sh

if [ ! -f "$ARMA3UNIXPATH/arma3_x64.exe" ]
then
    echo "Nie znaleziono pliku arma3_x64.exe"
    echo "Jestes pewien, ze masz zainstalowana Arme 3?"
    echo "Nacisnij ENTER aby zakonczyc..."
    read r
    exit 1
fi

if [ ! -d ../temp ]
then
    mkdir ../temp
fi
SCRIPTSPWD=$(pwd)
cd "$ARMA3UNIXPATH/../../workshop/content/107410"
MODSPWD=$(pwd)
cd ../../
ACFPWD=$(pwd)
cd "$SCRIPTSPWD"
ls "$MODSPWD" | tr " " "\n" > ../temp/toparse.txt

echo "Skrypt do usuwania starych niepotrzebnych/uszkodzonych modow. Edytuj plik cfg\DONOTDELETETHISMODS.txt aby pominac.

##################################################
PRZED KONTYNUOWANIEM UPEWNIJ SIE,
ZE KLIENT STEAM JEST WLACZONY
##################################################"

echo "Chcesz (n)aprawic uszkodzone mody czy (u)sunac niepotrzebne?
n - napraw
u - usun"
CHOICE="chuj"
while [ ! "$CHOICE" = "n" ] && [ ! "$CHOICE" = "u" ]
do
    echo "Wybierz poprawnie:"
    read CHOICE
done

if [ "$CHOICE" = "u" ]
then
    cat ../cfg/DONOTDELETETHISMODS.txt | awk '{ sub("\r$", ""); print }' > ../temp/temp.txt
    cat ../temp/temp.txt > ../cfg/DONOTDELETETHISMODS.txt
    cat ../cfg/DONOTDELETETHISMODS.txt | grep id | sed 's/.*=//' > ../temp/todownload3.txt
    cat ../cfg/DONOTDELETETHISMODS.txt|  awk 'sub("$", "\r")' > ../temp/temp.txt
    cat ../temp/temp.txt > ../cfg/DONOTDELETETHISMODS.txt

    cat ../profile/mody.json | jq '.[] | .itemId' > ../temp/todownload3.txt

    echo "Chcesz usunac wszystkie nieuzywane, czy zachowac wszystkie dopuszczone na serwerze? (PO WYBORZE NIE BEDZIE JUZ ODWROTU!!!)
    z - zachowaj
    u - usun"
    CHOICE="chuj"
    while [ ! "$CHOICE" = "z" ] && [ ! "$CHOICE" = "u" ]
    do
        echo "Wybierz poprawnie:"
        read CHOICE
    done

    echo "Pracuje..."

    if [ "$CHOICE" = "z" ]
    then
        cat ../profile/dopuszczone.json | jq '.[] | .itemId' >> ../temp/todownload3.txt
    else
        cat ../cfg/dodatkowemody.json | jq '.[] | .itemId' >> ../temp/todownload3.txt
    fi
    cat ../temp/todownload3.txt | sort | uniq > ../temp/temp3.txt
    cat ../temp/toparse.txt > ../temp/todownload.txt
    for each in `cat ../temp/temp3.txt`
    do
        cat ../temp/todownload.txt | grep -v "$each" > ../temp/todownloadtemp.txt
        cat ../temp/todownloadtemp.txt > ../temp/todownload.txt
    done
    rm ../temp/temp3.txt
    rm ../temp/todownload3.txt

else

    if [ ! -f ../cfg/dousuniecia.txt ]
    then
        >../cfg/dousuniecia.txt
        echo "Utworzono plik \"cfg/dousuniecia.txt\". Uzupelnij go teraz o mody (linkami Steam Workshop) ktore chcesz usunac.
Nacisnij ENTER aby kontynuowac..."
        read -r
    fi

    dos2unix -q ../cfg/dousuniecia.txt
    cat ../cfg/dousuniecia.txt | grep id | sed 's/.*=//' > ../temp/todownload.txt
    unix2dos -q ../cfg/dousuniecia.txt


fi

cat ../temp/todownload.txt | sort | uniq | sed ':a;N;$!ba;s/\n/ /g' > ../temp/todownload2.txt
if [ -s ../temp/todownload2.txt ]
then
    cat ../scripts/begin.html > ../cfg/dousuniecia.html
    HOWMANY=0
    for each in `cat ../temp/todownload2.txt`
    do
        HOWMANY=$((HOWMANY + 1))
    done
    echo ""
    echo "Do usuniecia $HOWMANY modow."
    echo ""
    echo "Po tej operacji nie bedzie juz odwrotu. Aby kontynuowac nacisnij ENTER:"
    echo ""
    read -r
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
        rm -rf "$MODSPWD/$each"
        if [ "$((COUNT % HOWMUCH))" = "0" ]
        then
            echo "echo Otwarto $COUNT z $HOWMANY modow do odsubskrybowania" >> ../temp/otwo.bat
            echo "pause" >> ../temp/otwo.bat
        fi
    done
    echo "pause" >> ../temp/otwo.bat
    awk 'sub("$", "\r")' ../temp/otwo.bat > ../start.bat
    echo ""
    echo ""

    cat "$ACFPWD/appworkshop_107410.acf" | grep --before-context=2 --after-context=3 size > ../temp/tempsize.txt
    for each in `cat ../temp/todownload2.txt`
    do
        cat ../temp/tempsize.txt | grep -B 2 -A 3 size | sed -e "/$each/,+5d" > ../temp/ttempsize.txt
        cat ../temp/ttempsize.txt > ../temp/tempsize.txt
    done
    cat "$ACFPWD/appworkshop_107410.acf" | grep --before-context=5 --after-context=1 subscribedby > ../temp/tempsubscribed.txt
    for each in `cat ../temp/todownload2.txt`
    do
        cat ../temp/tempsubscribed.txt | grep --before-context=5 --after-context=1 subscribedby | sed -e "/$each/,+6d" > ../temp/ttempsize.txt
        cat ../temp/ttempsize.txt > ../temp/tempsubscribed.txt
    done
    HOWMANY=0
    HOWMUCH=0
    echo "Pracuje..."
    for each in `cat ../temp/tempsize.txt | grep size |  sed -e 's/[^0-9]*//g' | sed ':a;N;$!ba;s/\n/ /g'`
    do
        HOWMUCH=$(calculator "$HOWMANY" "$each")
        HOWMANY="$HOWMUCH"
        #echo "$HOWMANY"
    done

    echo "\"AppWorkshop\"
{
	\"appid\"		\"107410\"
	\"SizeOnDisk\"		\"$HOWMANY\"
`cat "$ACFPWD/appworkshop_107410.acf" | grep NeedsUpdate`
`cat "$ACFPWD/appworkshop_107410.acf" | grep NeedsDownload`
`cat "$ACFPWD/appworkshop_107410.acf" | grep TimeLastUpdated`
`cat "$ACFPWD/appworkshop_107410.acf" | grep TimeLastAppRan`
	\"WorkshopItemsInstalled\"
	{
`cat ../temp/tempsize.txt`
	}
	\"WorkshopItemDetails\"
	{
`cat ../temp/tempsubscribed.txt`
	}
}" > ../temp/temp.acf

    cat ../temp/temp.acf > "$ACFPWD/appworkshop_107410.acf"
    cat ../temp/temp.acf > "../appworkshop_107410.acf"
    cd ../bin
    #for each in `cat ../temp/todownload2.txt`
    #do
    #WorkshopControl -u -w 107410 $each
    LISTOFMODS=$(cat ../temp/todownload2.txt | sed ':a;N;$!ba;s/\n/ /g')
    WorkshopControl -u -w 107410 $LISTOFMODS
    #done
fi


#cat ../start.bat |  awk 'sub("$", "\r")' > ../temp/temp.txt
#cat ../temp/temp.txt > ../start.bat
rm -rf ../temp
echo "Gotowe!!!
Nacisnij ENTER aby kontynuowac..."
read -r
#../start.bat
