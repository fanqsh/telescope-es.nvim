local sorters = require "telescope.sorters"
local pickers = require "telescope.pickers"
local conf = require("telescope.config").values

local Path = require "plenary.path"
local os_sep = Path.path.sep

local function picker(opts)
	opts = opts or {};

	local cwd = vim.loop.cwd()

	print(cwd);

	local find_command = {"es.exe", cwd, opts.search_file};

	local p = pickers.new(opts, {
			prompt_title = "find file by everything",
			finder = finders.new_oneshot_job(find_command, opts),
			previewer = conf.file_previewer(opts),
			sorter = conf.file_sorter(opts),
		});

	p:find();
end

assert (false);

return require("telescope").register_extension {
  setup = function(ext_config, config)
  end,

  exports = {
    find_files_by_es = picker,
  },
  health = function()
    local health = vim.health or require "health"
    local ok = health.ok or health.report_ok

	ok "lib working as expected"
  end,
}
