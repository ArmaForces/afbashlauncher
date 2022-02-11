#!/bin/sh
cd ..
if [ "`pwd | grep scripts`" = "" ]
then
    cd scripts
fi

if [ ! -d ../temp ]
then
    mkdir ../temp
fi

>../temp/availablemodlist.txt

>../temp/availablemodlistverbose.txt

>../temp/dodatkowemody.txt

>../temp/dopuszczone.json


cat ../profile/dopuszczone.json | jq '.[]|.itemId'  > ../temp/availablemodlist.txt
cat ../profile/dopuszczone.json | jq '.[]|.name'  | tr -d '"' > ../temp/availablemodlistname.txt
paste ../temp/availablemodlist.txt ../temp/availablemodlistname.txt > ../temp/availablemodlistverbose.txt
cat ../cfg/dodatkowemody.json | jq '.[]|.itemId'  > ../temp/dodatkowemody.txt


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
    cat ../profile/dopuszczone.json | jq '.[] | select(.itemId == '$each')'  >> ../temp/dopuszczone.json
done<../temp/dodatkowemody.txt

cat ../temp/dopuszczone.json | jq -s  > ../cfg/dodatkowemody.json

rm ../temp/dopuszczone.json
rm ../temp/dodatkowemody.txt
rm ../temp/availablemodlist.txt
rm ../temp/availablemodlistverbose.txt
echo "Mody dodatkowe zapisano. Nacisnij ENTER aby zakonczyc..."
read
