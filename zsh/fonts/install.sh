#!/bin/bash
sudo apt install unzip fontconfig -y
mkdir -p ~/.local/share/fonts
unzip SourceCodePro.zip -d ~/.local/share/fonts/
fc-cache ~/.local/share/fonts
