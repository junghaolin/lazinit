#!/bin/bash

# ==================== 安裝 Neovim 0.11.5 ====================
echo "安裝 Neovim 0.11.5..."

# 下載 AppImage
wget -q --show-progress -O /tmp/nvim.appimage \
    https://github.com/neovim/neovim/releases/download/v0.11.5/nvim-linux-x86_64.appimage

# 安裝 FUSE 依賴（AppImage 需要）
sudo apt update
sudo apt install -y fuse libfuse2

# 設置權限並安裝
chmod +x /tmp/nvim.appimage
sudo mv /tmp/nvim.appimage /usr/local/bin/nvim

echo "Neovim 安裝完成: $(nvim --version | head -n1)"

# ==================== 安裝基礎工具 ====================
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

# 安裝到 /opt 並創建符號連結
sudo mkdir -p /opt/lua-language-server
sudo cp -r build/bin/* /opt/lua-language-server/
sudo ln -sf /opt/lua-language-server/lua-language-server /usr/local/bin/lua-language-server

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

sudo apt-get install luajit
sudo apt-get install libmagickwand-dev
sudo apt-get install libgraphicsmagick1-dev
sudo apt-get install luarocks
sudo luarocks install magick
