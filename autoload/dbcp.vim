" vim-dbcp: Database Completion Provider
" Maintainer: liu
" License: MIT

if exists('g:autoloaded_dbcp')
  finish
endif
let g:autoloaded_dbcp = 1

" Main completion function for use with completefunc/omnifunc
" Usage: setlocal completefunc=dbcp#complete
function! dbcp#complete(findstart, base) abort
  let l:db_url = get(b:, 'db', get(g:, 'db', ''))
  if l:db_url == ''
    return a:findstart ? -1 : []
  endif

  " Detect db type from URL scheme
  let l:scheme = matchstr(l:db_url, '^\w\+')
  if l:scheme == ''
    return a:findstart ? -1 : []
  endif

  " Dispatch to adapter
  let l:adapter = 'dbcp#adapter#' . l:scheme . '#complete'

  try
    return call(l:adapter, [a:findstart, a:base, l:db_url])
  catch /E117/  " Undefined function
    return a:findstart ? -1 : []
  endtry
endfunction

" Omnifunc wrapper - use with: setlocal omnifunc=dbcp#omnifunc
" Trigger with <C-x><C-o>
function! dbcp#omnifunc(findstart, base) abort
  return dbcp#complete(a:findstart, a:base)
endfunction
