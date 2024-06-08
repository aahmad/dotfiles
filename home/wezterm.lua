-- Pull in the wezterm API
local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()
config:set_strict_mode(true)

-- This is where you actually apply your config choices

config.font = wezterm.font("FiraCode Nerd Font Mono", {weight=450, stretch="Normal", style="Normal"})
config.font_size = 16.0

config.scrollback_lines = 20000

config.tab_max_width = 24

config.color_scheme = 'Catppuccin Mocha (Gogh)'

local TITLEBAR_COLOR = '#333333'

config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'

config.window_frame = {
  font = wezterm.font("FiraCode Nerd Font Mono", {weight=450, stretch="Normal", style="Normal"}),
  font_size = 13.0,
  active_titlebar_bg = TITLEBAR_COLOR,
  inactive_titlebar_bg = TITLEBAR_COLOR,
}

function set_background(config, is_fullscreen)
  config.window_background_opacity = 1.0
  config.background = nil
end

wezterm.on('window-resized', function(window, pane)
  local overrides = window:get_config_overrides() or {}
  local is_fullscreen = window:get_dimensions().is_full_screen
  set_background(overrides, is_fullscreen)
  window:set_config_overrides(overrides)
end)

wezterm.on('update-status', function(window, pane)
  local cells = {}

  -- Figure out the hostname of the pane on a best-effort basis
  local hostname = wezterm.hostname()
  local cwd_uri = pane:get_current_working_dir()
  if cwd_uri and cwd_uri.host then
    hostname = cwd_uri.host
  end
  table.insert(cells, ' ' .. hostname)

  -- Format date/time in this style: "Wed Mar 3 08:14"
  local date = wezterm.strftime ' %a %b %-d %H:%M'
  table.insert(cells, date)

  -- Add an entry for each battery (typically 0 or 1)
  local batt_icons = {'', '', '', '', ''}
  for _, b in ipairs(wezterm.battery_info()) do
    local curr_batt_icon = batt_icons[math.ceil(b.state_of_charge * #batt_icons)]
    table.insert(cells, string.format('%s %.0f%%', curr_batt_icon, b.state_of_charge * 100))
  end

  -- Color palette for each cell
  local text_fg = '#c0c0c0'
  local colors = {
    TITLEBAR_COLOR,
    '#3c1361',
    '#52307c',
    '#663a82',
    '#7c5295',
    '#b491c8',
  }

  local elements = {}
  while #cells > 0 and #colors > 1 do
    local text = table.remove(cells, 1)
    local prev_color = table.remove(colors, 1)
    local curr_color = colors[1]

    table.insert(elements, { Background = { Color = prev_color } })
    table.insert(elements, { Foreground = { Color = curr_color } })
    table.insert(elements, { Text = '' })
    table.insert(elements, { Background = { Color = curr_color } })
    table.insert(elements, { Foreground = { Color = text_fg } })
    table.insert(elements, { Text = ' ' .. text .. ' ' })
  end
  window:set_right_status(wezterm.format(elements))
end)

config.keys = {
  { key = "LeftArrow", mods = "OPT", action=wezterm.action{SendString="\x1bb"} },
  { key = "RightArrow", mods = "OPT", action=wezterm.action{SendString="\x1bf"} },
  { key = 'LeftArrow', mods = 'CMD', action = act.ActivateTabRelative(-1), },
  { key = 'RightArrow', mods = 'CMD', action = act.ActivateTabRelative(1), },
}

-- and finally, return the configuration to wezterm
return config
