local M = {}

--- Apply a palette `c` as the colorscheme `name`.
--- `c.bg` is optional: when nil the background stays transparent.
function M.apply(name, c)
  vim.cmd.highlight 'clear'
  if vim.fn.exists 'syntax_on' == 1 then vim.cmd.syntax 'reset' end
  vim.o.termguicolors = true
  vim.o.background = 'dark'
  vim.g.colors_name = name

  local function hl(group, spec) vim.api.nvim_set_hl(0, group, spec) end
  local function fg(group, color, extra) hl(group, vim.tbl_extend('force', { fg = color }, extra or {})) end

  -- UI
  hl('Normal', { fg = c.fg, bg = c.bg })
  hl('NormalFloat', { fg = c.fg, bg = c.bg_float })
  hl('FloatBorder', { fg = c.border, bg = c.bg_float })
  hl('FloatTitle', { fg = c.accent, bg = c.bg_float, bold = true })
  hl('Cursor', { fg = c.cursor_fg, bg = c.accent })
  hl('CursorLine', { bg = c.bg_line })
  hl('CursorColumn', { bg = c.bg_line })
  hl('ColorColumn', { bg = c.bg_line })
  hl('LineNr', { fg = c.line_nr })
  hl('CursorLineNr', { fg = c.accent, bold = true })
  hl('SignColumn', {})
  hl('FoldColumn', { fg = c.line_nr })
  hl('Folded', { fg = c.dim, bg = c.bg_line })
  hl('VertSplit', { fg = c.border })
  hl('WinSeparator', { fg = c.border })
  hl('Visual', { bg = c.bg_sel })
  hl('Search', { fg = c.fg, bg = c.bg_search })
  hl('IncSearch', { fg = c.cursor_fg, bg = c.accent })
  hl('CurSearch', { fg = c.cursor_fg, bg = c.accent })
  hl('MatchParen', { fg = c.accent, bold = true, underline = true })
  hl('NonText', { fg = c.line_nr })
  hl('Whitespace', { fg = c.line_nr })
  hl('EndOfBuffer', { fg = c.bg or c.cursor_fg })
  hl('Directory', { fg = c.type })
  hl('Title', { fg = c.accent, bold = true })
  hl('Pmenu', { fg = c.fg, bg = c.bg_float })
  hl('PmenuSel', { fg = c.fg, bg = c.bg_sel, bold = true })
  hl('PmenuSbar', { bg = c.bg_float })
  hl('PmenuThumb', { bg = c.border })
  hl('StatusLine', { fg = c.fg, bg = c.bg_float })
  hl('StatusLineNC', { fg = c.dim, bg = c.bg_line })
  hl('TabLine', { fg = c.dim, bg = c.bg_line })
  hl('TabLineSel', { fg = c.accent, bg = c.bg_sel, bold = true })
  hl('TabLineFill', { bg = c.bg_line })
  hl('WildMenu', { fg = c.fg, bg = c.bg_sel })
  hl('ErrorMsg', { fg = c.red, bold = true })
  hl('WarningMsg', { fg = c.yellow })
  hl('MoreMsg', { fg = c.string })
  hl('ModeMsg', { fg = c.accent })
  hl('Question', { fg = c.string })
  hl('SpellBad', { undercurl = true, sp = c.red })
  hl('SpellCap', { undercurl = true, sp = c.yellow })
  hl('DiffAdd', { bg = '#0b3a2a' })
  hl('DiffChange', { bg = '#0d3340' })
  hl('DiffDelete', { bg = '#4a1f26' })
  hl('DiffText', { bg = '#165060' })
  fg('Added', c.green) fg('Changed', c.preproc) fg('Removed', c.red)

  -- Syntax
  fg('Comment', c.comment)
  fg('Constant', c.constant)
  fg('String', c.string)
  fg('Character', c.string)
  fg('Number', c.constant)
  fg('Boolean', c.constant)
  fg('Float', c.constant)
  fg('Identifier', c.fg)
  fg('Function', c.func)
  fg('Statement', c.keyword)
  fg('Conditional', c.keyword)
  fg('Repeat', c.keyword)
  fg('Label', c.keyword)
  fg('Keyword', c.keyword)
  fg('Exception', c.keyword)
  fg('Operator', c.operator)
  fg('PreProc', c.preproc)
  fg('Include', c.preproc)
  fg('Define', c.preproc)
  fg('Macro', c.preproc)
  fg('PreCondit', c.preproc)
  fg('Type', c.type)
  fg('StorageClass', c.type)
  fg('Structure', c.type)
  fg('Typedef', c.type)
  fg('Special', c.operator)
  fg('SpecialChar', c.red)
  fg('Delimiter', c.dim)
  fg('Todo', c.accent, { bold = true })
  fg('Error', c.red)
  hl('Underlined', { underline = true })

  -- Treesitter
  for group, link in pairs {
    ['@variable'] = 'Identifier', ['@variable.builtin'] = 'Special',
    ['@variable.parameter'] = 'Identifier', ['@variable.member'] = 'Identifier',
    ['@property'] = 'Identifier', ['@module'] = 'Include',
    ['@constant'] = 'Constant', ['@constant.builtin'] = 'Constant', ['@constant.macro'] = 'Macro',
    ['@string.escape'] = 'SpecialChar', ['@function.builtin'] = 'Function',
    ['@constructor'] = 'Type', ['@type.builtin'] = 'Type', ['@attribute'] = 'PreProc',
    ['@punctuation'] = 'Delimiter', ['@punctuation.bracket'] = 'Delimiter',
    ['@punctuation.delimiter'] = 'Delimiter', ['@tag'] = 'Keyword',
    ['@tag.attribute'] = 'Identifier', ['@tag.delimiter'] = 'Delimiter',
  } do hl(group, { link = link }) end

  -- Diagnostics
  for kind, color in pairs { Error = c.red, Warn = c.yellow, Info = c.preproc, Hint = c.type, Ok = c.green } do
    fg('Diagnostic' .. kind, color)
    hl('DiagnosticUnderline' .. kind, { undercurl = true, sp = color })
    fg('DiagnosticVirtualText' .. kind, color)
  end

  -- Plugins
  fg('GitSignsAdd', c.green) fg('GitSignsChange', c.preproc) fg('GitSignsDelete', c.red)
  hl('NvimTreeNormal', { fg = c.fg })
  fg('NvimTreeFolderName', c.type) fg('NvimTreeOpenedFolderName', c.type, { bold = true })
  fg('NvimTreeRootFolder', c.accent, { bold = true })
  hl('TelescopeNormal', { fg = c.fg, bg = c.bg_float })
  hl('TelescopeBorder', { fg = c.border, bg = c.bg_float })
  hl('TelescopeSelection', { bg = c.bg_sel, bold = true })
  fg('TelescopeMatching', c.accent, { bold = true })
  fg('CmpItemAbbrMatch', c.accent, { bold = true })
  fg('CmpItemAbbrMatchFuzzy', c.accent)
  fg('CmpItemKind', c.type)
end

return M
