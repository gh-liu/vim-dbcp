" vim-dbcp: PostgreSQL Adapter
" Provides SQL completion for PostgreSQL databases

if exists('g:autoloaded_dbcp_adapter_postgresql')
  finish
endif
let g:autoloaded_dbcp_adapter_postgresql = 1

function! dbcp#adapter#postgresql#get_dialect() abort
  return {
        \ 'quote': '"',
        \ 'escape': '"',
        \ 'keywords': ['ALL', 'ANALYSE', 'ANALYZE', 'AND', 'ANY', 'ARRAY', 'AS',
        \   'ASC', 'ASYMMETRIC', 'AUTHORIZATION', 'BINARY', 'BOTH', 'CASE',
        \   'CAST', 'CHECK', 'COLLATE', 'COLLATION', 'COLUMN', 'CONCURRENTLY',
        \   'CONSTRAINT', 'CREATE', 'CROSS', 'CURRENT_CATALOG', 'CURRENT_DATE',
        \   'CURRENT_ROLE', 'CURRENT_SCHEMA', 'CURRENT_TIME', 'CURRENT_TIMESTAMP',
        \   'CURRENT_USER', 'DEFAULT', 'DEFERRABLE', 'DESC', 'DISTINCT', 'DO',
        \   'ELSE', 'END', 'EXCEPT', 'FALSE', 'FETCH', 'FOR', 'FOREIGN', 'FROM',
        \   'FULL', 'GRANT', 'GROUP', 'HAVING', 'ILIKE', 'IN', 'INITIALLY',
        \   'INNER', 'INTERSECT', 'INTO', 'IS', 'ISNULL', 'JOIN', 'LATERAL',
        \   'LEADING', 'LEFT', 'LIKE', 'LIMIT', 'LOCALTIME', 'LOCALTIMESTAMP',
        \   'NATURAL', 'NOT', 'NOTNULL', 'NULL', 'OFFSET', 'ON', 'ONLY', 'OR',
        \   'ORDER', 'OUTER', 'OVERLAPS', 'PLACING', 'PRIMARY', 'REFERENCES',
        \   'RETURNING', 'RIGHT', 'SELECT', 'SESSION_USER', 'SIMILAR', 'SOME',
        \   'SYMMETRIC', 'TABLE', 'TABLESAMPLE', 'THEN', 'TO', 'TRAILING',
        \   'TRUE', 'UNION', 'UNIQUE', 'USER', 'USING', 'VARIADIC', 'VERBOSE',
        \   'WHEN', 'WHERE', 'WINDOW', 'WITH'],
        \ }
endfunction

function! dbcp#adapter#postgresql#complete(findstart, base, db_url) abort
  return dbcp#sql#complete(a:findstart, a:base, a:db_url, 'postgresql')
endfunction

function! dbcp#adapter#postgresql#clear_cache(...) abort
  if a:0 > 0
    call dbcp#sql#clear_cache(a:1)
  else
    call dbcp#sql#clear_cache()
  endif
endfunction
