FROM alpine:edge

ENV YTURL http://example.com
ENV ARCHIVEFILE /data/youtube-arhive-file.txt
ENV SKIPARCHIVEFILEINIT 5
ENV PGAPPDATA /data/
ENV PGREGENERATERSSURL http://example.com
ENV COOKIEFILE /data/youtube-cookie-file.txt
ENV LIMITRATE 1.5M
ENV YTDLOPTIONS --verbose
ENV MINSLEAP 30
ENV MAXSELEAP 120
ENV HOST http://example.com


RUN apk add youtube-dl bash xmlstarlet ffmpeg jq mutagen curl imagemagick rtmpdump

WORKDIR /scripts/

COPY ./scripts/ /scripts/

CMD ./dowload-playlist.sh
