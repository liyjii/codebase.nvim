local pickers = require("telescope.pickers")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local finders = require("telescope.finders")
local previewers = require("telescope.previewers")
local conf = require("telescope.config").values
local scandir = require("plenary.scandir")
local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
	error("This plugin requires nvim-telescope/telescope.nvim")
end

local code = function(opts)
	opts = vim.tbl_deep_extend("keep", opts or {}, require("telescope.themes").get_ivy({}))
	local path = opts.path or vim.fn.stdpath("config") .. "/codebase"
	local file_table = scandir.scan_dir(path, { hidden = true, depth = 2 })
	local results = {}
	for _, v in pairs(file_table) do
		local filesplit = vim.split(v, "/")
		local filename = filesplit[#filesplit]
		local handle = io.open(v, "r")
		local output = {}
		if handle ~= nil then
			local txt = handle:read("*a")
			output = vim.split(txt, "\n")
			handle:close()
		end
		table.insert(results, { filename, output })
	end
	pickers
		.new(opts, {
			prompt_title = "code",
			finder = finders.new_table({
				results = results,
				entry_maker = function(entry)
					return {
						value = entry,
						display = entry[1],
						ordinal = entry[1],
					}
				end,
			}),
			attach_mappings = function(prompt_bufnr, _)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					-- print(vim.inspect(selection))
					vim.api.nvim_put(selection.value[2], "", false, true)
				end)
				return true
			end,
			sorter = conf.generic_sorter(opts),
			previewer = previewers.new_buffer_previewer({
				define_preview = function(self, entry)
					vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, entry.value[2])
				end,
			}),
		})
		:find()
end

return telescope.register_extension({
	setup = function(opts)
		return opts
	end,
	exports = { codebase = code },
})
