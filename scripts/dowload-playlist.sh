#!/bin/bash -xe 
time {
    if [ "$SKIPYTDLUPDATE" == false ] ; then
	    pip install --upgrade youtube_dl
    fi

	if [ ! -f $ARCHIVEFILE ]; then
	    TMPFILE=$(mktemp)
	    for ID in $(youtube-dl $YTURL --get-id)
	    do
	        echo "youtube $ID" >> $TMPFILE
	    done
	    tail -n +$SKIPARCHIVEFILEINIT $TMPFILE > $ARCHIVEFILE
	fi
	
	youtube-dl $YTURL --download-archive $ARCHIVEFILE  --yes-playlist --limit-rate $LIMITRATE --cookies $COOKIEFILE --no-progress --write-info-json --sleep-interval $MINSLEAP --max-sleep-interval $MAXSELEAP -x --audio-format mp3 --id --exec './process-video.sh {}' $YTDLOPTIONS
}