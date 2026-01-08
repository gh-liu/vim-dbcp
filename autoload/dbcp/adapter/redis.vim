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
" Data Definitions
" =============================================================================

let s:COMMANDS = [
      \ ['GET', 'Get value'], ['SET', 'Set value'], ['DEL', 'Delete keys'],
      \ ['EXISTS', 'Check key exists'], ['EXPIRE', 'Set expiration'], ['TTL', 'Get TTL'],
      \ ['TYPE', 'Get value type'], ['KEYS', 'Find keys by pattern'], ['SCAN', 'Iterate keys'],
      \ ['MGET', 'Get multiple values'], ['MSET', 'Set multiple keys'], ['INCR', 'Increment'],
      \ ['DECR', 'Decrement'], ['HGET', 'Get hash field'], ['HSET', 'Set hash field'],
      \ ['HDEL', 'Delete hash fields'], ['HGETALL', 'Get all hash fields'], ['LPUSH', 'Push to list head'],
      \ ['RPUSH', 'Push to list tail'], ['LPOP', 'Pop from list head'], ['RPOP', 'Pop from list tail'],
      \ ['LLEN', 'Get list length'], ['SADD', 'Add set member'], ['SMEMBERS', 'Get all set members'],
      \ ['SISMEMBER', 'Check set membership'], ['ZADD', 'Add sorted set member'], ['ZRANGE', 'Get range by rank'],
      \ ['PUBLISH', 'Publish to channel'], ['INFO', 'Get server info'], ['CLIENT', 'Client commands'],
      \ ['CONFIG', 'Configuration'], ['ACL', 'Access control'], ['PING', 'Check connection'],
      \ ['AUTH', 'Authenticate'], ['SELECT', 'Select database'], ['FLUSHDB', 'Flush current database'],
      \ ['FLUSHALL', 'Flush all databases'], ['BGSAVE', 'Background save'], ['SAVE', 'Save database'],
      \ ['SHUTDOWN', 'Shutdown server'], ['EVAL', 'Evaluate Lua script'], ['MULTI', 'Start transaction'],
      \ ['EXEC', 'Execute transaction'], ['WATCH', 'Watch keys'], ['UNWATCH', 'Unwatch keys'],
      \ ['DBSIZE', 'Database size'], ['ECHO', 'Echo message'], ['QUIT', 'Quit connection'],
      \ ['COPY', 'Copy key'], ['MOVE', 'Move key'], ['RENAME', 'Rename key'], ['RENAMENX', 'Rename if not exists'],
      \ ['SORT', 'Sort elements'], ['BITCOUNT', 'Count bits'], ['BITOP', 'Bitwise operations'],
      \ ['GEOADD', 'Add geospatial'], ['GEORADIUS', 'Query by radius'], ['XADD', 'Add to stream'],
      \ ['XRANGE', 'Get stream range'], ['XREAD', 'Read from stream'], ['PFADD', 'Add to HyperLogLog'],
      \ ['PFCOUNT', 'Count unique'], ['PFMERGE', 'Merge HyperLogLogs'], ['WAIT', 'Wait for replication'],
      \ ['CLUSTER', 'Cluster commands'], ['MEMORY', 'Memory commands'], ['LATENCY', 'Latency monitoring'],
      \ ['SLOWLOG', 'Slow log'], ['OBJECT', 'Object commands'], ['TIME', 'Server time'],
      \ ['MODULE', 'Module commands'], ['REPLICAOF', 'Make replica'], ['ROLE', 'Show role info'],
      \ ['DEBUG', 'Debug commands']]

let s:SUBCOMMANDS = {
      \ 'CLIENT': [['LIST'], ['KILL'], ['SETNAME'], ['GETNAME'], ['ID'], ['INFO'], ['PAUSE'], ['UNPAUSE']],
      \ 'CONFIG': [['GET'], ['SET'], ['REWRITE'], ['RESETSTAT'], ['RESET']],
      \ 'ACL': [['LIST'], ['GETUSER'], ['SETUSER'], ['DELUSER'], ['CAT'], ['GENPASS'], ['WHOAMI'], ['LOG'], ['SAVE'], ['LOAD']],
      \ 'CLUSTER': [['INFO'], ['NODES'], ['MEET'], ['FORGET'], ['REPLICATE'], ['REPLICAS'], ['FAILOVER'], ['SLOTS'], ['KEYSLOT']],
      \ 'MEMORY': [['USAGE'], ['STATS'], ['MALLOC-STATS'], ['DOCTOR'], ['PURGE']],
      \ 'LATENCY': [['HISTORY'], ['GRAPH'], ['LATEST'], ['RESET'], ['DOCTOR']],
      \ 'SLOWLOG': [['GET'], ['LEN'], ['RESET']],
      \ 'OBJECT': [['ENCODING'], ['FREQ'], ['IDLETIME'], ['REFCOUNT']],
      \ 'MODULE': [['LIST'], ['LOAD'], ['UNLOAD'], ['LOADEX']],
      \ 'DEBUG': [['OBJECT'], ['RELOAD'], ['RESTART'], ['SLEEP'], ['SEGFAULT']],
      \ }

let s:OPTIONS = {
      \ 'SET': [['EX'], ['PX'], ['EXAT'], ['PXAT'], ['NX'], ['XX'], ['GET'], ['KEEPTTL']],
      \ }

let s:KEY_COMMANDS = ['GET', 'SET', 'DEL', 'EXISTS', 'EXPIRE', 'TTL', 'TYPE', 'MGET', 'MSET',
      \ 'INCR', 'DECR', 'COPY', 'MOVE', 'RENAME', 'RENAMENX', 'HGET', 'HSET', 'HDEL', 'HGETALL',
      \ 'LPUSH', 'RPUSH', 'LPOP', 'RPOP', 'LLEN', 'SADD', 'SMEMBERS', 'SISMEMBER', 'ZADD', 'ZRANGE',
      \ 'WATCH', 'SORT', 'BITCOUNT', 'BITOP', 'GEOADD', 'GEORADIUS', 'XADD', 'XRANGE', 'XREAD',
      \ 'PFADD', 'PFCOUNT', 'PFMERGE']

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
  if has_key(s:SUBCOMMANDS, l:cmd) && l:len == 2 && l:last_part =~# '^\w*$'
    return [s:CTX_SUBCOMMAND, l:offset + l:last_pos, l:cmd, '']
  endif
  
  " Option: SET key value EX/PX/NX/XX
  if l:cmd ==# 'SET' && l:len >= 3 && l:last_part =~# '^\w*$'
    if empty(l:last_part) || toupper(l:last_part) =~# '^\(EX\|PX\|NX\|XX\|GET\|KEEPTTL\|EXAT\|PXAT\)'
      return [s:CTX_OPTION, l:offset + l:last_pos, l:cmd, '']
    endif
  endif
  
  " Hash field: HGET key field, HSET key field value
  if l:cmd =~# '^H\(GET\|SET\|DEL\)$' && l:len == 3
    return [s:CTX_HASH_FIELD, l:offset + l:last_pos, l:cmd, l:parts[1]]
  endif
  
  " Key: command key
  if index(s:KEY_COMMANDS, l:cmd) >= 0 && l:len == 2 && l:last_part =~# '^\w*$'
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
    return s:filter(a:base, s:make_items(s:COMMANDS))
  elseif l:type == s:CTX_SUBCOMMAND
    let l:subs = get(s:SUBCOMMANDS, l:cmd, [])
    if !empty(l:subs)
      return s:filter(a:base, s:make_items(l:subs))
    endif
  elseif l:type == s:CTX_OPTION
    let l:opts = get(s:OPTIONS, l:cmd, [])
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
