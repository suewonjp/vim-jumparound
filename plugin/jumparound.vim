" ============================================================================
" Vim-JumpAround
" Author:       Suewon Bahng <https://github.com/suewonjp/>
" Version:      1.0
" ============================================================================

if exists('g:loaded_jumparound') || &cp || v:version < 700
  finish
endif
let g:loaded_jumparound = 1

" ============================================================================
" JUMPING AROUND TABS/WINDOWS/MARKS {{{1
" ============================================================================

" Bind Alt(Meta) key combinations {{{2
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
" }}}2

" Define <M-...> mappings for tab pages/windows navigation {{{2

" Switch to normal mode from other modes
" This may be quicker than pressing <ESC>
inoremap <expr><silent><M-y> pumvisible() ? '<C-y><ESC>' : '<ESC>'
vnoremap <M-y> o<ESC>
cnoremap <M-y> <C-e><C-u><BS>

" Make the given mapping work consistently for every major mode
function! <SID>MapForEveryMode(lhs, rhs)
  exe 'nnoremap ' . a:lhs ' ' . a:rhs
  exe 'inoremap ' . a:lhs ' <ESC>' . a:rhs
  exe 'vnoremap ' . a:lhs ' o<ESC>' . a:rhs
  exe 'cnoremap ' . a:lhs ' <C-e><C-u><BS>' . a:rhs
endfunction

" Save the buffer and switch to the normal mode unless it is
call <SID>MapForEveryMode('<M-s>', ' :<C-u>w<CR>')

" Move to next tab page
call <SID>MapForEveryMode(
      \ '<silent> <M-l>', ' :<C-u>call jumparound#GoToTabPage("++")<CR>')

" Move to previous tab page
call <SID>MapForEveryMode(
      \ '<silent> <M-h>', ' :<C-u>call jumparound#GoToTabPage("--")<CR>')

" Move to upper window
call <SID>MapForEveryMode(
      \ '<silent> <M-K>',
      \ ' :<C-u>call jumparound#JumpToWindowWithWrap("k", "j")<CR>')

" Move to lower window
call <SID>MapForEveryMode(
      \ '<silent> <M-J>',
      \ ' :<C-u>call jumparound#JumpToWindowWithWrap("j", "k")<CR>')

" Move to left window
call <SID>MapForEveryMode(
      \ '<silent> <M-H>',
      \ ' :<C-u>call jumparound#JumpToWindowWithWrap("h", "l")<CR>')

" Move to right window
call <SID>MapForEveryMode(
      \ '<silent> <M-L>',
      \ ' :<C-u>call jumparound#JumpToWindowWithWrap("l", "h")<CR>')

" Open a file explorer at the parent directory of % (the current file)
" in a new tab
call <SID>MapForEveryMode(
      \ '<silent> <M-t>', ' :<C-u>Tex %:p:h<CR>')

" Open a file explorer at the parent directory of %
" in a horizontal split window.
" Use the same mapping to close it.
call <SID>MapForEveryMode(
      \ '<silent> <M-x>', ' :<C-u>call jumparound#ToggleLex()<CR>')
" }}}2

" Jump to tab page by specifying its number {{{2
if ! exists('g:ja_add_nr_tab_mappings') || g:ja_add_nr_tab_mappings
  let s:max = 9
  let s:i = 1
  while s:i <= s:max
    " nnoremap N<Tab> :call jumparound#GoToTabPage('N')
    " where N is 1 ~ 9
    exe 'nnoremap <silent> ' . s:i . '<Tab>'
          \ ' :<C-u>call jumparound#GoToTabPage(' . s:i . ')<CR>'
    let s:i = s:i + 1
  endwhile

  " 0<Tab> is a special case, which jumps to the previous tab page
  nnoremap <silent> 0<Tab> :<C-u>call jumparound#GoToTabPage('0')<CR>
endif
" }}}2

" Jump to window by specifying its number {{{2
if ! exists('g:ja_add_nr_cr_mappings') || g:ja_add_nr_cr_mappings
  let s:max = 9
  let s:i = 1
  while s:i <= s:max
    " nnoremap N<CR> <C-w>w
    " where N is 1 ~ 9
    exe 'nnoremap <silent> ' . s:i . '<CR> ' . s:i . '<C-w>w'
    let s:i = s:i + 1
  endwhile

  " 0<CR> is a special case, which jumps to the previous window
  nnoremap <silent> 0<CR> <C-w>p
endif
" }}}2

" Jump across marks {{{2
if ! exists('g:ja_add_space_marks') || g:ja_add_space_marks
  nnoremap <silent><SPACE><CR> :<C-u>call jumparound#SetMark()<CR>

  nnoremap <silent><SPACE> :<C-u>call jumparound#JumpToMark()<CR>

  nnoremap <silent>0<SPACE> ``
endif
" }}}2

" }}}1

" ============================================================================
" QUICK SEARCH {{{1
" ============================================================================

if ! exists('g:ja_search_mapleader')
  " If mappings for quick search are conflicting,
  " define this global variable with non empty key;
  "     e.g., let g:ja_search_mapleader = '<C-g>'
  "     e.g., Then, you can type <C-g>sa for the 'sa' mapping
  " (See below for 'sa' mapping)
  let g:ja_search_mapleader = ''
endif

" You can use * or # for visually selected text {{{2
" just like you use * or # for quickly searching <cword> (:help star)
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
exe 'nnoremap <silent>' . g:ja_search_mapleader . 'sa'
      \ ' :<C-u>noautocmd vimgrep! /\V<C-r>//j ##'
      \ ' \| call jumparound#OpenQuickfix()<CR>'

" Search files for the pattern stored in @/ register.
" It's possibly very slow depending on the number of files to visit.
" Use it with the 'wildignore' option to avoid such situation;
"     e.g., :set wildignore+=build/**
exe 'nnoremap <silent>' . g:ja_search_mapleader . 'sf'
      \ ' :<C-u>noautocmd vimgrep! /\V<C-r>//j **'
      \ ' \| call jumparound#OpenQuickfix()<CR>'

" Same as 'sa' or 'sf' mappings except the search result will use 'location list'
" instead of 'quickfix list' (:help location-list) 
" Note that you CAN'T use 'qft' mapping to toggle the location list window.
" Use ':lopen' or ':lclose' command
exe 'nnoremap <silent>' . g:ja_search_mapleader . 'Sa'
      \ ' :<C-u>noautocmd lvimgrep! /\V<C-r>//j ##'
      \ ' \| call jumparound#OpenLocationList()<CR>'
exe 'nnoremap <silent>' . g:ja_search_mapleader . 'Sf' 
      \ ' :<C-u>noautocmd lvimgrep! /\V<C-r>//j **'
      \ ' \| call jumparound#OpenLocationList()<CR>'

" Search the argument list for the word under the cursor
exe 'nnoremap <silent>' . g:ja_search_mapleader . '#a'
      \ '*:<C-u>noautocmd vimgrep! /\V<C-r>//j ##'
      \ ' \| call jumparound#OpenQuickfix()<CR>'

" Search files for the word under the cursor
exe 'nnoremap <silent>' . g:ja_search_mapleader . '#f'
      \ '*:<C-u>noautocmd vimgrep! /\V<C-r>//j **'
      \ ' \| call jumparound#OpenQuickfix()<CR>'

" Search the argument list for the text visually selected
exe 'xnoremap <silent>' . g:ja_search_mapleader . '#a'
      \ ' :<C-u>call <SID>MapXmapStar("/")<CR>/<C-r>=@/<CR><CR>'
      \ ' : noautocmd vimgrep! /\V<C-r>//j ##'
      \ ' \| call jumparound#OpenQuickfix()<CR>'

" Search files for the text visually selected
exe 'xnoremap <silent>' . g:ja_search_mapleader . '#f'
      \ ' :<C-u>call <SID>MapXmapStar("/")<CR>/<C-r>=@/<CR><CR>'
      \ ' : noautocmd vimgrep! /\V<C-r>//j **'
      \ ' \| call jumparound#OpenQuickfix()<CR>'

" }}}2

" These command line mappings exist for more flexibility.
" They will print out the candidate command in the command line and
" wait for your editing and pressing <CR>
" The cursor will be placed where you can type file paths right away
if ! exists('g:ja_add_search_cabbrs') || g:ja_add_search_cabbrs
  cnoreabbrev vg+ <C-u>noautocmd vimgrep /\V<C-r>//j
        \ \| call jumparound#OpenQuickfix()<S-Left><S-Left><S-Left><Left>
  cnoreabbrev vg# <C-u>noautocmd vimgrep /\V<C-r>//j ##
        \ \| call jumparound#OpenQuickfix()<S-Left><S-Left><S-Left><Left>
  cnoreabbrev vg* <C-u>noautocmd vimgrep /\V<C-r>//j **
        \ \| call jumparound#OpenQuickfix()<S-Left><S-Left><S-Left><Left>
endif

" Some of mappings above will search through files in the argument list
" using ## notation with vimgrep command ( :help :_## )
" If you want to add buffers in the argument list, use 'argadd' command.
" Or in order to replace the argument list with all buffers currently loaded,
" use the following command.
" [LIMITATION] It will consider only buffers for readable files
command! JaUpdateArgsFromBufs call jumparound#UpdateArgsFromBufs()

" }}}1

" ============================================================================
" QUICKFIX WINDOW {{{1
" ============================================================================

" Toggle quickfix window ==> q(uick) f(ix) t(oggle)
nnoremap <silent>qft :<C-u>call jumparound#ToggleQuickfix()<CR>

if ! empty('g:mapleader') && maparg('<leader>q') == ''
  nnoremap <silent><leader>q :<C-u>call jumparound#ToggleQuickfix()<CR>
endif

" Focus to quickfix (or location list)
nnoremap <silent>q<CR> :<C-u>call jumparound#GoToQuickfixWin()<CR>

" }}}1

" vim: sw=2 foldmethod=marker :
