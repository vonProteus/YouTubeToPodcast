#!/bin/bash -xe

FILE=$1
FILE="${FILE##*/}"
ID="${FILE%.*}"

echo working on $FILE
JSONFILE=./${ID}.info.json

ORGINALURL=$(jq -r '.webpage_url' $JSONFILE)
TITLE=$(jq -r '.title' $JSONFILE)
UPLOADER=$(jq -r '.uploader' $JSONFILE)
SDATE=$(jq -r '.upload_date' $JSONFILE)
FULLDESCRIPTION=$(jq -r '.description' $JSONFILE)
THUMBNSILURL=$(jq -r ".thumbnails | max_by(.height).url" $JSONFILE)
ORGINALDURATIONINSECONDS=$(jq -r '.duration' $JSONFILE)
ORGINALDURATION=$(date -d @$ORGINALDURATIONINSECONDS -u +%H:%M:%S)

DATE=$(date -d "${SDATE}0000" +"%Y-%m-%d")
NEWFILENAME=${DATE}-$(echo ${TITLE} | sed 's/\W/_/g')-${ID}

curl -o "${NEWFILENAME}.jpg" "$THUMBNSILURL"
convert "${NEWFILENAME}.jpg" "${NEWFILENAME}.jpg"

cp "./$FILE" "$NEWFILENAME.mp3"
mid3v2 -D "$NEWFILENAME.mp3"

FULL="Original Video: $ORGINALURL
Original duration: $ORGINALDURATION

$FULLDESCRIPTION"
SHORT=${FULL:0:200}
SHORT=$FULL

mid3v2 -t "$TITLE" \
   -a "$UPLOADER" \
   -g "Speech" \
   -y "$DATE" \
   --picture="${NEWFILENAME}.jpg" \
   "$NEWFILENAME.mp3"

ffprobe -show_streams "$NEWFILENAME.mp3" -v quiet -of json >"$NEWFILENAME.json"

SIZE=$(($(ffprobe -i "$NEWFILENAME.mp3" -show_entries format=size -v quiet -of csv=p=0) / 1024 / 1024))
DURATION=$(jq -r ".streams[]|select(.codec_name == \"mp3\").duration" "$NEWFILENAME.json")
DURATION=${DURATION%.*}

if (($DURATION > $(($ORGINALDURATIONINSECONDS - 10)) && $DURATION < $(($ORGINALDURATIONINSECONDS + 10)))); then
   echo "duration $DURATION is ok"
else
   echo "duration $DURATION for $ID is not ok expected value around $ORGINALDURATIONINSECONDS"
   exit 1
fi

BITRATE=$(($(jq -r ".streams[]|select(.codec_name == \"mp3\").bit_rate" "$NEWFILENAME.json") / 1024))
FREQUENCY=$(jq -r ".streams[]|select(.codec_name == \"mp3\").sample_rate" "$NEWFILENAME.json")

IMGPGURL="http://${HOST}/images/${NEWFILENAME}.jpg"

cp /scripts/template.xml "${NEWFILENAME}.xml"

xml ed -L -u "/PodcastGenerator/episode/titlePG" --value "#CDATASTART#${TITLE}#CDATAEND#" "${NEWFILENAME}.xml"
xml ed -L -u "/PodcastGenerator/episode/shortdescPG" --value "#CDATASTART#${SHORT}#CDATAEND#" "${NEWFILENAME}.xml"
xml ed -L -u "/PodcastGenerator/episode/longdescPG" --value "#CDATASTART#${FULL}#CDATAEND#" "${NEWFILENAME}.xml"
xml ed -L -u "/PodcastGenerator/episode/imgPG" --value "$IMGPGURL" "${NEWFILENAME}.xml"
xml ed -L -u "/PodcastGenerator/episode/categoriesPG/category1PG" --value "uncategorized" "${NEWFILENAME}.xml"
xml ed -L -u "/PodcastGenerator/episode/categoriesPG/category2PG" --value "" "${NEWFILENAME}.xml"
xml ed -L -u "/PodcastGenerator/episode/categoriesPG/category3PG" --value "" "${NEWFILENAME}.xml"
xml ed -L -u "/PodcastGenerator/episode/keywordsPG" --value "#CDATASTART##CDATAEND#" "${NEWFILENAME}.xml"
xml ed -L -u "/PodcastGenerator/episode/explicitPG" --value "no" "${NEWFILENAME}.xml"
xml ed -L -u "/PodcastGenerator/episode/authorPG/namePG" --value "${UPLOADER}" "${NEWFILENAME}.xml"
xml ed -L -u "/PodcastGenerator/episode/authorPG/emailPG" --value "" "${NEWFILENAME}.xml"
xml ed -L -u "/PodcastGenerator/episode/fileInfoPG/size" --value "$SIZE" "${NEWFILENAME}.xml"
xml ed -L -u "/PodcastGenerator/episode/fileInfoPG/duration" --value "$DURATION" "${NEWFILENAME}.xml"
xml ed -L -u "/PodcastGenerator/episode/fileInfoPG/bitrate" --value "$BITRATE" "${NEWFILENAME}.xml"
xml ed -L -u "/PodcastGenerator/episode/fileInfoPG/frequency" --value "$FREQUENCY" "${NEWFILENAME}.xml"

sed -i 's/#CDATASTART#/\<\!\[CDATA\[/g' "${NEWFILENAME}.xml"
sed -i 's/#CDATAEND#/\]\]\>/g' "${NEWFILENAME}.xml"

touch -t ${SDATE}0000 "$NEWFILENAME.mp3"
touch -t ${SDATE}0000 "$NEWFILENAME.xml"
touch -t ${SDATE}0000 "$NEWFILENAME.jpg"

mkdir -p "${PGAPPDATA}/media"
mkdir -p "${PGAPPDATA}/images"

sudo -u $CPUID cp -p "$NEWFILENAME.mp3" "${PGAPPDATA}/media"
sudo -u $CPUID cp -p "$NEWFILENAME.xml" "${PGAPPDATA}/media"
sudo -u $CPUID cp -p "$NEWFILENAME.jpg" "${PGAPPDATA}/images"

rm "./$FILE" "./${ID}.info.json" "$NEWFILENAME.mp3" "$NEWFILENAME.jpg" "$NEWFILENAME.xml" "$NEWFILENAME.json"
