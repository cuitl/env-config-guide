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
