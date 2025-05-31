" ============================================================================
" Vim-JumpAround
" Author:       Suewon Bahng <https://github.com/suewonjp/>
" Version:      1.1.0
" ============================================================================

" ============================================================================
" GENERAL FUNCTIONS {{{1
" ============================================================================

function! jumparound#Msg(msg)
  echohl WarningMsg | echom 'vim-jumparound :' a:msg | echohl None
endfunction

function! jumparound#Error(msg)
  echohl ErrorMsg | echom 'vim-jumparound :' a:msg | echohl None
endfunction

" }}}1

" ============================================================================
" JUMPING AROUND TABS/WINDOWS/MARKS {{{1
" ============================================================================

" Jump across tab pages {{{2

let s:prev_tabpage_nr = 1

function! jumparound#RememberCurTabPage()
  let s:prev_tabpage_nr = tabpagenr()
endfunction

function! jumparound#GoToTabPage(tgt)
  let l:tc = tabpagenr('$')
  let l:count = v:count1
  if a:tgt == '++'
    " Next tab
    call jumparound#RememberCurTabPage()
    let l:next_tabpage_nr = s:prev_tabpage_nr + l:count
    if l:next_tabpage_nr > l:tc
      let l:next_tabpage_nr = l:next_tabpage_nr - l:tc
    endif
    exe l:next_tabpage_nr . 'tabn'
  elseif a:tgt == '--'
    " Previous tab
    call jumparound#RememberCurTabPage()
    let l:next_tabpage_nr = s:prev_tabpage_nr - l:count
    if l:next_tabpage_nr <= 0
      let l:next_tabpage_nr = l:tc + l:next_tabpage_nr
    endif
    exe l:next_tabpage_nr . 'tabn'
  else
    let l:tnr = str2nr(a:tgt)
    if l:tnr < 1
      " When 0<Tab> typed
      let l:tnr = s:prev_tabpage_nr
    elseif l:tnr == 9
      " When 9<Tab> typed
      let l:tnr = '$'
    elseif l:tnr > l:tc
      " When N<Tab> typed where N > total tab page count
      let l:tnr = l:tc
    endif
    call jumparound#RememberCurTabPage()
    exe l:tnr . 'tabn'
  endif
endfunction

" }}}2

" Jump across windows {{{2

function! jumparound#GotoNextWindow(direction, count)
  let l:prev_win_nr = winnr()
  exe a:count . 'wincmd ' . a:direction
  return winnr() != l:prev_win_nr
endfunction

function! jumparound#JumpToWindowWithWrap(direction, opposite)
  if ! jumparound#GotoNextWindow(a:direction, v:count1)
    call jumparound#GotoNextWindow(a:opposite, 999)
  endif
endfunction

function! jumparound#GetWindowInfo(wn)
  let l:info = getwininfo(win_getid(a:wn))
  if l:info != []
    return info[0]
  endif
  return {}
endfunction

function! jumparound#ToggleLex()
  if ! exists('t:ja_lex_winid')
    let t:ja_lex_winid = 0
  endif

  let l:nerdtree = exists('g:loaded_nerd_tree') && g:loaded_nerd_tree

  let l:lex_info = getwininfo(t:ja_lex_winid)
  let t:ja_lex_winid = 0
  if l:lex_info == []
    " We don't have Lex. Show it
    if l:nerdtree
      NERDTree %:p:h
    else
      Lex %:p:h
    endif
    let t:ja_lex_winid = jumparound#GetWindowInfo(1).winid
  else
    " We have Lex. Hide it
    if l:nerdtree
      NERDTreeClose
    else
      exe l:lex_info[0].winnr . 'wincmd c'
    endif
  endif
endfunction

" }}}2

" Jump across marks {{{2

if ! exists('g:ja_mark_prefix')
  let g:ja_mark_prefix = '`'
endif

if ! exists('g:ja_mark_suffix')
  let g:ja_mark_suffix = 'zz'
endif

function! jumparound#SetMark()
  let l:nr = getchar()
  let l:ch = nr2char(l:nr)
  if l:ch =~# '[0-9a-zA-Z]'
    exe 'norm! m' . l:ch
    call jumparound#Msg('Now you have a mark [' . l:ch . ']')
  endif
endfunction

function! jumparound#JumpToMark()
  let l:nr = getchar()
  let l:ch = nr2char(l:nr)
  if l:ch =~# "[0-9a-zA-Z.^'<>]"
    try
      exe 'norm!' g:ja_mark_prefix . l:ch . g:ja_mark_suffix
    catch /^Vim\%((\a\+)\)\=:E20/
      call jumparound#Error('Mark not set : ' . l:ch)
    endtry
  endif
endfunction

" }}}2

" }}}1

" ============================================================================
" QUICK SEARCH {{{1
" ============================================================================

function! jumparound#IsSearchableBuf(bufinfo)
  return a:bufinfo.listed && (filereadable(a:bufinfo.name))
    || isdirectory(a:bufinfo.name)
endfunction

function! jumparound#GetSearchableBufList()
  return filter(getbufinfo(), 'jumparound#IsSearchableBuf(v:val)')
endfunction

function! jumparound#UpdateArgsFromBufs()
  argd *
  for bi in jumparound#GetSearchableBufList()
    if filereadable(bi.name)
      " [NOTE] Adding only files
      " Don't know how to properly handle directories for now
      exe 'arga ' . bi.name
    endif
  endfor
endfunction

" }}}1

" ============================================================================
" QUICKFIX WINDOW {{{1
" ============================================================================

function! jumparound#GetQuickfixWinNr()
  let l:wn = winnr('$')
  while l:wn > 0
    let l:wi = jumparound#GetWindowInfo(l:wn)
    if l:wi.quickfix
      return l:wi.winnr
    endif
    let l:wn = l:wn - 1
  endwhile
  return 0
endfunction

function! jumparound#GoToQuickfixWin()
  let l:qfwn = jumparound#GetQuickfixWinNr()
  if l:qfwn
    exe l:qfwn 'wincmd w'
  endif
endfunction

function! jumparound#OpenTabFromQuickfix()
  let l:height = winheight(0)
  exe "norm! \<C-w>\<CR>\<C-w>TgT"
  call jumparound#GoToQuickfixWin()
  exe 'resize' l:height
endfunction

function! jumparound#OpenHorWinFromQuickfix()
  let l:height = winheight(0)
  exe "norm! \<C-w>\<CR>\<C-w>K"
  call jumparound#GoToQuickfixWin()
  exe 'resize' l:height
endfunction

function! jumparound#OpenVerWinFromQuickfix()
  exe "norm! \<C-w>\<CR>\<C-w>H"
  cclose
  call jumparound#OpenQuickfix()
endfunction

function! jumparound#AddMappingsForQuickfix()
  nnoremap <buffer><silent> t
        \ :<C-u>call jumparound#OpenTabFromQuickfix()<CR>gt
  nnoremap <buffer><silent> tt
        \ :<C-u>call jumparound#OpenTabFromQuickfix()<CR>
  nnoremap <buffer><silent> T
        \ :<C-u>call jumparound#OpenTabFromQuickfix()<CR>
  nnoremap <buffer><silent> x <CR>:cclose<CR>
  nnoremap <buffer><silent> s
        \ <CR>:<C-u>call jumparound#GoToQuickfixWin()<CR>
  nnoremap <buffer><silent> _
        \ :<C-u>call jumparound#OpenHorWinFromQuickfix()<CR><C-w>p
  nnoremap <buffer><silent> __
        \ :<C-u>call jumparound#OpenHorWinFromQuickfix()<CR>
  nnoremap <buffer><silent> _x
        \ :<C-u>call jumparound#OpenHorWinFromQuickfix()<CR>:cclose<CR>
  nnoremap <buffer><silent> \|
        \ :<C-u>call jumparound#OpenVerWinFromQuickfix()<CR><C-w>t
  nnoremap <buffer><silent> \|\|
        \ :<C-u>call jumparound#OpenVerWinFromQuickfix()<CR>
  nnoremap <buffer><silent> \|x
        \ :<C-u>call jumparound#OpenVerWinFromQuickfix()<CR>:cclose<CR>
endfunction

function! jumparound#OpenQuickfix()
  botright copen
endfunction

function! jumparound#OpenLocationList()
  lopen
endfunction

function! jumparound#ToggleQuickfix()
  let l:qfwn = jumparound#GetQuickfixWinNr()
  if l:qfwn
    cclose
  else
    call jumparound#OpenQuickfix()
  endif
endfunction

" }}}1

" vim: sw=2 foldmethod=marker :
