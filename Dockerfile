FROM ubuntu:18.04
####### AS ROOT #######
# deal with sources for build-dep
RUN cp /etc/apt/sources.list /etc/apt/sources.list~
RUN sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list
RUN apt-get update
# for QT
RUN apt-get build-dep -y qt5-default
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y  install libxcb-xinerama0-dev build-essential perl python git "^libxcb.*" libx11-xcb-dev libglu1-mesa-dev libxrender-dev libxi-dev flex bison gperf libicu-dev libxslt-dev ruby libssl-dev libxcursor-dev libxcomposite-dev libxdamage-dev libxrandr-dev libfontconfig1-dev libcap-dev libxtst-dev libpulse-dev libudev-dev libpci-dev libnss3-dev libasound2-dev libxss-dev libegl1-mesa-dev gperf bison libbz2-dev libgcrypt11-dev libdrm-dev libcups2-dev libatkmm-1.6-dev libasound2-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libbluetooth-dev bluetooth blueman bluez libusb-dev libdbus-1-dev bluez-hcidump bluez-tools libbluetooth-dev libgles2-mesa-dev

# Build and install Qt 5.12:
WORKDIR /opt
RUN mkdir qt5
# RUN sudo chown $USER qt5
RUN git clone https://code.qt.io/qt/qt5.git
# RUN cd qt5
WORKDIR /opt/qt5
RUN git checkout 5.12
RUN perl init-repository --module-subset=default,-qtwebkit,-qtwebkit-examples,-qtwebengine
RUN mkdir build
WORKDIR /opt/qt5/build
RUN ../configure -prefix /opt/Qt/5.12-static/ -release -opensource -confirm-license -static -no-sql-mysql -no-sql-psql -no-sql-sqlite -no-journald -qt-zlib -no-mtdev -no-gif -qt-libpng -qt-libjpeg -qt-harfbuzz -qt-pcre -qt-xcb -no-glib -no-compile-examples -no-cups -no-iconv -no-tslib -dbus-linked -no-xcb-xlib -no-eglfs -no-directfb -no-linuxfb -no-kms -nomake examples -nomake tests -skip qtwebsockets -skip qtwebchannel -skip qtwebengine -skip qtwayland -skip qtwinextras -skip qtsvg -skip qtsensors -skip multimedia -no-evdev -no-libproxy -no-icu -no-accessibility -qt-freetype -skip qtimageformats -opengl es2
RUN make -j9
RUN make install

# build vesc tool "platinum" because i took the time to build from   source
COPY files/vesc_tool /usr/local/src/vesc_tool
WORKDIR /usr/local/src/vesc_tool
ENV PATH="/opt/Qt/5.12-static/bin:${PATH}"
RUN qmake "CONFIG += release_lin build_platinum" vesc_tool.pro
RUN make clean
RUN make -j8
RUN rm -rf build/lin/obj
WORKDIR /usr/local/src/vesc_tool/build/lin
RUN zip vesc_tool_original_linux.zip `ls | grep -v '\.zip$'`
RUN ls | grep -v '\.zip$' | xargs rm

# add a non root user
RUN useradd --create-home --shell /bin/bash vescuser
RUN echo 'vescuser:vescuser' | chpasswd
RUN usermod -aG sudo vescuser
RUN usermod -aG dialout vescuser

# # deal with scripted entrypoints
# COPY entrypoints /usr/local/bin
# USER root
# RUN chmod +x /usr/local/bin/*.sh

# USER vescuser
# WORKDIR /home/vescuser
# ENV DISPLAY=localhost:0
ENTRYPOINT ["/bin/bash"]