#!/bin/sh
cd ..
if [ ! -d mods ]
then
    mkdir mods
fi

if [ ! -d profile ]
then
    mkdir profile
fi


cd mods
ADDITIONALMODSPWD="`pwd`"
cd ..

if [ -f armaforces_czekaj_na_tematyczny.bat ]
then
    rm armaforces_czekaj_na_tematyczny.bat
fi

if [ ! -d cfg ]
then
    mkdir cfg
    >cfg/DONOTDELETETHISMODS.txt
    >cfg/dousuniecia.txt
fi

echo "@echo off" > start.bat
cd scripts

cat logo.txt

sh mod_discovery.sh

if [ "$1" = "liberation" ]
then
    DOMAIN="stajniakunia.pl"
else
    DOMAIN="ts.armaforces.com"
fi

ARMA3UNIXPATH=$(reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\bohemia interactive\arma 3" /v main | grep "Arma 3" | sed 's/.*REG_SZ\ \ \ \ //' | sed 's/\\/\//g')
ARMA3ORIGPATH=$(echo "$ARMA3UNIXPATH" | sed 's/[/][/]*/\\/g')

if [ ! -f "$ARMA3UNIXPATH/arma3_x64.exe" ]
then
    echo "Nie znaleziono pliku arma3_x64.exe"
    echo "Jestes pewien, ze masz zainstalowana Arme 3?"
    echo "Nacisnij ENTER aby zakonczyc..."
    read r
    exit 1
fi

if [ -d ../temp ]
then
    rm -rf ../temp
fi
mkdir ../temp


if [ -f ../cfg/kun ]
then
    if [ -f ../cfg/local.txt ]
    then
        IP="`cat local.txt`"
    else
        echo "Wprowadz lokany adres serwera."
        read IP
        echo "$IP" > ../cfg/local.txt
        echo "Lokalny adres serwera zapisany. Aby zmienic zmodyfikuj zawartosc pliku local.txt."
        echo "Nacisnij ENTER aby kontynuowac"
        read -r
    fi
elif [ -f ../kun ] && [ "$1" = "liberation" ]
then
    IP="192.168.55.150"
else
    IP="`ping $DOMAIN -w 1 -n 1 | grep $DOMAIN | cut -d "[" -f2 | cut -d "]" -f1`"
fi

if [ ! -f ../cfg/DONOTDELETETHISMODS.txt ]
then
    cat ../profile/normalne/mody.txt > ../cfg/DONOTDELETETHISMODS.txt
    cat ../cfg/DONOTDELETETHISMODS.txt|  awk 'sub("$", "\r")' > ../temp/temp.txt
    cat ../temp/temp.txt > ../cfg/DONOTDELETETHISMODS.txt
fi

if [ -f ../cfg/haslo.txt ]
then
    echo ""
    echo "Wykryto plik z haslem serwera!"
    echo "Aby zmienic zmodyfikuj zawartosc pliku haslo.txt w folderze scripts."
    echo "Stosuje..."
    echo ""
else
    echo ""
    echo "#######    Nie wykryto pliku z haslem!!!    #######"
    echo -n "Wpisz haslo: "
    read PASSWD
    echo $PASSWD > ../cfg/haslo.txt
    echo "Haslo zapisane. Aby zmienic zmodyfikuj zawartosc pliku haslo.txt w folderze scripts."
    echo "Nacisnij ENTER aby kontynuowac"
    read -r
    echo "" > insertkremowka
fi

if [ -f ../cfg/parametry.txt ]
then
    echo ""
    echo "Wykryto plik parametrow!"
    echo "Aby zmienic zmodyfikuj zawartosc pliku parametry.txt w folderze scripts."
    echo "Stosuje..."
    echo ""
else
    echo ""
    echo "#######    Nie wykryto pliku parametrow!!!    #######"
    echo "Mozesz uzupelnic go o brakujace parametry jak: -enableHT, -skipIntro, itd..."
    echo "Aby dowiedziec sie jakie parametry mozna tu wstawic odwiedz strone:"
    echo ""
    echo 'https://community.bistudio.com/wiki/Arma_3_Startup_Parameters'
    echo ""
    echo "lub przegladnij zakladke :PARAMETRY: w oryginalnym Launcherze Army 3"
    echo ""
    echo "-noSplash -skipIntro -noPause -world=empty" > ../cfg/parametry.txt
    echo "
    Twoja linia parametrow: -noSplash -skipIntro -noPause -world=empty"
    echo "Utworzono plik parametry.txt."
    echo "Nacisnij ENTER aby kontynuowac"
    read -r
fi

PDWBEFORESRVCHECK="`pwd`"

cd ..

if [ -f kun ]
then
    sh scripts/gamedig.sh
else
    sh scripts/gamedig.sh
fi

echo "Serwer stoi?"
echo ""

if [ "$1" = "liberation" ]
then
    while [ "`cat status2/2302`" = "" ] && [ "`cat status2/2310`" = "" ]
    do
        echo "Nie ma serwera! Sprawdzam co 10 sekund."
        sleep 10
        if [ -f kun ]
        then
            sh scripts/gamedig.sh
        else
            sh scripts/gamedig.sh
        fi
        echo ""
        echo "Serwer stoi?"
        echo ""
    done
    cat scripts/tekst.txt
    PORT="2302"
    MODY="stajniakunia"
    echo ""
    cat status2/2302info.txt
else

    while [ "`cat status/2302`" = "" ] && [ "`cat status/2310`" = "" ]
    do
        echo "Nie ma serwera! Sprawdzam co 10 sekund."
        sleep 10
        if [ -f kun ]
        then
            sh scripts/gamedig.sh
        else
            sh scripts/gamedig.sh
        fi
        echo ""
        echo "Serwer stoi?"
        echo ""
    done

    cat scripts/tekst.txt

    echo ""

    echo "IP serwera: $IP"

    echo ""

    if [ ! -z "`cat status/2302`" ] && [ ! -z "`cat status/2310`" ]
    then
        echo "Stoja 2 serwery (na porcie 2302 \"`cat status/2302`\" oraz na porcie 2310 \"`cat status/2310`\""
        echo "Ktory wybierasz?"
        echo "  Odp.   Port/Serwer"
        echo ""
        echo "  1      2302 \"`cat status/2302`\"
`cat status/2302info.txt`"
        echo "  2      2310 \"`cat status/2310`\"
`cat status/2310info.txt`"
        echo ""
        echo -n "Wybor 1 lub 2: "
        read CHOICE

        while [ "$CHOICE" != "1" ] && [ "$CHOICE" != "2" ]
        do
            echo -n "Wybierz poprawnie: "
            read CHOICE
        done

        if [ "$CHOICE" = "1" ]
        then
            echo "Wybrales 2302 \"`cat status/2302`\""
            PORT="2302"
        else
            echo "Wybrales 2310 \"`cat status/2310`\""
            PORT="2310"
        fi

        if [ "`cat status/$PORT`" = "`cat scripts/default.txt`" ]
        then
            MODY="normalne"
        else
            MODY="tematyczne"
        fi
        echo "Startuje na porcie $PORT z modami na misje $MODY."
    elif [ ! -z "`cat status/2302`" ] && [ -z "`cat status/2310`" ]
    then
        PORT="2302"
        if [ "`cat status/$PORT`" = "`cat scripts/default.txt`" ]
        then
            MODY="normalne"
        else
            MODY="tematyczne"
        fi
        echo "Startuje serwer `cat status/2302name` na porcie $PORT.

`cat status/2302info.txt`

===================================================
        "
    elif [ -z "`cat status/2302`" ] && [ ! -z "`cat status/2310`" ]
    then
        PORT="2310"
        if [ "`cat status/$PORT`" = "`cat scripts/default.txt`" ]
        then
            MODY="normalne"
        else
            MODY="tematyczne"
        fi
        echo "Startuje serwer \"`cat status/2310`\" na porcie $PORT.

`cat status/2310info.txt`

===================================================
        "
    fi
fi
cd "$PDWBEFORESRVCHECK"

cd "$ARMA3UNIXPATH/../../workshop/content/107410"
MODPATH="$PWD"
cd "$PDWBEFORESRVCHECK"
echo ""

echo "

Dziekuje za uzywanie lauchera :)

===================================================
"
cd ../temp
curl -s "https://server.armaforces.com:8888/status" > current.json
cat current.json | jq '.modsetName' | sed 's/\"//g' | grep -v "null" | sed 's/\ /%20/g' > current.txt
cd "$PDWBEFORESRVCHECK"
dos2unix -q ../temp/current.txt
MODY="`cat ../temp/current.txt`"
echo "Startuje klienta z modami \"$MODY\""
echo "Parsuje liste modow. Poczekaj..."
sh deleteaddmods.sh "$MODY"
bash createmodstring.sh "$MODPATH" "$MODY" "$ARMA3UNIXPATH" > ../temp/modassembly.txt

PEEWUDE=$(pwd)

cd ../bin
LISTOFMODS=$(cat ../temp/mody | sed ':a;N;$!ba;s/\n/ /g')
#cat ../temp/mody | sed ':a;N;$!ba;s/\n/ /g' > ../chuje.txt
# WorkshopControl -s -w 107410 $LISTOFMODS
cd "$PEWUDE"

cat ../profile/$MODY/extra.txt
MODASSEMBLY="`cat ../temp/modassembly.txt`"
PARAMETERS="`cat ../cfg/parametry.txt`"
SVPASSWD="`cat ../cfg/haslo.txt`"

if [ -f insertkremowka ]
then
    echo "msg \"%username%\" \"Insert kremowka!!!\"" >> ../start.bat
    rm insertkremowka
fi
cd ..
echo "echo START!!!" >> start.bat
if [ -f origlauncher ]
then
    echo "start \"\" \"$ARMA3ORIGPATH\arma3launcher.exe\"" >> start.bat
else
    echo "start \"\" \"$ARMA3ORIGPATH\arma3_x64.exe\" $PARAMETERS -mod=\"$MODASSEMBLY\"" >> start.bat
fi
cat start.bat |  awk 'sub("$", "\r")' > temp/temp.txt
cat temp/temp.txt > start.bat

rm -rf temp

./start.bat
sleep 60
exit
