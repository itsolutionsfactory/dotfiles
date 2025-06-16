# Vim/Neovim Configuration

This module provides a modern Neovim configuration with the following features:

## Features

- Modern Neovim configuration using Lua
- Plugin management with [lazy.nvim](https://github.com/folke/lazy.nvim)
- Beautiful [Catppuccin](https://github.com/catppuccin/nvim) theme
- LSP support for better code intelligence
- Fuzzy finding with [Telescope](https://github.com/nvim-telescope/telescope.nvim)
- Enhanced syntax highlighting with [Treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- Git integration with [gitsigns](https://github.com/lewis6991/gitsigns.nvim)
- Status line with [lualine](https://github.com/nvim-lualine/lualine.nvim)
- File explorer with [nvim-tree](https://github.com/nvim-tree/nvim-tree.lua)

## Key Mappings

- `<leader>e` - Toggle file explorer
- `<leader>ff` - Find files
- `<leader>fg` - Live grep
- `<leader>fb` - List buffers

## Installation

This module is managed by GNU Stow. To install:

```bash
stow vim
```

## Requirements

- Neovim 0.8.0 or higher
- Git
- A Nerd Font for proper icon display

## First-time Setup

When you first open Neovim, it will automatically:
1. Install lazy.nvim
2. Download and install all configured plugins
3. Set up the configuration

This may take a few minutes depending on your internet connection. 