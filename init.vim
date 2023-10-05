"" Import Lua modules

if exists('g:vscode')
  " VSCode extension
  lua require('packer_init')
else
  " ordinary Neovim
  lua require('packer_init')
  lua require('core/options')
  lua require('core/keymaps')
  lua require('core/autocmds')
  lua require('core/colors')
  lua require('core/statusline')
  lua require('plugins/nvim-tree')
  lua require('plugins/alpha-nvim')
  "lua require('plugins/nvim-ts-lspconfig')
  "lua require('plugins/indent-blankline')
  "lua require('plugins/nvim-cmp')
  "lua require('plugins/nvim-common-lspconfig')
  lua require('plugins/nvim-metals')
  "lua require('plugins/nvim-cellular-automaton')
  "lua require('plugins/nvim-treesitter')
endif
