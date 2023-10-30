local has_telescope, _ = pcall(require, "telescope")
if not has_telescope then
    error("This plugin requires nvim-telescope/telescope.nvim")
end

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local sorters = require("telescope.sorters")
local conf = require("telescope.config").values
local make_entry = require("telescope.make_entry")

local flatten = vim.tbl_flatten

local es_config = {
    es_path = "es",
    regex = true,
    max_results = 100,
}

local function es_setup(ext_config)
    for k, v in pairs(ext_config) do
        es_config[k] = v
    end
end

local function SplitStr(szStrConcat, szSep)
	if (not szSep) then
		szSep = ",";
	end;

	local tbStrElem = {};
	if not szStrConcat or szStrConcat == "" then
		return tbStrElem;
	end

	--特殊转义字符指定长度
	local tbSpeSep = {
		["%."] = 1;
		["%$"] = 1;
	};

	local nSepLen = tbSpeSep[szSep] or #szSep;
	local nStart = 1;
	local nAt = string.find(szStrConcat, szSep);
	while nAt do
		local szStr = string.sub(szStrConcat, nStart, nAt - 1);
		tbStrElem[#tbStrElem+1] = szStr;
		nStart = nAt + nSepLen;
		nAt = string.find(szStrConcat, szSep, nStart);
	end
	local szStr = string.sub(szStrConcat, nStart);
	tbStrElem[#tbStrElem+1] = szStr;
	return tbStrElem;
end

local run = function(opts)
    opts = vim.tbl_deep_extend("force", es_config, opts or {})
	local cwd = vim.loop.cwd()
    local command_params = {}
	if opts.current_dir then
		table.insert(command_params, cwd);
	end

    if opts.case_sensitive then
        table.insert(command_params, "-case")
    end
    if opts.whole_word then
        table.insert(command_params, "-whole-word")
    end
    if opts.match_path then
        table.insert(command_params, "-match-path")
    end
    if opts.sort then
        table.insert(command_params, "-s")
    end
    if opts.offset then
        table.insert(command_params, "-offset")
        table.insert(command_params, tostring(opts.offset))
    end
    if opts.max_results then
        table.insert(command_params, "-max-results")
        table.insert(command_params, tostring(opts.max_results))
    end
    -- make sure regex is the last parameters
    if opts.regex then
        table.insert(command_params, "-regex")
    end

    pickers
        .new(opts, {
            prompt_title = "Everything:" .. cwd,
            finder = finders.new_job(function(prompt)
                if not prompt or prompt == "" then
                    return nil
                end

                local tbInfo = SplitStr(prompt, " ");
                return flatten({ opts.es_path, command_params, tbInfo })
            end, opts.entry_maker or make_entry.gen_from_file(opts)),
            previewer = conf.file_previewer(opts),
            sorter = sorters.highlighter_only(opts),
        })
        :find()
end

return require("telescope").register_extension({
    setup = es_setup,
    exports = {
        es = run,
    },
})
