" vim-dbcp: MariaDB Adapter (mariadb:// scheme)
" Provides SQL completion for MariaDB databases (uses MySQL dialect)

if exists('g:autoloaded_dbcp_adapter_mariadb')
  finish
endif
let g:autoloaded_dbcp_adapter_mariadb = 1

function! dbcp#adapter#mariadb#get_dialect() abort
  return dbcp#adapter#mysql#get_dialect()
endfunction

function! dbcp#adapter#mariadb#complete(findstart, base, db_url) abort
  return dbcp#sql#complete(a:findstart, a:base, a:db_url, 'mariadb')
endfunction

function! dbcp#adapter#mariadb#clear_cache(...) abort
  if a:0 > 0
    call dbcp#sql#clear_cache(a:1)
  else
    call dbcp#sql#clear_cache()
  endif
endfunction
