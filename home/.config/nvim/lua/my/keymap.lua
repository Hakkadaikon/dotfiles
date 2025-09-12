local mykeymap = {}

-- LSP key bindings
function mykeymap.setup()
  vim.keymap.set("n", "gx", function()
    require("tiny-code-action").code_action()
  end, { noremap = true, silent = true })

  vim.keymap.set("n", "gh", vim.lsp.buf.hover, { desc = "LSP Hover" })
  vim.keymap.set("n", "gf", "lua <cmd>vim.lsp.buf.formatting<CR>", { desc = "LSP Formatting" })
  vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "LSP References" })
  vim.keymap.set("n", "qd", vim.lsp.buf.definition, { desc = "LSP Go to Definition" })
  vim.keymap.set("n", "qD", vim.lsp.buf.declaration, { desc = "LSP Go to Declaration" })
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "LSP Go to Implementation" })
  vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, { desc = "LSP Go to Type Definition" })
  vim.keymap.set("n", "gn", vim.lsp.buf.rename, { desc = "LSP Rename" })
  vim.keymap.set("n", "ga", vim.lsp.buf.code_action, { desc = "LSP Code Action" })
  vim.keymap.set("n", "ge", vim.diagnostic.open_float, { desc = "Show Diagnostics" })
  vim.keymap.set("n", "g]", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
  vim.keymap.set("n", "g[", vim.diagnostic.goto_prev, { desc = "Previous Diagnostic" })
  vim.keymap.set("n", "<C-j>", "<Plug>(edgemotion-j)", { desc = "Edge motion down" })
  vim.keymap.set("n", "<C-k>", "<Plug>(edgemotion-k)", { desc = "Edge motion up" })
  vim.keymap.set("n", "tt", ":QuickRun<CR>", { silent = true, desc = "QuickRun" })
  vim.keymap.set("n", "tp", ":Terraform plan<CR>", { silent = true, desc = "Terraform" })
  vim.keymap.set("n", "sa", ":Startify<CR>", { silent = true, desc = "Startify" })
  vim.keymap.set("n", "<ESC>", ":nohlsearch<CR>", { silent = true, desc = "Clear Highlight" })
  vim.keymap.set("n", "q", ":nohlsearch<CR>", { silent = true, desc = "Clear Highlight" })
  vim.keymap.set("n", "<C-c>", function()
    return vim.fn["quickrun#is_running"]() == 1 and vim.fn["quickrun#sweep_sessions"]() or "<C-c>"
  end, { expr = true, silent = true, desc = "QuickRun Session Cleanup" })

  vim.keymap.set("n", "<C-e>", function()
    local path = vim.fn.bufname(vim.fn.bufnr())
    if vim.fn.isdirectory(path) ~= 1 then
      path = vim.fn.getcwd()
    end
    path = vim.fn.fnamemodify(path, ":p:h")

    require("vfiler").start(path, {
      options = {
        auto_cd = true,
        auto_resize = true,
        keep = true,
        name = "explorer",
        layout = "left",
        width = 40,
        columns = "indent,name,mode,size",
        show_hidden_files = true,
      },
    })
  end, { silent = true, desc = "Start VFiler Explorer" })

  -- Default configuration with all available options
  require("goose").setup({
    prefered_picker = nil, -- 'telescope', 'fzf', 'mini.pick', 'snacks', if nil, it will use the best available picker
    default_global_keymaps = false, -- If false, disables all default global keymaps
    keymap = {
      global = {
        toggle = "<Space>g", -- Open goose. Close if opened
        open_input = "<Space>i", -- Opens and focuses on input window on insert mode
        open_input_new_session = "<Space>I", -- Opens and focuses on input window on insert mode. Creates a new session
        open_output = "<Space>o", -- Opens and focuses on output window
        toggle_focus = "<Space>t", -- Toggle focus between goose and last window
        close = "<Space>q", -- Close UI windows
        toggle_fullscreen = "<Space>f", -- Toggle between normal and fullscreen mode
        select_session = "<Space>s", -- Select and load a goose session
        goose_mode_chat = "<Space>mc", -- Set goose mode to `chat`. (Tool calling disabled. No editor context besides selections)
        goose_mode_auto = "<Space>ma", -- Set goose mode to `auto`. (Default mode with full agent capabilities)
        configure_provider = "<Space>p", -- Quick provider and model switch from predefined list
        diff_open = "<Space>d", -- Opens a diff tab of a modified file since the last goose prompt
        diff_next = "<Space>]", -- Navigate to next file diff
        diff_prev = "<Space>[", -- Navigate to previous file diff
        diff_close = "<Space>c", -- Close diff view tab and return to normal editing
        diff_revert_all = "<Space>ra", -- Revert all file changes since the last goose prompt
        diff_revert_this = "<Space>rt", -- Revert current file changes since the last goose prompt
      },
      window = {
        submit = "<cr>", -- Submit prompt (normal mode)
        submit_insert = "<cr>", -- Submit prompt (insert mode)
        close = "<esc>", -- Close UI windows
        stop = "<C-c>", -- Stop goose while it is running
        next_message = "]]", -- Navigate to next message in the conversation
        prev_message = "[[", -- Navigate to previous message in the conversation
        mention_file = "@", -- Pick a file and add to context. See File Mentions section
        toggle_pane = "<tab>", -- Toggle between input and output panes
        prev_prompt_history = "<up>", -- Navigate to previous prompt in history
        next_prompt_history = "<down>", -- Navigate to next prompt in history
      },
    },
    ui = {
      window_width = 0.35, -- Width as percentage of editor width
      input_height = 0.15, -- Input height as percentage of window height
      fullscreen = false, -- Start in fullscreen mode (default: false)
      layout = "right", -- Options: "center" or "right"
      floating_height = 0.8, -- Height as percentage of editor height for "center" layout
      display_model = true, -- Display model name on top winbar
      display_goose_mode = true, -- Display mode on top winbar: auto|chat
    },
    providers = {
      --[[
      Define available providers and their models for quick model switching
      anthropic|azure|bedrock|databricks|google|groq|ollama|openai|openrouter
      Example:
      openrouter = {
        "anthropic/claude-3.5-sonnet",
        "openai/gpt-4.1",
      },
      ollama = {
        "cogito:14b"
      }
      --]]
    },
  })
end

return mykeymap
