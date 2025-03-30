#!/bin/bash
rm -rf actual_apt_pks
cat init_apt_pks | tr ' ' '\n' | while read pkg; do
  if apt-cache show "$pkg" >/dev/null 2>&1; then
    if apt-cache policy "$pkg" | grep -q 'Candidate: (none)'; then
      continue
    else
      echo "$pkg"
    fi
  fi
done |
  paste -sd ' ' |
  tee -a actual_apt_pks

SUDO="sudo"
if [ "$(id -u)" == "0" ]; then
  SUDO=""
fi

$SUDO apt update
$SUDO apt upgrade -y
$SUDO apt install $(cat actual_apt_pks) -y
ZSHP=$(pwd)/zsh
cd ~
mv .zshrc .zshrc.bk
mv .zsh .zsh.bk
ZP=$(realpath --relative-to="$HOME" "$ZSHP")
ln -s $ZP/zshrc .zshrc
ln -s $ZP/zsh .zsh

if [ ! "$SHELL" = "/usr/bin/zsh" ]; then
  chsh -s /usr/bin/zsh
  zsh
fi
