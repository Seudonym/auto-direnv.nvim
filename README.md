# auto-direnv.nvim
**auto-direnv.nvim** is a simple plugin to automatically manage your environment using [direnv](https://direnv.net/) without ever leaving Neovim.

## ⭐ Features

- Automatically detects .envrc files and applies the environment variables right inside Neovim.
- Uses [direnv](https://direnv.net/) directly, so respects you existing rules.
- Supports session managers. See [here](#session-support) for more details.

## ⚡️ Requirements

- Neovim `0.9.0` or higher
- [direnv](https://direnv.net/) executable installed and available in your system `$PATH`

## 📦 Installation

Install using your preferred plugin manager.

### vim.pack
```lua
vim.pack.add({
    "https://github.com/seudonym/auto-direnv.nvim"
})
```
Make sure to call `require('auto-direnv').setup()` somewhere.

## ⚙️ Configuration

Expand to see the list of options below

<details><summary>Default Options</summary>
```lua
--- @class AutoDirenvConfig
local default_config = {
    silent = false, -- set to true to disable notifications on trigger
}
```
</details>

## 💾 Sessions support

Since it relies on `VimEnter` and `DirChanged` events to update `vim.env`, it **should** work with session managers as well.
Though, only the following ones have been tested:
 - [auto-session](https://github.com/rmagatti/auto-session)

## Credits
- [NotAShelf/direnv.nvim](https://github.com/NotAShelf/direnv.nvim)
- [direnv/direnv.vim](https://github.com/direnv/direnv.vim)
