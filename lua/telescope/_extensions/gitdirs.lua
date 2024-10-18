local telescope = require 'telescope'
local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local conf = require('telescope.config').values

local function search_git_dirs(opts)
    opts = opts or {}

    local search_dirs = {}
    for i, d in ipairs(opts.search_dirs or { '~' }) do
        search_dirs[i] = vim.fn.expand(d)
    end

    local exclude_dirs = {}
    for i, d in ipairs(opts.exclude_dirs or { 'build', 'cmake-*' }) do
        exclude_dirs[i] = '-E ' .. d
    end

    local fd = { 'fd --case-sensitive --ignore-vcs --hidden --prune' }

    table.insert(fd, exclude_dirs)
    table.insert(fd, { '--glob .git' })
    table.insert(fd, search_dirs)
    local fd_command = vim.iter(fd):flatten():join ' '

    print(fd_command)

    local results = vim.fn.systemlist(fd_command) or {}
    for i, result in ipairs(results) do
        results[i] = result:gsub('%.git[\\/]$', '')
    end

    pickers
        .new(opts, {
            prompt_title = 'Git Directories',
            finder = finders.new_table {
                results = results,
            },
            sorter = conf.generic_sorter(opts),
        })
        :find()
end

return telescope.register_extension {
    exports = {
        gitdirs = search_git_dirs,
    },
}
