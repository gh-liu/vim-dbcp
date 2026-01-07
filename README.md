# vim-dbcp

**D**ata**b**ase **C**ompletion **P**rovider for Vim/Neovim.

Completion framework for database queries, works with [vim-dadbod](https://github.com/tpope/vim-dadbod).

## Supported

- **MongoDB** - collection names + collection methods

## Requirements

- Vim 8.0+ or Neovim 0.5+
- [vim-dadbod](https://github.com/tpope/vim-dadbod)

## Installation

```lua
-- lazy.nvim
{ "gh-liu/vim-dbcp", dependencies = { "tpope/vim-dadbod" } }
```

## Usage

```vim
" Set completion function
setlocal completefunc=dbcp#complete

" Trigger with <C-x><C-u>
```

## Writing an Adapter

Create `autoload/dbcp/adapter/{db_type}.vim`:

```vim
function! dbcp#adapter#{db_type}#complete(findstart, base, db_url) abort
  if a:findstart
    " Return start column
  endif
  " Return completion items
endfunction
```

## License

MIT
