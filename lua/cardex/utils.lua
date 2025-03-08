---@module "cardex.utils"
---@author Carlos Vigil Vásquez
---@license MIT 2024

local read_n_lines = function(path, n)
  n = n or 10
  local ok, contents = pcall(vim.fn.readfile, path, "", n)
  if ok and contents ~= nil then
    return contents
  end
  return nil
end

local M = {}

---Extracts tags from a given note file.
---@param note string|nil Path to the note file
---@return string|nil title Title of note file
M.get_title = function(note)
  -- Read file content
  local contents
  if note ~= nil then
    contents = read_n_lines(note, 3)
  else
    contents = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  end

  if contents ~= nil then
    -- Search title in each line
    for _, line in ipairs(contents) do
      if line ~= "" and string.find(line, "^# ") ~= nil then
        local title = line:gsub("^# ", "")
        return title
      end
    end
  end

  return "Untitled"
end

---Extracts titles from a list of notes files.
---@param opts Cardex.Config User config
---@return table tags Tags extracted from files, organized by file path
M.get_all_titles = function(opts)
  -- Get all notes in zettelkasten
  local all_notes = vim.split(vim.fn.glob(opts.path .. "*.md"), "\n", { trimempty = true })

  -- Get tags for each note in zettelaksten
  local all_notes_titles = {}
  for _, note in ipairs(all_notes) do
    all_notes_titles[note] = M.get_title(note)
  end

  return all_notes_titles
end

---Extracts tags from a given note file.
---@param note string Path to the note file
---@return table tags List of extracted tags
M.get_tags = function(note)
  -- Initialize empty tag collector
  local tags = {}

  -- Read file content
  local content = read_n_lines(note, 5)

  -- Search tags in each line
  if content ~= nil then
    for _, line in ipairs(content) do
      for tag in line:gmatch("#%w+[/%w+]*") do -- NOTE: this pattern extract #tag/subtag tags
        table.insert(tags, tag)
      end
    end
  end

  return tags
end

---Extracts tags from a list of notes files.
---@param opts Cardex.Config User config
---@return table tags Tags extracted from files, organized by file path
M.get_all_tags = function(opts)
  -- Get all notes in zettelkasten
  local all_notes = vim.split(vim.fn.glob(opts.path .. "*.md"), "\n", { trimempty = true })

  -- Get tags for each note in zettelaksten
  local all_note_tags = {}
  for _, note in ipairs(all_notes) do
    all_note_tags[note] = M.get_tags(note)
  end

  return all_note_tags
end

---Determines the type of a note based on its content.
---@param note string Path to the note file
---@return string|nil type The type of the note ("Journal", "Idea", "Reference", "Map-of-Contents") or nil if no type is found
M.get_type = function(note)
  -- Read file's first 10 lines
  local content = read_n_lines(note, 5)

  -- Search tags in each line
  if content ~= nil then
    for _, line in ipairs(content) do
      if line:find("#journal") then
        return "Journal"
      elseif line:find("#idea") then
        return "Idea"
      elseif line:find("#reference") then
        return "Reference"
      elseif line:find("#moc") then
        return "Map-of-Contents"
      end
    end
  end
  return "Invalid type"
end

---Extracts type of all notes in zettelkasten.
---@param opts Cardex.Config User config
---@return table all_note_types Types extracted from files, organized by file path
M.get_all_types = function(opts)
  -- Get all notes in zettelkasten
  local all_notes = vim.split(vim.fn.glob(opts.path .. "*.md"), "\n", { trimempty = true })

  -- Get type for each note in zettelaksten
  local all_note_types = {}
  for _, note in ipairs(all_notes) do
    if not all_note_types[note] then
      all_note_types[note] = {}
    end
    table.insert(all_note_types[note], M.get_type(note))
  end

  return all_note_types
end

M.get_metadata = function(note)
  return {
    path = note,
    title = M.get_title(note),
    type = M.get_type(note),
    tags = M.get_tags(note),
  }
end

M.get_all_metadatas = function(opts)
  -- Get all notes in zettelkasten
  local all_notes = vim.split(vim.fn.glob(opts.path .. "*.md"), "\n", { trimempty = true })

  -- Get type for each note in zettelaksten
  local all_notes_metadata = {}
  for _, note in ipairs(all_notes) do
    all_notes_metadata[note] = M.get_metadata(note)
  end

  return all_notes_metadata
end

---Get "to" links for a given note in a Zettelkasten system.
---@param note string The path of the note to find "to" links for
---@return table to_links Array of note paths that link to the given note
---@see M.get_from_links
M.get_to_links = function(note, opts)
  -- Read file content
  local content = vim.fn.readfile(note)

  -- Get "to"/foward links in note
  local to_links = {}
  if content ~= nil then
    for _, line in ipairs(content) do
      for match in line:gmatch("%[.-%]%((.-%.md)%)") do
        table.insert(to_links, vim.fn.resolve(opts.path .. match))
      end
    end
  end

  return to_links
end

---Get "from" links for a given note in a Zettelkasten system.
---@param note string The path of the note to find "from" links for
---@param opts Cardex.Config User config
---@return table from_links Array of note paths that link to the given note
---@see M.get_to_links
M.get_from_links = function(note, opts)
  -- Get all notes in zettelkasten
  local all_notes = vim.split(vim.fn.glob(opts.path .. "*.md"), "\n", { trimempty = true })

  -- Get "from" links from "to" links for each note in Zettelaksten
  local from_links = {}
  for _, n in ipairs(all_notes) do
    local links = M.get_to_links(n, opts)
    for _, l in ipairs(links) do
      if l == note then
        table.insert(from_links, n)
      end
    end
  end

  return from_links
end

---Retrieves all links associated with a note.
---@param note string The path of the note to find links for
---@param opts Cardex.Config User config
---@return table links A table containing 'from' and 'to' links
---@see M.get_from_links
---@see M.get_to_links
M.get_links = function(note, opts)
  return {
    from = M.get_from_links(note, opts),
    to = M.get_to_links(note, opts),
  }
end

M.get_all_links = function(opts)
  -- Get all notes in zettelkasten
  local all_notes = vim.split(vim.fn.glob(opts.path .. "*.md"), "\n", { trimempty = true })

  -- Get "from" and "to" links for each note in zettelaksten
  local all_notes_links = {}
  for _, note in ipairs(all_notes) do
    all_notes_links[note] = M.get_links(note, opts)
  end

  return all_notes_links
end

return M
