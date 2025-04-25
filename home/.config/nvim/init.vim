"#############################################################################"
"# File        : init.vim                                                     "
"# Description : Files loaded when nvim starts.                               "
"# Remarks     :                                                              "
"#############################################################################"

"#############################################################################"
" Plugins                                                                     "
"#############################################################################"
lua << EOF
require('my/lazy').setup()
require('my/common').setup()
require('my/colorscheme').setup()
require('my/lsp').setup()
require('my/keymap').setup()
require('my/tabstop').setup()
require("tiny-inline-diagnostic").setup({
    -- Style preset for diagnostic messages
    -- Available options:
    -- "modern", "classic", "minimal", "powerline",
    -- "ghost", "simple", "nonerdfont", "amongus"
    preset = "modern",

    transparent_bg = false, -- Set the background of the diagnostic to transparent

    hi = {
        error = "DiagnosticError", -- Highlight group for error messages
        warn = "DiagnosticWarn", -- Highlight group for warning messages
        info = "DiagnosticInfo", -- Highlight group for informational messages
        hint = "DiagnosticHint", -- Highlight group for hint or suggestion messages
        arrow = "NonText", -- Highlight group for diagnostic arrows

        -- Background color for diagnostics
        -- Can be a highlight group or a hexadecimal color (#RRGGBB)
        background = "CursorLine",

        -- Color blending option for the diagnostic background
        -- Use "None" or a hexadecimal color (#RRGGBB) to blend with another color
        mixing_color = "None",
    },

    options = {
        -- Display the source of the diagnostic (e.g., basedpyright, vsserver, lua_ls etc.)
        show_source = false,

        -- Use icons defined in the diagnostic configuration
        use_icons_from_diagnostic = false,

        -- Set the arrow icon to the same color as the first diagnostic severity
        set_arrow_to_diag_color = false,

        -- Add messages to diagnostics when multiline diagnostics are enabled
        -- If set to false, only signs will be displayed
        add_messages = true,

        -- Time (in milliseconds) to throttle updates while moving the cursor
        -- Increase this value for better performance if your computer is slow
        -- or set to 0 for immediate updates and better visual
        throttle = 20,

        -- Minimum message length before wrapping to a new line
        softwrap = 30,

        -- Configuration for multiline diagnostics
        -- Can either be a boolean or a table with the following options:
        --  multilines = {
        --      enabled = false,
        --      always_show = false,
        -- }
        -- If it set as true, it will enable the feature with this options:
        --  multilines = {
        --      enabled = true,
        --      always_show = false,
        -- }
        multilines = {
            -- Enable multiline diagnostic messages
            enabled = false,

            -- Always show messages on all lines for multiline diagnostics
            always_show = false,
        },

        -- Display all diagnostic messages on the cursor line
        show_all_diags_on_cursorline = false,

        -- Enable diagnostics in Insert mode
        -- If enabled, it is better to set the `throttle` option to 0 to avoid visual artifacts
        enable_on_insert = false,

		-- Enable diagnostics in Select mode (e.g when auto inserting with Blink)
        enable_on_select = false,

        overflow = {
            -- Manage how diagnostic messages handle overflow
            -- Options:
            -- "wrap" - Split long messages into multiple lines
            -- "none" - Do not truncate messages
            -- "oneline" - Keep the message on a single line, even if it's long
            mode = "wrap",

            -- Trigger wrapping to occur this many characters earlier when mode == "wrap".
            -- Increase this value appropriately if you notice that the last few characters
            -- of wrapped diagnostics are sometimes obscured.
            padding = 0,
        },

        -- Configuration for breaking long messages into separate lines
        break_line = {
            -- Enable the feature to break messages after a specific length
            enabled = false,

            -- Number of characters after which to break the line
            after = 30,
        },

        -- Custom format function for diagnostic messages
        -- Example:
        -- format = function(diagnostic)
        --     return diagnostic.message .. " [" .. diagnostic.source .. "]"
        -- end
        format = nil,


        virt_texts = {
            -- Priority for virtual text display
            priority = 2048,
        },

        -- Filter diagnostics by severity
        -- Available severities:
        -- vim.diagnostic.severity.ERROR
        -- vim.diagnostic.severity.WARN
        -- vim.diagnostic.severity.INFO
        -- vim.diagnostic.severity.HINT
        severity = {
            vim.diagnostic.severity.ERROR,
            vim.diagnostic.severity.WARN,
            vim.diagnostic.severity.INFO,
            vim.diagnostic.severity.HINT,
        },

        -- Events to attach diagnostics to buffers
        -- You should not change this unless the plugin does not work with your configuration
        overwrite_events = nil,
    },
    disabled_ft = {} -- List of filetypes to disable the plugin
})

require("tiny-code-action").setup({
	--- The backend to use, currently only "vim", "delta" and "difftastic" are supported
	backend = "vim",
	backend_opts = {
		delta = {
			-- Header from delta can be quite large.
			-- You can remove them by setting this to the number of lines to remove
			header_lines_to_remove = 4,

			-- The arguments to pass to delta
			-- If you have a custom configuration file, you can set the path to it like so:
			-- args = {
			--     "--config" .. os.getenv("HOME") .. "/.config/delta/config.yml",
			-- }
			args = {
				"--line-numbers",
			},
		},
		difftastic = {
			-- Header from delta can be quite large.
			-- You can remove them by setting this to the number of lines to remove
			header_lines_to_remove = 1,

			-- The arguments to pass to difftastic
			args = {
				"--color=always",
				"--display=inline",
				"--syntax-highlight=on",
			},
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
	-- The icons to use for the code actions
	-- You can add your own icons, you just need to set the exact action's kind of the code action
	-- You can set the highlight like so: { link = "DiagnosticError" } or  like nvim_set_hl ({ fg ..., bg..., bold..., ...})
	signs = {
		quickfix = { "󰁨", { link = "DiagnosticInfo" } },
		others = { "?", { link = "DiagnosticWarning" } },
		refactor = { "", { link = "DiagnosticWarning" } },
		["refactor.move"] = { "󰪹", { link = "DiagnosticInfo" } },
		["refactor.extract"] = { "", { link = "DiagnosticError" } },
		["source.organizeImports"] = { "", { link = "TelescopeResultVariable" } },
		["source.fixAll"] = { "", { link = "TelescopeResultVariable" } },
		["source"] = { "", { link = "DiagnosticError" } },
		["rename"] = { "󰑕", { link = "DiagnosticWarning" } },
		["codeAction"] = { "", { link = "DiagnosticError" } },
	},
})

EOF
let g:enable_spelunker_vim = 1

" let g:quickrun_config = {}
" let g:quickrun_config.c = {
" \   'command': 'gcc',
" \   'cmdopt': '-W -Wextra -O2 -fstack-usage',
" \   'exec': [
" \       '%c %o %s -o %s:p:r',
" \       '%s:p:r',
" \       'echo ---------- stack usage ----------',
" \       'cat %s:p:r.su',
" \       'echo ---------------------------------',
" \       'rm -f %s:p:r.su',
" \   ],
" \   'tempfile': '%{tempname()}.c',
" \   'hook/sweep/files': ['%S:p:r']
" \}

" let g:quickrun_config = {}
" let g:quickrun_config.c = {
" \   'command': 'gcc',
" \   'cmdopt': '-W -Wextra -O3 -fstack-usage',
" \   'exec': [
" \       '%c %o %s -o %s:p:r',
" \       'valgrind --tool=callgrind --instr-atstart=no %s:p:r',
" \       'echo ---------- gcc stack usage ----------',
" \       'cat %s:p:r.su',
" \       'echo -------------------------------------',
" \       'callgrind_annotate callgrind.out.*',
" \       'rm -f %s:p:r.su callgrind.out.*',
" \   ],
" \}

"clipboard settings(windows only)"
source <sfile>:h/lib/osc52.vim
augroup osc52
  autocmd!
  autocmd TextYankPost * if v:event.operator ==# 'y' | call SendViaOSC52(getreg(v:event.regname)) | endif
augroup END

"set tags=~/repos/fork/vim/src/tags"
