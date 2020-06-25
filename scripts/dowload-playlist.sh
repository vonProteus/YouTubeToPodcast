#!/bin/bash -xe 

if [ ! -f $ARCHIVEFILE ]; then
    TMPFILE=$(mktemp)
    for ID in $(youtube-dl $YTURL --get-id)
    do
        echo "youtube $ID" >> $TMPFILE
    done
    tail -n +$SKIPARCHIVEFILEINIT $TMPFILE > $ARCHIVEFILE
fi


youtube-dl $YTURL --download-archive $ARCHIVEFILE  --yes-playlist --limit-rate 1.5M --playlist-random --playlist-items 1-$SKIPARCHIVEFILEINIT --verbose -x --audio-format mp3 --id --exec './process-video.sh {}'
