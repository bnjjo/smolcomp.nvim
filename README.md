# smolcomp.nvim

## about & acknowledgements
this is a small plugin meant to mimic 'compile mode' from emacs. it is inspired by [compile-mode.nvim](https://github.com/ej-shafran/compile-mode.nvim), but intentionally smaller with zero dependencies.

## usage
`<leader>cp` triggers the compile mode prompt, enter your command and press `<CR>`.

## installation

### vim.pack (neovim 0.12+)
```lua
vim.pack.add({ "https://github.com/bnjjo/smolcomp.nvim" })
```
### lazy.nvim
```lua
{
  "bnjjo/smolcomp.nvim"
}
```
