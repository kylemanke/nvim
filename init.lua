-- Setup tabs 
vim.o.tabstop = 4 -- A TAB character looks like 4 spaces
vim.o.expandtab = true -- Pressing the TAB key will insert spaces instead of a TAB character
vim.o.softtabstop = 4 -- Number of spaces inserted instead of a TAB character
vim.o.shiftwidth = 4 -- Number of spaces inserted when indenting
vim.o.mouse = ''
vim.wo.wrap = false

-- Set up visuals 
vim.o.number = true

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- import your plugins
    {
        {
            'nvim-telescope/telescope.nvim', tag = '0.1.8',
            dependencies = {
                'nvim-lua/plenary.nvim',
                'BurntSushi/ripgrep',
            'sharkdp/fd'
            }
        }, {
            'nvim-telescope/telescope-fzf-native.nvim', build = 'make'
        },
        'tpope/vim-surround',
        'm4xshen/autoclose.nvim',
        { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
        'folke/tokyonight.nvim',
        'rebelot/kanagawa.nvim',
        {
            'nvim-treesitter/nvim-treesitter',
            build = ":TSUpdate",
            config = function()
                local configs = require("nvim-treesitter.configs")
                require('nvim-treesitter.install').compiler = { 'g++' }
                configs.setup({
                    ensure_installed = { "lua", "vimdoc" },
                    sync_installed = false,
                    highlight = { enable = false },
                    indent = { enable = false },
                })
            end
        },
        'williamboman/mason.nvim',
        'neovim/nvim-lspconfig',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-cmdline',
        'hrsh7th/nvim-cmp',
        'williamboman/mason-lspconfig.nvim',
        {
            'L3MON4D3/LuaSnip',
            --tag = 'v2.*',
        },
        'saadparwaiz1/cmp_luasnip',
    },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})

-- Setup Telescope
-- You dont need to set any of these options. These are the default ones. Only
-- the loading is important
require('telescope').setup {
  extensions = {
    fzf = {
      fuzzy = true,                    -- false will only do exact matching
      override_generic_sorter = true,  -- override the generic sorter
      override_file_sorter = true,     -- override the file sorter
      case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                       -- the default case_mode is "smart_case"
    }
  },
  pickers = {
    colorscheme = {
      enable_preview = true
    }
  }
}
-- To get fzf loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
require('telescope').load_extension('fzf')

-- Setup key mappings 
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fw', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
vim.keymap.set('n', '<leader>fc', builtin.colorscheme, { desc = 'Telescope colorschemes' })
vim.keymap.set('n', '<leader>ft', builtin.tags, { desc = 'Telescope ctags' })
vim.keymap.set('n', '<leader>fm', builtin.marks, { desc = 'Telescope marks' })
vim.keymap.set('n', '<leader>fo', builtin.vim_options, { desc = 'Telescope vim options' })
vim.keymap.set('n', '<leader>fj', builtin.jumplist, { desc = 'Telescope vim jumplist' })

-- Setup lsps 
require('mason').setup()
require('mason-lspconfig').setup {
    ensure_installed = { 'lua_ls' },
}

-- Setup cmp
local cmp = require('cmp')
cmp.setup({
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-u>'] = cmp.mapping.scroll_docs(-4),
        ['<C-d>'] = cmp.mapping.scroll_docs(4),
        ['<C-p>'] = cmp.mapping.select_prev_item(select_opts),
        ['<C-n>'] = cmp.mapping.select_next_item(select_opts),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<Tab>'] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'path' },
    }, {
        { name = 'buffer'}
    })
})

cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'buffer' }
    }
})

cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
        { name = 'cmdline' }
    }),
    matching = { disallow_symbol_nonprefix_matching = false }
})

-- Setup lsp servers
-- Get default capabilities for cmp 
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Setup lua_ls 
require ('lspconfig').lua_ls.setup {
    on_init = function(client)
        if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if vim.uv.fs_stat(path..'/.luarc.json') or vim.uv.fs_stat(path..'/.luarc.jsonc') then
                return
            end
        end

        client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
            runtime = {
                version = 'LuaJIT'
            },
            workspace = {
                checkThirdParty = false,
                library = {
                    vim.env.VIMRUNTIME
                }
            }
        })
    end,
    settings = {
        Lua = {
            diagnostics = {
                globals = { 'vim' }
            }
        }
    },
    capabilities = capabilities,
}

-- Setup pyright
require ('lspconfig').pyright.setup{
    capabilities = capabilities
}

-- Setup dartls
require('lspconfig').dartls.setup {
    capabilities = capabilities
}

-- Setup autoclose 
require('autoclose').setup()

-- Setup colorscheme
vim.cmd.colorscheme "catppuccin"

-- Setup completeopt
vim.opt.completeopt = {'menu', 'menuone', 'noselect'}

-- Setup autofolding 
-- require('auto_folding').setup()
