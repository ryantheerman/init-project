local map = vim.keymap.set

-- key remappings
map("n", "l",     "cl",             { noremap = true })
map("x", "l",     "cl",             { noremap = true })
map("n", "s",     "<Right>",        { noremap = true })
map("x", "s",     "<Right>",        { noremap = true })
map("n", "<C-L>", ":nohl<CR><C-L>", { noremap = true, silent = true })
map("n", "<C-w>s", "<C-w>l",        { noremap = true })
map("n", "<C-w>l", "<C-w>s",        { noremap = true })

map('n', '<leader>h', '<C-w>h',        { noremap = true })
map('n', '<leader>s', '<C-w>l',        { noremap = true })
map('n', '<leader>j', '<C-w>j',        { noremap = true })
map('n', '<leader>k', '<C-w>k',        { noremap = true })

-- custom leader invocations
map("n", "<leader>t", function()
  -- set backdrop
  local backdrop_buf = vim.api.nvim_create_buf(false, true)
  local backdrop_win = vim.api.nvim_open_win(backdrop_buf, false, {
    relative = "editor",
    width = vim.o.columns,
    height = vim.o.lines,
    row = 0,
    col = 0,
    style = "minimal",
    focusable = false,
    zindex = 49,
  })
  vim.api.nvim_set_option_value("winblend", 50, { win = backdrop_win })
  vim.api.nvim_set_option_value("winhighlight", "Normal:BlackoutFloat", { win = backdrop_win })

  -- terminal config
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = math.floor(vim.o.columns * 0.85),
    height = math.floor(vim.o.lines * 0.85),
    row = math.floor((vim.o.lines * 0.075)),
    col = math.floor((vim.o.columns * 0.075)),
    style = "minimal",
  })
  vim.api.nvim_set_option_value("winhighlight", "Normal:NormalFloat", { win = win })
  vim.fn.termopen(os.getenv("SHELL"))
  vim.api.nvim_buf_set_keymap(buf, "t", "<Esc>", "<C-\\><C-n>", { noremap = true })
  vim.cmd("startinsert")
  local prev_mouse = vim.o.mouse
  vim.o.mouse = "a"
  vim.api.nvim_create_autocmd("TermClose", {
    buffer = buf,
    once = true,
    callback = function()
      vim.o.mouse = prev_mouse
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
      if vim.api.nvim_win_is_valid(backdrop_win) then
        vim.api.nvim_win_close(backdrop_win, true)
      end
      if vim.api.nvim_buf_is_valid(backdrop_buf) then
        vim.api.nvim_buf_delete(backdrop_buf, { force = true })
      end
    end,
  })
end, { noremap = true })

-- nvim tree plugin
map("n", "<leader>e", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
map("n", "<leader>u", ":NvimTreeFocus<CR>",  { noremap = true, silent = true })

-- telescope plugin
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { noremap = true })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>",    { noremap = true })
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>",  { noremap = true })
map("n", "<leader>fr", "<cmd>Telescope oldfiles<CR>",   { noremap = true })

-- tslime plugin
map("v", "<C-h><C-t>", "<Plug>SendSelectionToTmux", {})
map("n", "<C-h><C-t>", "<Plug>NormalModeSendToTmux", {})
map("n", "<C-h>r",     "<Plug>SetTmuxVars", {})
vim.g.tslime_always_current_session = 1
vim.g.tslime_always_current_window  = 1
vim.g.tslime_autoset_pane           = 1

-- lsp server
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local opts = { buffer = ev.buf, noremap = true, silent = true }
    map("n", "gd",        vim.lsp.buf.definition,   opts)
    map("n", "gD",        vim.lsp.buf.declaration,  opts)
    map("n", "gr",        vim.lsp.buf.references,   opts)
    map("n", "K",         vim.lsp.buf.hover,        opts)
    map("n", "<leader>r", vim.lsp.buf.rename,       opts)
    map("n", "<leader>a", vim.lsp.buf.code_action,  opts)
    map("n", "[d",        vim.diagnostic.goto_prev, opts)
    map("n", "]d",        vim.diagnostic.goto_next, opts)
  end,
})
