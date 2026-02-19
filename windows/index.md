# Window 开发环境配置指引

## scoop 包管理器

[scoop](https://scoop.sh/) 是 windows下的包管理器，它可以在安装相关软件时，自动配置环境变量.

### powershell中执行，安装命令:

```bash

    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

```

### scoop 更换镜像:

```bash

    # from https://gitee.com/scoop-installer/scoop
    # 更换scoop的repo地址
    scoop config SCOOP_REPO "https://gitee.com/scoop-installer/scoop"

    # 拉取新库地址
    scoop update

```

### 支持安装图形界面的常用软件:

scoop bucket add extras

### 代理配置

> scoop可以配置代理，用来进行安装提速, 如：

scoop config proxy 127.0.0.1:7890 (clash)

### scoop 常用安装包:

- scoop install aria2 - 多连接下载支持
- scoop install sudo - 使用管理员权限
- scoop install 7zip - 压缩包安装的基础依赖
- scoop install git — 版本控制及许多包安装的前提 
- scoop install touch - 类似于mac、linux 创建文件的命令
- scoop install python - 部分包依赖python



### scoop 安装 node

scoop 不要直接安装node, 不然不利于多版本控制，可以按照以下流程安装：

1. scoop install nvm
2. nvm install --lts


### scoop 安装 hack

有时scoop下载文件会非常慢，并导致安装失败。
此时可以查看控制台的下载链接，通过浏览器访问手动下载，然后查看 scoop的缓存目录（通常是 C:\Users\space\scoop\cache）, 在缓存目录中可以看到以 `.download` 结尾的未下载完成文件。
此时我们把手动下载的文件复制到缓存目录，并将文件修改成`.download`文件的hash前的内容，下次安装，即可通过缓存直接安装。

如：未下载完成的文件 `zoxide#0.9.9#9099afa.zip.download`,
此时手动下载的文件改名到：`zoxide#0.9.9#9099afa` 即可

## powershell 7

> 通常 windows 自带的 powershell 版本比较低，需要手动安装最新版本.

我们可以根据 winget 来安装最新的powershell, winget 一般是windows 系统自带的工具.

### 安装步骤

1. 执行命令获取版本： `winget search --id Microsoft.PowerShell`
    > 一般会获取到如下信息
    ```
      Name               Id                           Version Source
      ---------------------------------------------------------------
      PowerShell         Microsoft.PowerShell         7.5.4.0 winget
      PowerShell Preview Microsoft.PowerShell.Preview 7.6.0.6 winget
    ```

2. 指定Id 进行安装：`winget install --id Microsoft.PowerShell --source winget`

当然也可以直接通过安装包进行安装，[详情](https://learn.microsoft.com/zh-cn/powershell/scripting/install/install-powershell-on-windows?view=powershell-7.5)

### powershell 基础配置及美化

powershell 默认的外观比较单调，我们可以通过 [on-my-posh](https://ohmypo.sh/docs/installation/windows) 进行美化，
通过 [posh-git](https://github.com/dahlbyk/posh-git?tab=readme-ov-file#installing-posh-git-via-powershellget-on-linux-macos-and-windows) 进行提示补全，
通过 [eza](https://github.com/eza-community/eza/blob/main/INSTALL.md#scoop-windows) 进行 `ls` 输出美化
通过 [zoxide](https://github.com/ajeetdsouza/zoxide) 增强 cd 命令

scoop安装相关依赖：

- posh-git: `Install-Module posh-git -Scope CurrentUser -Force`
- eza: `scoop install eza`
- zoxide: `scoop install zoxide`
- fzf: `scoop install fzf`
    - for powershell: `Install-Module -Name PSFzf -Scope CurrentUser -Force`


相关依赖安装完成后，我们可以通过 `nvim $PROFILE` | `code $PROFILE` 编辑powershell配置文件，如：

```bash
  # on-my-posh 初始化 + config 主题设置
  oh-my-posh init pwsh --config 'paradox' | Invoke-Expression

  # 设置 PowerShell 默认启动目录
  # Set-Location C:\D\my-github

  # Setup other alias


  # 资源管理器中打开当前目录, 保持与mac的一致, open .
  Set-Alias open Invoke-Item

  # 设置回到上一层的别名
  Set-Alias .. Set-Location

  # function l { Get-ChildItem }
  # function ll { Get-ChildItem -Force | Format-Table -AutoSize }
  # function la { Get-ChildItem -Force -Hidden }

  # -------------------------
  # eza ls 美化 - configuration
  # -------------------------

  # eza 默认行为
  $env:EZA_CONFIG_DIR = "$HOME\.config\eza"

  # function l   { eza --icons --group-directories-first }
  function l   { eza -A --icons --group-directories-first }
  function ll  { eza -la --icons --git --group-directories-first --header --binary }
  function la  { eza -a --icons --group-directories-first }

  # 树结构
  function lt  { eza --tree --level=2 --icons }
  function lta { eza --tree --level=2 -a --icons }

  # 只看目录
  function lsd { eza -l --icons --only-dirs --group-directories-first }
  # 目录大小统计
  function lsize { eza -l --icons --git --total-size }

  # git pretty log: glog
  function glog {
      git log --graph --oneline --decorate --all
  }

  # 更好的 cd - zoxide (延迟加载)
  $null = Register-EngineEvent -SourceIdentifier 'PowerShell.OnIdle' -MaxTriggerCount 1 -Action {
      Invoke-Expression (& { (zoxide init powershell | Out-String) })
  }

  # PSFzf 结合 fzf 快速查找 文件和命令
  # Ctrl + R 模糊历史搜索 | Ctrl + T 文件模糊选择 | Alt + C 目录跳转
  Register-EngineEvent PowerShell.OnIdle -Action {
    if (-not (Get-Module PSFzf)) {
      Import-Module PSFzf
      # 核心配置：显式绑定快捷键
      # -PSReadlineChordReverseHistory 'Ctrl+r' 启用交互式历史搜索
      # -PSReadlineChordProvider 'Ctrl+t' 启用快速查找文件路径
      # Set-PsFzfOption -PSReadlineChordReverseHistory 'Ctrl+r' -PSReadlineChordProvider 'Ctrl+t'
      Set-PsFzfOption -PSReadlineChordReverseHistory 'Ctrl+r'
    }
  } | Out-Null

  # # 延时 启用 posh-git
  # Register-EngineEvent PowerShell.OnIdle -Action {
  #   Import-Module posh-git
  # } | Out-Null

  # 延迟加载 posh-git (使用 git 命令时 才会启用)
  function git {
      if (-not (Get-Module posh-git)) {
          Import-Module posh-git
      }

      & git.exe @args
  }

  # clash 代理配置
  $env:http_proxy  = "http://127.0.0.1:7890"
  $env:https_proxy = "http://127.0.0.1:7890"
  $env:ALL_PROXY   = "socks5://127.0.0.1:7891"
```

## Git Bash 配置

当安装 git 时后，可以针对 Git Bash 做类似于 powershell 一样的美化配置。

相关依赖安装，同 powershell

- .bash_profile
  ```bash
    # 加载 .bashrc（标准做法）
    if [ -f ~/.bashrc ]; then
      . ~/.bashrc
    fi
  ```

- .bashrc
  ```bash
    # ~/.bashrc

    # # 默认启动目录是 $HOME 时，转向工作目录
    # if [ "$PWD" = "$HOME" ]; then
    #     cd /c/D/my-github
    # fi

    # UTF-8 support - 正常显示中文
    export LANG=en_US.UTF-8
    export LC_ALL=en_US.UTF-8

    # 让 Git Bash 使用 Windows 默认编辑器
    # 程序调用默认编辑器时，如：git 提交没加信息，git 会调用 nvim 打开内容，让你添加信息，默认可能是是 vi 或 系统默认编辑器
    export EDITOR="nvim"
    export VISUAL="nvim"

    # 打开文件夹（资源管理器）
    alias open='explorer.exe'

    # 快速 cd 函数
    alias ..='cd ..'
    alias ...='cd ../..'
    alias ....='cd ../../..'

    # 复制到剪贴板 cat file.txt | clip
    alias clip='clip.exe'

    # 更好的 ls 体验
    alias ls='ls -A --color=auto'

    # # alias l='ls -CF'
    # alias l='ls -A'
    # alias ll='ls -alF'
    # alias la='ls -A'

    alias l='eza -A --icons --group-directories-first'
    alias ll='eza -la --icons --group-directories-first --git'
    alias la='eza -A --icons --group-directories-first'

    # 树结构
    alias lt='eza --tree --level=2 --icons'
    alias lta='eza --tree --level=2 -a --icons'

    # 只看目录
    alias lsd='eza -l --icons --only-dirs --group-directories-first'
    # 目录大小统计
    alias lsize='eza -l --icons --git --total-size'

    # git 相关
    alias glog='git log --graph --oneline --decorate --all'
    # alias gs='git status'
    # alias ga='git add'
    # alias gc='git commit'
    # alias gcm='git commit -m'
    # alias gp='git push'
    # alias gl='git pull'
    # alias gd='git diff'
    # alias gb='git branch'
    # alias gco='git checkout'
    # alias gcb='git checkout -b'

    # 增大历史容量
    HISTSIZE=10000
    HISTFILESIZE=20000

    # 忽略重复命令
    HISTCONTROL=ignoredups:erasedups

    # 禁用路径转换（减少奇怪问题）
    export MSYS_NO_PATHCONV=1

    # fzf 搜索增强
    # Ctrl + R 模糊历史搜索 | Ctrl + T 文件模糊选择 | Alt + C 目录跳转
    [ -f ~/.fzf.bash ] && source ~/.fzf.bash

    # # 多窗口共享历史 (非多窗口会导致初始化变慢 暂不建议开启)
    # shopt -s histappend
    # PROMPT_COMMAND="history -a; history -n; $PROMPT_COMMAND"

    # oh-my-posh 终端美化
    eval "$(oh-my-posh init bash --config 'paradox')"
    # cd 增强，z folder, https://github.com/ajeetdsouza/zoxide
    eval "$(zoxide init bash)"
  ```

## windows terminal

windows terminal 是一个现代话的终端，可以集成cmd, powershell 等多个shell, [详情](https://learn.microsoft.com/zh-cn/windows/terminal/install)

基础配置如下(重点关注 profiles )：

```json
{
  // ...
  "profiles": {
    "defaults": {
      // 终端默认主题
      "colorScheme": "Campbell",
      // cursor 颜色、形状
      "cursorColor": "#528BFF",
      "cursorShape": "filledBox",

      "font": {
        "face": "MesloLGM Nerd Font"
      },
      // 终端背景图相关
      "backgroundImage": "C://Users//space//Pictures//background//12.jpg",
      "backgroundImageOpacity": 0.3,
      "backgroundImageStretchMode": "uniformToFill",
      "backgroundImageAlignment": "center",
      // 进阶：如果你想要背景图随窗口缩放但固定不动
      "extraOptions": {
        "backgroundImageFixed": true
      }
    },
    "list": [
      {
        "commandline": "%SystemRoot%\\System32\\WindowsPowerShell\\v1.0\\powershell.exe",
        "guid": "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}",
        "hidden": false,
        "name": "Windows PowerShell"
      },
      {
        "commandline": "%SystemRoot%\\System32\\cmd.exe",
        "guid": "{0caa0dad-35be-5f56-a8ff-afceeeaa6101}",
        "hidden": false,
        "name": "\u547d\u4ee4\u63d0\u793a\u7b26"
      },
      {
        "guid": "{b453ae62-4e3d-5e58-b989-0a998ec441b8}",
        "hidden": false,
        "name": "Azure Cloud Shell",
        "source": "Windows.Terminal.Azure"
      },
      {
        "guid": "{574e775e-4f2a-5b96-ac1e-a2962a402336}",
        "hidden": false,
        "name": "PowerShell",
        "source": "Windows.Terminal.PowershellCore"
      },
      {
        // windows terminal 中集成 Git Bash
        "commandline": "C:\\Users\\space\\scoop\\apps\\git\\current\\bin\\bash.exe",
        "guid": "{86a0331a-5795-4cb9-a83e-d1174ace797d}",
        "hidden": false,
        "icon": "C:\\Users\\space\\scoop\\apps\\git\\current\\mingw64\\share\\git\\git-for-windows.ico",
        "name": "Git Bash",
        // git bash 启动初始目录
        "startingDirectory": "C:\\Users\\space"
      }
    ]
  },
  // ...
}
```

## 其它终端

> 除了 windows terminal 之外，还可以下载使用其它终端.

windows 常见终端：

- [kitty](https://sw.kovidgoyal.net/kitty/quickstart/)
- [ghostty](https://ghostty.org/docs)
- [warp](https://www.warp.dev/)
- [wezterm](https://wezterm.org/)

webterm 配置(.wezterm):

```lua

local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- 基础视觉配置
-- config.color_scheme = 'Catppuccin Mocha' -- 经典的暗色主题
-- config.color_scheme = 'AlienBlood' -- 经典的暗色主题
-- config.color_scheme = 'Dark Ocean (terminal.sexy)'
-- config.color_scheme = 'Dark Violet (base16)'
-- config.color_scheme = 'Dark+'
-- config.color_scheme = 'Darkside'
-- config.color_scheme = 'deep'
-- config.color_scheme = 'Dotshare (terminal.sexy)'
config.color_scheme = 'Dracula (Gogh)'

config.font = wezterm.font 'MesloLGM Nerd Font' -- 确保和你 NvChad 字体一致
-- config.font_size = 12.0
config.font_size = 11.0

-- 重点：开启图像支持
config.enable_wayland = false -- Windows 下保持 false

-- 性能与渲染
config.animation_fps = 60
config.max_fps = 120

-- 背景透明度 (配合 NvChad 效果更佳)
config.window_background_opacity = 0.95
-- 开启 Windows 的亚克力效果（可选）
config.win32_system_backdrop = 'Acrylic'

-- 将边距设为 0（或者很小的值，如 2）
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}
-- 让窗口在缩放时自动微调字符间距以填满边缘
-- config.integral_scaling_ignore_gui_visibility = true

config.background = {
  {
    source = {
      -- 替换为你图片的绝对路径（注意 Windows 路径用正斜杠 /）
      File = 'C:/Users/space/Pictures/background/35.jpg',
    },
    -- 图片亮度调节（0.1 很暗，适合写代码不分心）
    hsb = { brightness = 0.8 },
    -- 填充模式
    repeat_x = 'NoRepeat',
    vertical_align = 'Middle',
    horizontal_align = 'Center',
    attachment = 'Fixed', -- 背景不随滚动条移动
  },

  -- 可以在图片上叠加一层半透明纯色，增加文字清晰度
  {
    source = { Color = '#1a1b26' },
    width = '100%',
    height = '100%',
    -- opacity = 0.85, -- 调整这个值看背景的深浅
    opacity = 0.15,
  },
}

config.front_end = "WebGpu" -- 使用更现代的渲染引擎

config.default_prog = { 'pwsh.exe', '-NoLogo' }

config.enable_tab_bar = false
config.show_tabs_in_tab_bar = false
config.show_new_tab_button_in_tab_bar = false

-- 键位相关 start

-- NvChad 有些快捷键会用到 Alt，在 WezTerm 中需要确保它能透传
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = true

-- 由于 Windows 习惯 Ctrl-C/V，但终端里它们有特殊含义。WezTerm 支持智能映射：
-- table.insert(config.keys, { key = 'V', mods = 'CTRL', action = wezterm.action.PasteFrom 'Clipboard' })
-- table.insert(config.keys, { key = 'C', mods = 'CTRL', action = wezterm.action.CopyTo 'Clipboard' })


-- 设置 Leader 键为 Ctrl-a (比默认的 Ctrl-b 更顺手)
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }

config.keys = {
  -- 1. 分屏操作 (模仿 tmux)
  { key = 'v', mods = 'LEADER', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 's', mods = 'LEADER', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
  -- 分屏关闭 -  增加确认弹窗，防止误删正在运行的 Nvim 
  { key = 'x', mods = 'LEADER', action = wezterm.action.CloseCurrentPane { confirm = true }, },
  -- 2. 切换分屏 (模仿 Nvim)
  { key = 'h', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Left' },
  { key = 'j', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Down' },
  { key = 'k', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Up' },
  { key = 'l', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Right' },
  -- 4. 调整分屏大小 (按住 Leader 后狂按 H/J/K/L)
  { key = 'H', mods = 'LEADER', action = wezterm.action.AdjustPaneSize { 'Left', 5 } },
  { key = 'L', mods = 'LEADER', action = wezterm.action.AdjustPaneSize { 'Right', 5 } },
  -- 4. 搜索模式 (进入类似 Nvim 的缓存搜索)
  { key = 'f', mods = 'LEADER', action = wezterm.action.Search 'CurrentSelectionOrEmptyString' },
  -- 5. 快速缩放当前分屏 (全屏/恢复)
  { key = 'z', mods = 'LEADER', action = wezterm.action.TogglePaneZoomState },

  -- 创建新标签页 (Tab)
  { key = 't', mods = 'LEADER', action = wezterm.action.SpawnTab 'DefaultDomain' },
  -- 切换标签页 (Tab)
  { key = 'n', mods = 'LEADER', action = wezterm.action.ActivateTabRelative(1) },  -- 下一个
  { key = 'p', mods = 'LEADER', action = wezterm.action.ActivateTabRelative(-1) }, -- 上一个

  -- 直接跳转到指定标签页 (1-9)
  { key = '1', mods = 'LEADER', action = wezterm.action.ActivateTab(0) },
  { key = '2', mods = 'LEADER', action = wezterm.action.ActivateTab(1) },
  { key = '3', mods = 'LEADER', action = wezterm.action.ActivateTab(2) },
  { key = '4', mods = 'LEADER', action = wezterm.action.ActivateTab(3) },
  { key = '5', mods = 'LEADER', action = wezterm.action.ActivateTab(4) },

  -- 映射 Ctrl-a + w 弹出所有 Tab 和 Pane 的预览列表
  { key = 'w', mods = 'LEADER', action = wezterm.action.ShowLauncherArgs { flags = 'TABS | WORKSPACES' }, },
}

-- 键位相关 end

return config


```
