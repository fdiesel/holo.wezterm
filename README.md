# holo.wezterm

"Holo" — a restrained sci-fi HUD theme for [WezTerm](https://wezfurlong.org/wezterm/): one cyan hue, ice-blue text, translucent navy glass.

## Usage

```lua
local wezterm = require("wezterm")
local config = wezterm.config_builder()

wezterm.plugin.require("https://github.com/fdiesel/holo.wezterm").apply_to_config(config, {
	opacity = 0.5, -- 1.0 = solid (default 0.5)
	acrylic = true, -- Windows 11 blur behind the glass (default true, ignored elsewhere)
})

return config
```

Call `apply_to_config` before your own settings so they win. Your `config.keys` are kept; the plugin appends its key.

The palette is exposed as `require(...).palette` if you want to reuse the colours.

## Keys

| Key | Action |
|---|---|
| Ctrl+Shift+O | Toggle solid background (screen sharing, bright wallpapers) |

## Updating

WezTerm caches the plugin. To pull the latest version, run `wezterm.plugin.update_all()` in the debug overlay (Ctrl+Shift+L).
