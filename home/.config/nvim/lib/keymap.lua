local function set_keymap()
  -- LSP key bindings
  vim.keymap.set('n', 'K'    , '<cmd>lua vim.lsp.buf.hover()<CR>'          , { desc = 'LSP Hover' })
  vim.keymap.set('n', 'gf'   , '<cmd>lua vim.lsp.buf.formatting()<CR>'     , { desc = 'LSP Formatting' })
  vim.keymap.set('n', 'gr'   , '<cmd>lua vim.lsp.buf.references()<CR>'     , { desc = 'LSP References' })
  vim.keymap.set('n', 'gd'   , '<cmd>lua vim.lsp.buf.definition()<CR>'     , { desc = 'LSP Go to Definition' })
  vim.keymap.set('n', 'gD'   , '<cmd>lua vim.lsp.buf.declaration()<CR>'    , { desc = 'LSP Go to Declaration' })
  vim.keymap.set('n', 'gi'   , '<cmd>lua vim.lsp.buf.implementation()<CR>' , { desc = 'LSP Go to Implementation' })
  vim.keymap.set('n', 'gt'   , '<cmd>lua vim.lsp.buf.type_definition()<CR>', { desc = 'LSP Go to Type Definition' })
  vim.keymap.set('n', 'gn'   , '<cmd>lua vim.lsp.buf.rename()<CR>'         , { desc = 'LSP Rename' })
  vim.keymap.set('n', 'ga'   , '<cmd>lua vim.lsp.buf.code_action()<CR>'    , { desc = 'LSP Code Action' })
  vim.keymap.set('n', 'ge'   , '<cmd>lua vim.diagnostic.open_float()<CR>'  , { desc = 'Show Diagnostics' })
  vim.keymap.set('n', 'g]'   , '<cmd>lua vim.diagnostic.goto_next()<CR>'   , { desc = 'Next Diagnostic' })
  vim.keymap.set('n', 'g['   , '<cmd>lua vim.diagnostic.goto_prev()<CR>'   , { desc = 'Previous Diagnostic' })
  vim.keymap.set('n', '<C-j>', '<Plug>(edgemotion-j)'                      , { desc = 'Edge motion down' })
  vim.keymap.set('n', '<C-k>', '<Plug>(edgemotion-k)'                      , { desc = 'Edge motion up' })
  vim.keymap.set('i', '<C-y>', '<Plug>(dmacro-play-macro)'                 , { desc = 'Play Macro' })
  vim.keymap.set('n', '<C-y>', '<Plug>(dmacro-play-macro)'                 , { desc = 'Play Macro' })
  vim.keymap.set('n', 'tt'   , ':QuickRun<CR>'                             , { silent = true, desc = 'QuickRun' })
  vim.keymap.set('n', 'sa'   , ':Startify<CR>'                             , { silent = true, desc = 'Startify' })
  vim.keymap.set('n', '<ESC>', ':nohlsearch<CR>'                           , { silent = true, desc = 'Clear Highlight' })
  vim.keymap.set('n', 'q'    , ':nohlsearch<CR>'                           , { silent = true, desc = 'Clear Highlight' })
  vim.keymap.set(
    'n',
    '<C-c>',
    function()
      return vim.fn['quickrun#is_running']() == 1 and vim.fn['quickrun#sweep_sessions']() or '<C-c>'
    end,
    { expr = true, silent = true, desc = 'QuickRun Session Cleanup' }
  )
  vim.keymap.set(
    'n',
    '<C-e>',
    function()
      local path = vim.fn.bufname(vim.fn.bufnr())
      if vim.fn.isdirectory(path) ~= 1 then
        path = vim.fn.getcwd()
      end
      path = vim.fn.fnamemodify(path, ':p:h')

      require('vfiler').start(path, {
        options = {
          auto_cd = true,
          auto_resize = true,
          keep = true,
          name = 'explorer',
          layout = 'left',
          width = 40,
          columns = 'indent,name,mode,size',
          show_hidden_files = true
        },
      })
    end,
    { silent = true, desc = 'Start VFiler Explorer' })
end

set_keymap()
