FROM lscr.io/linuxserver/webtop:ubuntu-xfce

# Set environment variables
ENV WINEPREFIX="/config/.wine"
ENV WINEARCH="win32"

# Install Wine and dependencies
RUN \
  echo "**** add architecture i386 ****" && \
  dpkg --add-architecture i386 && \
  echo "**** install wine and tools ****" && \
  apt-get update && \
  apt-get install -y \
    wine \
    wine32 \
    winetricks \
    p7zip-full && \
  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Copy split installer parts
COPY "iVMS-4200(V3.6.0.6_E).tar.gz.part"* /tmp/

# Reassemble and extract installer
RUN \
  echo "**** reassemble installer ****" && \
  cat /tmp/"iVMS-4200(V3.6.0.6_E).tar.gz.part"* | tar -xzv -C /tmp/ && \
  rm /tmp/"iVMS-4200(V3.6.0.6_E).tar.gz.part"*

# Metadata
LABEL maintainer="Antigravity"
LABEL description="iVMS-4200 in Docker using Wine and Webtop (noVNC)"
