vim.g.mapleader = " "

vim.keymap.set("n", "<C-s>", "<cmd>w<cr>")
vim.keymap.set("n", "<C-q>", "<cmd>q<cr>")

vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>")
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>")
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>")

local function dap_action(method)
    return function()
        local ok, dap = pcall(require, "dap")
        if not ok then
            vim.notify("nvim-dap is not installed yet", vim.log.levels.WARN)
            return
        end

        dap[method]()
    end
end

vim.keymap.set("n", "<F5>", dap_action("continue"))
vim.keymap.set("n", "<F9>", dap_action("toggle_breakpoint"))
vim.keymap.set("n", "<F10>", dap_action("step_over"))
vim.keymap.set("n", "<F11>", dap_action("step_into"))
vim.keymap.set("n", "<F12>", dap_action("step_out"))
