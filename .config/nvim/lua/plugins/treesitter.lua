return {{
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,

    config = function()
        local treesitter = require("nvim-treesitter")
        local languages = {"c", "cpp", "go", "lua", "python", "typescript", "bash", "c_sharp"}

        treesitter.setup({})
        treesitter.install(languages)

        local group = vim.api.nvim_create_augroup("treesitter-config", {
            clear = true
        })

        vim.api.nvim_create_autocmd("FileType", {
            group = group,
            callback = function(args)
                if pcall(vim.treesitter.start, args.buf) then
                    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end
            end
        })
    end
}}
