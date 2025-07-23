-- Lazy load multicursor to avoid startup time impact
local multicursor_loaded = false
local mc = nil

local function setup_multicursor()
    if multicursor_loaded then
        return mc
    end
    multicursor_loaded = true

    mc = require("multicursor-nvim")
    mc.setup()

    -- Mappings that only apply when there are multiple cursors
    mc.addKeymapLayer(function(layerSet)
        -- Select a different cursor as the main one
        layerSet({ "n", "x" }, "<left>", mc.prevCursor)
        layerSet({ "n", "x" }, "<right>", mc.nextCursor)

        -- Delete the main cursor
        layerSet({ "n", "x" }, "<leader>x", mc.deleteCursor)

        -- Enable and clear cursors using escape
        layerSet("n", "<esc>", function()
            if not mc.cursorsEnabled() then
                mc.enableCursors()
            else
                mc.clearCursors()
            end
        end)
    end)

    -- Customize how cursors look
    local hl = vim.api.nvim_set_hl
    hl(0, "MultiCursorCursor", { reverse = true })
    hl(0, "MultiCursorVisual", { link = "Visual" })
    hl(0, "MultiCursorSign", { link = "SignColumn" })
    hl(0, "MultiCursorDisabledCursor", { reverse = true })
    hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
    hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })

    return mc
end

local set = vim.keymap.set

-- Add or skip cursor above/below the main cursor
set({ "n", "x" }, "<up>", function() setup_multicursor().lineAddCursor(-1) end)
set({ "n", "x" }, "<down>", function() setup_multicursor().lineAddCursor(1) end)
set({ "n", "x" }, "<leader><up>", function() setup_multicursor().lineSkipCursor(-1) end)
set({ "n", "x" }, "<leader><down>", function() setup_multicursor().lineSkipCursor(1) end)

-- Add or skip adding a new cursor by matching word/selection
set({ "n", "x" }, "<leader>m", function() setup_multicursor().matchAddCursor(1) end)
set({ "n", "x" }, "<leader>M", function() setup_multicursor().matchAddCursor(-1) end)
set({ "n", "x" }, "<leader>ms", function() setup_multicursor().matchSkipCursor(1) end)
set({ "n", "x" }, "<leader>mS", function() setup_multicursor().matchSkipCursor(-1) end)

-- Add and remove cursors with control + left click
set("n", "<c-leftmouse>", function() setup_multicursor().handleMouse() end)
set("n", "<c-leftdrag>", function() setup_multicursor().handleMouseDrag() end)
set("n", "<c-leftrelease>", function() setup_multicursor().handleMouseRelease() end)

-- Disable and enable cursors
set({ "n", "x" }, "<c-q>", function() setup_multicursor().toggleCursor() end)

-- Add a cursor for all matches of cursor word/selection in the document
set({ "n", "x" }, "<leader>A", function() setup_multicursor().matchAllAddCursors() end)

