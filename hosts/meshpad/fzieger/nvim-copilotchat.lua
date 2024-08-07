require('CopilotChat').setup {
    window = {
        layout = 'vertical',
    }
}

-- AI shortcuts start with <leader>a
vim.api.nvim_set_keymap('v', '<Leader>aa', ':CopilotChat ', { noremap = true })

-- Quick chat
vim.api.nvim_set_keymap('n', '<leader>aa', [[:lua QuickChat()<CR>]], { noremap = true, silent = true })
function QuickChat()
    local input = vim.fn.input('Quick Chat: ')
    if input ~= '' then
        require('CopilotChat').ask(input, { selection = require('CopilotChat.select').buffer })
    end
end
