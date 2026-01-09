" vim-dbcp: Oracle Adapter
" Provides SQL completion for Oracle databases

if exists('g:autoloaded_dbcp_adapter_oracle')
  finish
endif
let g:autoloaded_dbcp_adapter_oracle = 1

let s:script_path = expand('<sfile>:p')
let s:dialect_cache = v:null

function! dbcp#adapter#oracle#get_dialect() abort
  if s:dialect_cache isnot v:null | return s:dialect_cache | endif
  let l:csv = dbcp#csv#load('oracle_keywords.csv', s:script_path)
  let l:keywords = l:csv is v:null ? [] : map(l:csv, {_, v -> v[0]})
  let s:dialect_cache = {'quote': '"', 'escape': '"', 'keywords': l:keywords}
  return s:dialect_cache
endfunction

function! dbcp#adapter#oracle#complete(findstart, base, db_url) abort
  return dbcp#sql#complete(a:findstart, a:base, a:db_url, 'oracle')
endfunction

" Clear cache for this adapter
function! dbcp#adapter#oracle#clear_cache(...) abort
  if a:0 > 0
    call dbcp#sql#clear_cache(a:1)
  else
    call dbcp#sql#clear_cache()
  endif
endfunction
