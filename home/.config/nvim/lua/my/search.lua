local mysearch = {}

function mysearch.setup()
  vim.opt.ignorecase = true -- Case insensitive
  vim.opt.wrapscan = true -- Wrap around when the search is finished
  vim.opt.incsearch = true -- Incremental search
  vim.opt.hlsearch = true -- Highlight search results
  vim.opt.showmatch = true -- Bracket highlighting
  vim.opt.matchtime = 1 -- Time to show bracket highlighting
end

return mysearch
