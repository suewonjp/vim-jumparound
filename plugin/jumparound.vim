" ============================================================================
" Vim-JumpAround
" Author:       Suewon Bahng <https://github.com/suewonjp/>
" Version:      1.0
" ============================================================================

if exists('g:loaded_jumparound') || &cp || v:version < 800
  finish
endif
let g:loaded_jumparound = 1

" ============================================================================
" GENERAL FUNCTIONS {{{1
" ============================================================================

if ! exists('g:ja_check_mapping_confliction')
  let g:ja_check_mapping_confliction = 0
endif

function! <SID>CheckMapping(map, mode, abbr)
  if g:ja_check_mapping_confliction
    if maparg(a:map, a:mode, a:abbr) != ''
      call jumparound#Msg('Mapping conflict detected! : ' . a:map)
    endif
  endi
endfunction

function! <SID>MapForEveryMajorMode(lhs, rhs, alias)
  if maparg(a:alias, 'n') == ''
    exe 'nnoremap <silent>' a:alias  a:rhs == '' ? '<NOP>' : a:rhs
  endif
  if maparg(a:alias, 'i') == ''
    exe 'inoremap <silent>' a:alias '<ESC>' . a:rhs
  endif
  if maparg(a:alias, 'v') == ''
    exe 'vnoremap <silent>' a:alias 'o<ESC>' . a:rhs
  endif
  if maparg(a:alias, 'c') == ''
    exe 'cnoremap <silent>' a:alias '<C-e><C-u><BS>' . a:rhs
  endif

  if ! hasmapto(a:alias, 'n')
    call <SID>CheckMapping(a:lhs, 'n', 0)
    exe 'nmap' a:lhs  a:alias
  endif
  if ! hasmapto(a:alias, 'i')
    call <SID>CheckMapping(a:lhs, 'i', 0)
    exe 'imap' a:lhs  a:alias
  endif
  if ! hasmapto(a:alias, 'v')
    call <SID>CheckMapping(a:lhs, 'v', 0)
    exe 'vmap' a:lhs  a:alias
  endif
  if ! hasmapto(a:alias, 'c')
    call <SID>CheckMapping(a:lhs, 'c', 0)
    exe 'cmap' a:lhs  a:alias
  endif
endfunction

function! <SID>MapForSingleMode(mode, lhs, rhs, alias)
  exe a:mode . 'noremap <silent>' a:alias a:rhs
  if ! hasmapto(a:alias, a:mode)
    call <SID>CheckMapping(a:lhs, a:mode, 0)
    exe a:mode . 'map' a:lhs a:alias
  endif
endfunction

function! <SID>AbbrForSingleMode(mode, lhs, rhs)
  call <SID>CheckMapping(a:lhs, a:mode, 1)
  exe a:mode . 'noreabbr' a:lhs a:rhs
endfunction

" }}}1

" ============================================================================
" JUMPING AROUND TABS/WINDOWS/MARKS {{{1
" ============================================================================

" Define Alt(Meta) key mappings for tab pages/windows navigation and etc. {{{2

" Bind Alt(Meta) key combinations {{{3
if ! exists('g:ja_bind_alt_meta_mappings') || g:ja_bind_alt_meta_mappings
  exe "set <M-l>=\el"
  exe "set <M-h>=\eh"
  exe "set <M-L>=\eL"
  exe "set <M-H>=\eH"
  exe "set <M-J>=\eJ"
  exe "set <M-K>=\eK"
  exe "set <M-t>=\et"
  exe "set <M-x>=\ex"
  exe "set <M-s>=\es"
  exe "set <M-y>=\ey"
endif
" }}}3

" Define <M-...> mappings for tab pages/windows navigation {{{3

" Move to next tab page
call <SID>MapForEveryMajorMode(
      \ '<M-l>', ' :<C-u>call jumparound#GoToTabPage("++")<CR>',
      \ '<Plug>JumparoundGoToNextTabPage')

" Move to previous tab page
call <SID>MapForEveryMajorMode(
      \ '<M-h>', ' :<C-u>call jumparound#GoToTabPage("--")<CR>',
      \ '<Plug>JumparoundGoToPrevTabPage')

" Move to upper window
call <SID>MapForEveryMajorMode(
      \ '<M-K>',
      \ ' :<C-u>call jumparound#JumpToWindowWithWrap("k", "j")<CR>',
      \ '<Plug>JumparoundGoToUpperWindow')

" Move to lower window
call <SID>MapForEveryMajorMode(
      \ '<M-J>',
      \ ' :<C-u>call jumparound#JumpToWindowWithWrap("j", "k")<CR>',
      \ ' <Plug>JumparoundGoToLowerWindow')

" Move to left window
call <SID>MapForEveryMajorMode(
      \ '<M-H>',
      \ ' :<C-u>call jumparound#JumpToWindowWithWrap("h", "l")<CR>',
      \ ' <Plug>JumparoundGoToLeftWindow')

" Move to right window
call <SID>MapForEveryMajorMode(
      \ '<M-L>',
      \ ' :<C-u>call jumparound#JumpToWindowWithWrap("l", "h")<CR>',
      \ ' <Plug>JumparoundGoToRightWindow')

" Open a file explorer in a new tab
call <SID>MapForEveryMajorMode(
      \ '<M-t>', ' :<C-u>Tex %:p:h<CR>',
      \ ' <Plug>JumparoundOpenTex')

" Open a file explorer in a horizontal split window.
call <SID>MapForEveryMajorMode(
      \ '<M-x>', ' :<C-u>call jumparound#ToggleLex()<CR>',
      \ ' <Plug>JumparoundToggleLex')

" }}}3

" Other mappings using Alt(Meta) key {{{3

" Switch to the Normal mode
inoremap <expr><silent> <Plug>JumparoundGoBackToNmlMode
      \ pumvisible() ? '<C-y><ESC>' : '<ESC>'
call <SID>MapForEveryMajorMode('<M-y>', '', '<Plug>JumparoundGoBackToNmlMode')

" Save the buffer and switch to the Normal mode
call <SID>MapForEveryMajorMode('<M-s>', ' :<C-u>w<CR>',
      \ '<Plug>JumparoundSaveBufAndGoToNmlMode')

" }}}3

" }}}2

" Jump to tab page by specifying its number {{{2
if ! exists('g:ja_add_nr_tab_mappings') || g:ja_add_nr_tab_mappings
  let s:max = 9
  let s:i = 1
  while s:i <= s:max
    " nnoremap N<Tab> :call jumparound#GoToTabPage('N')<CR>
    " where N is 1 ~ 9
    call <SID>MapForSingleMode('n', s:i . '<TAB>',
          \ ':<C-u>call jumparound#GoToTabPage(' . s:i . ')<CR>',
          \ '<Plug>JumparoundGoToTabPage' . s:i)
    let s:i = s:i + 1
  endwhile

  " 0<Tab> is for jumping to the previously accessed tab page
  call <SID>MapForSingleMode('n', '0<TAB>',
        \ ':<C-u>call jumparound#GoToTabPage("0")<CR>',
        \ '<Plug>JumparoundGoToTabPage0')
endif
" }}}2

" Jump to window by specifying its number {{{2
if ! exists('g:ja_add_nr_cr_mappings') || g:ja_add_nr_cr_mappings
  let s:max = 9
  let s:i = 1
  while s:i <= s:max
    " nnoremap N<CR> <C-w>w
    " where N is 1 ~ 9
    call <SID>MapForSingleMode('n', s:i . '<CR>',
          \ s:i . '<C-w>w',
          \ '<Plug>JumparoundGoToWindow' . s:i)
    let s:i = s:i + 1
  endwhile

  " 0<CR> is for jumping to the previously accessed window
  call <SID>MapForSingleMode('n', '0<CR>',
        \ '<C-w>p',
        \ '<Plug>JumparoundGoToWindow0')
endif
" }}}2

" Jump across marks {{{2
if ! exists('g:ja_add_space_marks') || g:ja_add_space_marks
  call <SID>MapForSingleMode('n', '<SPACE><CR>',
        \ ':<C-u>call jumparound#SetMark()<CR>',
        \ '<Plug>JumparoundSetMark')

  call <SID>MapForSingleMode('n', '<SPACE>',
        \ ':<C-u>call jumparound#JumpToMark()<CR>',
        \ '<Plug>JumparoundJumpToMark')

  call <SID>MapForSingleMode('n', '0<SPACE>',
        \ '``',
        \ '<Plug>JumparoundJumpToLastPosition')
endif
" }}}2

" }}}1

" ============================================================================
" QUICK SEARCH {{{1
" ============================================================================

if ! exists('g:ja_search_mapleader')
  let g:ja_search_mapleader = ''
endif

" * or # command for arbitrary text selected in the Visual mode {{{2
function! <SID>MapXmapStar(cmd)
  let l:tmp = @t
  try
    norm! gv"ty
    let @/ = substitute(escape(@t, a:cmd . '\'), '\n', '\\n', 'g')
  finally
    let @t = l:tmp
  endtry
endfunction

if ! exists('g:ja_add_xmap_star') || g:ja_add_xmap_star
  if maparg('*', 'v') == ''
    xnoremap * :<C-u>call <SID>MapXmapStar('/')<CR>/<C-r>=@/<CR><CR>
  endif
  if maparg('#', 'v') == ''
    xnoremap # :<C-u>call <SID>MapXmapStar('?')<CR>?<C-r>=@/<CR><CR>
  endif
endif
" }}}2

" Normal mode mappings for quick text search {{{2

" Search the argument list for the pattern stored in @/ register
call <SID>MapForSingleMode('n', g:ja_search_mapleader . 'sa',
      \ ':<C-u>silent noautocmd vimgrep! /\V<C-r>//j ##' .
      \ ' \| call jumparound#OpenQuickfix()<CR>',
      \ '<Plug>JumparoundSearchArgList')

" Search files for the pattern stored in @/ register.
call <SID>MapForSingleMode('n', g:ja_search_mapleader . 'sf',
      \ ':<C-u>silent noautocmd vimgrep! /\V<C-r>//j **' .
      \ ' \| call jumparound#OpenQuickfix()<CR>',
      \ '<Plug>JumparoundSearchFiles')

" Same as 'sa' or 'sf' mappings except the search result will use
" 'location list' instead of 'quickfix list' (:help location-list) 
call <SID>MapForSingleMode('n', g:ja_search_mapleader . 'Sa',
      \ ':<C-u>silent noautocmd lvimgrep! /\V<C-r>//j ##' .
      \ ' \| call jumparound#OpenLocationList()<CR>',
      \ '<Plug>JumparoundSearchArgListLoc')

call <SID>MapForSingleMode('n', g:ja_search_mapleader . 'Sf',
      \ ':<C-u>silent noautocmd lvimgrep! /\V<C-r>//j **' .
      \ ' \| call jumparound#OpenLocationList()<CR>',
      \ '<Plug>JumparoundSearchFilesLoc')

" Search the argument list for <cword>
call <SID>MapForSingleMode('n', g:ja_search_mapleader . '#a',
      \ '*:<C-u>silent noautocmd vimgrep! /\V<C-r>//j ##' .
      \ ' \| call jumparound#OpenQuickfix()<CR>',
      \ '<Plug>JumparoundQuickSearchArgList')

" Search files for <cword>
call <SID>MapForSingleMode('n', g:ja_search_mapleader . '#f',
      \ '*:<C-u>silent noautocmd vimgrep! /\V<C-r>//j **' .
      \ ' \| call jumparound#OpenQuickfix()<CR>',
      \ '<Plug>JumparoundQuickSearchFiles')

" Search the argument list for the text selected in the Visual mode
call <SID>MapForSingleMode('x', g:ja_search_mapleader . '#a',
      \ ' :<C-u>call <SID>MapXmapStar("/")<CR>/<C-r>=@/<CR><CR>' .
      \ ' :silent noautocmd vimgrep! /\V<C-r>//j ##' .
      \ ' \| call jumparound#OpenQuickfix()<CR>',
      \ '<Plug>JumparoundQuickSearchArgList')

" Search files for the text selected in the Visual mode
call <SID>MapForSingleMode('x', g:ja_search_mapleader . '#f',
      \ ' :<C-u>call <SID>MapXmapStar("/")<CR>/<C-r>=@/<CR><CR>' .
      \ ' :silent noautocmd vimgrep! /\V<C-r>//j **' .
      \ ' \| call jumparound#OpenQuickfix()<CR>',
      \ '<Plug>JumparoundQuickSearchFiles')

" }}}2

" Command mode abbreviations for more flexibility {{{2
if ! exists('g:ja_add_search_cabbrs') || g:ja_add_search_cabbrs
  call <SID>AbbrForSingleMode('c', 'vg+',
        \ '<C-u>silent noautocmd vimgrep /\V<C-r>//j' .
        \ ' \| call jumparound#OpenQuickfix()<S-Left><S-Left><S-Left><Left>')

  call <SID>AbbrForSingleMode('c', 'vg#',
        \ '<C-u>silent noautocmd vimgrep /\V<C-r>//j ##' .
        \ ' \| call jumparound#OpenQuickfix()<S-Left><S-Left><S-Left><Left>')

  call <SID>AbbrForSingleMode('c', 'vg*',
        \ '<C-u>silent noautocmd vimgrep /\V<C-r>//j **' .
        \ ' \| call jumparound#OpenQuickfix()<S-Left><S-Left><S-Left><Left>')
endif
" }}}2

" Replace the argument list with all buffers currently loaded
command! JaUpdateArgsFromBufs call jumparound#UpdateArgsFromBufs()

" }}}1

" ============================================================================
" QUICKFIX WINDOW {{{1
" ============================================================================

" Toggle the Quickfix window
call <SID>MapForSingleMode('n', 'qft',
      \ ':<C-u>call jumparound#ToggleQuickfix()<CR>',
      \ '<Plug>JumparoundToggleQuickfix')

" Jump to the Quickfix window
call <SID>MapForSingleMode('n', 'q<CR>',
      \ ':<C-u>call jumparound#GoToQuickfixWin()<CR>',
      \ '<Plug>JumparoundGoToQuickfixWin')

" }}}1

" vim: sw=2 foldmethod=marker :
