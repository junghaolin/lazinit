# ~/.zsh/utils/check_alias.zsh
check_alias() {
  cmd="$1"
  pkg1="$2"
  pkg2="$3"

  # 若指令已存在則不處理
  if command -v "$cmd" >/dev/null 2>&1; then
    return 0
  fi

  # 遍歷候選套件
  for pkg in "$pkg1" "$pkg2"; do
    if apt-cache show "$pkg" >/dev/null 2>&1; then
      if apt-cache policy "$pkg" | grep -q 'Candidate: (none)'; then
        echo "Package '$pkg' exists but has no installable candidate. Skipping..."
        continue
      fi

      # 權限與安裝處理
      if [ "$(id -u)" -eq 0 ]; then
        apt install "$pkg" -y
        return $?
      elif groups "$USER" | grep -qw sudo; then
        echo "Installing '$pkg' for missing command '$cmd' requires sudo."
        if sudo -v; then
          sudo apt install "$pkg" -y
          return $?
        else
          echo "Sudo authentication failed. Cannot install '$pkg'."
          return 1
        fi
      else
        echo "Cannot install '$pkg'. You are not root and do not have sudo permissions."
        return 1
      fi
    fi
  done

  echo "Command '$cmd' not found and no matching apt packages available."
  return 1
}

