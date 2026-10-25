-- acario-light: a port of doom-acario-light from doom-themes (Emacs).
vim.cmd("highlight clear")
vim.o.background = "light"
vim.g.colors_name = "acario-light"

local c = {
  bg = "#F5F5F9",
  bg_alt = "#E9E9F2",
  base0 = "#D0D0E3",
  base2 = "#C0CCD0",
  base3 = "#9EA6B0",
  base4 = "#585C6C",
  base5 = "#4E4E4E",
  base8 = "#1E1E33",
  fg = "#0F1019",
  red = "#D70000",
  green = "#005F00",
  yellow = "#AF8700",
  blue = "#1F55A0",
  magenta = "#AF005F",
  cyan = "#007687",
  orange = "#D75F00",
  teal = "#009B7C",
  violet = "#8700AF",
  bg_blue = "#DEEAF8",
  bg_cyan = "#D5FAFF",
  variables = "#004751", -- cyan darkened 40%, as in the Emacs theme
  modeline_inactive = "#BABAC2",
  add_bg = "#DCEFDC",
  change_bg = "#F3ECD4",
  delete_bg = "#F7DADA",
}

local hl = function(group, spec)
  vim.api.nvim_set_hl(0, group, spec)
end

-- editor
hl("Normal", { fg = c.fg, bg = c.bg })
hl("NormalNC", { link = "Normal" })
hl("NormalFloat", { fg = c.fg, bg = c.bg_alt })
hl("FloatBorder", { fg = c.base3, bg = c.bg_alt })
hl("FloatTitle", { fg = c.blue, bg = c.bg_alt, bold = true })
hl("Cursor", { fg = c.bg, bg = c.fg })
hl("CursorLine", { bg = c.bg_alt })
hl("CursorColumn", { bg = c.bg_alt })
hl("ColorColumn", { bg = c.bg_alt })
hl("LineNr", { fg = c.base4 })
hl("CursorLineNr", { fg = c.orange, bold = true })
hl("SignColumn", { bg = c.bg })
hl("FoldColumn", { fg = c.base3, bg = c.bg })
hl("Folded", { fg = c.base5, bg = c.bg_alt })
hl("WinSeparator", { fg = c.base0 })
hl("VertSplit", { link = "WinSeparator" })
hl("EndOfBuffer", { fg = c.bg })
hl("NonText", { fg = c.base3 })
hl("Whitespace", { fg = c.base0 })
hl("SpecialKey", { fg = c.base3 })
hl("Visual", { bg = c.base2 })
hl("Search", { bg = c.bg_blue, fg = c.fg })
hl("CurSearch", { bg = c.teal, fg = c.bg, bold = true })
hl("IncSearch", { link = "CurSearch" })
hl("Substitute", { bg = c.orange, fg = c.bg })
hl("MatchParen", { bg = c.base2, bold = true })
hl("StatusLine", { fg = c.fg, bg = c.base3 })
hl("StatusLineNC", { fg = c.base5, bg = c.modeline_inactive })
hl("TabLine", { fg = c.base5, bg = c.bg_alt })
hl("TabLineFill", { bg = c.bg_alt })
hl("TabLineSel", { fg = c.fg, bg = c.base3, bold = true })
hl("WinBar", { fg = c.fg, bold = true })
hl("WinBarNC", { fg = c.base5 })
hl("Pmenu", { fg = c.fg, bg = c.bg_alt })
hl("PmenuSel", { bg = c.bg_blue, bold = true })
hl("PmenuSbar", { bg = c.base0 })
hl("PmenuThumb", { bg = c.base3 })
hl("PmenuKind", { fg = c.blue, bg = c.bg_alt })
hl("PmenuExtra", { fg = c.base5, bg = c.bg_alt })
hl("WildMenu", { link = "PmenuSel" })
hl("Directory", { fg = c.blue, bold = true })
hl("Title", { fg = c.blue, bold = true })
hl("Question", { fg = c.green })
hl("MoreMsg", { fg = c.green })
hl("ModeMsg", { fg = c.fg, bold = true })
hl("ErrorMsg", { fg = c.red, bold = true })
hl("WarningMsg", { fg = c.orange })
hl("QuickFixLine", { bg = c.bg_blue })
hl("SpellBad", { undercurl = true, sp = c.red })
hl("SpellCap", { undercurl = true, sp = c.orange })
hl("SpellRare", { undercurl = true, sp = c.violet })
hl("SpellLocal", { undercurl = true, sp = c.cyan })

-- syntax (face categories from the Emacs theme)
hl("Comment", { fg = c.base5, italic = true })
hl("Constant", { fg = c.magenta })
hl("String", { fg = c.green })
hl("Character", { fg = c.green })
hl("Number", { fg = c.orange })
hl("Boolean", { fg = c.magenta })
hl("Float", { fg = c.orange })
hl("Identifier", { fg = c.variables })
hl("Function", { fg = c.yellow })
hl("Statement", { fg = c.red })
hl("Keyword", { fg = c.red })
hl("Conditional", { fg = c.red })
hl("Repeat", { fg = c.red })
hl("Label", { fg = c.red })
hl("Exception", { fg = c.red })
hl("Operator", { fg = c.blue })
hl("PreProc", { fg = c.blue })
hl("Include", { fg = c.red })
hl("Type", { fg = c.blue })
hl("Special", { fg = c.cyan })
hl("Delimiter", { fg = c.fg })
hl("Todo", { fg = c.bg, bg = c.yellow, bold = true })
hl("Error", { fg = c.red })
hl("Underlined", { underline = true })

-- treesitter
hl("@variable", { fg = c.variables })
hl("@variable.builtin", { fg = c.blue })
hl("@variable.parameter", { fg = c.variables })
hl("@variable.member", { fg = c.variables })
hl("@property", { fg = c.variables })
hl("@constant.builtin", { fg = c.magenta })
hl("@function.builtin", { fg = c.blue })
hl("@function.method", { fg = c.cyan })
hl("@function.method.call", { fg = c.cyan })
hl("@constructor", { fg = c.blue })
hl("@type.builtin", { fg = c.blue })
hl("@module", { fg = c.fg })
hl("@punctuation", { fg = c.fg })
hl("@tag", { fg = c.red })
hl("@tag.attribute", { fg = c.yellow })
hl("@comment.documentation", { fg = "#004700", italic = true })
hl("@markup.heading", { fg = c.blue, bold = true })
hl("@markup.link", { fg = c.cyan, underline = true })
hl("@markup.raw", { fg = c.magenta })
hl("@markup.strong", { bold = true })
hl("@markup.italic", { italic = true })
hl("@lsp.type.variable", {})

-- diagnostics / diff / git
hl("DiagnosticError", { fg = c.red })
hl("DiagnosticWarn", { fg = c.orange })
hl("DiagnosticInfo", { fg = c.blue })
hl("DiagnosticHint", { fg = c.teal })
hl("DiagnosticOk", { fg = c.green })
hl("DiagnosticUnderlineError", { undercurl = true, sp = c.red })
hl("DiagnosticUnderlineWarn", { undercurl = true, sp = c.orange })
hl("DiagnosticUnderlineInfo", { undercurl = true, sp = c.blue })
hl("DiagnosticUnderlineHint", { undercurl = true, sp = c.teal })
hl("DiffAdd", { bg = c.add_bg })
hl("DiffChange", { bg = c.change_bg })
hl("DiffDelete", { fg = c.red, bg = c.delete_bg })
hl("DiffText", { bg = c.bg_blue, bold = true })
hl("Added", { fg = c.green })
hl("Changed", { fg = c.yellow })
hl("Removed", { fg = c.red })
hl("LspReferenceText", { bg = c.bg_alt })
hl("LspReferenceRead", { bg = c.bg_alt })
hl("LspReferenceWrite", { bg = c.bg_alt })
hl("LspInlayHint", { fg = c.base3, italic = true })

-- plugins
hl("TelescopeSelection", { bg = c.bg_blue, bold = true })
hl("TelescopeMatching", { fg = c.teal, bold = true })
hl("TelescopeBorder", { link = "FloatBorder" })
hl("WhichKey", { fg = c.blue })
hl("WhichKeyGroup", { fg = c.magenta })
hl("WhichKeyDesc", { fg = c.fg })
hl("FlashLabel", { fg = c.bg, bg = c.magenta, bold = true })
hl("NvimTreeNormal", { fg = c.fg, bg = c.bg })
hl("NvimTreeFolderName", { fg = c.blue })
hl("NvimTreeOpenedFolderName", { fg = c.blue, bold = true })
hl("NvimTreeRootFolder", { fg = c.green, bold = true })
hl("MiniStarterHeader", { fg = c.blue })
hl("MiniStarterSection", { fg = c.magenta, bold = true })
hl("MiniStarterItem", { fg = c.fg })
hl("MiniStarterItemPrefix", { fg = c.orange })
hl("MiniStarterQuery", { fg = c.teal, bold = true })

-- :terminal palette
local term = {
  c.fg,
  c.red,
  c.green,
  c.yellow,
  c.blue,
  c.magenta,
  c.cyan,
  c.base2,
  c.base5,
  c.orange,
  c.teal,
  c.yellow,
  c.blue,
  c.violet,
  c.cyan,
  c.base0,
}
for i, color in ipairs(term) do
  vim.g["terminal_color_" .. (i - 1)] = color
end
