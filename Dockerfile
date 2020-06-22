FROM alpine:edge

ENV YTURL https://www.youtube.com/channel/UChS9wazLlTUHSTeKVG39hZw
ENV ARCHIVEFILE /data/youtube-arhive-file.txt
ENV SKIPARCHIVEFILEINIT 5
ENV PGAPPDATA /data/
ENV PGREGENERATERSSURL http://example.com

RUN apk add youtube-dl bash xmlstarlet ffmpeg jq mutagen curl imagemagick

WORKDIR /scripts/

COPY ./scripts/ /scripts/

CMD ./dowload-playlist.sh
