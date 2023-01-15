command! -nargs=1 SetFont call ezguifont#SetFont(<f-args>)
command! DecreaseFontSize call ezguifont#DecreaseFontSize()
command! IncreaseFontSize call ezguifont#IncreaseFontSize()

if !exists('g:ezguifont_step_size')
  let g:ezguifont_step_size = 1
endif

if !exists('g:ezguifont_default_font_size')
  let g:ezguifont_default_font_size = 11
endif

if exists('s:loaded')
  finish
endif
let s:loaded = 1

if exists('g:ezguifont')
  call ezguifont#SetFont(g:ezguifont)
endif
