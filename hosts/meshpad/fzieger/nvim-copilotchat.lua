require('CopilotChat').setup {
    {
        window = {
            layout = 'float',
            relative = 'cursor',
            width = 1,
            height = 0.4,
            row = 1
        }
    },
}

-- AI shortcuts start with <leader>a
-- vim.api.nvim_set_keymap('n', '<Leader>a', ':CopilotChatToggle<CR>', { noremap = true }) -- toggle
vim.api.nvim_set_keymap('v', '<Leader>ae', ':CopilotChatExplain<CR>', { noremap = true })  -- explain
vim.api.nvim_set_keymap('v', '<Leader>af', ':CopilotChatFix<CR>', { noremap = true })      -- fix
vim.api.nvim_set_keymap('v', '<Leader>ao', ':CopilotChatOptimize<CR>', { noremap = true }) -- optimize
vim.api.nvim_set_keymap('v', '<Leader>ad', ':CopilotChateDocs<CR>', { noremap = true })    -- docs
vim.api.nvim_set_keymap('v', '<Leader>at', ':CopilotChatTests<CR>', { noremap = true })    -- tests


-- Quick chat
vim.api.nvim_set_keymap('n', '<leader>aa', [[:lua QuickChat()<CR>]], { noremap = true, silent = true })
function QuickChat()
    local input = vim.fn.input('Quick Chat: ')
    if input ~= '' then
        require('CopilotChat').ask(input, { selection = require('CopilotChat.select').buffer })
    end
end
