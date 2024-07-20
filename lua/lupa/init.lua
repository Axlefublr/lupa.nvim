local m = {}

-- This plugin doesn't just use \V to make the `/` register useful to just paste in.
-- If I used \V, then any time you search for something with this plugin, the `/` register becomes kinda useless

--- Escape a string to make it a valid search pattern (with default magic set)
---@param str string
---@return string
function m.escape_for_search(str) return vim.fn.escape(str, '\\/.*[]~^$') end

-- The following mechanism is used to allow search offsets.
-- Which wouldn't work with the alternative solution of filling the `/` register with the pattern and `vim.cmd.normal`ing `n`

--- The plugin's mechanism for searching.
--- Lets you "feed" keys into neovim, to queue them up to be executed as if the user pressed them.
--- Does *not* consider user remappings.
---@param keys string
function m.feedkeys(keys) vim.api.nvim_feedkeys(keys, 'n', false) end

--- Same as `feedkeys`, but interprets special codes.
--- For example, `<CR>` will be interpreted as the Enter key.
---@param keys string
function m.feedkeys_int(keys)
	local feedable_keys = vim.api.nvim_replace_termcodes(keys, true, false, true)
	vim.api.nvim_feedkeys(feedable_keys, 'n', true)
end

---@param backwards boolean?
---@return string
local function get_searcher_key(backwards)
	return backwards and '?' or '/'
end

---@param search_offset string?
---@param searcher string
local function get_search_offset(search_offset, searcher)
	return search_offset and (searcher .. search_offset) or ''
end

---@return string
local function get_actual_default_register()
	if vim.go.clipboard == 'unnamedplus' or vim.go.clipboard == 'unnamedplus,unnamed' then
		return '+'
	elseif vim.go.clipboard == 'unnamed' or vim.go.clipboard == 'unnamed,unnamedplus' then
		return '*'
	else
		return '"'
	end
end

--- Make a search for the contents of a vim register.
---@param register string
---@param backwards boolean?
---@param search_offset string? without the leading / or ?
---@param edit boolean? don't *make* the search, let the user edit it first (by not sending enter)
---@param not_inside boolean? don't match the pattern if it's inside another word (by prepending \< to the search pattern and appending it with \>)
---@param opts table containing any of the parameters specified above.
function m.register(register, opts)
	opts = opts or {}
	local register = vim.fn.getreg(register)
	local pattern = m.escape_for_search(register)
	if opts.not_inside then pattern = '\\<' .. pattern .. '\\>' end
	local searcher = get_searcher_key(opts.backwards)
	local search_offset = get_search_offset(opts.search_offset, searcher)
	m.feedkeys(searcher .. pattern .. search_offset)
	if not opts.edit then m.feedkeys_int('<CR>') end
end

--- Make a search for your visual selection.
--- Expects you to be in visual mode
---@param backwards boolean?
---@param search_offset string? without the leading / or ?
---@param edit boolean? don't *make* the search, let the user edit it first (by not sending enter)
---@param not_inside boolean? don't match the pattern if it's inside another word (by prepending \< to the search pattern and appending it with \>)
---@param opts table containing any of the parameters specified above.
function m.selection(opts)
	opts = opts or {}
	local actual_default_register = get_actual_default_register()
	local previous_default_register_contents = vim.fn.getreg(actual_default_register)
	local previous_yanked_register_contents = vim.fn.getreg('0')
	m.feedkeys('y')
	vim.schedule(function()
		local yanked = vim.fn.getreg('0')
		vim.fn.setreg(actual_default_register, previous_default_register_contents)
		vim.fn.setreg('0', previous_yanked_register_contents)
		local pattern = m.escape_for_search(yanked)
		if opts.not_inside then pattern = '\\<' .. pattern .. '\\>' end
		local searcher = get_searcher_key(opts.backwards)
		local search_offset = get_search_offset(opts.search_offset, searcher)
		m.feedkeys(searcher .. pattern .. search_offset)
		if not opts.edit then m.feedkeys_int('<CR>') end
	end)
end

--- Make a search for the word closest to your cursor.
---@param backwards boolean?
---@param search_offset string? without the leading / or ?
---@param edit boolean? don't *make* the search, let the user edit it first (by not sending enter)
---@param not_inside boolean? don't match the pattern if it's inside another word (by prepending \< to the search pattern and appending it with \>)
---@param opts table containing any of the parameters specified above.
function m.word(opts)
	opts = opts or {}
	local searcher = get_searcher_key(opts.backwards)
	local search_offset = get_search_offset(opts.search_offset, searcher)
	m.feedkeys(searcher)
	if opts.not_inside then m.feedkeys('\\<') end
	m.feedkeys_int('<C-r><C-w>')
	if opts.not_inside then m.feedkeys('\\>') end
	m.feedkeys(search_offset)
	if not opts.edit then m.feedkeys_int('<CR>') end
end

return m
