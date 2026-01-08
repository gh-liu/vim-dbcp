" vim-dbcp: Oracle Adapter
" Provides SQL completion for Oracle databases

if exists('g:autoloaded_dbcp_adapter_oracle')
  finish
endif
let g:autoloaded_dbcp_adapter_oracle = 1

function! dbcp#adapter#oracle#get_dialect() abort
  return {
        \ 'quote': '"',
        \ 'escape': '"',
        \ 'keywords': ['ACCESS', 'ADD', 'ALL', 'ALTER', 'AND', 'ANY', 'AS', 'ASC',
        \   'AUDIT', 'BETWEEN', 'BY', 'CHAR', 'CHECK', 'CLUSTER', 'COLUMN',
        \   'COLUMN_VALUE', 'COMMENT', 'COMPRESS', 'CONNECT', 'CREATE', 'CURRENT',
        \   'DATE', 'DECIMAL', 'DEFAULT', 'DELETE', 'DESC', 'DISTINCT', 'DROP',
        \   'ELSE', 'EXCLUSIVE', 'EXISTS', 'FILE', 'FLOAT', 'FOR', 'FROM', 'GRANT',
        \   'GROUP', 'HAVING', 'IDENTIFIED', 'IMMEDIATE', 'IN', 'INCREMENT',
        \   'INDEX', 'INITIAL', 'INSERT', 'INTEGER', 'INTERSECT', 'INTO', 'IS',
        \   'LEVEL', 'LIKE', 'LOCK', 'LONG', 'MAXEXTENTS', 'MINUS', 'MLSLABEL',
        \   'MODE', 'MODIFY', 'NESTED_TABLE_ID', 'NOAUDIT', 'NOCOMPRESS', 'NOT',
        \   'NOWAIT', 'NULL', 'NUMBER', 'OF', 'OFFLINE', 'ON', 'ONLINE', 'OPTION',
        \   'OR', 'ORDER', 'PCTFREE', 'PRIOR', 'PUBLIC', 'RAW', 'RENAME',
        \   'RESOURCE', 'REVOKE', 'ROW', 'ROWID', 'ROWNUM', 'ROWS', 'SELECT',
        \   'SESSION', 'SET', 'SHARE', 'SIZE', 'SMALLINT', 'START', 'SUCCESSFUL',
        \   'SYNONYM', 'SYSDATE', 'TABLE', 'THEN', 'TO', 'TRIGGER', 'UID', 'UNION',
        \   'UNIQUE', 'UPDATE', 'USER', 'VALIDATE', 'VALUES', 'VARCHAR', 'VARCHAR2',
        \   'VIEW', 'WHENEVER', 'WHERE', 'WITH'],
        \ }
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
