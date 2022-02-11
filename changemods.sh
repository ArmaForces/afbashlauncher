#!/bin/sh
cd ..
if [ "`pwd | grep scripts`" = "" ]
then
    cd scripts
fi

#sh mod_discovery.sh

if [ ! -d ../temp ]
then
    mkdir ../temp
fi

>../temp/availablemodlist.txt

>../temp/availablemodlistverbose.txt

>../temp/dodatkowemody.txt

>../temp/dopuszczone.json

#IEFES=$IFS
#IFS=';'
#while read id name
#do
#echo $(echo $id | tr -d '"') >> ../temp/availablemodlist.txt
#echo "$(echo $name | tr -d '"') $(echo $id | tr -d '"')" >> ../temp/availablemodlistverbose.txt
#done < ../profile/dopuszczone.csv

#while read id name
#do
#echo $(echo $id | tr -d '"') >> ../temp/dodatkowemody.txt
#done < ../cfg/dodatkowemody.csv

#IFS=$IEFES


jq '.[]|.itemId' ../profile/dopuszczone.json > ../temp/availablemodlist.txt
jq '.[]|.name' ../profile/dopuszczone.json | tr -d '"' > ../temp/availablemodlistname.txt
paste ../temp/availablemodlist.txt ../temp/availablemodlistname.txt > ../temp/availablemodlistverbose.txt
jq '.[]|.itemId' ../cfg/dodatkowemody.json > ../temp/dodatkowemody.txt


while [ ! "$SWITCH" = "z" ]
do
    NUMBER=0
    while read each
    do
        NUMBER=$((NUMBER+1))
        STERING="`cat ../temp/availablemodlistverbose.txt | grep "$each"`"
        STEERING="`cat ../temp/dodatkowemody.txt | grep "$each"`"
        if [ "$STEERING" = "" ]
        then
            echo "$NUMBER.	N $STERING"
        else
            echo "$NUMBER.	A $STERING"
        fi
    done <../temp/availablemodlist.txt

    echo "
    1-$NUMBER	- aktywuj/dezaktywuj moda.
    z	- zapisz i zamknij
    "
    echo "Wybor: "
    read SWITCH
    NUMBER=0
    while read each
    do
        NUMBER=$((NUMBER+1))
        STERING="`cat ../temp/availablemodlistverbose.txt | grep "$each"`"
        STEERING="`cat ../temp/dodatkowemody.txt | grep "$each"`"
        if [ "$NUMBER" = "$SWITCH" ]
        then
            if [ "$STEERING" = "" ]
            then
                echo "$each" >> ../temp/dodatkowemody.txt
            else
                cat ../temp/dodatkowemody.txt | grep -v "$each" > ../temp/temp_dodatkowemody.txt
                cat ../temp/temp_dodatkowemody.txt > ../temp/dodatkowemody.txt
            fi
        fi
    done <../temp/availablemodlist.txt

    NUMBER=0
done
echo "
Zapisuje...
"
while read each
do
    jq '.[] | select(.itemId == '$each')' ../profile/dopuszczone.json >> ../temp/dopuszczone.json
done<../temp/dodatkowemody.txt

jq -s ../temp/dopuszczone.json > ../cfg/dodatkowemody.json

#while read each
#do
    #cat ../profile/dopuszczone.csv | grep "$each" >> ../temp/dopuszczone.csv
#done <../temp/dodatkowemody.txt
#cat ../temp/dopuszczone.csv > ../cfg/dodatkowemody.csv

rm ../temp/dopuszczone.csv
rm ../temp/dodatkowemody.txt
rm ../temp/availablemodlist.txt
rm ../temp/availablemodlistverbose.txt
echo "Mody dodatkowe zapisano. Nacisnij ENTER aby zakonczyc..."
read
