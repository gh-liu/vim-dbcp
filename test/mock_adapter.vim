" Mock database adapter for testing
" Enhanced version supporting all database types
" This file should be placed in test/tmp/autoload/db/adapter.vim

function! db#adapter#call(scheme, method, args, ...) abort
  " ============================================================================
  " SQL Databases (PostgreSQL, MySQL, MariaDB, SQLite, SQL Server, Oracle)
  " ============================================================================
  if a:scheme =~# '^\(postgresql\|mysql\|mariadb\|sqlite\|sqlserver\|oracle\)$'
    if a:method ==# 'tables'
      return ['users', 'orders', 'products', 'order_items', 'order']
    elseif a:method ==# 'columns'
      if len(a:args) >= 2
        let l:table = a:args[1]
        if l:table ==# 'users'
          return ['id', 'name', 'email', 'created_at', 'select']
        elseif l:table ==# 'orders'
          return ['id', 'user_id', 'total', 'status', 'created_at']
        elseif l:table ==# 'products'
          return ['id', 'name', 'price', 'stock']
        elseif l:table ==# 'order_items'
          return ['id', 'order_id', 'product_id', 'quantity']
        elseif l:table ==# 'order'
          return ['id', 'user_id', 'total']
        endif
      endif
    endif
  
  " ============================================================================
  " MongoDB
  " ============================================================================
  elseif a:scheme ==# 'mongodb'
    if a:method ==# 'tables'
      " Return collections in format: db.collection_name
      return ['db.users', 'db.products', 'db.orders']
    endif
  
  " ============================================================================
  " Redis
  " ============================================================================
  elseif a:scheme ==# 'redis'
    if a:method ==# 'keys'
      " args: [db_url, pattern, limit]
      " Return list of keys matching pattern
      let l:pattern = len(a:args) >= 2 ? a:args[1] : '*'
      let l:all_keys = ['user:1', 'user:2', 'user:3', 'session:abc', 'session:def', 'product:100', 'product:200']
      
      " Simple pattern matching (support * wildcard)
      if l:pattern ==# '*' || l:pattern ==# ''
        return l:all_keys
      endif
      
      " Convert pattern to regex
      let l:pattern_regex = substitute(l:pattern, '\*', '.*', 'g')
      let l:pattern_regex = '^' . l:pattern_regex . '$'
      
      return filter(copy(l:all_keys), {_, v -> v =~# l:pattern_regex})
    elseif a:method ==# 'hkeys'
      " args: [db_url, key]
      " Return hash field names for a key
      if len(a:args) >= 2
        let l:key = a:args[1]
        if l:key ==# 'user:1' || l:key ==# 'user:2' || l:key ==# 'user:3'
          return ['name', 'email', 'age', 'created_at']
        elseif l:key =~# '^session:'
          return ['token', 'expires', 'user_id']
        elseif l:key =~# '^product:'
          return ['name', 'price', 'stock', 'description']
        endif
      endif
      return []
    endif
  endif
  
  return []
endfunction
