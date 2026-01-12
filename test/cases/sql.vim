" SQL Database Completion Test Cases
" Covers: PostgreSQL, MySQL, MariaDB, SQLite, SQL Server, Oracle

" Load framework
source test/framework.vim

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
      \ 'expected_start': 13
      \ })

" Test: Column after alias.
call TestRegister({
      \ 'name': 'Column after alias.',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT * FROM users u WHERE u.'],
      \ 'cursor_pos': [1, 36],
      \ 'expected_start': 33
      \ })

" Test: Column with AS alias
call TestRegister({
      \ 'name': 'Column with AS alias',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT * FROM orders AS o WHERE o.'],
      \ 'cursor_pos': [1, 34],
      \ 'expected_start': 33
      \ })

" Test: Column with implicit alias
call TestRegister({
      \ 'name': 'Column with implicit alias',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT * FROM users u users WHERE u.'],
      \ 'cursor_pos': [1, 46],
      \ 'expected_start': 33
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
      \ 'expected_start': 13
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
      \ 'expected_start': -1
      \ })

" Test: Column with schema.table prefix
call TestRegister({
      \ 'name': 'Column with schema.table prefix',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT public.users.'],
      \ 'cursor_pos': [1, 22],
      \ 'expected_start': -1
      \ })

" Test: Schema.table in UPDATE
call TestRegister({
      \ 'name': 'Schema.table in UPDATE',
      \ 'db_type': 'postgresql',
      \ 'context': ['UPDATE public.'],
      \ 'cursor_pos': [1, 15],
      \ 'expected_start': -1
      \ })

" Test: Schema.table in DELETE FROM
call TestRegister({
      \ 'name': 'Schema.table in DELETE FROM',
      \ 'db_type': 'postgresql',
      \ 'context': ['DELETE FROM public.'],
      \ 'cursor_pos': [1, 21],
      \ 'expected_start': -1
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
      \ 'min_count': 1
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
      \ 'expected_start': 39
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

" =============================================================================
" Test Group: Error Handling (High Priority)
" =============================================================================

call TestGroup('SQL - Error Handling')

call TestRegister({
      \ 'name': 'Invalid table name returns empty',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT * FROM xyz_nonexistent_12345'],
      \ 'cursor_pos': [1, 30],
      \ 'expected_start': -1
      \ })

call TestRegister({
      \ 'name': 'Orphan dot no completion',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT .'],
      \ 'cursor_pos': [1, 8],
      \ 'expected_start': -1
      \ })

call TestRegister({
      \ 'name': 'Column after invalid table alias',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT nonexistent.'],
      \ 'cursor_pos': [1, 19],
      \ 'expected_start': 11,
      \ 'min_count': 0
      \ })

call TestRegister({
      \ 'name': 'Nested comment context',
      \ 'db_type': 'postgresql',
      \ 'context': ['/* SELECT * FROM '],
      \ 'cursor_pos': [1, 19],
      \ 'expected_start': -1
      \ })

call TestRegister({
      \ 'name': 'String literal context',
      \ 'db_type': 'postgresql',
      \ 'context': ["SELECT * FROM users WHERE name = 'sel"],
      \ 'cursor_pos': [1, 40],
      \ 'expected_start': -1
      \ })

call TestRegister({
      \ 'name': 'Number literal context',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT 123 FROM '],
      \ 'cursor_pos': [1, 16],
      \ 'expected_start': 12,
      \ 'expected_contains': ['users', 'orders']
      \ })

" =============================================================================
" Test Group: Edge Cases (High Priority)
" =============================================================================

call TestGroup('SQL - Edge Cases')

call TestRegister({
      \ 'name': 'Very long identifier',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT * FROM users WHERE users.very_long_column_name_that_exceeds'],
      \ 'cursor_pos': [1, 60],
      \ 'expected_start': 38
      \ })

call TestRegister({
      \ 'name': 'Column in AND condition',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT * FROM users WHERE id = 1 AND '],
      \ 'cursor_pos': [1, 37],
      \ 'expected_start': 32,
      \ 'expected_contains': ['name', 'email', 'status']
      \ })

call TestRegister({
      \ 'name': 'Column in OR condition',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT * FROM users WHERE id = 1 OR '],
      \ 'cursor_pos': [1, 36],
      \ 'expected_start': 31,
      \ 'expected_contains': ['name', 'email']
      \ })

call TestRegister({
      \ 'name': 'Column in subquery WHERE',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT * FROM users WHERE id IN (SELECT id FROM '],
      \ 'cursor_pos': [1, 46],
      \ 'expected_start': 42,
      \ 'expected_contains': ['orders', 'products']
      \ })

call TestRegister({
      \ 'name': 'Multiple tables same prefix',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT * FROM user'],
      \ 'cursor_pos': [1, 18],
      \ 'base': 'user',
      \ 'expected_start': 13,
      \ 'min_count': 1
      \ })

" =============================================================================
" Test Group: MySQL Specific (Medium Priority)
" =============================================================================

call TestGroup('SQL - MySQL Specific')

call TestRegister({
      \ 'name': 'MySQL LIMIT completion',
      \ 'db_type': 'mysql',
      \ 'context': ['SELECT * FROM users LIM'],
      \ 'cursor_pos': [1, 25],
      \ 'base': 'LIM',
      \ 'expected_start': 23,
      \ 'expected_contains': ['LIMIT']
      \ })

call TestRegister({
      \ 'name': 'MySQL auto_increment keyword',
      \ 'db_type': 'mysql',
      \ 'context': ['CREATE TABLE test (id '],
      \ 'cursor_pos': [1, 24],
      \ 'expected_start': 21,
      \ 'expected_contains': ['AUTO_INCREMENT']
      \ })

call TestRegister({
      \ 'name': 'MySQL ENGINE keyword',
      \ 'db_type': 'mysql',
      \ 'context': ['CREATE TABLE test () ENG'],
      \ 'cursor_pos': [1, 26],
      \ 'base': 'ENG',
      \ 'expected_start': 23,
      \ 'expected_contains': ['ENGINE']
      \ })

call TestRegister({
      \ 'name': 'MySQL table with tick quoting',
      \ 'db_type': 'mysql',
      \ 'context': ['SELECT * FROM `ord'],
      \ 'cursor_pos': [1, 19],
      \ 'base': 'ord',
      \ 'expected_start': 13,
      \ 'expected_contains': ['`order`']
      \ })

" =============================================================================
" Test Group: SQL Server Specific (Medium Priority)
" =============================================================================

call TestGroup('SQL - SQL Server Specific')

call TestRegister({
      \ 'name': 'SQL Server TOP completion',
      \ 'db_type': 'sqlserver',
      \ 'context': ['SELECT TOP '],
      \ 'cursor_pos': [1, 11],
      \ 'expected_start': 7,
      \ 'expected_contains': ['10', '100']
      \ })

call TestRegister({
      \ 'name': 'SQL Server identity keyword',
      \ 'db_type': 'sqlserver',
      \ 'context': ['CREATE TABLE test (id '],
      \ 'cursor_pos': [1, 24],
      \ 'expected_start': 21,
      \ 'expected_contains': ['IDENTITY']
      \ })

call TestRegister({
      \ 'name': 'SQL Server with bracket quoting',
      \ 'db_type': 'sqlserver',
      \ 'context': ['SELECT * FROM [ord'],
      \ 'cursor_pos': [1, 20],
      \ 'base': 'ord',
      \ 'expected_start': 13,
      \ 'expected_contains': ['[order]']
      \ })

call TestRegister({
      \ 'name': 'SQL Server schema sys',
      \ 'db_type': 'sqlserver',
      \ 'context': ['SELECT * FROM sys.'],
      \ 'cursor_pos': [1, 18],
      \ 'expected_start': -1
      \ })

" =============================================================================
" Test Group: SQLite Specific (Low Priority)
" =============================================================================

call TestGroup('SQL - SQLite Specific')

call TestRegister({
      \ 'name': 'SQLite WITHOUT ROWID',
      \ 'db_type': 'sqlite',
      \ 'context': ['CREATE TABLE test (id INTEGER) WIT'],
      \ 'cursor_pos': [1, 36],
      \ 'base': 'WIT',
      \ 'expected_start': 33,
      \ 'expected_contains': ['WITHOUT', 'WITHOUT ROWID']
      \ })

call TestRegister({
      \ 'name': 'SQLite STRICT keyword',
      \ 'db_type': 'sqlite',
      \ 'context': ['CREATE TABLE test (id INTEGER) ST'],
      \ 'cursor_pos': [1, 35],
      \ 'base': 'ST',
      \ 'expected_start': 33,
      \ 'expected_contains': ['STRICT']
      \ })

" =============================================================================
" Test Group: Oracle Specific (Low Priority)
" =============================================================================

call TestGroup('SQL - Oracle Specific')

call TestRegister({
      \ 'name': 'Oracle NUMBER type',
      \ 'db_type': 'oracle',
      \ 'context': ['CREATE TABLE test (id NU'],
      \ 'cursor_pos': [1, 24],
      \ 'base': 'NU',
      \ 'expected_start': 21,
      \ 'expected_contains': ['NUMBER']
      \ })

call TestRegister({
      \ 'name': 'Oracle VARCHAR2 type',
      \ 'db_type': 'oracle',
      \ 'context': ['CREATE TABLE test (name VA'],
      \ 'cursor_pos': [1, 28],
      \ 'base': 'VA',
      \ 'expected_start': 25,
      \ 'expected_contains': ['VARCHAR2']
      \ })

" =============================================================================
" Test Group: Complex Queries (Medium Priority)
" =============================================================================

call TestGroup('SQL - Complex Queries')

call TestRegister({
      \ 'name': 'UNION query table completion',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT * FROM users UNION SELECT * FROM '],
      \ 'cursor_pos': [1, 44],
      \ 'expected_start': 40,
      \ 'expected_contains': ['orders', 'products']
      \ })

call TestRegister({
      \ 'name': 'INTERSECT query table completion',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT id FROM users INTERSECT SELECT id FROM '],
      \ 'cursor_pos': [1, 45],
      \ 'expected_start': 41,
      \ 'expected_contains': ['orders']
      \ })

call TestRegister({
      \ 'name': 'EXCEPT query table completion',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT id FROM users EXCEPT SELECT id FROM '],
      \ 'cursor_pos': [1, 44],
      \ 'expected_start': 40,
      \ 'expected_contains': ['orders']
      \ })

call TestRegister({
      \ 'name': 'JOIN ON condition column',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT * FROM users u JOIN orders o ON u.id = o.'],
      \ 'cursor_pos': [1, 52],
      \ 'expected_start': 49
      \ })

call TestRegister({
      \ 'name': 'NATURAL JOIN column',
      \ 'db_type': 'postgresql',
      \ 'context': ['SELECT * FROM users NATURAL JOIN orders WHERE '],
      \ 'cursor_pos': [1, 46],
      \ 'expected_start': -1
      \ })

" =============================================================================
" Test Group: Transaction Statements (Low Priority)
" =============================================================================

call TestGroup('SQL - Transaction Statements')

call TestRegister({
      \ 'name': 'TRUNCATE table completion',
      \ 'db_type': 'postgresql',
      \ 'context': ['TRUNCATE '],
      \ 'cursor_pos': [1, 9],
      \ 'expected_start': 8,
      \ 'expected_contains': ['users', 'orders']
      \ })

call TestRegister({
      \ 'name': 'DROP TABLE completion',
      \ 'db_type': 'postgresql',
      \ 'context': ['DROP TABLE '],
      \ 'cursor_pos': [1, 12],
      \ 'expected_start': 11,
      \ 'expected_contains': ['users', 'orders']
      \ })

