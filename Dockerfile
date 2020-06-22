FROM alpine:3

ENV YTURL
ENV ARCHIVEFILE /tmp/arhivefile.txt
ENV SKIPARCHIVEFILEINIT 5
ENV PGAPPDATA /data/

RUN apk add youtube-dl xmlstarlet ffmpeg jq mutagen 

WORKDIR /scripts/

COPY . /scripts/