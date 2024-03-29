#!/bin/bash -xe
time {
   if [ "$SKIPYTDLUPDATE" == false ]; then
      pushd /src
      git reset
      git checkout .
      git clean -fdx
      git pull
      echo "updating to version from git $(git rev-parse HEAD)"
      make youtube-dl
      popd
   fi

   if [ ! -f $ARCHIVEFILE ]; then
      TMPFILE=$(mktemp)
      for ID in $(youtube-dl $YTURL --get-id); do
         echo "youtube $ID" >>$TMPFILE
      done
      tail -n +$SKIPARCHIVEFILEINIT $TMPFILE >$ARCHIVEFILE
   fi

   youtube-dl $YTURL --download-archive $ARCHIVEFILE --yes-playlist --limit-rate $LIMITRATE --cookies $COOKIEFILE --no-progress --write-info-json --sleep-interval $MINSLEAP --max-sleep-interval $MAXSELEAP -x --audio-format mp3 --id --exec 'process-video.sh {}' $YTDLOPTIONS
   YT_EXIT_CODE=$?

   curl $PGREGENERATERSSURL || echo "notifying PodcastGenerator failed…"

   exit $YT_EXIT_CODE
}
