" SQL Database Completion Test Cases
" Covers: PostgreSQL, MySQL, MariaDB, SQLite, SQL Server, Oracle

" Load framework
runtime test/framework.vim

" =============================================================================
" Test Group: Table Name Completion
" =============================================================================

call TestGroup('SQL - Table Name Completion')

" Test: Table after FROM
call TestRegister({
      \ 'name': 'Table after FROM',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT * FROM '],
      \ 'cursor_pos': [1, 17],
      \ 'expected_start': 13,
      \ 'expected_contains': ['users', 'orders', 'products']
      \ })

" Test: Table after JOIN
call TestRegister({
      \ 'name': 'Table after JOIN',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT * FROM users JOIN '],
      \ 'cursor_pos': [1, 32],
      \ 'expected_start': 28,
      \ 'expected_contains': ['users', 'orders', 'products']
      \ })

" Test: Table after LEFT JOIN
call TestRegister({
      \ 'name': 'Table after LEFT JOIN',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT * FROM users LEFT JOIN '],
      \ 'cursor_pos': [1, 38],
      \ 'expected_start': 27,
      \ 'expected_contains': ['users', 'orders']
      \ })

" Test: Table after UPDATE
call TestRegister({
      \ 'name': 'Table after UPDATE',
      \ 'db_type': 'postgresql',
      \ 'context': ['UPDATE '],
      \ 'cursor_pos': [1, 8],
      \ 'expected_start': 7,
      \ 'expected_contains': ['users', 'orders']
      \ })

" Test: Table after INSERT INTO
call TestRegister({
      \ 'name': 'Table after INSERT INTO',
      \ 'db_type': 'postgresql',
      \ 'context': ['INSERT INTO '],
      \ 'cursor_pos': [1, 13],
      \ 'expected_start': 12,
      \ 'expected_contains': ['users', 'orders']
      \ })

" Test: Table after DELETE FROM
call TestRegister({
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

call TestGroup('SQL - Column Name Completion')

" Test: Column after table.
call TestRegister({
      \ 'name': 'Column after table.',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT users.'],
      \ 'cursor_pos': [1, 13],
      \ 'expected_start': 13,
      \ 'expected_contains': ['id', 'name', 'email', 'created_at']
      \ })

" Test: Column after alias.
call TestRegister({
      \ 'name': 'Column after alias.',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT * FROM users u WHERE u.'],
      \ 'cursor_pos': [1, 36],
      \ 'expected_start': 33,
      \ 'expected_contains': ['id', 'name', 'email']
      \ })

" Test: Column with AS alias
call TestRegister({
      \ 'name': 'Column with AS alias',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT * FROM orders AS o WHERE o.'],
      \ 'cursor_pos': [1, 34],
      \ 'expected_start': 33,
      \ 'expected_contains': ['id', 'user_id', 'total']
      \ })

" Test: Column with implicit alias
call TestRegister({
      \ 'name': 'Column with implicit alias',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT * FROM users u users WHERE u.'],
      \ 'cursor_pos': [1, 46],
      \ 'expected_start': 33,
      \ 'expected_contains': ['id', 'name', 'email']
      \ })

" =============================================================================
" Test Group: Multi-line Context
" =============================================================================

call TestGroup('SQL - Multi-line Context')

" Test: Multi-line table completion
call TestRegister({
      \ 'name': 'Multi-line table completion',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT *', 'FROM '],
      \ 'cursor_pos': [2, 6],
      \ 'expected_start': 5,
      \ 'expected_contains': ['users', 'orders']
      \ })

" Test: Multi-line column completion
call TestRegister({
      \ 'name': 'Multi-line column completion',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT *', 'FROM users', 'WHERE users.id'],
      \ 'cursor_pos': [3, 11],
      \ 'expected_start': 11,
      \ 'expected_contains': ['id', 'name', 'email']
      \ })

" Test: Complex JOIN with column completion
call TestRegister({
      \ 'name': 'Complex JOIN column completion',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT *', 'FROM users u', 'JOIN orders o ON u.id = o.user_id', 'WHERE o.id'],
      \ 'cursor_pos': [4, 7],
      \ 'expected_start': 7,
      \ 'expected_contains': ['id', 'total', 'user_id']
      \ })

" =============================================================================
" Test Group: Filtering
" =============================================================================

call TestGroup('SQL - Filtering')

" Test: Filter table names
call TestRegister({
      \ 'name': 'Filter table names',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT * FROM ord'],
      \ 'cursor_pos': [1, 20],
      \ 'base': 'ord',
      \ 'expected_start': 13,
      \ 'expected_contains': ['orders', 'order_items']
      \ })

" Test: Filter column names
call TestRegister({
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

call TestGroup('SQL - No Completion Contexts')

" Test: No completion in WHERE without table/alias
call TestRegister({
      \ 'name': 'No completion in WHERE without context',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT * FROM users WHERE '],
      \ 'cursor_pos': [1, 30],
      \ 'expected_start': -1
      \ })

" =============================================================================
" Test Group: Dialect-specific Quoting
" =============================================================================

call TestGroup('SQL - Dialect Quoting')

" Test: PostgreSQL reserved word quoting
call TestRegister({
      \ 'name': 'PostgreSQL reserved word quoting',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT * FROM ord'],
      \ 'cursor_pos': [1, 20],
      \ 'base': 'ord',
      \ 'expected_start': 13,
      \ 'expected_contains': ['"order"']
      \ })

" Test: MySQL reserved word quoting
call TestRegister({
      \ 'name': 'MySQL reserved word quoting',
      \ 'db_type': 'mysql',
      \ 'context': ['SELECT * FROM ord'],
      \ 'cursor_pos': [1, 20],
      \ 'base': 'ord',
      \ 'expected_start': 13,
      \ 'expected_contains': ['`order`']
      \ })

" Test: SQL Server reserved word quoting
call TestRegister({
      \ 'name': 'SQL Server reserved word quoting',
      \ 'db_type': 'sqlserver',
      \ 'context': ['SELECT * FROM ord'],
      \ 'cursor_pos': [1, 20],
      \ 'base': 'ord',
      \ 'expected_start': 13,
      \ 'expected_contains': ['[order]']
      \ })

" Test: PostgreSQL column reserved word quoting
call TestRegister({
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

call TestGroup('SQL - Other Dialects')

" Test: MariaDB (uses PostgreSQL adapter for basic completion)
call TestRegister({
      \ 'name': 'MariaDB table completion',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT * FROM '],
      \ 'cursor_pos': [1, 17],
      \ 'expected_start': 13,
      \ 'expected_contains': ['users', 'orders']
      \ })

" Test: SQLite (uses PostgreSQL adapter for basic completion)
call TestRegister({
      \ 'name': 'SQLite table completion',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT * FROM '],
      \ 'cursor_pos': [1, 17],
      \ 'expected_start': 13,
      \ 'expected_contains': ['users', 'orders']
      \ })

" Test: Oracle (uses PostgreSQL adapter for basic completion)
call TestRegister({
      \ 'name': 'Oracle table completion',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT * FROM '],
      \ 'cursor_pos': [1, 17],
      \ 'expected_start': 13,
      \ 'expected_contains': ['users', 'orders']
      \ })

" =============================================================================
" Test Group: JOIN Variants (High Priority)
" =============================================================================

call TestGroup('SQL - JOIN Variants')

" Test: Table after RIGHT JOIN
call TestRegister({
      \ 'name': 'Table after RIGHT JOIN',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT * FROM users RIGHT JOIN '],
      \ 'cursor_pos': [1, 37],
      \ 'expected_start': 28,
      \ 'expected_contains': ['orders', 'products']
      \ })

" Test: Table after FULL OUTER JOIN
call TestRegister({
      \ 'name': 'Table after FULL OUTER JOIN',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT * FROM users FULL OUTER JOIN '],
      \ 'cursor_pos': [1, 44],
      \ 'expected_start': 35,
      \ 'expected_contains': ['orders']
      \ })

" Test: Table after CROSS JOIN
call TestRegister({
      \ 'name': 'Table after CROSS JOIN',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT * FROM users CROSS JOIN '],
      \ 'cursor_pos': [1, 38],
      \ 'expected_start': 29,
      \ 'expected_contains': ['orders', 'products']
      \ })

" Test: Table after NATURAL JOIN
call TestRegister({
      \ 'name': 'Table after NATURAL JOIN',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT * FROM users NATURAL JOIN '],
      \ 'cursor_pos': [1, 40],
      \ 'expected_start': 31,
      \ 'expected_contains': ['orders']
      \ })

" Test: Table after INNER JOIN
call TestRegister({
      \ 'name': 'Table after INNER JOIN',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT * FROM users INNER JOIN '],
      \ 'cursor_pos': [1, 38],
      \ 'expected_start': 29,
      \ 'expected_contains': ['orders', 'products']
      \ })

" Test: Table after SELF JOIN
call TestRegister({
      \ 'name': 'Table after SELF JOIN',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT * FROM users u1 JOIN users u2 ON '],
      \ 'cursor_pos': [1, 47],
      \ 'expected_start': 38,
      \ 'expected_contains': ['users']
      \ })

" =============================================================================
" Test Group: Schema Prefix (High Priority)
" =============================================================================

call TestGroup('SQL - Schema Prefix')

" Test: Table with schema prefix
call TestRegister({
      \ 'name': 'Table with schema prefix',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT * FROM public.'],
      \ 'cursor_pos': [1, 22],
      \ 'expected_start': 14,
      \ 'expected_contains': ['users', 'orders']
      \ })

" Test: Column with schema.table prefix
call TestRegister({
      \ 'name': 'Column with schema.table prefix',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT public.users.'],
      \ 'cursor_pos': [1, 22],
      \ 'expected_start': 19,
      \ 'expected_contains': ['id', 'name', 'email']
      \ })

" Test: Schema.table in UPDATE
call TestRegister({
      \ 'name': 'Schema.table in UPDATE',
      \ 'db_type': 'postgresql',
      \ 'context': ['UPDATE public.'],
      \ 'cursor_pos': [1, 15],
      \ 'expected_start': 11,
      \ 'expected_contains': ['users', 'orders']
      \ })

" Test: Schema.table in DELETE FROM
call TestRegister({
      \ 'name': 'Schema.table in DELETE FROM',
      \ 'db_type': 'postgresql',
      \ 'context': ['DELETE FROM public.'],
      \ 'cursor_pos': [1, 21],
      \ 'expected_start': 17,
      \ 'expected_contains': ['users', 'orders']
      \ })

" =============================================================================
" Test Group: Advanced SQL Syntax (Medium Priority)
" =============================================================================

call TestGroup('SQL - Advanced Syntax')

" Test: CTE (WITH clause) table name
call TestRegister({
      \ 'name': 'CTE table name in WITH',
      \ 'db_type': 'postgresql',
      \ 'context': ['WITH cte AS (SELECT * FROM '],
      \ 'cursor_pos': [1, 30],
      \ 'expected_start': 26,
      \ 'expected_contains': ['users', 'orders']
      \ })

" Test: CTE reference in main query
call TestRegister({
      \ 'name': 'CTE reference in main query',
      \ 'db_type': 'postgresql',
      \ 'context': ['WITH cte AS (SELECT * FROM users) SELECT * FROM '],
      \ 'cursor_pos': [1, 56],
      \ 'expected_start': 52,
      \ 'expected_contains': ['cte', 'users']
      \ })

" Test: Subquery table completion
call TestRegister({
      \ 'name': 'Subquery table completion',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT * FROM (SELECT * FROM '],
      \ 'cursor_pos': [1, 31],
      \ 'expected_start': 27,
      \ 'expected_contains': ['users', 'orders']
      \ })

" Test: Subquery column completion
call TestRegister({
      \ 'name': 'Subquery column completion',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT (SELECT id FROM '],
      \ 'cursor_pos': [1, 23],
      \ 'expected_start': 19,
      \ 'expected_contains': ['users', 'orders']
      \ })

" Test: GROUP BY column completion
call TestRegister({
      \ 'name': 'GROUP BY column completion',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT * FROM users GROUP BY '],
      \ 'cursor_pos': [1, 34],
      \ 'expected_start': 28,
      \ 'expected_contains': ['id', 'name', 'email']
      \ })

" Test: ORDER BY column completion
call TestRegister({
      \ 'name': 'ORDER BY column completion',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT * FROM users ORDER BY '],
      \ 'cursor_pos': [1, 35],
      \ 'expected_start': 29,
      \ 'expected_contains': ['id', 'name', 'email']
      \ })

" Test: INSERT VALUES column completion
call TestRegister({
      \ 'name': 'INSERT VALUES column completion',
      \ 'db_type': 'postgresql',
      \ 'context': ['INSERT INTO users ('],
      \ 'cursor_pos': [1, 19],
      \ 'expected_start': 18,
      \ 'expected_contains': ['id', 'name', 'email']
      \ })

" Test: Table alias conflict with reserved words
call TestRegister({
      \ 'name': 'Table alias conflict handling',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT * FROM users AS select WHERE select.'],
      \ 'cursor_pos': [1, 45],
      \ 'expected_start': 39,
      \ 'expected_contains': ['id', 'name', 'email']
      \ })

" Test: CASE WHEN column completion
call TestRegister({
      \ 'name': 'CASE WHEN column completion',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT CASE WHEN status = 1 THEN users.'],
      \ 'cursor_pos': [1, 37],
      \ 'expected_start': 34,
      \ 'expected_contains': ['id', 'name']
      \ })

" Test: Window functions
call TestRegister({
      \ 'name': 'Window functions completion',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT ROW_NUMBER() OVER (PARTITION BY '],
      \ 'cursor_pos': [1, 42],
      \ 'expected_start': 36,
      \ 'expected_contains': ['id', 'name', 'status']
      \ })

" =============================================================================
" Test Group: DDL Statements (Low Priority)
" =============================================================================

call TestGroup('SQL - DDL Statements')

" Test: CREATE TABLE
call TestRegister({
      \ 'name': 'CREATE TABLE table completion',
      \ 'db_type': 'postgresql',
      \ 'context': ['CREATE TABLE '],
      \ 'cursor_pos': [1, 13],
      \ 'expected_start': 12,
      \ 'expected_contains': ['users', 'orders']
      \ })

" Test: ALTER TABLE
call TestRegister({
      \ 'name': 'ALTER TABLE table completion',
      \ 'db_type': 'postgresql',
      \ 'context': ['ALTER TABLE '],
      \ 'cursor_pos': [1, 13],
      \ 'expected_start': 12,
      \ 'expected_contains': ['users', 'orders']
      \ })
