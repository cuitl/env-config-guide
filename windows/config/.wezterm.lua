-- wezterm config

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
