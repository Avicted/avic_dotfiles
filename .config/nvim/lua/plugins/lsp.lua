return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "gopls",
          "clangd",
          "pyright",
          "ts_ls",
          "lua_ls",
          "bashls",
        },
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    config = function()

      vim.lsp.enable("gopls")
      vim.lsp.enable("clangd")
      vim.lsp.enable("pyright")
      vim.lsp.enable("ts_ls")
      vim.lsp.enable("lua_ls")
      vim.lsp.enable("bashls")

    end,
  },
}
