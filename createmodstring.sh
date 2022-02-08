#!/bin/bash
>../temp/mody
#cat ../temp/dodatkoweobrobione.csv | grep id | sed 's/.*=//' | sed ':a;N;$!ba;s/\n/ /g' > ../temp/mody
#cat ../profile/$2/mody.csv | grep id | sed 's/.*=//' | sed ':a;N;$!ba;s/\n/ /g' >> ../temp/mody

IEFES=$IFS
IFS=';'
while read id name
do
    echo $(echo $id | tr -d '"') >> ../temp/mody
done < ../temp/dodatkoweobrobione.csv
while read id name
do
    echo $(echo $id | tr -d '"') >> ../temp/mody
done < ../profile/$2/mody.csv
IFS=$IEFES


#echo "$1" | tr '/' '\'
if [ -f ../cfg/lin ]
then
    echo "$1" | sed 's/[/][/]*/\\\\/g' > ../temp/modpath.txt
    echo `cat ../temp/modpath.txt`\\\\ > ../temp/modpath2.txt
    MODPATH=`cat ../temp/modpath2.txt`
    echo "$3" | sed 's/[/][/]*/\\\\/g' > ../temp/modpath.txt
    echo `cat ../temp/modpath.txt`\\\\ > ../temp/modpath2.txt
    ADDMODPATH=`cat ../temp/modpath2.txt`
else
    echo "$1" | sed 's/[/][/]*/\\/g' > ../temp/modpath.txt
    echo `cat ../temp/modpath.txt`\\ > ../temp/modpath2.txt
    MODPATH=`cat ../temp/modpath2.txt`
    echo "$3" | sed 's/[/][/]*/\\/g' > ../temp/modpath.txt
    echo `cat ../temp/modpath.txt`\\ > ../temp/modpath2.txt
    ADDMODPATH=`cat ../temp/modpath2.txt`
fi
for fn in `cat ../temp/mody`; do
    ok="$ok$(echo "$MODPATH$fn;")"
done


IEFES=$IFS
IFS='
'
for fn in `cat ../profile/$2/extra.txt`; do
    ok="$ok$(echo "$ADDMODPATH$fn;")"
done
IFS=$IEFES
echo "${ok%?}"

echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<addons-presets>
  <last-update>2021-11-14T18:07:14.279354+01:00</last-update>
  <published-ids>" > ../temp/AFLaucher.preset2

for launch in `cat ../temp/mody`
do
    echo "    <id>steam:$launch</id>" >> ../temp/AFLaucher.preset2
done

for launch in `cat ../profile/$2/extra.txt`
do
    echo "    <id>local:$ADDMODPATH$launch\\</id>" >> ../temp/AFLaucher.preset2
done

if [ -s ../profile/$2/dlcs_appId.txt ]
then
    echo "  </published-ids>
  <dlcs-appids>" >> ../temp/AFLaucher.preset2
IEFES=$IFS
IFS='
'
    for launch in `cat ../profile/$2/dlcs_appId.txt`
    do
        echo "    <id>$launch</id>" >> ../temp/AFLaucher.preset2
    done
    IFS=$IEFES
    echo "  </dlcs-appids>
</addons-presets>" >> ../temp/AFLaucher.preset2
else
    echo "  </published-ids>
  <dlcs-appids />
</addons-presets>" >> ../temp/AFLaucher.preset2
fi
LAUNCHERPRESETPATH=$(../scripts/discover_local_appdata.bat | sed 's/\\/\//g')
cat ../temp/AFLaucher.preset2 > "$LAUNCHERPRESETPATH"
unix2dos -q "$LAUNCHERPRESETPATH"
