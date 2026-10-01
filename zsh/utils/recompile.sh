#!/bin/bash
# ZSH 配置重新編譯腳本
# 用途：在修改配置後重新編譯所有 .zsh 檔案

echo "🔄 重新編譯 ZSH 配置..."

# 編譯主配置
echo "  編譯 ~/.zshrc..."
zsh -c "zcompile ~/.zshrc" 2>/dev/null

# 編譯所有 lazy loading 腳本
echo "  編譯 lazy loading 腳本..."
cd ~/.zsh

for file in lazy_*_v2.zsh utils/check_alias.zsh; do
  if [ -f "$file" ]; then
    zsh -c "zcompile $file" 2>/dev/null
    echo "    ✓ $file"
  fi
done

echo ""
echo "✅ 編譯完成！"
echo ""
echo "📊 編譯檔案大小："
ls -lh ~/.zshrc.zwc ~/.zsh/*.zwc ~/.zsh/utils/*.zwc 2>/dev/null | awk '{print "  " $5 "\t" $9}'

echo ""
echo "💡 執行以下命令使配置生效："
echo "   source ~/.zshrc"
