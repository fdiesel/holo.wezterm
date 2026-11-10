# holo.wezterm

**Holo** is a restrained sci-fi HUD theme for [WezTerm](https://wezfurlong.org/wezterm/), packaged as a WezTerm plugin.

<img width="520" height="339" alt="HoloDefault" src="https://github.com/user-attachments/assets/e1969754-643b-453f-b3fd-073f9acec38f" />

<img width="520" height="339" alt="HoloSolid" src="https://github.com/user-attachments/assets/5620386c-b6c3-46be-b05a-619914536bc8" />

- One dominant hue: everything structural (borders, cursor, active tab) is a shade of cyan.
- Pale ice-blue body text. Saturated cyan is kept for accents.
- Translucent navy "glass" background, with Acrylic blur on Windows 11.
- Warm colours only where they mean something: amber for attention, red for errors.
- Text stays at ≥ 4.3:1 contrast even over a white window at the default opacity.
- A tab bar in the terminal font, plus a breathing cursor and a cyan bell pulse.

## Setup

WezTerm 20230320 or newer is required, since that release added plugin support.

Add this to your `wezterm.lua` (usually `~/.wezterm.lua` or `~/.config/wezterm/wezterm.lua`):

```lua
local wezterm = require("wezterm")
local config = wezterm.config_builder()

wezterm.plugin.require("https://github.com/fdiesel/holo.wezterm").apply_to_config(config)

-- your own settings go below, so they win over the theme
config.font_size = 11

return config
```

On first start WezTerm clones this repository into its plugin cache. You don't need to install anything else.

### Options

```lua
wezterm.plugin.require("https://github.com/fdiesel/holo.wezterm").apply_to_config(config, {
	opacity = 0.5, -- 1.0 = solid, lower = more glass and less contrast (default 0.5)
	acrylic = true, -- Windows 11 blur behind the glass (default true, ignored on other OSes)
})
```

### Overriding

The theme sets plain `config` fields, so any setting you assign after `apply_to_config` takes precedence. Your existing `config.keys` are kept, and the plugin appends its own binding.

The palette is available if you want to reuse the colours elsewhere in your config:

```lua
local holo = wezterm.plugin.require("https://github.com/fdiesel/holo.wezterm")
holo.apply_to_config(config)
config.colors = { split = holo.palette.accent }
```

## Keys

| Key | Action |
|---|---|
| Ctrl+Shift+O | Toggle a solid background, for screen sharing or bright wallpapers |

## Updating

WezTerm does **not** pull plugin updates on its own. It keeps the copy it cloned first.

1. Open the debug overlay with Ctrl+Shift+L.
2. Run `wezterm.plugin.update_all()`.
3. Reload the config with Ctrl+Shift+R, or restart WezTerm.

If an update fails, delete the cached clone and restart. WezTerm will clone the repository again:

| OS | Plugin cache |
|---|---|
| Windows | `%APPDATA%\wezterm\plugins\` |
| Linux / macOS | `~/.local/share/wezterm/plugins/` |

The folder name is the URL with its special characters encoded, for example `httpssCssZssZsgithubsDscomsZsfdieselsZsholosDswezterm`. To get the exact path, run `wezterm.plugin.list()` in the debug overlay.

Version pinning isn't built in. Each machine stays on whatever it cloned until you run `update_all()`. For a fixed version, fork the repository.

## Developing

Point WezTerm at a local clone using a `file://` URL:

```lua
wezterm.plugin.require("file:///C:/path/to/holo.wezterm").apply_to_config(config)
```

- WezTerm clones the **last commit**, so commit a change before you test it, then run `update_all()`.
- To preview without touching your main config, save that snippet as a separate config file and start a separate WezTerm process with it. Otherwise the window may open in your already-running WezTerm, which uses your normal config:

  ```sh
  wezterm --config-file test.lua start --always-new-process
  ```
- Run `wezterm --config-file test.lua show-keys` to check for Lua errors without opening a window.

The theme lives entirely in `plugin/init.lua`.
