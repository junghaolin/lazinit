#!/bin/bash

# 取得腳本所在目錄的絕對路徑
UTIL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 第一個參數為 Profile ID (例如 1, 2...)
PROFILE=$1
shift

if [[ -z "$PROFILE" ]]; then
    echo "Usage: cont.sh <id> [-- <command>]"
    echo "Example: cont.sh 1 -- ls -al"
    exit 1
fi

# 尋找對應的 .dex.<id>.env 檔案
ENV_FILE="${UTIL_DIR}/.dex.${PROFILE}.env"

if [[ ! -f "$ENV_FILE" ]]; then
    echo "Error: Config file $ENV_FILE not found."
    exit 1
fi

# --- 讀取環境變數 ---
# 1. 載入到目前的 script 環境 (用於獲取 CONTAINER_NAME 等)
# 2. 準備傳遞給 docker exec 的 -e 參數
ENV_ARGS=()
while IFS= read -r line || [[ -n "$line" ]]; do
    # 忽略註解與空行
    [[ "$line" =~ ^#.*$ ]] && continue
    [[ -z "$line" ]] && continue
    
    # 提取 key 和 value
    key=$(echo "$line" | cut -d'=' -f1)
    value=$(echo "$line" | cut -d'=' -f2-)
    
    # 匯出到目前的腳本環境
    export "$key"="$value"
    
    # 如果不是控制變數，則準備傳遞給容器
    if [[ ! "$key" =~ ^(CONTAINER_NAME|HOST_REFERENCE_PATH|GUEST_REFERENCE_PATH)$ ]]; then
        ENV_ARGS+=("-e" "$key=$value")
    fi
done < "$ENV_FILE"

# 檢查必要變數
CONTAINER=${CONTAINER_NAME}
if [[ -z "$CONTAINER" ]]; then
    echo "Error: CONTAINER_NAME must be specified in $ENV_FILE"
    exit 1
fi

# 設定 Reference Paths
HOST_REF=${HOST_REFERENCE_PATH:-$HOME}
GUEST_REF=${GUEST_REFERENCE_PATH:-$HOME}

# --- 路徑映射邏輯 ---
CWD=$(pwd)
HOST_REF_CLEAN="${HOST_REF%/}"
GUEST_REF_CLEAN="${GUEST_REF%/}"

if [[ "$CWD" == "$HOST_REF_CLEAN"* ]]; then
    REL_PATH="${CWD#$HOST_REF_CLEAN}"
    TARGET_PATH="${GUEST_REF_CLEAN}${REL_PATH}"
else
    TARGET_PATH="$GUEST_REF_CLEAN"
fi

# --- 容器狀態檢查與啟動 ---
STATE=$(docker inspect -f '{{.State.Running}}' "$CONTAINER" 2>/dev/null)
if [[ $? -ne 0 ]]; then
    echo "Error: Container '$CONTAINER' does not exist."
    exit 1
fi

if [[ "$STATE" != "true" ]]; then
    echo "Container '$CONTAINER' is not running. Starting it now..."
    docker start "$CONTAINER" > /dev/null
fi

# --- 執行指令 ---
if [[ "$1" == "--" ]]; then
    shift
fi

# 使用 bash -lic 來確保進入互動模式並載入完整環境 (包含 Alias 和 .bashrc)
if [[ $# -eq 0 ]]; then
    exec docker exec "${ENV_ARGS[@]}" -w "$TARGET_PATH" -it "$CONTAINER" bash -lic "bash"
else
    # 將所有參數封裝成字串，交由 bash -lic 執行
    CMD_STR=$(printf " %q" "$@")
    exec docker exec "${ENV_ARGS[@]}" -w "$TARGET_PATH" -it "$CONTAINER" bash -lic "$CMD_STR"
fi
