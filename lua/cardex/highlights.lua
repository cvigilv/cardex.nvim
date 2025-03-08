---@module "cardex.highlights"
---@author Carlos Vigil-Vásquez
---@license MIT 2025

local M = {}

M.setup = function(opts)
  print(opts.path .. "*.md")
  vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = opts.path .. "*.md",
    callback = function()
      print("[cardex.nvim] Added contact highlights")
      vim.fn.clearmatches()
      vim.fn.matchadd("@cardex.contact", [[@[A-Z][a-z]\+\([A-Z][a-z]\+\)*]])
      vim.api.nvim_set_hl(0, "@cardex.contact", { link = "Constant" })
    end,
  })
end

return M
