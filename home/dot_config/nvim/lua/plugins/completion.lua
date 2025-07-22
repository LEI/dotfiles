return {
  {
    -- Alternative: hrsh7th/nvim-cmp
    'saghen/blink.cmp',
    -- optional: provides snippets for the snippet source
    dependencies = { 'rafamadriz/friendly-snippets' },

    -- use a release tag to download pre-built binaries
    version = '1.*',
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
        ['<Tab>'] = { 'select_next', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'fallback' },
      },

      -- Automatically show the documentation popup
      completion = {
        documentation = {
          auto_show = true,
          -- auto_show_delay_ms = 500,
          -- treesitter_highlighting = false,
        },

        -- Manual selection with auto-insert
        -- https://cmp.saghen.dev/configuration/completion.html#list
        list = { selection = { preselect = false, auto_insert = true } },

        -- Ghost text
        -- https://cmp.saghen.dev/configuration/completion.html#ghost-text
        -- menu = { auto_show = true },
        -- ghost_text = { enabled = true, show_with_menu = true },
      },

      -- Default list of enabled providers defined so that you can extend it
      -- elsewhere in your config, without redefining it, due to `opts_extend`
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
        -- https://github.com/kristijanhusak/vim-dadbod-completion#install
        per_filetype = {
          sql = { 'snippets', 'dadbod', 'buffer' },
        },
        providers = {
          dadbod = { name = 'Dadbod', module = 'vim_dadbod_completion.blink' },
        },
      },

      -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
      -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
      -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
      --
      -- See the fuzzy documentation for more information
      fuzzy = { implementation = 'prefer_rust_with_warning' },

      cmdline = {
        -- FIXME: allow tab expansion (e.g. %)
        enabled = false,
        keymap = {
          preset = 'inherit',
          ['<CR>'] = { 'accept_and_enter', 'fallback' },
          ['<Tab>'] = { 'show', 'accept' },
        },
        completion = {
          list = { selection = { preselect = false, auto_insert = true } },
          menu = {
            auto_show = true,
            -- function(ctx) return vim.fn.getcmdtype() == ':' or vim.fn.getcmdtype() == '@' end,
          },
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
