-- https://github.com/nvim-telescope/telescope.nvim/wiki/Configuration-Recipes#file-and-text-search-in-hidden-files-and-directories
local telescopeConfig = require('telescope.config')

-- Clone the default Telescope configuration
local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }

table.insert(vimgrep_arguments, '--hidden')
table.insert(vimgrep_arguments, '--glob')
table.insert(vimgrep_arguments, '!**/.git/*')

-- https://github.com/nvim-telescope/telescope.nvim/wiki/Configuration-Recipes#ignore-files-bigger-than-a-threshold

local previewers = require('telescope.previewers')
local putils = require('telescope.previewers.utils')
local pfiletype = require('plenary.filetype')
-- local Job = require('plenary.job')

local new_maker = function(filepath, bufnr, opts)
  opts = opts or {}
  if opts.use_ft_detect == nil then
    local ft = pfiletype.detect(filepath)
    -- Here for example you can say: if ft == 'xyz' then this_regex_highlighing else nothing end
    opts.use_ft_detect = false
    putils.regex_highlighter(bufnr, ft)
  end
  previewers.buffer_previewer_maker(filepath, bufnr, opts)

  -- -- https://github.com/nvim-telescope/telescope.nvim/wiki/Configuration-Recipes#dont-preview-binaries
  -- filepath = vim.fn.expand(filepath)
  -- Job:new({
  --   command = 'file',
  --   args = { '--mime-type', '-b', filepath },
  --   on_exit = function(j)
  --     local mime_type = vim.split(j:result()[1], '/')[1]
  --     if mime_type == 'text' then
  --       previewers.buffer_previewer_maker(filepath, bufnr, opts)
  --     else
  --       -- maybe we want to write something to the buffer here
  --       vim.schedule(function()
  --         vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { 'BINARY' })
  --       end)
  --     end
  --   end
  -- }):sync()
end

-- https://github.com/nvim-telescope/telescope.nvim/wiki/Configuration-Recipes#fused-layout

local Layout = require('nui.layout')
local Popup = require('nui.popup')

local TSLayout = require('telescope.pickers.layout')

local function make_popup(options)
  local popup = Popup(options)
  function popup.border:change_title(title)
    popup.border.set_text(popup.border, 'top', title)
  end

  return TSLayout.Window(popup)
end

require('telescope').setup({
  defaults = {
    layout_strategy = 'flex',
    layout_config = {
      horizontal = {
        size = {
          width = '90%',
          height = '60%',
        },
      },
      vertical = {
        size = {
          width = '90%',
          height = '90%',
        },
      },
    },
    create_layout = function(picker)
      local border = {
        results = {
          top_left = "┌",
          top = "─",
          top_right = "┬",
          right = "│",
          bottom_right = "",
          bottom = "",
          bottom_left = "",
          left = "│",
        },
        results_patch = {
          minimal = {
            top_left = "┌",
            top_right = "┐",
          },
          horizontal = {
            top_left = "┌",
            top_right = "┬",
          },
          vertical = {
            top_left = "├",
            top_right = "┤",
          },
        },
        prompt = {
          top_left = "├",
          top = "─",
          top_right = "┤",
          right = "│",
          bottom_right = "┘",
          bottom = "─",
          bottom_left = "└",
          left = "│",
        },
        prompt_patch = {
          minimal = {
            bottom_right = "┘",
          },
          horizontal = {
            bottom_right = "┴",
          },
          vertical = {
            bottom_right = "┘",
          },
        },
        preview = {
          top_left = "┌",
          top = "─",
          top_right = "┐",
          right = "│",
          bottom_right = "┘",
          bottom = "─",
          bottom_left = "└",
          left = "│",
        },
        preview_patch = {
          minimal = {},
          horizontal = {
            bottom = "─",
            bottom_left = "",
            bottom_right = "┘",
            left = "",
            top_left = "",
          },
          vertical = {
            bottom = "",
            bottom_left = "",
            bottom_right = "",
            left = "│",
            top_left = "┌",
          },
        },
      }

      local results = make_popup({
        focusable = false,
        border = {
          style = border.results,
          text = {
            top = picker.results_title,
            top_align = 'center',
          },
        },
        win_options = {
          winhighlight = 'Normal:Normal',
        },
      })

      local prompt = make_popup({
        enter = true,
        border = {
          style = border.prompt,
          text = {
            top = picker.prompt_title,
            top_align = 'center',
          },
        },
        win_options = {
          winhighlight = 'Normal:Normal',
        },
      })

      local preview = make_popup({
        focusable = false,
        border = {
          style = border.preview,
          text = {
            top = picker.preview_title,
            top_align = 'center',
          },
        },
      })

      local box_by_kind = {
        vertical = Layout.Box({
          Layout.Box(preview, { grow = 1 }),
          Layout.Box(results, { grow = 1 }),
          Layout.Box(prompt, { size = 3 }),
        }, { dir = 'col' }),
        horizontal = Layout.Box({
          Layout.Box({
            Layout.Box(results, { grow = 1 }),
            Layout.Box(prompt, { size = 3 }),
          }, { dir = 'col', size = '50%' }),
          Layout.Box(preview, { size = '50%' }),
        }, { dir = 'row' }),
        minimal = Layout.Box({
          Layout.Box(results, { grow = 1 }),
          Layout.Box(prompt, { size = 3 }),
        }, { dir = 'col' }),
      }

      local function get_box()
        local strategy = picker.layout_strategy
        if strategy == 'vertical' or strategy == 'horizontal' then
          return box_by_kind[strategy], strategy
        end

        local height, width = vim.o.lines, vim.o.columns
        local box_kind = 'horizontal'
        if width < 100 then
          box_kind = 'vertical'
          if height < 40 then
            box_kind = 'minimal'
          end
        end
        return box_by_kind[box_kind], box_kind
      end

      local function prepare_layout_parts(layout, box_type)
        layout.results = results
        results.border:set_style(border.results_patch[box_type])

        layout.prompt = prompt
        prompt.border:set_style(border.prompt_patch[box_type])

        if box_type == 'minimal' then
          layout.preview = nil
        else
          layout.preview = preview
          preview.border:set_style(border.preview_patch[box_type])
        end
      end

      local function get_layout_size(box_kind)
        return picker.layout_config[box_kind == 'minimal' and 'vertical' or box_kind].size
      end

      local box, box_kind = get_box()
      local layout = Layout({
        relative = 'editor',
        position = '50%',
        size = get_layout_size(box_kind),
      }, box)

      layout.picker = picker
      prepare_layout_parts(layout, box_kind)

      local layout_update = layout.update
      function layout:update()
        local box, box_kind = get_box()
        prepare_layout_parts(layout, box_kind)
        layout_update(self, { size = get_layout_size(box_kind) }, box)
      end

      return TSLayout(layout)
    end,

    buffer_previewer_maker = new_maker,
    -- `hidden = true` is not supported in text grep commands.
    vimgrep_arguments = vimgrep_arguments,

    -- https://github.com/nvim-telescope/telescope.nvim/wiki/Configuration-Recipes#use-terminal-image-viewer-to-preview-images
    preview = {
      mime_hook = function(filepath, bufnr, opts)
        local is_image = function(filepath)
          local image_extensions = { 'png', 'jpg' } -- Supported image formats
          local split_path = vim.split(filepath:lower(), '.', { plain = true })
          local extension = split_path[#split_path]
          return vim.tbl_contains(image_extensions, extension)
        end
        if is_image(filepath) then
          local term = vim.api.nvim_open_term(bufnr, {})
          local function send_output(_, data, _)
            for _, d in ipairs(data) do
              vim.api.nvim_chan_send(term, d .. '\r\n')
            end
          end
          vim.fn.jobstart(
            {
              'catimg', filepath -- Terminal image viewer command
            },
            { on_stdout = send_output, stdout_buffered = true, pty = true })
        else
          require('telescope.previewers.utils').set_preview_message(bufnr, opts.winid, 'Binary cannot be previewed')
        end
      end
    },
  },
  extensions = {
    'fidget',
  },
  pickers = {
    find_files = {
      -- `hidden = true` will still show the inside of `.git/` as it's not `.gitignore`d.
      find_command = { 'rg', '--files', '--hidden', '--glob', '!**/.git/*' },
      -- theme = 'dropdown',
    },
  },
})
