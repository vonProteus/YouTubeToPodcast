#!/bin/bash -xe 

FILE=$1
ID="${FILE%.*}"

echo working on $FILE
JSONFILE=${ID}.info.json


ORGINALURL=$(jq -r  '.webpage_url' $JSONFILE)
TITLE=$(jq -r  '.title' $JSONFILE)
UPLOADER=$(jq -r  '.uploader' $JSONFILE)
SDATE=$(jq -r '.upload_date' $JSONFILE)
FULLDESCRIPTION=$(jq -r '.description' $JSONFILE)
THUMBNSILURL=$(jq -r ".thumbnails | max_by(.height).url" $JSONFILE)

DATE=$(date -d "${SDATE}0000" +"%Y-%m-%d")
NEWFILENAME=${DATE}-$(echo ${TITLE} | sed 's/\W/_/g')-${ID}

curl -o "${NEWFILENAME}.jpg" "$THUMBNSILURL"
convert "${NEWFILENAME}.jpg" "${NEWFILENAME}.jpg"

cp "./$FILE" "$NEWFILENAME.mp3"
mid3v2 -D "$NEWFILENAME.mp3"

FULLDESCRIPTION=${FULLDESCRIPTION//&/ !and! }

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

ffprobe -show_streams "$NEWFILENAME.mp3" -v quiet -of json > "$NEWFILENAME.json"

SIZE=$(($(ffprobe -i "$NEWFILENAME.mp3" -show_entries format=size -v quiet -of csv=p=0) / 1024 / 1024))
DURATION=$(jq -r ".streams[]|select(.codec_name == \"mp3\").duration" "$NEWFILENAME.json")
DURATION=${DURATION%.*}
BITRATE=$(($(jq -r ".streams[]|select(.codec_name == \"mp3\").bit_rate" "$NEWFILENAME.json") / 1024))
FREQUENCY=$(jq -r ".streams[]|select(.codec_name == \"mp3\").sample_rate" "$NEWFILENAME.json")

IMGPGURL="http://${HOST}/images/${NEWFILENAME}.jpg"

cp template.xml "${NEWFILENAME}.xml"

xml ed -L -u "/PodcastGenerator/episode/titlePG" --value "$TITLE" "${NEWFILENAME}.xml"
xml ed -L -u "/PodcastGenerator/episode/shortdescPG" --value "$SHORT" "${NEWFILENAME}.xml"
xml ed -L -u "/PodcastGenerator/episode/longdescPG" --value "$FULL" "${NEWFILENAME}.xml"
xml ed -L -u "/PodcastGenerator/episode/imgPG" --value "$IMGPGURL" "${NEWFILENAME}.xml"
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

rm "./$FILE" "./${ID}.info.json" "$NEWFILENAME.mp3" "$NEWFILENAME.jpg" "$NEWFILENAME.xml" "$NEWFILENAME.json"

curl $PGREGENERATERSSURL
