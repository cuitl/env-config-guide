  # $HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
  
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
