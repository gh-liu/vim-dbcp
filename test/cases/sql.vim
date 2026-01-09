" SQL Database Completion Test Cases
" Covers: PostgreSQL, MySQL, MariaDB, SQLite, SQL Server, Oracle

" Load framework
runtime test/framework.vim

" =============================================================================
" Test Group: Table Name Completion
" =============================================================================

call dbcp#test#group('SQL - Table Name Completion')

" Test: Table after FROM
call dbcp#test#register({
      \ 'name': 'Table after FROM',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT * FROM '],
      \ 'cursor_pos': [1, 17],
      \ 'expected_start': 15,
      \ 'expected_contains': ['users', 'orders', 'products']
      \ })

" Test: Table after JOIN
call dbcp#test#register({
      \ 'name': 'Table after JOIN',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT * FROM users JOIN '],
      \ 'cursor_pos': [1, 32],
      \ 'expected_start': 27,
      \ 'expected_contains': ['users', 'orders', 'products']
      \ })

" Test: Table after LEFT JOIN
call dbcp#test#register({
      \ 'name': 'Table after LEFT JOIN',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT * FROM users LEFT JOIN '],
      \ 'cursor_pos': [1, 38],
      \ 'expected_start': 27,
      \ 'expected_contains': ['users', 'orders']
      \ })

" Test: Table after UPDATE
call dbcp#test#register({
      \ 'name': 'Table after UPDATE',
      \ 'db_type': 'postgresql',
      \ 'context': ['UPDATE '],
      \ 'cursor_pos': [1, 8],
      \ 'expected_start': 7,
      \ 'expected_contains': ['users', 'orders']
      \ })

" Test: Table after INSERT INTO
call dbcp#test#register({
      \ 'name': 'Table after INSERT INTO',
      \ 'db_type': 'postgresql',
      \ 'context': ['INSERT INTO '],
      \ 'cursor_pos': [1, 13],
      \ 'expected_start': 12,
      \ 'expected_contains': ['users', 'orders']
      \ })

" Test: Table after DELETE FROM
call dbcp#test#register({
      \ 'name': 'Table after DELETE FROM',
      \ 'db_type': 'postgresql',
      \ 'context': ['DELETE FROM '],
      \ 'cursor_pos': [1, 13],
      \ 'expected_start': 12,
      \ 'expected_contains': ['users', 'orders']
      \ })

" =============================================================================
" Test Group: Column Name Completion
" =============================================================================

call dbcp#test#group('SQL - Column Name Completion')

" Test: Column after table.
call dbcp#test#register({
      \ 'name': 'Column after table.',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT users.'],
      \ 'cursor_pos': [1, 13],
      \ 'expected_start': 13,
      \ 'expected_contains': ['id', 'name', 'email', 'created_at']
      \ })

" Test: Column after alias.
call dbcp#test#register({
      \ 'name': 'Column after alias.',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT * FROM users u WHERE u.'],
      \ 'cursor_pos': [1, 36],
      \ 'expected_start': 35,
      \ 'expected_contains': ['id', 'name', 'email']
      \ })

" Test: Column with AS alias
call dbcp#test#register({
      \ 'name': 'Column with AS alias',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT * FROM orders AS o WHERE o.'],
      \ 'cursor_pos': [1, 42],
      \ 'expected_start': 41,
      \ 'expected_contains': ['id', 'user_id', 'total']
      \ })

" Test: Column with implicit alias
call dbcp#test#register({
      \ 'name': 'Column with implicit alias',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT * FROM users users WHERE users.'],
      \ 'cursor_pos': [1, 44],
      \ 'expected_start': 38,
      \ 'expected_contains': ['id', 'name', 'email']
      \ })

" =============================================================================
" Test Group: Multi-line Context
" =============================================================================

call dbcp#test#group('SQL - Multi-line Context')

" Test: Multi-line table completion
call dbcp#test#register({
      \ 'name': 'Multi-line table completion',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT *', 'FROM '],
      \ 'cursor_pos': [2, 6],
      \ 'expected_start': 5,
      \ 'expected_contains': ['users', 'orders']
      \ })

" Test: Multi-line column completion
call dbcp#test#register({
      \ 'name': 'Multi-line column completion',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT *', 'FROM users u', 'WHERE u.'],
      \ 'cursor_pos': [3, 10],
      \ 'expected_start': 8,
      \ 'expected_contains': ['id', 'name', 'email']
      \ })

" Test: Complex JOIN with column completion
call dbcp#test#register({
      \ 'name': 'Complex JOIN column completion',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT u.name, o.total', 'FROM users u', 'JOIN orders o ON u.id = o.user_id', 'WHERE o.'],
      \ 'cursor_pos': [4, 8],
      \ 'expected_start': 7,
      \ 'expected_contains': ['id', 'total', 'user_id']
      \ })

" =============================================================================
" Test Group: Filtering
" =============================================================================

call dbcp#test#group('SQL - Filtering')

" Test: Filter table names
call dbcp#test#register({
      \ 'name': 'Filter table names',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT * FROM ord'],
      \ 'cursor_pos': [1, 20],
      \ 'base': 'ord',
      \ 'expected_start': 15,
      \ 'expected_contains': ['orders', 'order_items']
      \ })

" Test: Filter column names
call dbcp#test#register({
      \ 'name': 'Filter column names',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT users.cre'],
      \ 'cursor_pos': [1, 19],
      \ 'base': 'cre',
      \ 'expected_start': 13,
      \ 'expected_contains': ['created_at']
      \ })

" =============================================================================
" Test Group: No Completion Contexts
" =============================================================================

call dbcp#test#group('SQL - No Completion Contexts')

" Test: No completion in WHERE without table/alias
call dbcp#test#register({
      \ 'name': 'No completion in WHERE without context',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT * FROM users WHERE '],
      \ 'cursor_pos': [1, 30],
      \ 'expected_start': -1
      \ })

" =============================================================================
" Test Group: Dialect-specific Quoting
" =============================================================================

call dbcp#test#group('SQL - Dialect Quoting')

" Test: PostgreSQL reserved word quoting
call dbcp#test#register({
      \ 'name': 'PostgreSQL reserved word quoting',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT * FROM ord'],
      \ 'cursor_pos': [1, 20],
      \ 'base': 'ord',
      \ 'expected_start': 15,
      \ 'expected_contains': ['"order"']
      \ })

" Test: MySQL reserved word quoting
call dbcp#test#register({
      \ 'name': 'MySQL reserved word quoting',
      \ 'db_type': 'mysql',
      \ 'context': ['SELECT * FROM ord'],
      \ 'cursor_pos': [1, 20],
      \ 'base': 'ord',
      \ 'expected_start': 15,
      \ 'expected_contains': ['`order`']
      \ })

" Test: SQL Server reserved word quoting
call dbcp#test#register({
      \ 'name': 'SQL Server reserved word quoting',
      \ 'db_type': 'sqlserver',
      \ 'context': ['SELECT * FROM ord'],
      \ 'cursor_pos': [1, 20],
      \ 'base': 'ord',
      \ 'expected_start': 15,
      \ 'expected_contains': ['[order]']
      \ })

" Test: PostgreSQL column reserved word quoting
call dbcp#test#register({
      \ 'name': 'PostgreSQL column reserved word quoting',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT users.'],
      \ 'cursor_pos': [1, 13],
      \ 'expected_start': 13,
      \ 'expected_contains': ['"select"']
      \ })

" =============================================================================
" Test Group: Other SQL Dialects
" =============================================================================

call dbcp#test#group('SQL - Other Dialects')

" Test: MariaDB (same as MySQL)
call dbcp#test#register({
      \ 'name': 'MariaDB table completion',
      \ 'db_type': 'mariadb',
      \ 'context': ['SELECT * FROM '],
      \ 'cursor_pos': [1, 17],
      \ 'expected_start': 15,
      \ 'expected_contains': ['users', 'orders']
      \ })

" Test: SQLite
call dbcp#test#register({
      \ 'name': 'SQLite table completion',
      \ 'db_type': 'sqlite',
      \ 'context': ['SELECT * FROM '],
      \ 'cursor_pos': [1, 17],
      \ 'expected_start': 15,
      \ 'expected_contains': ['users', 'orders']
      \ })

" Test: Oracle
call dbcp#test#register({
      \ 'name': 'Oracle table completion',
      \ 'db_type': 'oracle',
      \ 'context': ['SELECT * FROM '],
      \ 'cursor_pos': [1, 17],
      \ 'expected_start': 15,
      \ 'expected_contains': ['users', 'orders']
      \ })
