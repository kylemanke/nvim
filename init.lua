-- Setup Lazy.vim
require("config.lazy")

-- Setup Telescope
require("config.telescope")

-- Setup colorscheme
vim.cmd.colorscheme "catppuccin"

-- Setup tabs 
vim.o.tabstop = 4 -- A TAB character looks like 4 spaces
vim.o.expandtab = true -- Pressing the TAB key will insert spaces instead of a TAB character
vim.o.softtabstop = 4 -- Number of spaces inserted instead of a TAB character
vim.o.shiftwidth = 4 -- Number of spaces inserted when indenting

-- Set up visuals 
vim.o.number = true
