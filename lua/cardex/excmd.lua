---@module "cardex.excmd"
---@author Carlos Vigil Vásquez
---@license MIT 2024

local factory = require("cardex.factory")
local finders = require("cardex.finders")
local ui = require("cardex.ui")

local M = {}

---Creates user commands for managing Zettelkasten notes in Neovim.
---@param opts Cardex.Config User configuration
M.create_excmds = function(opts)
  -- Notes creation
  vim.api.nvim_create_user_command("CardexNewNote", function()
    factory.create_new_note(opts)
  end, { desc = "Create a new daily note" })

  -- Note searching
  vim.api.nvim_create_user_command("CardexSearchNotes", function()
    finders.search_headings(opts)
  end, { desc = "Search notes by heading" })

  vim.api.nvim_create_user_command("CardexSearchTags", function()
    finders.search_tags(opts)
  end, { desc = "Search notes by heading" })

  -- UI
  vim.api.nvim_create_user_command(
    "CardexLinks",
    -- TODO: Check if window is open to decide wheter opening it or focusing onto it
    function()
      ui.show_links(nil, opts)
    end,
    { desc = "Show links to file." }
  )
end

return M
