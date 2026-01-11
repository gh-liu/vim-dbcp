" vim-dbcp: MongoDB Adapter

if exists('g:autoloaded_dbcp_adapter_mongodb')
  finish
endif
let g:autoloaded_dbcp_adapter_mongodb = 1

" =============================================================================
" Constants
" =============================================================================

" Context types
let s:CTX_NONE = 0
let s:CTX_DB_METHOD = 1      " db.<method>
let s:CTX_COLLECTION = 2     " db.<collection> (when not a db method)
let s:CTX_COLL_METHOD = 3    " db.<collection>.<method>
let s:CTX_CHAIN_METHOD = 4   " db.<collection>.<method>(...).<chain_method> - chained method name
let s:CTX_OPERATOR = 5       " $<operator>

" Pattern matching regexes
let s:PATTERN_DB_DOT = 'db\.\w*$'
let s:PATTERN_COLL_METHOD = 'db\.\w\+\.\w*$'
let s:PATTERN_COLL_METHOD_WITH_PAREN = 'db\.\w\+\.\w\+('
let s:PATTERN_CHAIN_METHOD = 'db\.\w\+\.\w\+.*)\s*\.\w*$'
let s:PATTERN_CHAIN_METHOD_BEFORE_DOT = 'db\.\w\+\.\w\+.*)'
let s:PATTERN_OPERATOR = '\$\w*$'

" =============================================================================
" Context Detection
" =============================================================================

 " Get multiline context (look back up to 10 lines, forward up to 5 lines)
 function! s:get_multiline_context(line_num, col) abort
   let l:start_line = max([1, a:line_num - 10])
   let l:before_lines = []
   for l:lnum in range(l:start_line, a:line_num - 1)
     call add(l:before_lines, getline(l:lnum))
   endfor

   let l:current_line = getline(a:line_num)
   let l:before = join(l:before_lines, ' ')
   if !empty(l:before_lines)
     let l:before .= ' '
   endif
   let l:before .= l:current_line[:a:col]
   let l:after = l:current_line[a:col + 1:]

   let l:end_line = min([line('$'), a:line_num + 5])
   let l:after_lines = []
   for l:lnum in range(a:line_num + 1, l:end_line)
     call add(l:after_lines, getline(l:lnum))
   endfor
   let l:after = l:after . ' ' . join(l:after_lines, ' ')

   return [l:before, l:after, strlen(join(l:before_lines, ' ')) + 1]
 endfunction

" Detect chain method context: db.collection.method(...).chain_method
function! s:detect_chain_method(before, offset) abort
  if a:before !~# s:PATTERN_CHAIN_METHOD
    return [s:CTX_NONE, -1]
  endif
  
  let l:dot_pos = strridx(a:before, '.')
  if l:dot_pos == -1
    return [s:CTX_NONE, -1]
  endif
  
  let l:before_dot = a:before[:l:dot_pos - 1]
  if l:before_dot !~# s:PATTERN_CHAIN_METHOD_BEFORE_DOT
    return [s:CTX_NONE, -1]
  endif
  
  return [s:CTX_CHAIN_METHOD, a:offset + l:dot_pos + 1]
endfunction

" Detect collection method context: db.collection.method
function! s:detect_coll_method(before, offset) abort
  " Don't trigger if method already has opening parenthesis
  if a:before =~# s:PATTERN_COLL_METHOD_WITH_PAREN
    return [s:CTX_NONE, -1]
  endif
  
  if a:before !~# s:PATTERN_COLL_METHOD
    return [s:CTX_NONE, -1]
  endif
  
  let l:match_pos = match(a:before, '\w*$')
  return [s:CTX_COLL_METHOD, a:offset + l:match_pos]
endfunction

" Detect database method/collection context: db.something
function! s:detect_db_method(before, offset) abort
  if a:before !~# s:PATTERN_DB_DOT
    return [s:CTX_NONE, -1]
  endif
  
  " Exclude if it's a collection method pattern
  if a:before =~# 'db\.\w\+\.'
    return [s:CTX_NONE, -1]
  endif
  
  let l:db_pos = match(a:before, 'db\.')
  return [s:CTX_DB_METHOD, a:offset + l:db_pos + 3]
endfunction

" Detect operator context: $operator
function! s:detect_operator(before, offset) abort
  if a:before !~# s:PATTERN_OPERATOR
    return [s:CTX_NONE, -1]
  endif
  
  let l:pos = match(a:before, s:PATTERN_OPERATOR)
  let l:after_op = matchstr(a:before, '\$\w\+$')
  let l:has_word_after = len(l:after_op) > 1
  let l:actual_pos = a:offset + (l:has_word_after ? l:pos : l:pos + 1)
  return [s:CTX_OPERATOR, l:actual_pos]
endfunction

" Main context detection function
function! s:get_context() abort
  let l:line_num = line('.')
  let l:col = col('.') - 1  " 0-based column
  let l:current_line = getline(l:line_num)
  let l:before = l:current_line[:l:col]
  
  " Try simple patterns first (single line, fast)
  let l:result = s:detect_chain_method(l:before, 0)
  if l:result[0] != s:CTX_NONE
    return l:result
  endif
  
  let l:result = s:detect_coll_method(l:before, 0)
  if l:result[0] != s:CTX_NONE
    return l:result
  endif
  
  let l:result = s:detect_db_method(l:before, 0)
  if l:result[0] != s:CTX_NONE
    return l:result
  endif
  
  " If simple patterns fail, get multiline context for complex patterns
  let [l:before, l:after, l:offset] = s:get_multiline_context(l:line_num, l:col)
  
  " Try operator detection (needs multiline context)
  let l:result = s:detect_operator(l:before, l:offset)
  if l:result[0] != s:CTX_NONE
    return l:result
  endif
  
  " Try chain method with multiline context
  let l:result = s:detect_chain_method(l:before, l:offset)
  if l:result[0] != s:CTX_NONE
    return l:result
  endif
  
  " Try collection method with multiline context
  let l:result = s:detect_coll_method(l:before, l:offset)
  if l:result[0] != s:CTX_NONE
    return l:result
  endif
  
  " Try database method with multiline context
  let l:result = s:detect_db_method(l:before, l:offset)
  if l:result[0] != s:CTX_NONE
    return l:result
  endif
  
  return [s:CTX_NONE, -1]
endfunction


" =============================================================================
" Cache Management
" =============================================================================

" Context cache: { 'line:col': [ctx_info, timestamp] }
let s:context_cache = {}
let s:context_cache_ttl = 1  " 1 second TTL for context cache

function! s:get_cached_context(line, col) abort
  let l:key = a:line . ':' . a:col
  if has_key(s:context_cache, l:key)
    let l:cached = s:context_cache[l:key]
    " Check if cache is still valid (within 1 second)
    if localtime() - l:cached[1] < s:context_cache_ttl
      return l:cached[0]
    endif
    " Cache expired, remove it
    call remove(s:context_cache, l:key)
  endif
  return v:null
endfunction

function! s:set_cached_context(line, col, ctx_info) abort
  let l:key = a:line . ':' . a:col
  let s:context_cache[l:key] = [a:ctx_info, localtime()]
  " Clean up old cache entries (keep only last 10)
  if len(s:context_cache) > 10
    let l:keys = keys(s:context_cache)
    call sort(l:keys, {a, b -> s:context_cache[a][1] - s:context_cache[b][1]})
    for l:k in l:keys[:len(l:keys) - 10]
      call remove(s:context_cache, l:k)
    endfor
  endif
endfunction

" =============================================================================
" Completion
" =============================================================================

" Saved context structure: [type, start_col, collection, method, param_index]
let s:saved_ctx = [s:CTX_NONE, -1, '', '', 0]

 function! dbcp#adapter#mongodb#complete(findstart, base, db_url) abort
   if a:findstart
     " First call: detect context and save it
     let l:line = line('.')
     let l:col = col('.')

     " Try to get from cache first
     let l:ctx_info = s:get_cached_context(l:line, l:col)
     if l:ctx_info is v:null
       " Cache miss, compute context
       let l:ctx_info = s:get_context()
       " Cache the result
       call s:set_cached_context(l:line, l:col, l:ctx_info)
     endif

     let s:saved_ctx = l:ctx_info
     let l:ctx_type = l:ctx_info[0]
     let l:start_col = l:ctx_info[1]

     return l:ctx_type == s:CTX_NONE ? -1 : l:start_col
   endif

  " Second call: use saved context
  let l:ctx_type = s:saved_ctx[0]
  let l:collection = len(s:saved_ctx) > 2 ? s:saved_ctx[2] : ''
  let l:method = len(s:saved_ctx) > 3 ? s:saved_ctx[3] : ''

  if l:ctx_type == s:CTX_DB_METHOD
    " Combine db methods and collections
    let l:items = s:get_db_methods()
    let l:results = s:filter(a:base, l:items, 'f')
    " Only fetch collections if db_url is set
    if a:db_url != ''
      let l:collections = s:get_collections(a:db_url)
      let l:results = l:results + s:filter(a:base, l:collections, 'v')
    endif
    return l:results
  elseif l:ctx_type == s:CTX_COLL_METHOD
    return s:filter(a:base, s:get_coll_methods(), 'f')
  elseif l:ctx_type == s:CTX_CHAIN_METHOD
    return s:filter(a:base, s:get_chain_methods(), 'f')
  elseif l:ctx_type == s:CTX_OPERATOR
    return s:filter(a:base, s:get_operators(), 'v')
  endif

  return []
endfunction

" =============================================================================
" Data Definitions
" =============================================================================

let s:script_path = expand('<sfile>:p')

" =============================================================================
" DB Methods
" =============================================================================

let s:db_methods = v:null

function! s:get_db_methods() abort
  if s:db_methods isnot v:null | return s:db_methods | endif
  let l:csv = dbcp#csv#load('mongodb_db_methods.csv', s:script_path)
  let l:raw = l:csv is v:null ? [] : map(l:csv, {_, v -> [v[0], '', v[1]]})
  let s:db_methods = s:make_items(l:raw)
  return s:db_methods
endfunction

" =============================================================================
" Collection Methods
" =============================================================================

let s:coll_methods = v:null

function! s:get_coll_methods() abort
  if s:coll_methods isnot v:null | return s:coll_methods | endif
  let l:csv = dbcp#csv#load('mongodb_coll_methods.csv', s:script_path)
  let l:raw = l:csv is v:null ? [] : map(l:csv, {_, v -> [v[0], '', v[1]]})
  let s:coll_methods = s:make_items(l:raw)
  return s:coll_methods
endfunction

" =============================================================================
" Chain Methods (cursor methods after find(), findOne(), etc.)
" =============================================================================

let s:chain_methods = v:null

function! s:get_chain_methods() abort
  if s:chain_methods isnot v:null | return s:chain_methods | endif
  let l:csv = dbcp#csv#load('mongodb_chain_methods.csv', s:script_path)
  let l:raw = l:csv is v:null ? [] : map(l:csv, {_, v -> [v[0], '', v[1]]})
  let s:chain_methods = s:make_items(l:raw)
  return s:chain_methods
endfunction

" =============================================================================
" Operators
" =============================================================================

let s:operators = v:null

function! s:get_operators() abort
  if s:operators isnot v:null | return s:operators | endif
  let l:csv = dbcp#csv#load('mongodb_operators.csv', s:script_path)
  let l:raw = l:csv is v:null ? [] : map(l:csv, {_, v -> [v[0], v[1], get(v, 2, '')]})
  let s:operators = map(copy(l:raw), {_, v -> {'word': v[0], 'menu': v[1], 'info': get(v, 2, ' ')}})
  return s:operators
endfunction

" =============================================================================
" Data Access
" =============================================================================

" Database Adapter Wrapper
function! s:db_call(method, args, default) abort
  return db#adapter#call('mongodb', a:method, a:args, a:default)
endfunction

" Collections cache: { db_url: { data: [...], timestamp: <time> } }
let s:collections_cache = {}
let s:collections_cache_ttl = 300  " 5 minutes TTL

function! s:is_collections_cache_valid(cache_entry) abort
  if !has_key(a:cache_entry, 'timestamp')
    return 0
  endif
  return localtime() - a:cache_entry.timestamp < s:collections_cache_ttl
endfunction

function! s:get_collections(db_url) abort
  " Check cache validity
  if has_key(s:collections_cache, a:db_url)
    let l:cached = s:collections_cache[a:db_url]
    if s:is_collections_cache_valid(l:cached)
      return l:cached.data
    endif
    " Cache expired, remove it
    call remove(s:collections_cache, a:db_url)
  endif

  " Fetch collections from database
  try
    let l:tables = s:db_call('tables', [a:db_url], [])
  catch /.*/
    " Don't cache errors - allow retry on next completion
    return []
  endtry

  " Validate response
  if type(l:tables) != v:t_list || empty(l:tables)
    " Cache empty result with timestamp
    let s:collections_cache[a:db_url] = {
          \ 'data': [],
          \ 'timestamp': localtime()
          \ }
    return []
  endif

  " Process collections
  let l:collections = map(l:tables, {_, v -> {
        \ 'word': substitute(v, '^db\.', '', ''),
        \ 'abbr': substitute(v, '^db\.', '', ''),
        \ 'menu': 'collection',
        \ }})

  " Cache successful result
  let s:collections_cache[a:db_url] = {
        \ 'data': l:collections,
        \ 'timestamp': localtime()
        \ }
  return l:collections
endfunction

 " Function to clear cache (useful for manual refresh)
 function! dbcp#adapter#mongodb#clear_cache(...) abort
   if a:0 > 0
     " Clear specific db_url cache
     if has_key(s:collections_cache, a:1)
       call remove(s:collections_cache, a:1)
     endif
   else
     " Clear all cache
     let s:collections_cache = {}
     let s:context_cache = {}
   endif
 endfunction

" =============================================================================
" Helper Functions
" =============================================================================

function! s:make_items(raw) abort
  return map(copy(a:raw), {_, v -> {
        \ 'word': v[0],
        \ 'abbr': v[0],
        \ 'menu': v[1],
        \ 'info': get(v, 2, ' ')
        \ }})
endfunction

function! s:filter(base, items, kind) abort
  if empty(a:base)
    " Return all items if no filter
    return map(copy(a:items), {_, v -> 
          \ type(v) == v:t_dict ? extend(copy(v), {'kind': a:kind}, 'keep') 
          \ : {'word': v, 'kind': a:kind}
          \})
  endif

  let l:results = []
  let l:len = strlen(a:base)
  let l:base_lower = tolower(a:base)  " Case-insensitive matching

  for l:item in a:items
    let l:word = type(l:item) == v:t_dict ? l:item.word : l:item
    " Use case-insensitive prefix matching for better UX
    if tolower(strpart(l:word, 0, l:len)) ==# l:base_lower
      if type(l:item) == v:t_dict
        call add(l:results, extend(copy(l:item), {'kind': a:kind}, 'keep'))
      else
        call add(l:results, {'word': l:word, 'kind': a:kind})
      endif
    endif
  endfor

  return l:results
endfunction
