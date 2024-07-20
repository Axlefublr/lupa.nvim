# lupa.nvim

> "lupa" means 🔍 in russian, and this plugin is for searching!

You might know about the built in neovim `*` & `#` motions.
They let you search for the word closest to your cursor, if you're in normal mode.
And if you're in visual mode, to search for your selection.

The issue the former has is that it wraps the pattern in `\<\>`.
This makes it so the word doesn't match if it's inside of another word.
That is of course a reasonable default, but it messes up the `/` register's usefulness.

Say you searched for the current word, then after going through some of the matches you now want to paste it somewhere.
You can't do `"/p` anymore, because instead of just pasting the word, you'll paste `\<word\>`, which I'm sure isn't what you actually want to do.
This plugin gives you a _choice_ about whether you want the `\<\>` or not.

The visual selection searching has not just an issue, but a bug too!
Instead of using `\<\>`, it uses `\V` at the start of the pattern. `\V` makes it so the pattern is taken _more_ literally (notice how it still doesn't make it completely literal).

This is of course convenient in terms of creating the mapping, but makes the `/` register useless once again.
This plugin won't make the `/` register magically always what you want, but will make the searched selection, more often than not, pastable normally (because it doesn't use `\V`).

And the final feature of the plugin doesn't even exist by default: search for the contents of some register.
I find this to be most useful to search for what's in my default register.
If what you're looking for is to effectively store searches in registers, I recommend using [search harps](https://github.com/Axlefublr/harp-nvim) instead.

## Install

With lazy.nvim:

```lua
{
  'Axlefublr/lupa.nvim',
  lazy = true,
}
```

As you can see, the setup call is optional and I don't provide any options so far.
You can lazy load this plugin because the mappings suggested in the next section (_suggested_, not automatically provided) all lazy load the plugin.

## Suggested mappings

```lua
vim.keymap.set('n', '#', function() require('lupa').word({ backwards = true }) end)
vim.keymap.set('n', '*', function() require('lupa').word() end)

vim.keymap.set('n', '<Leader>#', function() require('lupa').word({ backwards = true, edit = true }) end)
vim.keymap.set('n', '<Leader>*', function() require('lupa').word({ edit = true }) end)

vim.keymap.set('n', 'g#', function() require('lupa').register('"', { backwards = true }) end)
vim.keymap.set('n', 'g*', function() require('lupa').register('"') end)

vim.keymap.set('n', '<Leader>g#', function() require('lupa').register('"', { edit = true }) end)
vim.keymap.set('n', '<Leader>g*', function() require('lupa').register('"', { edit = true }) end)

vim.keymap.set('x', '#', function() require('lupa').selection({ backwards = true }) end)
vim.keymap.set('x', '*', function() require('lupa').selection() end)

vim.keymap.set('x', '<Leader>#', function() require('lupa').selection({ edit = true, backwards = true }) end)
vim.keymap.set('x', '<Leader>*', function() require('lupa').selection({ edit = true }) end)
```

## Details

```lua
local opts = {
  backwards = false, -- direction of the search
  search_offset = nil, -- a string with the `:h search-offset` you want to use
  edit = false, -- if true, don't press <CR> on the search, letting you edit the pattern
  not_inside = false, -- if true, surrounds the pattern with `\<\>`, which makes it not match while inside of another word
}
require('lupa').word(opts)
require('lupa').selection(opts)
require('lupa').register(register, opts)
```

All three functions take the (optional) `opts` table, in which you can decide to override defaults.
Every option is disabled by default.
