function! ezguifont#SetFont(font_spec)
  " First parse the passed font spec into a platform-neutral dictionary

  let fonts = split(a:font_spec, ',', 1)
  let i = 0
  while i < len(fonts)
    let parts = split(fonts[i], ':', 1)
    if len(parts) > 1 " Mac/Nvim/Windows style font spec
      let options = parts[1:]
      let fonts[i] = { 'name': parts[0], 'options': options, 'size': s:get_size_from_options(options) }
    else " GTK style font spec
      let name = fonts[i]
      let size = 0
      if fonts[i] =~ '\d\+\.\d*\s*$'  " Float
        let size = str2float(matchstr(name, '\d\+\.\d*\s*$'))
        let name = substitute(name, '\s*\d\+\.\d*\s*$', '', '')
      elseif name =~ '\d\+\s*$'       " Integer
        let size = str2nr(matchstr(name, '\d\+\s*$'))
        let name = substitute(name, '\s*\d\+\s*$', '', '')
      endif
      let fonts[i] = { 'name': name, 'options': [], 'size': size }
    endif

    if fonts[i]['size'] == 0 " Set a default font size if not specified
      let fonts[i]['size'] = g:ezguifont_default_font_size
    endif

    if s:get_size_from_options(fonts[i]['options']) == 0                    " Check if size exists in options
      call add(fonts[i]['options'], 'h' . s:format_size(fonts[i]['size']))  " And if not, populate it
    endif

    let i = i + 1
  endwhile

  " Then render the dictionary entries in a platform-specific format

  if has('gui_gtk')
    let name = substitute(fonts[0]['name'], '_', ' ', 'g') " Underscores aren't supported on GTK
    let size = s:format_size(fonts[0]['size'])
    let &guifont = name . ' ' . size

  elseif exists(':VimRSetFontAndSize')
    let name = fonts[0]['name']
    let size = fonts[0]['size']
    execute 'VimRSetFontAndSize "' . name . '",' . size

  else " Mac/Nvim/Windows
    let formatted = []
    for font in fonts
      let parts = [font['name']] + font['options']
      call add(formatted, join(parts, ':'))
    endfor
    " Note: setting multiple fonts does not appear to be supported—at least on
    " neovim-qt in Linux. If after investigation it turns out no non-GTK
    " platform supports multiple fonts, we can simplify this logic to choosing
    " the first font.
    let &guifont = join(formatted, ',')
  endif
endfunction

function! ezguifont#DecreaseFont()
  call s:adjust_font_size(-1 * g:ezguifont_step_size)
endfunction

function! ezguifont#IncreaseFont()
  call s:adjust_font_size(g:ezguifont_step_size)
endfunction

function! ezguifont#ResetFontSize()
  call s:set_font_size(g:ezguifont_default_font_size)
endfunction

function! s:adjust_font_size(step)
  let fonts = split(&guifont, ',', 1)

  let i = 0
  while i < len(fonts)
    if has('gui_gtk')
      let match_pattern = ''
      if fonts[i] =~ '\d\+\.\d*\s*$'  " Float
        let match_pattern = '\d\+\.\d*\s*$'
        let old_size = str2float(matchstr(fonts[i], match_pattern))
      elseif fonts[i] =~ '\d\+\s*$'   " Integer
        let match_pattern = '\d\+\s*$'
        let old_size = str2nr(matchstr(fonts[i], match_pattern))
      else                            " No size, pick a default
        let match_pattern = '$'
        let old_size = g:ezguifont_default_font_size
      endif

      if !empty(match_pattern)
        let new_size = old_size + a:step
        if new_size > 0
          let fonts[i] = substitute(fonts[i], match_pattern, s:format_size(new_size), '')
        endif
      endif

    else " Mac/Nvim/Windows
      let options = split(fonts[i], ':', 1)

      let j = 0
      let matched = 0
      while j < len(options)
        let old_size = s:parse_size_option(options[j])
        if old_size != 0 " Check if is a size option or some other option
          let matched = 1
          let new_size = old_size + a:step
          if new_size > 0
            let options[j] = 'h' . s:format_size(new_size)
          endif
        endif

        let j = j + 1
      endwhile

      if !matched
        " Note: fallback doesn't work on all Vim GUIs/platforms if there isn't
        " a font specified
        let new_size = g:ezguifont_default_font_size + a:step
        call add(options, 'h' . s:format_size(new_size))
      endif

      let fonts[i] = join(options, ':')
    endif

    let i = i + 1
  endwhile

  let &guifont = join(fonts, ',')
endfunction

function! s:set_font_size(new_size)
  let fonts = split(&guifont, ',', 1)

  let i = 0
  while i < len(fonts)
    if has('gui_gtk')
      let match_pattern = ''
      if fonts[i] =~ '\d\+\.\d*\s*$'  " Float
        let match_pattern = '\d\+\.\d*\s*$'
      elseif fonts[i] =~ '\d\+\s*$'   " Integer
        let match_pattern = '\d\+\s*$'
      else                            " No size, pick a default
        let match_pattern = '$'
      endif

      if !empty(match_pattern)
        let fonts[i] = substitute(fonts[i], match_pattern, s:format_size(a:new_size), '')
      endif

    else " Mac/Nvim/Windows
      let options = split(fonts[i], ':', 1)

      let j = 0
      let matched = 0
      while j < len(options)
        let old_size = s:parse_size_option(options[j])
        if old_size != 0 " Check if is a size option or some other option
          let matched = 1
          let options[j] = 'h' . s:format_size(a:new_size)
        endif

        let j = j + 1
      endwhile

      if !matched
        " Note: fallback doesn't work on all Vim GUIs/platforms if there isn't
        " a font specified
        call add(options, 'h' . s:format_size(a:new_size))
      endif

      let fonts[i] = join(options, ':')
    endif

    let i = i + 1
  endwhile

  let &guifont = join(fonts, ',')
endfunction

function! s:format_size(size)
  if type(a:size) == v:t_float
    return printf('%g', a:size)
  elseif type(a:size) == v:t_number
    return printf('%d', a:size)
  else
    echohl WarningMsg | echom 'Unsupport type passed to format_size:' type(a:size) | echohl None
    return ''
  endif
endfunction

function! s:get_size_from_options(options)
  for option in a:options
    let size = s:parse_size_option(option)
    if size != 0
      return size
    endif
  endfor
  return 0
endfunction

function! s:parse_size_option(option)
  if a:option =~ '^\s*h\d\+\.\d*\s*$' " Float
    return str2float(matchstr(a:option, '\d\+\.\d*'))
  elseif a:option =~ '^\s*h\d\+\s*$'  " Integer
    return str2nr(matchstr(a:option, '\d\+'))
  else
    return 0
  endif
endfunction
