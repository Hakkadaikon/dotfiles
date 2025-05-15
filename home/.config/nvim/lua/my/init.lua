local init = {}

function init.setup()
  require('my/lazy').setup()
  require('my/common').setup()
  require('my/colorscheme').setup()
  require('my/lsp').setup()
  require('my/keymap').setup()
  require('my/tabstop').setup()
  require("tiny-inline-diagnostic").setup(
      {
        preset = "modern",
        transparent_bg = false,
        hi = {
          error = "DiagnosticError",
          warn = "DiagnosticWarn",
          info = "DiagnosticInfo",
          hint = "DiagnosticHint",
          arrow = "NonText",
          background = "CursorLine",
          mixing_color = "None",
        },

        options = {
          show_source = false,
          use_icons_from_diagnostic = false,
          set_arrow_to_diag_color = false,
          add_messages = true,
          throttle = 20,
          softwrap = 30,
          multilines = {enabled = false, always_show = false},
          show_all_diags_on_cursorline = false,
          enable_on_insert = false,
          enable_on_select = false,
          overflow = {mode = "wrap", padding = 0},
          break_line = {enabled = false, after = 30},
          -- Custom format function for diagnostic messages
          -- Example:
          -- format = function(diagnostic)
          --     return diagnostic.message .. " [" .. diagnostic.source .. "]"
          -- end
          format = nil,
          virt_texts = {priority = 2048},
          severity = {
            vim.diagnostic.severity.ERROR,
            vim.diagnostic.severity.WARN,
            vim.diagnostic.severity.INFO,
            vim.diagnostic.severity.HINT,
          },
          overwrite_events = nil,
        },
        disabled_ft = {}, -- List of filetypes to disable the plugin
      }
  )

  require("tiny-code-action").setup(
      {
        backend = "vim",
        backend_opts = {
          delta = {header_lines_to_remove = 4, args = {"--line-numbers"}},
          difftastic = {
            header_lines_to_remove = 1,
            args = {"--color=always", "--display=inline", "--syntax-highlight=on"},
          },
        },
        telescope_opts = {
          layout_strategy = "vertical",
          layout_config = {
            width = 0.7,
            height = 0.9,
            preview_cutoff = 1,
            preview_height = function(_, _, max_lines)
              local h = math.floor(max_lines * 0.5)
              return math.max(h, 10)
            end,
          },
        },
        signs = {
          quickfix = {"󰁨", {link = "DiagnosticInfo"}},
          others = {"?", {link = "DiagnosticWarning"}},
          refactor = {"", {link = "DiagnosticWarning"}},
          ["refactor.move"] = {"󰪹", {link = "DiagnosticInfo"}},
          ["refactor.extract"] = {"", {link = "DiagnosticError"}},
          ["source.organizeImports"] = {"", {link = "TelescopeResultVariable"}},
          ["source.fixAll"] = {"", {link = "TelescopeResultVariable"}},
          ["source"] = {"", {link = "DiagnosticError"}},
          ["rename"] = {"󰑕", {link = "DiagnosticWarning"}},
          ["codeAction"] = {"", {link = "DiagnosticError"}},
        },
      }
  )
end

return init
