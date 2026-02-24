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

    # 查看 bucket
    scoop bucket list

    # bucket 不符合预期 - 删除 + 重新添加
    scoop bucket rm [bucket]
    scoop bucket add [bucket]

```

### 支持安装图形界面的常用软件:

scoop bucket add extras

### add font bucket

scoop bucket add nerd-fonts

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
此时可以查看控制台的下载链接，通过浏览器访问手动下载，然后查看 scoop的缓存目录（通常是 ~\scoop\cache）, 在缓存目录中可以看到以 `.download` 结尾的未下载完成文件。
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
local act = wezterm.action

-------------------------------------------------
-- 颜色定义
-------------------------------------------------
local colors = {
  bg = "#1a1b26",
  leader = "#7aa2f7",
  pane = "#9ece6a",
  tab = "#e0af68",
  search = "#46dbeb",
  window = "#bb9af7",
  text = "#c0caf5",
  muted = "#565f89",
}

-------------------------------------------------
-- 辅助函数：生成彩色标签块
-------------------------------------------------
local function badge(color, icon, text, text_color)
  return wezterm.format({
    { Background = { Color = color } },
    { Foreground = { Color = text_color or colors.bg } },
    { Text = " " .. icon .. " " .. text .. " " },
    { Background = { Color = "none" } },
    { Foreground = { Color = colors.text } },
    { Text = "  " },
  })
end

local function ui(title, body)
  return wezterm.format({
    {Foreground={Color=colors.leader}},
    {Text=""..title..""},
    {Foreground={Color=colors.text}},
    {Text=" "..body.."  "},
  })
end

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

-- 将窗口控制按钮（最小化、最大化、关闭）集成到标签栏（Tab bar）中，而不是显示独立的标题栏
-- see: https://wezterm.org/config/lua/config/window_decorations.html
config.window_decorations = "INTEGRATED_BUTTONS | RESIZE"

-- 将边距设为 0（或者很小的值，如 2）
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

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

config.enable_tab_bar = true -- 展示 tab_bar(默认true)
config.use_fancy_tab_bar = false -- 关闭 mac 风格 UI，使用纯文本样式
config.show_tabs_in_tab_bar = false -- 隐藏tab
config.show_new_tab_button_in_tab_bar = false -- 隐藏新增tab按钮
-- config.tab_bar_at_bottom = true -- tab_bar 在底部显示

config.colors = {
  tab_bar = {
    -- tab_bar 透明
    background = "rgba(0,0,0,0.0)",
  },
}

-- 键位相关 start

-- NvChad 有些快捷键会用到 Alt，在 WezTerm 中需要确保它能透传
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = true

-- 由于 Windows 习惯 Ctrl-C/V，但终端里它们有特殊含义。WezTerm 支持智能映射：
-- table.insert(config.keys, { key = 'V', mods = 'CTRL', action = wezterm.action.PasteFrom 'Clipboard' })
-- table.insert(config.keys, { key = 'C', mods = 'CTRL', action = wezterm.action.CopyTo 'Clipboard' })


-------------------------------------------------
-- 状态提示系统
-------------------------------------------------
wezterm.on("update-right-status", function(window)
  local table = window:active_key_table()

  if table == "leader" then
    window:set_left_status(
      badge(colors.leader, "󰘳", "LEADER")
      .. badge(colors.pane, "", "P  Pane")
      .. badge(colors.tab, "󰓩", "T  Tab")
      .. badge(colors.search, "󰍉", "S  Search")
      .. badge(colors.window, "󰖲", "W  Window")
      .. ui("󰊓", "z Zoom")
    )

  elseif table == "pane" then
    window:set_left_status(
      badge(colors.pane, "", "PANE")
      -- .. badge(colors.pane, "", "[v] split-h | [s] split-v | [x] close | [h/j/k/l] move | [H/L] resize | [z] zoom", '#0633a7')
      .. ui("[v]", "split-h")
      .. ui("[s]", "split-v")
      .. ui("[x]", "close")
      .. ui("[h/j/k/l]", "move")
      .. ui("[H/L]", "resize")
      .. ui("[z]", "zoom")
    )

  elseif table == "tab" then
    window:set_left_status(
      badge(colors.tab, "󰓩", "TAB")
      -- .. badge(colors.tab, "", "[t] new | [n] next | [p] prev | [1-5] jump")
      .. ui("[t]", "new")
      .. ui("[n]", "next")
      .. ui("[p]", "prev")
      .. ui("[1-5]", "jump")
    )

  elseif table == "search" then
    window:set_left_status(
      badge(colors.search, "󰍉", "SEARCH")
      .. badge(colors.search, "", "[f] search mode")
    )


  elseif table == "workspace" then
    window:set_left_status(
      badge(colors.window, "󰖲", "WORKSPACE")
      -- .. badge(colors.window, "", "[w] launcher | [r] reload | [q] quit")
      .. ui("[w]", "launcher")
      .. ui("[r]", "reload")
      .. ui("[q]", "quit")
    )

  else
    window:set_left_status("")
  end
end)

-------------------------------------------------
-- Leader 入口
-------------------------------------------------

-- 设置 Leader
-- config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }

-- 不使用默认leader, 以保证 ctrl + a 时可以触发提示信息(底部状态栏)
config.keys = {
  {
    key = 'a',
    mods = 'CTRL',
    action = act.ActivateKeyTable {
      name = 'leader',
      timeout_milliseconds = 3000,
      one_shot = false,
    },
  },
}

-------------------------------------------------
-- 分层 key tables
-------------------------------------------------
config.key_tables = {

  -------------------------------------------------
  -- 一级分组
  -------------------------------------------------
  leader = {
    { key = 'p', action = act.ActivateKeyTable { name = 'pane', timeout_milliseconds = 3000 } },
    { key = 't', action = act.ActivateKeyTable { name = 'tab', timeout_milliseconds = 3000 } },
    { key = 's', action = act.ActivateKeyTable { name = 'search', timeout_milliseconds = 3000 } },
    { key = 'w', action = act.ActivateKeyTable { name = 'workspace', timeout_milliseconds = 3000 } },
    { key = 'z', action = act.TogglePaneZoomState },
    { key = 'Escape', action = 'PopKeyTable' },
  },

  -------------------------------------------------
  -- Pane 组
  -------------------------------------------------
  pane = {
    -- 分屏
    { key = 'v', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
    { key = 's', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
    { key = 'x', action = act.CloseCurrentPane { confirm = true } },

    -- 移动
    { key = 'h', action = act.ActivatePaneDirection 'Left' },
    { key = 'j', action = act.ActivatePaneDirection 'Down' },
    { key = 'k', action = act.ActivatePaneDirection 'Up' },
    { key = 'l', action = act.ActivatePaneDirection 'Right' },

    -- Resize
    { key = 'H', action = act.AdjustPaneSize { 'Left', 5 } },
    { key = 'L', action = act.AdjustPaneSize { 'Right', 5 } },

    -- Zoom
    { key = 'z', action = act.TogglePaneZoomState },

    { key = 'Escape', action = 'PopKeyTable' },
  },

  -------------------------------------------------
  -- Tab 组
  -------------------------------------------------
  tab = {
    { key = 't', action = act.SpawnTab 'DefaultDomain' },
    { key = 'n', action = act.ActivateTabRelative(1) },
    { key = 'p', action = act.ActivateTabRelative(-1) },

    { key = '1', action = act.ActivateTab(0) },
    { key = '2', action = act.ActivateTab(1) },
    { key = '3', action = act.ActivateTab(2) },
    { key = '4', action = act.ActivateTab(3) },
    { key = '5', action = act.ActivateTab(4) },

    { key = 'Escape', action = 'PopKeyTable' },
  },

  -------------------------------------------------
  -- Search 组
  -------------------------------------------------
  search = {
    { key = 'f', action = act.Search 'CurrentSelectionOrEmptyString' },
    { key = 'Escape', action = 'PopKeyTable' },
  },

  -------------------------------------------------
  -- Workspace / Launcher 组
  -------------------------------------------------
  workspace = {
    {
      key = 'w',
      action = act.ShowLauncherArgs {
        flags = 'TABS | WORKSPACES'
      },
    },
    { key = 'r', action = act.ReloadConfiguration },
    { key = 'q', action = act.CloseCurrentPane { confirm = true } },
    { key = 'Escape', action = 'PopKeyTable' },
  },
}


-- 键位相关 end

return config


```
