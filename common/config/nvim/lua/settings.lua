local opt = vim.opt

opt.number         = true
opt.relativenumber = true
opt.shiftwidth     = 4
opt.softtabstop    = 4
opt.tabstop        = 4
opt.expandtab      = true
opt.incsearch      = true
opt.ignorecase     = true
opt.smartcase      = true
opt.showcmd        = true
opt.showmode       = true
opt.history        = 1000
opt.linebreak      = true
opt.autoindent     = true
opt.wrap           = true
opt.wrapmargin     = 0
opt.textwidth      = 0
opt.breakindent    = true
opt.breakindentopt = "shift:2"
opt.hlsearch       = true
opt.showmatch      = true
opt.cursorline     = true
opt.spellfile      = vim.fn.expand("~/.vim/spell/en.utf-8.add")
opt.spell          = true
opt.spelllang      = { "en" }
opt.spellcapcheck  = ""
opt.mouse      = ""
opt.signcolumn     = "yes"
opt.cmdheight=0
opt.splitbelow = true
opt.splitright = true

-- Disable auto-comment continuation on new lines
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})

-- Restore cursor to last known position when reopening a file
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    local ft = vim.bo.filetype
    if mark[1] > 0
      and mark[1] <= lcount
      and ft ~= "commit"
      and ft ~= "xxd"
      and ft ~= "gitrebase"
      and not vim.wo.diff
    then
      vim.api.nvim_win_set_cursor(0, mark)
    end
  end,
})

-- Racket/Lisp: use scmindent for = indentation operator
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lisp", "scheme", "racket" },
  callback = function()
    vim.opt_local.equalprg = "scmindent.rkt"
  end,
})

-- start treesitter for lisp like files
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "racket", "scheme", "lisp" },
  callback = function()
    vim.treesitter.start()
  end,
})

-- closes nvim tree if it's the last buffer in a window
vim.api.nvim_create_autocmd("BufEnter", {
  nested = true,
  callback = function()
    if #vim.api.nvim_tabpage_list_wins(0) == 1
      and vim.bo.filetype == "NvimTree"
    then
      vim.schedule(function()
        vim.cmd("quit")
      end)
    end
  end,
})

-- toggles auto complete
vim.keymap.set("n", "<leader>cc", function()
  local cmp = require("cmp")
  cmp.setup({ enabled = not cmp.get_config().enabled })
end, { noremap = true })
