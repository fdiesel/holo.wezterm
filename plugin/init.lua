---------------------------------------------------------------------------
-- "HOLO" — a restrained sci-fi HUD theme for WezTerm
--
-- Design rules (what makes film UIs look good *and* stay readable):
--  * One dominant hue (cyan/azure ~195°). Everything structural — borders,
--    cursor, active tab — is a shade of that hue, varied by brightness only.
--  * Body text is a pale ice-blue, NOT saturated cyan: saturated text is
--    tiring to read; saturated cyan is reserved for accents.
--  * Dark navy instead of black, translucent + blurred (Acrylic) for the
--    "glass panel" look. Blur keeps text readable over busy wallpapers.
--  * Warm colours are rare and meaningful: amber = attention, red = error.
--    The other ANSI colours are shifted cool but stay distinguishable, so
--    git diffs, errors and syntax highlighting still work.
--  * All text colours are >= 4.3:1 contrast even with a white window behind
--    the terminal at the default opacity (>= 6.5:1 on the plain bg).
---------------------------------------------------------------------------
local wezterm = require("wezterm")

local M = {}

M.palette = {
	bg = "#06111c", -- deep navy (window background)
	bar = "#0c2132", -- slightly lifted surface (tab bar, palette)
	surface = "#133550", -- inactive tab / raised element
	fg = "#c4e3f3", -- ice-blue body text
	dim = "#7ea6c2", -- secondary text (also ANSI bright black)
	accent = "#4cd4ff", -- the "hologram" cyan: cursor, active borders
	accent_dim = "#2b7299", -- inactive borders, scrollbar
	selection = "#1d5378",
	amber = "#ffbd5c",
	red = "#ff5f7e",
}

local function scheme(h)
	return {
		foreground = h.fg,
		background = h.bg,

		cursor_bg = h.accent,
		cursor_fg = h.bg,
		cursor_border = h.accent,

		selection_fg = "#eaf7ff",
		selection_bg = h.selection,

		scrollbar_thumb = h.accent_dim,
		split = h.accent_dim,
		compose_cursor = h.amber,
		visual_bell = "#0f3550",

		copy_mode_active_highlight_bg = { Color = h.accent },
		copy_mode_active_highlight_fg = { Color = h.bg },
		copy_mode_inactive_highlight_bg = { Color = h.selection },
		copy_mode_inactive_highlight_fg = { Color = "#eaf7ff" },
		quick_select_label_bg = { Color = h.amber },
		quick_select_label_fg = { Color = h.bg },
		quick_select_match_bg = { Color = h.selection },
		quick_select_match_fg = { Color = "#eaf7ff" },

		ansi = {
			"#1b3347", -- black
			h.red, -- red
			"#4fe0a8", -- green (aqua-ish)
			h.amber, -- yellow (HUD amber)
			"#4a9eff", -- blue
			"#b591ff", -- magenta (cool violet)
			"#3dcfee", -- cyan
			"#a8c7da", -- white
		},
		brights = {
			h.dim, -- bright black (PSReadLine params/operators — keep readable)
			"#ff8aa0", -- bright red
			"#86f0c6", -- bright green
			"#ffd690", -- bright yellow
			"#82bcff", -- bright blue
			"#d0b6ff", -- bright magenta
			"#86e8ff", -- bright cyan
			"#eaf7ff", -- bright white
		},

		-- HUD tab strip: no solid cyan block; the active tab is a lifted panel with
		-- cyan text, inactive tabs sink into the glass.
		tab_bar = {
			background = h.bg,
			active_tab = { bg_color = h.selection, fg_color = h.accent, intensity = "Bold" },
			inactive_tab = { bg_color = h.bg, fg_color = h.dim },
			inactive_tab_hover = { bg_color = h.bar, fg_color = h.fg },
			new_tab = { bg_color = h.bg, fg_color = h.accent_dim },
			new_tab_hover = { bg_color = h.bar, fg_color = h.accent },
		},
	}
end

-- Ctrl+Shift+O: toggle solid background (screen sharing, bright wallpapers)
wezterm.on("holo-toggle-opacity", function(window, _)
	local overrides = window:get_config_overrides() or {}
	if overrides.window_background_opacity == 1.0 then
		overrides.window_background_opacity = nil
		overrides.text_background_opacity = nil
	else
		overrides.window_background_opacity = 1.0
		overrides.text_background_opacity = 1.0
	end
	window:set_config_overrides(overrides)
end)

--- opts.opacity: 1.0 = solid, lower = more glass, less contrast (default 0.5)
--- opts.acrylic: Windows 11 blur behind the glass (default true, Windows only)
function M.apply_to_config(config, opts)
	opts = opts or {}
	local h = M.palette
	local opacity = opts.opacity or 0.5

	config.color_schemes = config.color_schemes or {}
	config.color_schemes["Holo"] = scheme(h)
	config.color_scheme = "Holo"

	-- Glass panel
	config.window_background_opacity = opacity
	-- Cells with an explicit background (zellij bars, lazygit highlights) get the
	-- same translucency, otherwise they show up as solid strips on the glass.
	config.text_background_opacity = opacity
	if opts.acrylic ~= false and wezterm.target_triple:find("windows") then
		config.win32_system_backdrop = "Acrylic"
	end

	config.keys = config.keys or {}
	-- lowercase key + SHIFT in mods; uppercase "O" with SHIFT never matched
	table.insert(config.keys, {
		key = "o",
		mods = "CTRL|SHIFT",
		action = wezterm.action.EmitEvent("holo-toggle-opacity"),
	})

	-- HUD details
	config.window_padding = { left = 10, right = 10, top = 8, bottom = 6 }

	-- Smoothly "breathing" cursor; easing is chosen so it spends little time fully dark
	config.default_cursor_style = "BlinkingBlock"
	config.cursor_blink_rate = 700
	config.cursor_blink_ease_in = "EaseOut" -- leave the dark point fast
	config.cursor_blink_ease_out = "EaseIn" -- stay bright, drop late
	config.animation_fps = 60

	-- Bell = brief cyan pulse
	config.visual_bell = {
		fade_in_function = "EaseIn",
		fade_in_duration_ms = 75,
		fade_out_function = "EaseOut",
		fade_out_duration_ms = 200,
	}

	-- Fade unfocused wezterm panes slightly
	config.inactive_pane_hsb = { saturation = 0.8, brightness = 0.75 }

	-- Retro tab bar: drawn in the terminal font as cells, so it matches the text
	-- (the fancy bar uses its own font and rounded tabs that look like browser tabs)
	config.use_fancy_tab_bar = false
	config.tab_max_width = 32

	-- Title bar (only used with integrated title bar buttons)
	config.window_frame = {
		active_titlebar_bg = h.bg,
		inactive_titlebar_bg = h.bg,
		active_titlebar_fg = h.accent,
		inactive_titlebar_fg = h.dim,
		active_titlebar_border_bottom = h.accent_dim,
		inactive_titlebar_border_bottom = h.bar,
		button_fg = h.dim,
		button_bg = h.bg,
		button_hover_fg = h.bg,
		button_hover_bg = h.accent,
	}

	-- Command palette (Ctrl+Shift+P) & char select
	config.command_palette_bg_color = h.bar
	config.command_palette_fg_color = h.fg
	config.char_select_bg_color = h.bar
	config.char_select_fg_color = h.fg
end

return M
