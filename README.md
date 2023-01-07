# ezguifont.vim

*Set and adjust the font in a cross-platform way. Supports gVim and all the Neovim GUIs.*

This plugin exists because I got used to being able to <kbd>Ctrl +</kbd> and <kbd>Ctrl -</kbd> in every other GUI application to quickly increase and decrease the font size. It isn't hard to write a basic `.vimrc` function to do this on a given platform, but if you bounce between Linux, Mac, and Windows like me, the logic becomes [annoyingly complicated](./autoload/ezguifont.vim). In addition, it is nice to have a cross-platform command to set the font in the first place, so you can get rid of any font platform-checking logic you have in your `.vimrc`.

It probably goes without saying, but this plugin is only useful if you run a GUI version of Vim (gVim, Neovim frontend, etc.) at least some of the time. If you run Vim exclusively from the terminal, you'll want to look at adjusting the font of your terminal emulator instead.

## Installation

This plugin can be installed like [any other modern Vim plugin](https://vi.stackexchange.com/q/613). For example, with [vim-plug](https://github.com/junegunn/vim-plug) you would add:

```vim
Plug 'mkropat/vim-ezguifont'
```

## Setting a Font

For first time configuration, I recommend starting with:

```vim
set guifont=*
```

This should open a platform-specific font picker. That way you don't have to tediously figure out how to construct a valid font string.

Once you have set the font, run:

```vim
set guifont?
```

This prints out the full font string that you just set. In order to have the font setting take effect when you restart Vim, add the following to your `.vimrc`:

```vim
let g:ezguifont = 'WHATEVER GUIFONT VALUE WAS JUST PRINTED'
```

For example, I use:

```vim
let g:ezguifont = 'IBM Plex Mono 11'
```

Don't worry if the font format looks platform-specific—ezguifont.vim handles parsing whatever format you give it and then translates it to the format of the currently running platform.

Changes to `g:ezguifont` only take affect at Vim startup. If you need to set a different font after startup, use the `:SetFont` command. For example:

```vim
:SetFont IBM Plex Mono 11
```

## Adjusting Font Size

ezguifont.vim provides two commands to adjust the rendered font size:

- `:IncreaseFontSize`
- `:DecreaseFontSize`

In my `.vimrc` I map these to <kbd>Ctrl +</kbd> and <kbd>Ctrl -</kbd> respectively:

```vim
nnoremap <C-+> :IncreaseFontSize<CR>
nnoremap <C--> :DecreaseFontSize<CR>
```

__Note__: these mappings do not work in every version of Vim, due to esoteric key code handling limitations in some implementations. For that reason, ezguifont.vim does not automatically set any key mappings out-of-the-box, since it is not possible to use the obvious choice of mappings in a way that will work everywhere. Perhaps ezguifont.vim will be smarter about automatically setting key mappings in the future.
