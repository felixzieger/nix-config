-- Activate lualine
vim.g.gitblame_display_virtual_text = 0 -- Disable virtual text
vim.g.gitblame_date_format = '%r'

-- Defer lualine and git-blame loading by 50ms after VimEnter
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        vim.defer_fn(function()
            local git_blame = require('gitblame')
            
            require('lualine').setup({
                options = {
                    theme = 'powerline'
                },
                sections = {
                    lualine_c = {
                        { git_blame.get_current_blame_text, cond = git_blame.is_blame_text_available }
                    },
                    lualine_x = { 'filename' },
                },
            })
        end, 50)
    end
})
