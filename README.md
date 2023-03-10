# ezguifont.vim

*Set and adjust the font in a cross-platform way. Supports gVim and all the Neovim GUIs.*

This plugin exists because I got used to being able to <kbd>Ctrl +</kbd> and <kbd>Ctrl -</kbd> in every other GUI application to quickly increase and decrease the font size. It isn't hard to write a basic `.vimrc` function to do this on a given platform, but if you bounce between Linux, Mac, and Windows like me, the logic becomes [annoyingly complicated](./autoload/ezguifont.vim). In addition, it is nice to have a cross-platform command to set the font in the first place, so you can get rid of any font platform-checking logic you have in your `.vimrc`.

It probably goes without saying, but this plugin is only useful if you run a GUI version of Vim (gVim, Neovim frontend, etc.) at least some of the time. If you run Vim exclusively from the terminal, you'll want to look at adjusting the font of your terminal emulator instead.

## Installation

This plugin can be installed like [any other modern Vim plugin](https://vi.stackexchange.com/q/613). For example, with [vim-plug](https://github.com/junegunn/vim-plug) you would add:

```vim
Plug 'mkropat/vim-ezguifont'
```

## Adjusting Font Size

ezguifont.vim provides three commands to adjust the rendered font size:

- `:IncreaseFont`
- `:DecreaseFont`
- `:ResetFontSize`

__Note__: these commands work best if you have an explicit font set. See the next section for how to set a font.

In my `.vimrc` I map these to <kbd>Ctrl +</kbd> (or without shift, <kbd>Ctrl =</kbd>), <kbd>Ctrl -</kbd>, and <kbd>Ctrl 0</kbd> respectively:

```vim
nnoremap <silent> <C--> :DecreaseFont<CR>
nnoremap <silent> <C-=> :IncreaseFont<CR>
nnoremap <silent> <C-+> :IncreaseFont<CR>
nnoremap <silent> <C-0> :ResetFontSize<CR>
```

__Note__: these mappings do not work in every version of Vim, due to esoteric key code handling limitations in some implementations. For that reason, ezguifont.vim does not automatically set any key mappings out-of-the-box, since it is not possible to use the obvious choice of mappings in a way that will work everywhere. Perhaps ezguifont.vim will be smarter about automatically setting key mappings in the future.

## Setting a Custom Font

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

Don't worry if the font format looks platform-specific???ezguifont.vim handles parsing whatever format you give it and then translates it to the format of the currently running platform.

Changes to `g:ezguifont` only take affect at Vim startup. If you need to set a different font after startup, use the `:SetFont` command. For example:

```vim
:SetFont IBM Plex Mono 11
```

## Limitations

### Adjusting the Default (Empty) Font Size

By default, Vim sets the font to:

```
guifont=
```

Or in other words the empty string. This gets interpreted by Vim as using some default font.

On some platforms you can adjust the default font size by specifying a size (even if you omit the font name), for example `set guifont=16` or `set guifont=:h16`. On platforms that support this, `:IncreaseFont` and `:DecreaseFont` work as expected. On platforms that don't support this, however, `:IncreaseFont`/`:DecreaseFont` don't do anything when you are using the empty font.

ezguifont.vim works best if you set an explicit font.

### Multiple Fonts / Fallback Fonts

ezguifont.vim does not go out of its way to support multiple fonts or fallback fonts. On some Vim GUI implementations you can pass multiple, comma-separated fonts to `guifont`, and if the first font isn't available Vim will try the second one and so on until an available font is found. Comma separated font lists are honored by `:SetFont` and passed along to `guifont` dutifully. However, not all Vim GUIs support comma-separated `guifont` values the way you would expect, either because fallback fonts are ignored or because a missing font throws an error (even if there is a fallback available). So YMMV, especially if you are trying to share the same `:SetFont` config across multiple platforms.

What I do is make a point to install the same custom font on every platform I use so that specifying a fallback font isn't necessary.

### X11 Fonts

Is anyone even still using the gVim build for vanilla X11? I am not talking about using a GTK build of gVim or using Neovim on X11. I am talking about setting old school fonts like:

```
-Misc-Fixed-Medium-R-Normal--13-120-75-75-C-70-ISO10646-1
```

If your fonts look like that, sorry, there is no support in ezguifont.vim. Chances are pretty good though that even if you are running an X11/Xorg desktop, you're not using old school fonts like that, so everything should work.
