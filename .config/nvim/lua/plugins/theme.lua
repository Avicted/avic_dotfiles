return {
{
    'alljokecake/naysayer-theme.nvim',
    name = 'naysayer',
    lazy = false,
    priority = 1000,
    config = function()
      require('naysayer').setup {
        variant = 'main',
        dark_variant = 'main',
        disable_background = true,
        disable_float_background = true,
        disable_italics = true,
      }
      vim.cmd.colorscheme 'naysayer'
    end,
}
}
