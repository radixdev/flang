data.raw["gui-style"].default.big_box_style = {
  type = "textbox_style",
  minimal_height = 40,
  minimal_width = 40,
  maximal_height = 1000,
  maximal_width = 1000
}

local WIDTH = 800

-- All other widths reference this value
local EDITOR_WIDTH = WIDTH
local EDITOR_HEIGHT = 500
data.raw["gui-style"].default.flang_editor_window_style = {
  type = "textbox_style",
  minimal_height = EDITOR_HEIGHT,
  minimal_width = EDITOR_WIDTH,
  maximal_height = EDITOR_HEIGHT,
  maximal_width = EDITOR_WIDTH,
  want_ellipsis = false
}

local INFO_WINDOW_WIDTH = WIDTH
local INFO_WINDOW_HEIGHT = 200
data.raw["gui-style"].default.flang_info_window_style = {
  type = "textbox_style",
  minimal_height = INFO_WINDOW_HEIGHT,
  minimal_width = INFO_WINDOW_WIDTH,
  maximal_height = INFO_WINDOW_HEIGHT,
  maximal_width = INFO_WINDOW_WIDTH,
  want_ellipsis = false,
  single_line = false,
}

local MENU_WINDOW_WIDTH = WIDTH
local MENU_WINDOW_HEIGHT = 200
data.raw["gui-style"].default.flang_menu_window_style = {
  type = "textbox_style",
  minimal_height = MENU_WINDOW_HEIGHT,
  minimal_width = MENU_WINDOW_WIDTH,
  maximal_height = MENU_WINDOW_HEIGHT,
  maximal_width = MENU_WINDOW_WIDTH,
  want_ellipsis = false,
}
