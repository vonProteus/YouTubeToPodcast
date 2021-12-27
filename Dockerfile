FROM alpine:3.15

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
    HOST=example.com \
    SKIPYTDLUPDATE=false

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="YouTube to Podcast" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/vonProteus/YouTubeToPodcast" \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0"

RUN apk add --no-cache py-pip bash xmlstarlet ffmpeg jq mutagen curl imagemagick rtmpdump \
    && pip install --upgrade youtube_dl

WORKDIR /scripts/

COPY ./scripts/ /scripts/

CMD ./dowload-playlist.sh
