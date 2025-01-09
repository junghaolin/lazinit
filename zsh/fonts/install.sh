#!/bin/bash
sudo apt install unzip fontconfig -y
mkdir -p ~/.local/share/fonts
unzip SourceCodePro.zip -d ~/.local/share/fonts/
unzip Hack.zip -d ~/.local/share/fonts/
unzip FiraMono.zip -d ~/.local/share/fonts/
wget https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip
unzip JetBrainsMono-2.304.zip -d ~/.local/share/fonts/

fc-cache ~/.local/share/fonts
