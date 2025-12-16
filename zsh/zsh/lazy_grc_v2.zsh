# ~/.zsh/lazy_grc_v2.zsh
# 優化版：避免覆蓋核心系統命令，使用別名前綴

# 設定所有 grc 相關 alias（使用 'g' 前綴避免覆蓋系統命令）
_setup_grc_aliases() {
  alias grc='grc -es --colour=auto'
  
  # 使用前綴避免覆蓋系統命令
  alias gnetstat='grc netstat'
  alias glsof='grc lsof'
  alias gping='grc ping'
  alias gtraceroute='grc traceroute'
  alias gifconfig='grc ifconfig'
  alias gmount='grc mount'
  alias gps='grc ps'
  alias gdf='grc df'
  alias gdu='grc du'
  alias gdig='grc dig'
  alias gdiff='grc diff'
  alias gwdiff='grc wdiff'
  alias groute='grc route'
  alias gmtr='grc mtr'
  
  # 這些命令通常只在終端使用，覆蓋影響較小（可選）
  # 如果你想要覆蓋，取消以下註釋：
  # alias git='grc git'
  # alias docker='grc docker'
}

# 如果 grc 已存在，直接設定
if command -v grc >/dev/null 2>&1; then
  _setup_grc_aliases
  unfunction _setup_grc_aliases
  return
fi

# Lazy loading：一次性初始化
_lazy_grc_init_once() {
  # 嘗試安裝
  if ! command -v grc >/dev/null 2>&1; then
    if command -v apt-cache >/dev/null 2>&1 && apt-cache show grc >/dev/null 2>&1; then
      echo "[lazy_grc] Installing grc..."
      if [ "$(id -u)" -eq 0 ]; then
        apt install grc -y >/dev/null 2>&1
      elif groups "$USER" | grep -qw sudo; then
        sudo apt install grc -y 2>/dev/null
      fi
    fi
  fi

  # 設定 alias
  if command -v grc >/dev/null 2>&1; then
    _setup_grc_aliases
  fi

  # 清理函數
  unfunction gnetstat glsof gping gtraceroute gifconfig gmount gps gdf gdu gdig gdiff gwdiff groute gmtr 2>/dev/null
  unfunction _lazy_grc_init_once _setup_grc_aliases 2>/dev/null
}

# 單一觸發函數
_lazy_grc_trigger() {
  _lazy_grc_init_once
  "$@"
}

# 使用 'g' 前綴的命令
gnetstat()     { _lazy_grc_trigger gnetstat "$@"; }
glsof()        { _lazy_grc_trigger glsof "$@"; }
gping()        { _lazy_grc_trigger gping "$@"; }
gtraceroute()  { _lazy_grc_trigger gtraceroute "$@"; }
gifconfig()    { _lazy_grc_trigger gifconfig "$@"; }
gmount()       { _lazy_grc_trigger gmount "$@"; }
gps()          { _lazy_grc_trigger gps "$@"; }
gdf()          { _lazy_grc_trigger gdf "$@"; }
gdu()          { _lazy_grc_trigger gdu "$@"; }
gdig()         { _lazy_grc_trigger gdig "$@"; }
gdiff()        { _lazy_grc_trigger gdiff "$@"; }
gwdiff()       { _lazy_grc_trigger gwdiff "$@"; }
groute()       { _lazy_grc_trigger groute "$@"; }
gmtr()         { _lazy_grc_trigger gmtr "$@"; }
