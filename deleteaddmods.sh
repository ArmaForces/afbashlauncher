#!/bin/bash
#modan="`cat ../profile/$1/dopuszczone.csv | grep id | sed 's/.*=//' | sed ':a;N;$!ba;s/\n/ /g'`"

IEFES=$IFS
IFS=';'
while read id name
do
	echo $(echo $id | tr -d '"') >> ../temp/modan.txt
done < "../profile/$1/dopuszczone.csv"
IFS=$IEFES

modan="`cat ../temp/modan.txt`"

modon="`cat ../cfg/dodatkowemody.csv`"
maden="`cat ../cfg/dodatkowemody.csv`"
for each in $modan
do
modon=$(echo "$modon" | grep -v $each)
done
echo "$modon" > ../temp/modon.csv


IEFES=$IFS
IFS=';'
while read id name
do
	echo $(echo $id | tr -d '"') >> ../temp/modon.txt
done < "../temp/modon.csv"
IFS=$IEFES

modong="`cat ../temp/modon.txt`"
#modon="`echo "$modon" | grep id | sed 's/.*=//' | sed ':a;N;$!ba;s/\n/ /g'`"

for each in $modong
do
maden=$(echo "$maden" | grep -v $each)
done
echo "$maden" > ../temp/dodatkoweobrobione.csv

