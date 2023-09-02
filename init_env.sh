#!/bin/bash
SUDO="sudo"
if [ "$(id -u)" == "0" ];then
  SUDO=""
fi
$SUDO apt update
$SUDO apt upgrade -y
$SUDO apt install $(cat init_apt_pks) -y
