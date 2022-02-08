#!/bin/sh

#####################################################################################################################
################## zmienne niskiego kosztu - te moga sie odpalac za kazdym razem ####################################
#####################################################################################################################

ARMA3UNIXPATH=$(reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\bohemia interactive\arma 3" /v main | grep "Arma 3" | sed 's/.*REG_SZ\ \ \ \ //' | sed 's/\\/\//g')

if [ ! -f "$ARMA3UNIXPATH/arma3_x64.exe" ] #sprawdzenie czy arma byla odpalona - jezeli nie to wywala z launchera
then
	echo "Nie znaleziono pliku arma3_x64.exe"
	echo "Jestes pewien, ze masz zainstalowana Arme 3?"
	echo "Nacisnij ENTER aby zakonczyc..."
	read r
	exit 1
fi

ARMA3ORIGPATH=$(echo "$ARMA3UNIXPATH" | sed 's/[/][/]*/\\/g')
DOMAIN=$(cat ../scripts/adres.txt)

PDWBEFORESRVCHECK="`pwd`"

cd "$PDWBEFORESRVCHECK"

cd "$ARMA3UNIXPATH/../../workshop/content/107410"
MODPATH="$PWD"
cd "$PDWBEFORESRVCHECK"

#####################################################################################################################

#####################################################################################################################
################## wyciaganie zmiennych oraz zmienne wysokiego kosztu na zadanie ####################################
#####################################################################################################################

if [ "$1" = "ARMA3UNIXPATH" ]
then
echo "$ARMA3UNIXPATH"
elif [ "$1" = "ARMA3ORIGPATH" ]
then
echo "$ARMA3ORIGPATH"
elif [ "$1" = "DOMAIN" ]
then
echo "$DOMAIN"
elif [ "$1" = "MODPATH" ]
then
echo "$MODPATH"
fi
