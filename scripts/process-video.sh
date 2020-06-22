#!/bin/bash -xe 

FILE=$1
ID="${FILE%.*}"
IDURL=https://www.youtube.com/watch?v=${ID}

echo working on $FILE

JSONID=$(youtube-dl $IDURL -J)

ORGINALURL=$(echo "$JSONID" | jq -r  '.webpage_url')
TITLE=$(echo "$JSONID" | jq -r  '.title')
UPLOADER=$(echo "$JSONID" | jq -r  '.uploader')
SDATE=$(echo "$JSONID" | jq -r '.upload_date')
DATE=$(date -d "${SDATE}0000" +"%Y-%m-%d")
FULLDESCRIPTION=$(echo "$JSONID" | jq -r '.description')
THUMBNSILURL=$(youtube-dl $IDURL --get-thumbnail)
NEWFILENAME=${DATE}-${TITLE}-${ID}
NEWFILENAME=${NEWFILENAME///}

curl -o "${NEWFILENAME}.jpg" "$THUMBNSILURL"
convert "${NEWFILENAME}.jpg" "${NEWFILENAME}.jpg"

cp "./$FILE" "$NEWFILENAME.mp3"
mid3v2 -D "$NEWFILENAME.mp3"

FULL="Orginal Viedo: <a href=\"$ORGINALURL\">$ORGINALURL</a>

$FULLDESCRIPTION"
SHORT=${FULL:0:200}
SHORT=$FULL

mid3v2 -t "$TITLE" \
       -a "$UPLOADER" \
       -g "Speech" \
       -y "$DATE" \
       --picture="${NEWFILENAME}.jpg" \
       "$NEWFILENAME.mp3"

mid3v2 "$NEWFILENAME.mp3"

SIZE=$(($(ffprobe -i "$NEWFILENAME.mp3" -show_entries format=size -v quiet -of csv=p=0) / 1024 / 1024))
DURATION=$(ffprobe -i "$NEWFILENAME.mp3" -show_entries format=duration -v quiet -of csv="p=0" -sexagesimal)
DURATION=${DURATION%.*}
BITRATE=$(($(ffprobe -i "$NEWFILENAME.mp3" -show_entries format=bit_rate -v quiet -of csv="p=0") / 1024))
FREQUENCY=$(ffprobe -show_streams "$NEWFILENAME.mp3" -v quiet -of json | jq -r ".streams[]|select(.codec_name == \"mp3\").sample_rate")

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
xml ed -L -u "/PodcastGenerator/episode/authorPG/namePG" --value "${UPLOADER}" "${NEWFILENAME}.xml"
xml ed -L -u "/PodcastGenerator/episode/authorPG/emailPG" --value "" "${NEWFILENAME}.xml"
xml ed -L -u "/PodcastGenerator/episode/fileInfoPG/size" --value "$SIZE" "${NEWFILENAME}.xml"
xml ed -L -u "/PodcastGenerator/episode/fileInfoPG/duration" --value "$DURATION" "${NEWFILENAME}.xml"
xml ed -L -u "/PodcastGenerator/episode/fileInfoPG/bitrate" --value "$BITRATE" "${NEWFILENAME}.xml"
xml ed -L -u "/PodcastGenerator/episode/fileInfoPG/frequency" --value "$FREQUENCY" "${NEWFILENAME}.xml"

touch -t ${SDATE}0000 "$NEWFILENAME.mp3"
touch -t ${SDATE}0000 "$NEWFILENAME.xml"
touch -t ${SDATE}0000 "$NEWFILENAME.jpg"

mkdir -p "${PGAPPDATA}/media"
mkdir -p "${PGAPPDATA}/images"

cp -p "$NEWFILENAME.mp3" "${PGAPPDATA}/media"
cp -p "$NEWFILENAME.xml" "${PGAPPDATA}/media"
cp -p "$NEWFILENAME.jpg" "${PGAPPDATA}/images"

rm "$NEWFILENAME.mp3" "$NEWFILENAME.jpg" "$NEWFILENAME.xml" "./$FILE"

curl $PGREGENERATERSSURL
