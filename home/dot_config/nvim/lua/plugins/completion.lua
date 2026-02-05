return {
  {
    -- Alternative: hrsh7th/nvim-cmp
    'saghen/blink.cmp',
    enabled = vim.fn.has('nvim-0.10') == 1,
    -- optional: provides snippets for the snippet source
    dependencies = {
      'rafamadriz/friendly-snippets',
      'folke/lazydev.nvim',
      'mgalliou/blink-cmp-tmux',
    },

    -- use a release tag to download pre-built binaries
    -- version = '1.*', -- '1.6.0',
    version = '1.8.*', -- 1.9.1 keeps menu open
    -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
    -- build = 'cargo build --release',
    -- If you use nix, you can build from source using latest nightly rust with:
    -- build = 'nix run .#build-plugin',

    event = {
      'CmdlineEnter',
      'InsertEnter',
      -- 'TermEnter',
    },

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
      -- 'super-tab' for mappings similar to vscode (tab to accept)
      -- 'enter' for enter to accept
      -- 'none' for no mappings
      --
      -- All presets have the following mappings:
      -- C-space: Open menu or open docs if already open
      -- C-n/C-p or Up/Down: Select next/previous item
      -- C-e: Hide menu
      -- C-k: Toggle signature help (if signature.enabled = true)
      --
      -- See :h blink-cmp-config-keymap for defining your own keymap
      keymap = {
        preset = 'enter',
        ['<Up>'] = false,
        ['<Down>'] = false,
        -- ['<Left>'] = { 'fallback' },
        -- ['<Right>'] = { 'fallback' },
        ['<C-y>'] = { 'select_and_accept' },
        -- ['<Tab>'] = { 'select_next', 'fallback' },
        ['<Tab>'] = {
          'select_next',
          -- function() -- sidekick next edit suggestion
          --   return require('sidekick').nes_jump_or_apply()
          -- end,
          function() -- if you are using Neovim's native inline completions
            return vim.lsp.inline_completion and vim.lsp.inline_completion.get() or nil
          end,
          'fallback',
        },
        ['<S-Tab>'] = { 'select_prev', 'fallback' },
      },

      -- Automatically show the documentation popup
      completion = {
        documentation = {
          auto_show = true,
          -- auto_show_delay_ms = 500,
          -- treesitter_highlighting = false,
        },

        -- Ghost text
        -- https://cmp.saghen.dev/configuration/completion.html#ghost-text
        -- menu = { auto_show = true },
        -- ghost_text = { enabled = true, show_with_menu = true },

        -- Manual selection with auto-insert
        -- https://cmp.saghen.dev/configuration/completion.html#list
        list = { selection = { preselect = false, auto_insert = true } },

        -- Completion menu drawing (mini.icons)
        menu = {
          draw = {
            components = {
              kind_icon = {
                text = function(ctx)
                  local kind_icon, _, _ = require('mini.icons').get('lsp', ctx.kind)
                  return kind_icon
                end,
                -- (optional) use highlights from mini.icons
                highlight = function(ctx)
                  local _, hl, _ = require('mini.icons').get('lsp', ctx.kind)
                  return hl
                end,
              },
              kind = {
                -- (optional) use highlights from mini.icons
                highlight = function(ctx)
                  local _, hl, _ = require('mini.icons').get('lsp', ctx.kind)
                  return hl
                end,
              },
            },
          },
        },
      },

      -- Default list of enabled providers defined so that you can extend it
      -- elsewhere in your config, without redefining it, due to `opts_extend`
      sources = {
        default = {
          'lsp',
          'path',
          'snippets',
          'buffer',
          'tmux',
        },
        -- https://github.com/kristijanhusak/vim-dadbod-completion#install
        per_filetype = {
          blade = { inherit_defaults = true, 'blade-nav' },
          lua = { inherit_defaults = true, 'lazydev' },
          php = { inherit_defaults = true, 'blade-nav' },
          sql = { inherit_defaults = true, 'dadbod' },
        },
        providers = {
          -- buffer = { fallbacks = { 'tmux' } },

          -- Always show buffer completions with LSP
          -- lsp = { fallbacks = {} }, -- defaults to `{ 'buffer' }`

          -- -- Path completion from cwd instead of current buffer's directory
          -- path = {
          --   opts = {
          --     get_cwd = function(_)
          --       return vim.fn.getcwd()
          --     end,
          --   },
          -- },

          ['blade-nav'] = {
            module = 'blade-nav.blink',
            opts = { close_tag_on_complete = true },
          },
          dadbod = { name = 'Dadbod', module = 'vim_dadbod_completion.blink' },
          lazydev = {
            name = 'LazyDev',
            module = 'lazydev.integrations.blink',
            -- make lazydev completions top priority (see `:h blink.cmp`)
            score_offset = 100,
          },
          tmux = {
            module = 'blink-cmp-tmux',
            name = 'tmux',
            opts = {
              all_panes = false,
              capture_history = true,
              triggered_only = false,
              -- trigger_chars = { '.' },
            },
            score_offset = -100,
          },
        },
      },

      -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
      -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
      -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
      --
      -- See the fuzzy documentation for more information
      fuzzy = {
        implementation = 'prefer_rust_with_warning',
        -- -- Always prioritoze exact matches
        -- sorts = {
        --   'exact',
        --   -- defaults
        --   'score',
        --   'sort_text',
        -- },
      },

      cmdline = {
        -- FIXME: allow tab expansion (e.g. %)
        enabled = true,
        keymap = {
          preset = 'inherit',
          ['<CR>'] = { 'accept_and_enter', 'fallback' },
          -- ['<Right>'] = false,
          -- ['<Left>'] = false,
          -- ['<Tab>'] = { 'show', 'accept' },
        },
        completion = {
          list = { selection = { preselect = false, auto_insert = true } },
          menu = {
            auto_show = function(ctx)
              return vim.fn.getcmdtype() == ':' or vim.fn.getcmdtype() == '@'
            end,
          },
          ghost_text = { enabled = true },
        },
      },

      -- Experimental
      -- https://cmp.saghen.dev/configuration/signature
      signature = {
        enabled = true,
        -- window = { show_documentation = false },
      },

      -- term = {
      --   enabled = vim.fn.has('nvim-0.11') == 1,
      -- },
    },
    opts_extend = { 'sources.default' },
  },
}
