" vim-dbcp: Generic SQL Completion Engine
" Provides context-aware completion for SQL databases
" Supports: table names, column names (with alias detection), auto-quoting

if exists('g:autoloaded_dbcp_sql')
  finish
endif
let g:autoloaded_dbcp_sql = 1

" =============================================================================
" Constants
" =============================================================================

" Context types
let s:CTX_NONE = 0
let s:CTX_TABLE = 1       " FROM/JOIN/UPDATE/INTO/DELETE FROM - expecting table name
let s:CTX_COLUMN = 2      " alias./table. - expecting column name
let s:CTX_SCHEMA = 3      " schema. - expecting table name within schema

let s:script_path = expand('<sfile>:p')
let s:TABLE_KEYWORDS = v:null

function! s:load_table_keywords() abort
  if s:TABLE_KEYWORDS isnot v:null | return s:TABLE_KEYWORDS | endif
  let l:csv = dbcp#csv#load('sql_table_keywords.csv', s:script_path)
  let s:TABLE_KEYWORDS = l:csv is v:null ? [] : map(l:csv, {_, v -> v[0]})
  return s:TABLE_KEYWORDS
endfunction

" Pattern to match identifier (table/alias name)
let s:IDENT_PATTERN = '\v[A-Za-z_][A-Za-z0-9_]*'

" =============================================================================
" Dialect Management
" =============================================================================

" Cache for loaded dialects
let s:dialect_cache = {}

" Get dialect configuration from adapter
" Falls back to SQLite if adapter doesn't provide dialect
function! s:get_dialect(scheme) abort
  " Check cache
  if has_key(s:dialect_cache, a:scheme)
    return s:dialect_cache[a:scheme]
  endif
  
  " Try to get dialect from adapter (use scheme directly from dadbod)
  let l:dialect_func = 'dbcp#adapter#' . a:scheme . '#get_dialect'
  if exists('*' . l:dialect_func)
    let l:dialect = call(l:dialect_func, [])
    let s:dialect_cache[a:scheme] = l:dialect
    return l:dialect
  endif
  
  " Fallback to minimal SQL dialect (SQL-92 core keywords)
  if !has_key(s:dialect_cache, '_default')
    let l:csv = dbcp#csv#load('sql_keywords_default.csv', s:script_path)
    let l:keywords = l:csv is v:null ? [] : map(l:csv, {_, v -> v[0]})
    let s:dialect_cache['_default'] = {'quote': '"', 'escape': '"', 'keywords': l:keywords}
  endif
  return s:dialect_cache['_default']
endfunction

" =============================================================================
" Cache Management
" =============================================================================

" Tables cache: { db_url: { data: [...], timestamp: <time> } }
let s:tables_cache = {}
let s:tables_cache_ttl = 300  " 5 minutes

" Columns cache: { db_url: { table: { data: [...], timestamp: <time> } } }
let s:columns_cache = {}
let s:columns_cache_ttl = 300  " 5 minutes

function! s:is_cache_valid(cache_entry, ttl) abort
  if type(a:cache_entry) != v:t_dict || !has_key(a:cache_entry, 'timestamp')
    return 0
  endif
  return localtime() - a:cache_entry.timestamp < a:ttl
endfunction

" Clear cache (can be called externally)
function! dbcp#sql#clear_cache(...) abort
  if a:0 > 0
    let l:db_url = a:1
    if has_key(s:tables_cache, l:db_url)
      call remove(s:tables_cache, l:db_url)
    endif
    if has_key(s:columns_cache, l:db_url)
      call remove(s:columns_cache, l:db_url)
    endif
  else
    let s:tables_cache = {}
    let s:columns_cache = {}
  endif
endfunction

" =============================================================================
" Data Access (via vim-dadbod)
" =============================================================================

function! s:get_tables(db_url, scheme) abort
  " Check cache
  if has_key(s:tables_cache, a:db_url)
    let l:cached = s:tables_cache[a:db_url]
    if s:is_cache_valid(l:cached, s:tables_cache_ttl)
      return l:cached.data
    endif
  endif

  " Fetch from database via dadbod
  try
    let l:tables = db#adapter#call(a:scheme, 'tables', [a:db_url], [])
  catch /.*/
    return []
  endtry

  " Normalize result
  if type(l:tables) != v:t_list
    let l:tables = []
  endif

  let l:result = []
  for l:t in l:tables
    if type(l:t) == v:t_string
      call add(l:result, substitute(l:t, '^\w\+\.', '', ''))
    elseif type(l:t) == v:t_dict && has_key(l:t, 'name')
      call add(l:result, l:t.name)
    endif
  endfor

  " Cache result
  let s:tables_cache[a:db_url] = {
        \ 'data': l:result,
        \ 'timestamp': localtime()
        \ }

  return l:result
endfunction

function! s:get_columns(db_url, scheme, table) abort
  " Check cache
  if has_key(s:columns_cache, a:db_url)
    let l:db_cache = s:columns_cache[a:db_url]
    if has_key(l:db_cache, a:table) && s:is_cache_valid(l:db_cache[a:table], s:columns_cache_ttl)
      return l:db_cache[a:table].data
    endif
  else
    let s:columns_cache[a:db_url] = {}
  endif

  " Fetch from database via dadbod
  try
    let l:columns = db#adapter#call(a:scheme, 'columns', [a:db_url, a:table], [])
  catch /.*/
    return []
  endtry

  " Normalize result
  if type(l:columns) != v:t_list
    let l:columns = []
  endif

  let l:result = []
  for l:c in l:columns
    if type(l:c) == v:t_string
      call add(l:result, l:c)
    elseif type(l:c) == v:t_dict && has_key(l:c, 'name')
      call add(l:result, l:c.name)
    endif
  endfor

  " Cache result
  let s:columns_cache[a:db_url][a:table] = {
        \ 'data': l:result,
        \ 'timestamp': localtime()
        \ }

  return l:result
endfunction

" =============================================================================
" Quoting
" =============================================================================


function! s:needs_quote(name, dialect) abort
  if a:name !~# '^\v[A-Za-z_][A-Za-z0-9_]*$' | return 1 | endif
  return index(a:dialect.keywords, toupper(a:name)) >= 0
endfunction

function! s:quote_identifier(name, dialect) abort
  if !s:needs_quote(a:name, a:dialect)
    return a:name
  endif

  let l:quote = a:dialect.quote
  let l:quote_end = get(a:dialect, 'quote_end', l:quote)
  let l:escape = a:dialect.escape

  " Escape existing quote characters
  let l:escaped = substitute(a:name, l:escape, l:escape . l:escape, 'g')
  return l:quote . l:escaped . l:quote_end
endfunction

" =============================================================================
" Context Detection
" =============================================================================

let s:ctx_cache = {'line': -1, 'col': -1, 'text': '', 'aliases': {}}
let s:non_alias_kw = v:null

function! s:load_non_alias_keywords() abort
  if s:non_alias_kw isnot v:null | return s:non_alias_kw | endif
  let l:csv = dbcp#csv#load('sql_non_alias_keywords.csv', s:script_path)
  let s:non_alias_kw = {}
  if l:csv isnot v:null
    for l:row in l:csv
      let s:non_alias_kw[tolower(l:row[0])] = 1
    endfor
  endif
  return s:non_alias_kw
endfunction

function! s:get_context_text() abort
  let l:ln = line('.')
  let l:col = col('.')
  if s:ctx_cache.line == l:ln && s:ctx_cache.col == l:col
    return s:ctx_cache.text
  endif
  let l:lines = []
  for l:i in range(max([1, l:ln - 20]), l:ln - 1)
    call add(l:lines, getline(l:i))
  endfor
  call add(l:lines, getline(l:ln)[:l:col - 1])
  let s:ctx_cache.text = join(l:lines, ' ')
  let s:ctx_cache.line = l:ln
  let s:ctx_cache.col = l:col
  return s:ctx_cache.text
endfunction

function! s:extract_aliases(text) abort
  try
    if s:ctx_cache.text ==# a:text && !empty(s:ctx_cache.aliases)
      return s:ctx_cache.aliases
    endif
    let l:aliases = {}
    let l:pos = 0
    " Match: FROM/JOIN table [AS] alias
    while 1
      let l:m = matchlist(a:text, '\v\c(FROM|JOIN)\s+([A-Za-z_]\w+)', l:pos)
      if empty(l:m) | break | endif
      let l:table = l:m[2]
      let l:tl = tolower(l:table)
      if !has_key(l:aliases, l:tl) | let l:aliases[l:tl] = l:table | endif
      let l:pos = matchend(a:text, '\v\c(FROM|JOIN)\s+([A-Za-z_]\w+)', l:pos)
      " Look for alias after table (either "AS alias" or just "alias")
      let l:rest = strpart(a:text, l:pos)
      let l:parts = split(l:rest)
      if len(l:parts) > 0
        let l:alias = l:parts[0]
        if l:alias ==# 'AS' && len(l:parts) > 1
          let l:alias = l:parts[1]
        endif
        if !empty(l:alias)
          let l:alias_lower = tolower(l:alias)
          let l:is_reserved = 0
          let l:non_alias_kw = {}
          let l:csv = dbcp#csv#load('sql_non_alias_keywords.csv', s:script_path)
          if type(l:csv) == v:t_list
            for l:row in l:csv
              if type(l:row) == v:t_list && len(l:row) > 0
                let l:kw = l:row[0]
                let l:non_alias_kw[tolower(l:kw)] = 1
              endif
            endfor
          endif
          if has_key(l:non_alias_kw, l:alias_lower)
            let l:is_reserved = 1
          endif
          if l:alias !=# l:table && !l:is_reserved
            let l:aliases[l:alias_lower] = l:table
          endif
          let l:pos += strlen(l:parts[0]) + 1
        endif
      endif
      if l:pos >= len(a:text) | break | endif
    endwhile
    if s:ctx_cache.text ==# a:text | let s:ctx_cache.aliases = l:aliases | endif
    return l:aliases
  catch
    return {}
  endtry
endfunction

function! s:detect_context() abort
  let l:line = getline('.')
  let l:col = col('.') - 1
  let l:before = l:line[:l:col]
  
   " Check alias.column pattern
   let l:m = matchlist(l:before, '\v([A-Za-z_][A-Za-z0-9_]*)\.([A-Za-z_][A-Za-z0-9_]*)?$')
   if !empty(l:m)
     let l:aliases = s:extract_aliases(s:get_context_text())
     return [s:CTX_COLUMN, strridx(l:before, '.'), get(l:aliases, tolower(l:m[1]), l:m[1])]
   endif
  
  " Check table context
  let l:text = s:get_context_text()
  for l:kw in s:load_table_keywords()
    let l:pat = '\v\c' . substitute(l:kw, '_', '\\s\\+', 'g') . '\s+([A-Za-z_][A-Za-z0-9_]*)?$'
    if l:text =~# l:pat
      let l:m = matchlist(l:before, '\v([A-Za-z_][A-Za-z0-9_]*)$')
      return [s:CTX_TABLE, empty(l:m) ? l:col : l:col - len(l:m[1]), '']
    endif
  endfor
  
  return [s:CTX_NONE, -1, '']
endfunction

" =============================================================================
" Completion Items
" =============================================================================

function! s:make_items(names, dialect, menu) abort
  let l:items = []
  for l:name in a:names
    call add(l:items, {
          \ 'word': s:quote_identifier(l:name, a:dialect),
          \ 'abbr': l:name,
          \ 'menu': a:menu,
          \ 'kind': 'v',
          \ })
  endfor
  return l:items
endfunction

function! s:filter_items(base, items) abort
  if empty(a:base) | return a:items | endif
  let l:bl = tolower(a:base)
  let l:blen = len(a:base)
  let l:res = []
  for l:item in a:items
    let l:abbr = get(l:item, 'abbr', l:item.word)
    if len(l:abbr) >= l:blen && tolower(l:abbr[:l:blen - 1]) ==# l:bl
      call add(l:res, l:item)
    endif
  endfor
  return l:res
endfunction

" =============================================================================
" Main Completion Function
" =============================================================================

" Saved context for second call
let s:saved_context = [s:CTX_NONE, -1, '']

function! dbcp#sql#complete(findstart, base, db_url, scheme) abort
  if a:findstart
    " First call: detect context
    let s:saved_context = s:detect_context()
    let l:ctx_type = s:saved_context[0]
    let l:start_col = s:saved_context[1]
    
    return l:ctx_type == s:CTX_NONE ? -1 : l:start_col
  endif
  
  " Second call: return completions
  let l:ctx_type = s:saved_context[0]
  let l:extra = s:saved_context[2]
  let l:dialect = s:get_dialect(a:scheme)
  
  if l:ctx_type == s:CTX_TABLE
    return s:filter_items(a:base, s:make_items(s:get_tables(a:db_url, a:scheme), l:dialect, 'table'))
  elseif l:ctx_type == s:CTX_COLUMN
    return s:filter_items(a:base, s:make_items(s:get_columns(a:db_url, a:scheme, l:extra), l:dialect, l:extra))
  endif
  
  return []
endfunction
