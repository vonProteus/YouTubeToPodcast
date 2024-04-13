#!/bin/bash -xe
time {
   if [ "$SKIPYTDLUPDATE" == false ]; then
      pushd /src
      YT_GIT_REVISION=${YT_GIT_REVISION:="master"}
      git reset
      git clean -fdx
      git pull
      git checkout "${YT_GIT_REVISION}"
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

   youtube-dl $YTURL \
      --download-archive $ARCHIVEFILE \
      --yes-playlist \
      --limit-rate $LIMITRATE \
      --cookies $COOKIEFILE \
      --no-progress \
      --write-info-json \
      --sleep-interval $MINSLEAP \
      --max-sleep-interval $MAXSELEAP \
      --extract-audio \
      --audio-format mp3 \
      --id \
      --exec 'process-video.sh {}' \
      $YTDLOPTIONS \
      || YT_EXIT_CODE=$?

   curl -i -L "$PGREGENERATERSSURL" || echo "notifying PodcastGenerator failed…"

   exit ${YT_EXIT_CODE:=0}
}
