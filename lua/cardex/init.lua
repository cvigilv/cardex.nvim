---@module "cardex"
---@author Carlos Vigil Vasquez
---@license MIT 2024

local M = {}

--- Setup `cardex.nvim`
---@param opts Cardex.Config User configuration table
M.setup = function(opts)
  local config = require("cardex.config")

  -- update defaults
  opts = config.update_config(opts)

  -- Module functionality
  require("cardex.excmd").create_excmds(opts)
  require("cardex.autocmd").setup(opts)
  require("cardex.cmp").setup(opts)
  require("cardex.highlights").setup(opts)

  _G.cardex = {}
end

return M
