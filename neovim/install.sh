#!/bin/bash

sudo apt update
sudo apt install git

#install lazy.vim
git clone --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable ~/.local/share/nvim/lazy/lazy.nvim

#install nvm
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

#install node/npm
nvm install --lts

#installations for LSP:

#Markdown:
curl -L -o marksman.tar.gz https://github.com/artempyanykh/marksman/releases/latest/download/marksman-linux.tar.gz
tar -xvzf marksman.tar.gz
sudo mv marksman /usr/local/bin/

#Lua
sudo apt install ninja-build git build-essential
cd /tmp
git clone https://github.com/LuaLS/lua-language-server.git
cd lua-language-server
git submodule update --init --recursive
cd 3rd/luamake
./compile/install.sh
cd ../..
./3rd/luamake/luamake rebuild
sudo mv build/bin/lua-language-server /usr/local/bin/
sudo mkdir -p /opt
sudo mv build/bin/main.lua /opt/

#YAML
npm install -g yaml-language-server

#golang
sudo apt install golang -y
go install golang.org/x/tools/gopls@latest

#C/C++
sudo apt install clangd

#Bash
npm install -g bash-language-server

#Python
npm install -g pyright

#JSON
npm install -g vscode-langservers-extracted

#Dockerfile
npm install -g dockerfile-language-server-nodejs
