FROM alpine:edge

ENV YTURL=http://example.com/video?v=wwdsfkpgjpds \
    ARCHIVEFILE=/data/youtube-arhive-file.txt \
    SKIPARCHIVEFILEINIT=5 \
    PGAPPDATA=/data/ \
    PGREGENERATERSSURL=http://example.com \
    COOKIEFILE=/data/youtube-cookie-file.txt \
    LIMITRATE=1.5M \
    YTDLOPTIONS="--verbose" \
    MINSLEAP=30 \
    MAXSELEAP=120 \
    HOST=example.com


RUN apk add youtube-dl bash xmlstarlet ffmpeg jq mutagen curl imagemagick rtmpdump

WORKDIR /scripts/

COPY ./scripts/ /scripts/

CMD ./dowload-playlist.sh
