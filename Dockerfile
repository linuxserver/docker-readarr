FROM ghcr.io/linuxserver/baseimage-ubuntu:focal

# set version label
ARG BUILD_DATE
ARG VERSION
ARG READARR_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="Roxedus"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ARG READARR_BRANCH="nightly"
ENV XDG_CONFIG_HOME="/config/xdg"

RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install --no-install-recommends -y \
    jq \
    libchromaprint-tools \    
    libicu66 \
    sqlite3 && \
  echo "**** install readarr ****" && \
  mkdir -p /app/readarr/bin && \
  if [ -z ${READARR_RELEASE+x} ]; then \
    READARR_RELEASE=$(curl -sL "https://readarr.servarr.com/v1/update/${READARR_BRANCH}/changes?runtime=netcore&os=linux" \
    | jq -r '.[0].version'); \
  fi && \
  curl -o \
  /tmp/readarr.tar.gz -L \
    "https://readarr.servarr.com/v1/update/${READARR_BRANCH}/updatefile?version=${READARR_RELEASE}&os=linux&runtime=netcore&arch=x64" && \
  tar ixzf \
  /tmp/readarr.tar.gz -C \
    /app/readarr/bin --strip-components=1 && \
  echo "UpdateMethod=docker\nBranch=${READARR_BRANCH}\nPackageVersion=${VERSION}\nPackageAuthor=linuxserver.io" > /app/readarr/package_info && \
  echo "**** cleanup ****" && \
  rm -rf \
    /app/readarr/bin/Readarr.Update \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 8787
VOLUME /config
