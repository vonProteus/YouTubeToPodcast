#!/bin/bash -xe 

FILE=$1
ID="${FILE%.*}"

echo working on $FILE

JSONID=$(youtube-dl $ID -J)

ORGINALURL=$(echo "$JSONID" | jq -r  '.webpage_url')
TITLE=$(echo "$JSONID" | jq -r  '.title')
UPLOADER=$(echo "$JSONID" | jq -r  '.uploader')
SDATE=$(echo "$JSONID" | jq -r '.upload_date')
DATE=$(date -jf "%Y%m%d" "$SDATE" +"%Y-%m-%d")
FULLDESCRIPTION=$(echo "$JSONID" | jq -r '.description')
THUMBNSILURL=$(youtube-dl $ID --get-thumbnail)
NEWFILENAME=${DATE}-${TITLE}-${ID}
NEWFILENAME=${NEWFILENAME///}

curl -o "${NEWFILENAME}.jpg" "$THUMBNSILURL"

cp $FILE "$NEWFILENAME.mp3"
mid3v2 -D "$NEWFILENAME.mp3"

FULL="Orginal Viedo: $ORGINALURL

$FULLDESCRIPTION"
SHORT=${FULL:0:200}

mid3v2 -t "$TITLE" \
       -a "$UPLOADER" \
       -g "Speech" \
       -y "$DATE" \
       --picture="${NEWFILENAME}.jpg" \
       "$NEWFILENAME.mp3"

mid3v2 "$NEWFILENAME.mp3"

SIZE=$(( $(mp3info -p %k "$NEWFILENAME.mp3") / 1024 ))
DURATION=$(mp3info -p %m:%s "$NEWFILENAME.mp3")
BITRATE=$(( $(mp3info -p %k "$NEWFILENAME.mp3") * 8 / $(mp3info -p %S "$NEWFILENAME.mp3") ))
FREQUENCY=$(mp3info -p %Q "$NEWFILENAME.mp3")

cp template.xml "${NEWFILENAME}.xml"

xml ed -L -u "/PodcastGenerator/episode/titlePG" --value "$TITLE" "${NEWFILENAME}.xml"
xml ed -L -u "/PodcastGenerator/episode/shortdescPG" --value "$SHORT" "${NEWFILENAME}.xml"
xml ed -L -u "/PodcastGenerator/episode/longdescPG" --value "$FULL" "${NEWFILENAME}.xml"
xml ed -L -u "/PodcastGenerator/episode/imgPG" --value "$THUMBNSILURL" "${NEWFILENAME}.xml"
xml ed -L -u "/PodcastGenerator/episode/categoriesPG/category1PG" --value "uncategorized" "${NEWFILENAME}.xml"
xml ed -L -u "/PodcastGenerator/episode/categoriesPG/category2PG" --value "" "${NEWFILENAME}.xml"
xml ed -L -u "/PodcastGenerator/episode/categoriesPG/category3PG" --value "" "${NEWFILENAME}.xml"
xml ed -L -u "/PodcastGenerator/episode/keywordsPG" --value "" "${NEWFILENAME}.xml"
xml ed -L -u "/PodcastGenerator/episode/explicitPG" --value "no" "${NEWFILENAME}.xml"
xml ed -L -u "/PodcastGenerator/episode/authorPG/namePG" --value "$UPLOADER" "${NEWFILENAME}.xml"
xml ed -L -u "/PodcastGenerator/episode/authorPG/emailPG" --value "" "${NEWFILENAME}.xml"
xml ed -L -u "/PodcastGenerator/episode/fileInfoPG/size" --value "$SIZE" "${NEWFILENAME}.xml"
xml ed -L -u "/PodcastGenerator/episode/fileInfoPG/duration" --value "$DURATION" "${NEWFILENAME}.xml"
xml ed -L -u "/PodcastGenerator/episode/fileInfoPG/bitrate" --value "$BITRATE" "${NEWFILENAME}.xml"
xml ed -L -u "/PodcastGenerator/episode/fileInfoPG/frequency" --value "$FREQUENCY" "${NEWFILENAME}.xml"

touch -t ${SDATE}0000 "$NEWFILENAME.mp3"
touch -t ${SDATE}0000 "$NEWFILENAME.xml"
touch -t ${SDATE}0000 "$NEWFILENAME.jpg"

# rm "$NEWFILENAME.mp3" "$NEWFILENAME.jpg" "$NEWFILENAME.xml" $FILE