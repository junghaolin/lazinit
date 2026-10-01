# 模块化安装和错误处理说明

## 🎯 问题 1: 包安装失败会中断吗?

### ❌ 之前的行为
```bash
# 一次性安装所有包
apt install $(cat actual_apt_pks) -y

# 如果某个包不存在或安装失败，整个命令失败，后续包不会安装
```

### ✅ 现在的行为（已修复 install.v2.sh）

```bash
# 逐个安装，容忍错误
while read -r pkg; do
    if apt install -y "$pkg"; then
        echo "✓ $pkg"
        SUCCESS_COUNT++
    else
        echo "✗ $pkg (跳过)"
        FAILED_COUNT++
        FAILED_PKGS="$FAILED_PKGS $pkg"
    fi
done < actual_apt_pks

# 显示统计
echo "成功: $SUCCESS_COUNT"
echo "失败: $FAILED_COUNT"
```

**效果**：
- ✅ 单个包失败不影响其他包
- ✅ 显示详细的成功/失败统计
- ✅ 安装继续进行

---

## 🎯 问题 2: 如何只安装特定模块?

### 方法 1: 使用命令行参数

```bash
# 只安装 ZSH
./install.sh --only-zsh
# 或
./init_env.v2.sh --only-zsh

# 只安装 Neovim
./install.sh --only-nvim
# 或
cd neovim && ./install.v2.sh

# 跳过包安装，只配置
./install.sh --skip-pkgs

# 跳过 ZSH，只装包和 Neovim
./install.sh --skip-zsh

# 跳过 Neovim 提示
./install.sh --skip-nvim
```

### 方法 2: 直接运行子模块

```bash
# 只配置 ZSH（不安装包）
cd ~/lazinit/zsh
./install.sh

# 只安装 Neovim
cd ~/lazinit/neovim
./install.v2.sh

# 只编译 ZSH 配置
cd ~/lazinit/zsh/utils
./recompile.sh
```

---

## 📋 完整参数列表

### install.sh / init_env.v2.sh

| 参数 | 说明 | 包安装 | ZSH | Neovim |
|------|------|--------|-----|--------|
| (无参数) | 完整安装 | ✅ | ✅ | ✅ (询问) |
| `--only-zsh` | 只安装 ZSH | ✅ | ✅ | ❌ |
| `--only-nvim` | 只安装 Neovim | ❌ | ❌ | ✅ (直接安装) |
| `--skip-pkgs` | 跳过包安装 | ❌ | ✅ | ✅ (询问) |
| `--skip-zsh` | 跳过 ZSH | ✅ | ❌ | ✅ (询问) |
| `--skip-nvim` | 跳过 Neovim | ✅ | ✅ | ❌ |
| `--help` | 显示帮助 | - | - | - |

---

## 🚀 使用场景

### 场景 1: 全新机器完整安装
```bash
cd ~/lazinit
./install.sh
```

### 场景 2: 只想要 ZSH 配置
```bash
cd ~/lazinit
./install.sh --only-zsh
```

### 场景 3: 只想要 Neovim
```bash
cd ~/lazinit
./install.sh --only-nvim
# 或直接
cd ~/lazinit/neovim
./install.v2.sh
```

### 场景 4: 包已经安装，只想配置
```bash
cd ~/lazinit
./install.sh --skip-pkgs
```

### 场景 5: 更新 ZSH 配置
```bash
cd ~/lazinit/zsh
git pull
./utils/recompile.sh
```

### 场景 6: 重新安装 Neovim
```bash
cd ~/lazinit/neovim
./fix_neotree.sh  # 如有问题先修复
./install.v2.sh   # 重新安装
```

---

## 🛡️ 错误处理

### 包安装错误
```
━━━ 安装软件包 ━━━

安装包（逐个安装，容忍错误）...
  - git ... ✓
  - curl ... ✓
  - zsh ... ✓
  - nonexistent-package ... ✗
  - nvim ... ✓

安装统计:
  成功: 4
  失败: 1
⚠ 失败的包: nonexistent-package
⚠ 部分包安装失败，但继续运行...
```

**关键点**：
- ✅ 失败不中断
- ✅ 显示详细信息
- ✅ 继续后续步骤

### 模块失败处理
```bash
# 如果 ZSH 配置失败
./install.sh --only-zsh  # 单独重试

# 如果 Neovim 安装失败
cd neovim
./fix_neotree.sh  # 先修复
./install.v2.sh   # 重新安装
```

---

## 📊 安装流程图

### 完整安装
```
install.sh
  ↓
init_env.v2.sh
  ├─ 环境检测（OS, VM, Work）
  ├─ 包列表选择（完整/精简/macOS）
  ├─ 包安装（逐个，容错）
  │   ├─ git ✓
  │   ├─ curl ✓
  │   ├─ bad-pkg ✗ (跳过)
  │   └─ zsh ✓
  ├─ ZSH 配置
  │   ├─ 符号链接
  │   ├─ 编译配置
  │   └─ 工作环境（可选）
  └─ Neovim 安装（询问）
      └─ neovim/install.v2.sh
          ├─ 安装 Neovim 0.11.5
          ├─ 安装 LSP（9 languages）
          ├─ 预防性修复
          └─ 配置符号链接
```

### 只安装 ZSH
```
install.sh --only-zsh
  ↓
init_env.v2.sh --only-zsh
  ├─ 环境检测
  ├─ 包安装（包含 zsh 相关）
  └─ ZSH 配置
```

### 只安装 Neovim
```
install.sh --only-nvim
  ↓
neovim/install.v2.sh
  ├─ 安装 Neovim
  ├─ 安装 LSP
  ├─ 预防性修复
  └─ 配置
```

---

## 🔧 实际测试

### 测试包安装容错
```bash
# 在 init_apt_pks 中添加不存在的包
echo "nonexistent-package-xyz" >> init_apt_pks

# 运行安装
./install.sh

# 预期：
# ✗ nonexistent-package-xyz (跳过)
# 其他包正常安装
```

### 测试模块化安装
```bash
# 1. 只安装 ZSH
./install.sh --only-zsh

# 2. 检查结果
ls -la ~/.zshrc  # 应该有符号链接
zsh --version    # 应该安装成功

# 3. 后续安装 Neovim
cd neovim
./install.v2.sh
```

---

## 💡 最佳实践

### 1. 新机器推荐流程
```bash
# Step 1: 克隆
git clone <repo> ~/lazinit
cd ~/lazinit

# Step 2: 完整安装
./install.sh

# Step 3: 启动 ZSH
exec zsh

# Step 4: 启动 Neovim（如已安装）
nvim
```

### 2. 只想试用 ZSH
```bash
git clone <repo> ~/lazinit
cd ~/lazinit
./install.sh --only-zsh
exec zsh
```

### 3. 只想试用 Neovim
```bash
git clone <repo> ~/lazinit
cd ~/lazinit/neovim
./install.v2.sh
nvim
```

### 4. 已有配置，只想更新
```bash
cd ~/lazinit
git pull

# 只重新编译 ZSH
cd zsh/utils
./recompile.sh

# 或重新配置 Neovim
cd ~/lazinit/neovim
./fix_neotree.sh
```

---

## 📝 注意事项

### 包安装
- ✅ 逐个安装，失败不中断
- ✅ 显示详细统计
- ⚠️ 检查失败的包，手动处理（如需要）

### 符号链接
- ✅ 自动备份现有配置
- ✅ 创建相对路径符号链接
- ⚠️ 不要删除 ~/lazinit 目录

### 依赖关系
- ZSH 配置需要：git, zsh
- Neovim 需要：git, curl, wget, build-essential（编译 LSP）
- 如果跳过包安装，确保依赖已安装

---

*最后更新：2025-12-16*
