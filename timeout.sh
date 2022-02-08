#!/bin/sh

cd scripts

sh mod_discovery.sh 
cd ..

sh scripts/gamedig.sh

SEMAPHORE2302="0"
SEMAPHORE2310="0"

if [ "`cat status/2302info.txt | grep "Misja:"`" = "Misja: Arma 3" ]
then
	SEMAPHORE2302="1"
fi
if [ "`cat status/2302info.txt | grep "Misja:"`" = "Misja: Altis_Lajf" ]
then
	SEMAPHORE2302="1"
fi
if [ "`cat status/2302info.txt | grep "Misja:"`" = "Misja: " ]
then
	SEMAPHORE2302="1"
fi
if [ "`cat status/2310info.txt | grep "Misja:"`" = "Misja: Arma 3" ]
then
	SEMAPHORE2310="1"
fi
if [ "`cat status/2310info.txt | grep "Misja:"`" = "Misja: Altis_Lajf" ]
then
	SEMAPHORE2310="1"
fi
if [ "`cat status/2310info.txt | grep "Misja:"`" = "Misja: " ]
then
	SEMAPHORE2310="1"
fi
if [ ! "`cat status/2302 | grep "Spesul Furses Special Edition"`" = "Spesul Furses Special Edition" ]
then
	SEMAPTHORE2302="0"
fi
if [ ! "`cat status/2310 | grep "Spesul Furses Special Edition"`" = "Spesul Furses Special Edition" ]
then
	SEMAPTHORE2310="0"
fi

#while [ "`cat status/2302 | grep -v "Spesul Furses Special Edition"`" = "" ] && [ "`cat status/2310 | grep -v "Spesul Furses Special Edition"`" = "" ]
while [ "$SEMAPHORE2302" = "1" ] && [ "$SEMAPHORE2310" = "1" ]
do
	SEMAPHORE2302="0"
	SEMAPHORE2310="0"
	#echo "Nie ma jeszcze tematycznej misji. Sprawdzam co 10 sekund."
	echo "Nie ma jeszcze misji. Sprawdzam co 10 sekund."
	sleep 1
	echo -n " ."
	sleep 1
	echo -n " ."
	sleep 1
	echo -n " ."
	sleep 1
	echo -n " ."
	sleep 1
	echo -n " ."
	sleep 1
	echo -n " ."
	sleep 1
	echo -n " ."
	sleep 1
	echo -n " ."
	sleep 1
	echo -n " ."
	sleep 1
	echo -n " ."
	sh scripts/gamedig.sh
	echo ""
	#echo "Jest tematyczna misja?"
	echo "Jest misja?"
	echo ""
	if [ "`cat status/2302info.txt | grep "Misja:"`" = "Misja: Arma 3" ]
	then
		SEMAPHORE2302="1"
	fi
	if [ "`cat status/2302info.txt | grep "Misja:"`" = "Misja: Altis_Lajf" ]
	then
		SEMAPHORE2302="1"
	fi
	if [ "`cat status/2302info.txt | grep "Misja:"`" = "Misja: " ]
	then
		SEMAPHORE2302="1"
	fi
	if [ "`cat status/2310info.txt | grep "Misja:"`" = "Misja: Arma 3" ]
	then
		SEMAPHORE2310="1"
	fi
	if [ "`cat status/2310info.txt | grep "Misja:"`" = "Misja: Altis_Lajf" ]
	then
		SEMAPHORE2310="1"
	fi
	if [ "`cat status/2310info.txt | grep "Misja:"`" = "Misja: " ]
	then
		SEMAPHORE2310="1"
	fi
	if [ ! "`cat status/2302 | grep "Spesul Furses Special Edition"`" = "Spesul Furses Special Edition" ]
	then
		SEMAPTHORE2302="0"
	fi
	if [ ! "`cat status/2310 | grep "Spesul Furses Special Edition"`" = "Spesul Furses Special Edition" ]
	then
		SEMAPTHORE2310="0"
	fi
done
