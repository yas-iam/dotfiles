-- Matrix Purple Neovim Config
vim.g.mapleader = " "

-- 1. Bootstrap Lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- 2. Plugins Setup
require("lazy").setup({
    -- THEME: Moonfly
    { 
        "bluz71/vim-moonfly-colors", 
        name = "moonfly", 
        lazy = false, 
        priority = 1000,
        config = function()
            vim.cmd([[colorscheme moonfly]])
        end
    },

    -- DASHBOARD: Alpha (Matrix Purple)
    {
        'goolord/alpha-nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function ()
            local alpha = require('alpha')
            local dashboard = require('alpha.themes.dashboard')
            dashboard.section.header.val = {
                "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
                "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
                "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
                "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
                "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
                "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
            }
            dashboard.section.header.opts.hl = "AlphaHeader"
            vim.cmd([[highlight AlphaHeader guifg=#8A2BE2]])

            local emoon_tag = {
                type = "text",
                val = "> EMOON <",
                opts = { hl = "AlphaEmoon", position = "center" },
            }
            vim.cmd([[highlight AlphaEmoon guifg=#ae81ff gui=bold]])

            dashboard.section.buttons.val = {
                dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
                dashboard.button("f", "󰈭  Find file", ":Telescope find_files<CR>"),
                dashboard.button("r", "  Recent files", ":Telescope oldfiles<CR>"),
                dashboard.button("c", "  Config", ":e $MYVIMRC<CR>"),
                dashboard.button("q", "󰅚  Quit NVIM", ":qa<CR>"),
            }

            dashboard.config.layout = {
                { type = "padding", val = 2 },
                dashboard.section.header,
                { type = "padding", val = 1 },
                emoon_tag,
                { type = "padding", val = 2 },
                dashboard.section.buttons,
                dashboard.section.footer,
            }
            alpha.setup(dashboard.opts)
        end
    },

    -- LSP: LSP-Zero
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v3.x',
        dependencies = {
            {'williamboman/mason.nvim'},
            {'williamboman/mason-lspconfig.nvim'},
            {'neovim/nvim-lspconfig'},
            {'hrsh7th/nvim-cmp'},
            {'hrsh7th/cmp-nvim-lsp'},
            {'L3MON4D3/LuaSnip'},
        },
        config = function()
            local lsp_zero = require('lsp-zero')
            lsp_zero.extend_lspconfig()
            lsp_zero.on_attach(function(client, bufnr)
                lsp_zero.default_keymaps({buffer = bufnr})
            end)
            require('mason').setup({})
            require('mason-lspconfig').setup({
                -- Note: You have both emmet_language_server AND emmet-vim below.
                -- They might overlap, but this is fine if you prefer emmet-vim shortcuts.
                ensure_installed = {'clangd', 'html', 'emmet_language_server', 'cssls'},
                handlers = { lsp_zero.default_setup },
            })
            local cmp = require('cmp')
            cmp.setup({
                mapping = cmp.mapping.preset.insert({
                    ['<CR>'] = cmp.mapping.confirm({select = true}),
                    ['<Tab>'] = cmp.mapping.select_next_item(),
                    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
                })
            })
        end
    },

    -- TREESITTER
    { 
        'nvim-treesitter/nvim-treesitter', 
        build = ":TSUpdate", 
        config = function() 
            require("nvim-treesitter.configs").setup({ 
                ensure_installed = {"c", "lua", "html", "css"}, 
                highlight = {enable = true} 
            }) 
        end 
    },
    
    -- AUTO CLOSE TAGS (Deduplicated and Merged)
    { 
        'windwp/nvim-ts-autotag', 
        config = function() require('nvim-ts-autotag').setup() end 
    },

    -- EMMET VIM (Merged from your bottom snippet)
    {
        "mattn/emmet-vim",
        init = function() -- Changed 'setup' to 'init' for vim.g variables
            vim.g.user_emmet_leader_key = ',' 
        end
    },

    -- LIVE SERVER
    {
        'barrett-ruth/live-server.nvim',
        cmd = { 'LiveServerStart', 'LiveServerStop' },
    },

    -- UTILS
    { 'nvim-telescope/telescope.nvim', dependencies = { 'nvim-lua/plenary.nvim' } },
    { 'nvim-lualine/lualine.nvim', config = function() require('lualine').setup({options={theme='moonfly'}}) end },
    { "nvim-tree/nvim-tree.lua", config = function() require("nvim-tree").setup() end },
    { "echasnovski/mini.pairs", config = function() require("mini.pairs").setup() end },
})

-- 3. Options
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.clipboard = "unnamedplus"

-- 4. Keymaps
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")
vim.keymap.set("n", "<leader>w", ":w<CR>")
vim.keymap.set("n", "<leader>q", ":q<CR>")

-- Compile and Run C (Info 2 / Study Workflow)
vim.keymap.set('n', '<leader>r', function()
    vim.cmd("w")
    vim.cmd("split | term gcc % -o %:r && ./%:r")
    vim.cmd("startinsert")
end)

-- Custom Toggle for Live Server
local is_live_server_running = false
vim.api.nvim_create_user_command("LiveServerToggle", function()
    if is_live_server_running then
        vim.cmd("LiveServerStop")
        print("Live Server Stopped")
        is_live_server_running = false
    else
        vim.cmd("LiveServerStart")
        print("Live Server Started")
        is_live_server_running = true
    end
end, {})

vim.keymap.set("n", "<leader>l", ":LiveServerToggle<CR>")
