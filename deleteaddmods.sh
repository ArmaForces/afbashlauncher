#!/bin/bash

modan="`cat ../profile/$1/dopuszczone.json | jq '.itemId' `"

modon="`cat ../cfg/dodatkowemody.json | jq '.[]|.itemId' `"
maden="`cat ../cfg/dodatkowemody.json | jq '.[]|.itemId' `"

for each in $modan
do
    modon=$(echo "$modon" | grep -v $each)
done

for each in $modon
do
    maden=$(echo "$maden" | grep -v $each)
done

for each in $maden
do
    cat ../cfg/dodatkowemody.json | jq '.[] | select(.itemId == '$each')' >> ../temp/deladdmods_temp.json
done

cat ../temp/deladdmods_temp.json | jq -s > ../temp/dodatkoweobrobione.json
