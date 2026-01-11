" vim-dbcp: Redis Adapter
" Provides completion for Redis commands

if exists('g:autoloaded_dbcp_adapter_redis')
  finish
endif
let g:autoloaded_dbcp_adapter_redis = 1

" =============================================================================
" Constants
" =============================================================================

let s:CTX_NONE = 0
let s:CTX_COMMAND = 1
let s:CTX_SUBCOMMAND = 2
let s:CTX_KEY = 3
let s:CTX_HASH_FIELD = 4
let s:CTX_OPTION = 5

let s:CACHE_TTL = 300

" =============================================================================
" Data Definitions & Loading
" =============================================================================

let s:COMMANDS = v:null
let s:SUBCOMMANDS = v:null
let s:OPTIONS = v:null
let s:KEY_COMMANDS = v:null

let s:script_path = expand('<sfile>:p')

function! s:load_commands() abort
  if s:COMMANDS isnot v:null | return s:COMMANDS | endif
  let l:csv = dbcp#csv#load('redis_commands.csv', s:script_path)
  let s:COMMANDS = l:csv is v:null ? [] : map(l:csv, {_, v -> [v[0], v[1]]})
  return s:COMMANDS
endfunction

function! s:load_subcommands() abort
  if s:SUBCOMMANDS isnot v:null | return s:SUBCOMMANDS | endif
  let l:csv = dbcp#csv#load('redis_subcommands.csv', s:script_path)
  let s:SUBCOMMANDS = {}
  if l:csv isnot v:null
    for l:row in l:csv
      if len(l:row) >= 4
        if !has_key(s:SUBCOMMANDS, l:row[3])
          let s:SUBCOMMANDS[l:row[3]] = []
        endif
        call add(s:SUBCOMMANDS[l:row[3]], [l:row[0]])
      endif
    endfor
  endif
  return s:SUBCOMMANDS
endfunction

function! s:load_options() abort
  if s:OPTIONS isnot v:null | return s:OPTIONS | endif
  let l:csv = dbcp#csv#load('redis_options.csv', s:script_path)
  let s:OPTIONS = {}
  if l:csv isnot v:null
    for l:row in l:csv
      if len(l:row) >= 4
        if !has_key(s:OPTIONS, l:row[3])
          let s:OPTIONS[l:row[3]] = []
        endif
        call add(s:OPTIONS[l:row[3]], [l:row[0]])
      endif
    endfor
  endif
  return s:OPTIONS
endfunction

function! s:load_key_commands() abort
  if s:KEY_COMMANDS isnot v:null | return s:KEY_COMMANDS | endif
  let l:csv = dbcp#csv#load('redis_key_commands.csv', s:script_path)
  let s:KEY_COMMANDS = l:csv is v:null ? [] : map(l:csv, {_, v -> v[0]})
  return s:KEY_COMMANDS
endfunction

" =============================================================================
" Helper Functions
" =============================================================================

function! s:make_items(raw) abort
  return map(copy(a:raw), {_, v -> {
        \ 'word': v[0],
        \ 'abbr': v[0],
        \ 'menu': get(v, 1, ''),
        \ 'kind': 'v',
        \ }})
endfunction

function! s:filter(base, items) abort
  if empty(a:base) | return a:items | endif
  let l:base_lower = tolower(a:base)
  return filter(copy(a:items), {_, v -> tolower(v.word) =~# '^' . l:base_lower})
endfunction

function! s:db_call(method, args, default) abort
  try
    return db#adapter#call('redis', a:method, a:args, a:default)
  catch | return a:default | endtry
endfunction

" =============================================================================
" Context Detection
" =============================================================================

function! s:get_context() abort
  let l:line = getline('.')
  let l:col = col('.') - 1
  let l:before = l:line[:l:col]
  
  " Get multiline context (up to 5 lines back)
  let l:start_line = max([1, line('.') - 5])
  let l:multiline = join(map(range(l:start_line, line('.') - 1), 'getline(v:val)'), ' ') . ' ' . l:before
  let l:offset = len(l:multiline) - len(l:before)
  
  " Parse command line (simple split, handle quotes)
  let l:parts = s:parse_line(l:multiline)
  if empty(l:parts) | return [s:CTX_NONE, -1, '', ''] | endif
  
  let l:cmd = toupper(l:parts[0])
  let l:len = len(l:parts)
  let l:last_part = get(l:parts, -1, '')
  let l:last_pos = strridx(l:multiline, l:last_part)
  if l:last_pos == -1 | let l:last_pos = len(l:multiline) - len(l:last_part) | endif

  " Subcommand: CLIENT LIST, CONFIG GET, etc.
  " When user types "CLIENT " (len=1), we should offer subcommand completion
  let l:subcommands = s:load_subcommands()
  if has_key(l:subcommands, l:cmd) && (l:len == 1 || (l:len == 2 && l:last_part =~# '^\w*$'))
    return [s:CTX_SUBCOMMAND, l:offset + l:last_pos, l:cmd, '']
  endif

  " Option: SET key value EX/PX/NX/XX
  " When user types "SET key value " (len=3), we should offer option completion
  if l:cmd ==# 'SET' && l:len >= 3 && (l:last_part =~# '^\w*$' || l:last_part ==# '')
    if empty(l:last_part) || toupper(l:last_part) =~# '^\(EX\|PX\|NX\|XX\|GET\|KEEPTTL\|EXAT\|PXAT\)'
      return [s:CTX_OPTION, l:offset + l:last_pos, l:cmd, '']
    endif
  endif

  " Hash field: HGET key field, HSET key field value
  " When user types "HGET key " (len=2), we should offer field completion
  if l:cmd =~# '^H\(GET\|SET\|DEL\)$' && (l:len == 2 || (l:len == 3 && l:last_part =~# '^\w*$'))
    return [s:CTX_HASH_FIELD, l:offset + l:last_pos, l:cmd, l:parts[1]]
  endif

  " Key: command key
  " When user types "GET " (len=1), we should offer key completion
  let l:key_commands = s:load_key_commands()
  if index(l:key_commands, l:cmd) >= 0 && (l:len == 1 || (l:len == 2 && l:last_part =~# '^\w*$'))
    return [s:CTX_KEY, l:offset + l:last_pos, l:cmd, '']
  endif

  " Command: at start of line
  let l:trimmed = substitute(l:before, '^\s*', '', '')
  if l:trimmed =~# '^\w*$'
    let l:start = match(l:trimmed, '\w')
    return [s:CTX_COMMAND, l:start, '', '']
  endif

  return [s:CTX_NONE, -1, '', '']
endfunction

function! s:parse_line(text) abort
  let l:parts = []
  let l:current = ''
  let l:in_quote = 0
  let l:quote_char = ''
  
  for l:char in split(a:text, '\zs')
    if l:in_quote
      if l:char == l:quote_char
        let l:in_quote = 0
        let l:quote_char = ''
        if l:current != '' | call add(l:parts, l:current) | let l:current = '' | endif
      else
        let l:current .= l:char
      endif
    elseif l:char == '"' || l:char == "'"
      let l:in_quote = 1
      let l:quote_char = l:char
      if l:current != '' | call add(l:parts, l:current) | let l:current = '' | endif
    elseif l:char =~# '\s'
      if l:current != '' | call add(l:parts, l:current) | let l:current = '' | endif
    else
      let l:current .= l:char
    endif
  endfor
  
  if l:current != '' | call add(l:parts, l:current) | endif
  return l:parts
endfunction

" =============================================================================
" Data Access & Cache
" =============================================================================

let s:cache = {}

function! s:get_cached(key) abort
  if has_key(s:cache, a:key)
    let l:entry = s:cache[a:key]
    if localtime() - l:entry.timestamp < s:CACHE_TTL
      return l:entry.data
    endif
    call remove(s:cache, a:key)
  endif
  return v:null
endfunction

function! s:set_cached(key, data) abort
  let s:cache[a:key] = {'data': a:data, 'timestamp': localtime()}
endfunction

function! s:get_keys(db_url, pattern) abort
  let l:cache_key = a:db_url . ':keys:' . a:pattern
  let l:cached = s:get_cached(l:cache_key)
  if l:cached isnot v:null | return l:cached | endif
  
  try
    let l:keys = s:db_call('keys', [a:db_url, a:pattern, 1000], [])
    if type(l:keys) == v:t_list
      let l:items = map(l:keys, {_, v -> {'word': v, 'abbr': v, 'menu': 'key', 'kind': 'v'}})
      call s:set_cached(l:cache_key, l:items)
      return l:items
    endif
  catch | endtry
  call s:set_cached(l:cache_key, [])
  return []
endfunction

function! s:get_hash_fields(db_url, key) abort
  let l:cache_key = a:db_url . ':fields:' . a:key
  let l:cached = s:get_cached(l:cache_key)
  if l:cached isnot v:null | return l:cached | endif
  
  try
    let l:fields = s:db_call('hkeys', [a:db_url, a:key], [])
    if type(l:fields) == v:t_list
      let l:items = map(l:fields, {_, v -> {'word': v, 'abbr': v, 'menu': 'field', 'kind': 'v'}})
      call s:set_cached(l:cache_key, l:items)
      return l:items
    endif
  catch | endtry
  call s:set_cached(l:cache_key, [])
  return []
endfunction

" =============================================================================
" Main Completion Function
" =============================================================================

let s:saved_ctx = [s:CTX_NONE, -1, '', '']

function! dbcp#adapter#redis#complete(findstart, base, db_url) abort
  if a:findstart
    let l:ctx = s:get_context()
    if len(l:ctx) < 4 | call add(l:ctx, '') | endif
    let s:saved_ctx = l:ctx
    return l:ctx[0] == s:CTX_NONE ? -1 : l:ctx[1]
  endif
  
  let [l:type, _, l:cmd, l:extra] = s:saved_ctx
  
  if l:type == s:CTX_COMMAND
    return s:filter(a:base, s:make_items(s:load_commands()))
  elseif l:type == s:CTX_SUBCOMMAND
    let l:subcommands = s:load_subcommands()
    let l:subs = get(l:subcommands, l:cmd, [])
    if !empty(l:subs)
      return s:filter(a:base, s:make_items(l:subs))
    endif
  elseif l:type == s:CTX_OPTION
    let l:options = s:load_options()
    let l:opts = get(l:options, l:cmd, [])
    if !empty(l:opts)
      return s:filter(a:base, s:make_items(l:opts))
    endif
  elseif l:type == s:CTX_KEY && a:db_url != ''
    return s:filter(a:base, s:get_keys(a:db_url, empty(a:base) ? '*' : a:base . '*'))
  elseif l:type == s:CTX_HASH_FIELD && a:db_url != '' && l:extra != ''
    return s:filter(a:base, s:get_hash_fields(a:db_url, l:extra))
  endif
  
  return []
endfunction

" =============================================================================
" Cache Management
" =============================================================================

function! dbcp#adapter#redis#clear_cache(...) abort
  if a:0 > 0
    let l:prefix = a:1 . ':'
    call filter(s:cache, {k, v -> stridx(k, l:prefix) != 0})
  else
    let s:cache = {}
  endif
endfunction
