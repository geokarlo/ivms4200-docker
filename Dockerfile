FROM lscr.io/linuxserver/webtop:ubuntu-xfce

# Set environment variables for Wine
ENV WINEPREFIX="/config/.wine" \
  WINEARCH="win32" \
  DISPLAY=:1

# Install Wine and dependencies
RUN echo "**** add architecture i386 ****" && \
  dpkg --add-architecture i386 && \
  echo "**** install wine and tools ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
  wine \
  wine32 \
  wine64 \
  winetricks \
  cabextract \
  p7zip-full \
  zenity \
  xdotool \
  wmctrl \
  xvfb \
  libodbc2 \
  libodbc2:i386 && \
  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy split installer parts
COPY "iVMS-4200(V3.5.0.9_E).tar.gz.part"* /tmp/

# Reassemble and extract installer
RUN echo "**** reassemble installer ****" && \
  cat /tmp/"iVMS-4200(V3.5.0.9_E).tar.gz.part"* | tar -xzv -C /tmp/ && \
  rm -f /tmp/"iVMS-4200(V3.5.0.9_E).tar.gz.part"* && \
  echo "**** installer ready at /tmp/iVMS-4200(V3.5.0.9_E).exe ****"

# Copy custom scripts
COPY install-ivms.sh /usr/local/bin/install-ivms.sh
COPY autostart-ivms.sh /usr/local/bin/autostart-ivms.sh
COPY custom-services.d/ivms-init /etc/services.d/ivms-init/run

# Set permissions for scripts
RUN chmod +x /usr/local/bin/install-ivms.sh && \
  chmod +x /usr/local/bin/autostart-ivms.sh && \
  chmod +x /etc/services.d/ivms-init/run

# Create autostart desktop entry
RUN rm -rf /defaults/autostart && \
  mkdir -p /defaults/autostart && \
  echo "[Desktop Entry]" > /defaults/autostart/ivms4200.desktop && \
  echo "Type=Application" >> /defaults/autostart/ivms4200.desktop && \
  echo "Name=iVMS-4200" >> /defaults/autostart/ivms4200.desktop && \
  echo "Exec=/usr/local/bin/autostart-ivms.sh" >> /defaults/autostart/ivms4200.desktop && \
  echo "Hidden=false" >> /defaults/autostart/ivms4200.desktop && \
  echo "NoDisplay=false" >> /defaults/autostart/ivms4200.desktop && \
  echo "X-GNOME-Autostart-enabled=true" >> /defaults/autostart/ivms4200.desktop

# Expose noVNC port
EXPOSE 3000

# Metadata
LABEL maintainer="https://github.com/geokarlo/ivms4200-docker.git" \
  description="iVMS-4200 v3.5.0.9 in Docker using Wine and Webtop (noVNC) with automated installation" \
  version="3.5.0.9"
