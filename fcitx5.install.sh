#!/bin/bash

sudo apt install fcitx5-chinese-addons cmake build-essential extra-cmake-modules gettext libimecore-dev libimetable-dev libboost-system-dev libboost-thread-dev libboost-program-options-dev libboost-test-dev libfcitx5utils-dev libfcitx5core-dev zenity
cd /tmp
git clone https://github.com/fcitx/fcitx5-table-extra.git
cd fcitx5-table-extra
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_LIBDIR=/usr/lib ..
cmake --build .
sudo cmake --install .
im-config
