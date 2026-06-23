-- Cursorline: underline only, no background

-- Search
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.api.nvim_set_hl(0, "MatchParen",     { fg = "black", bg = "white" })
    vim.api.nvim_set_hl(0, "Search",     { fg = "black", bg = "darkgreen" })
    vim.api.nvim_set_hl(0, "SpellBad", { fg = "yellow", bg = "darkred", cterm = { undercurl = false } })
    vim.api.nvim_set_hl(0, "Comment",   { fg = "yellow" })
    vim.api.nvim_set_hl(0, "@comment", { fg = "#ffff00" })
    vim.api.nvim_set_hl(0, "CursorLine",   { underline = true })
    vim.api.nvim_set_hl(0, "CursorLineNr", { underline = true })
--    vim.api.nvim_set_hl(0, "BlackoutFloat", { bg = "#000000", blend = 70 })
    vim.api.nvim_set_hl(0, "BlackoutFloat", { bg = "#000000" })
    vim.api.nvim_set_hl(0, "blue", { fg = "blue" })
    vim.api.nvim_set_hl(0, "green", { fg = "green" })
    vim.api.nvim_set_hl(0, "yellow", { fg = "yellow" })
    vim.api.nvim_set_hl(0, "red", { fg = "red" })

  end,
})

-- Custom annotation patterns
vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter", "BufWinEnter" }, {
  callback = function()
    vim.fn.matchadd("blue",  ".*??.*", 10)
    vim.fn.matchadd("green",      ".*##.*", 11)
    vim.fn.matchadd("yellow", ".*<<.*", 12)
    vim.fn.matchadd("red",   ".*!!.*", 13)
  end,
})
