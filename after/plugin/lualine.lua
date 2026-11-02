local transparent = { bg = 'none', fg = '#686f9a' }
local active = {
  a = { bg = 'none', fg = '#686f9a', gui = 'bold' },
  b = transparent,
  c = transparent,
}

require('lualine').setup{
  options = {
    icons_enabled = true,
    theme = {
      normal = active,
      insert = active,
      visual = active,
      replace = active,
      command = active,
      inactive = active,
    },
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
  },
}
