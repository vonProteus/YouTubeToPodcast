FROM alpine:3.17

ENV YTURL=https://www.youtube.com/watch?v=dQw4w9WgXcQ \
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
    SKIPYTDLUPDATE=false \
    PATH=$PATH:/scripts/ \
    CPUID=\#33

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="YouTube to Podcast" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/vonProteus/YouTubeToPodcast" \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0"

RUN apk add --no-cache py-pip bash xmlstarlet ffmpeg jq mutagen curl imagemagick rtmpdump sudo\
    && pip install --upgrade youtube_dl

WORKDIR /tmp/

COPY ./scripts/ /scripts/

CMD dowload-playlist.sh
