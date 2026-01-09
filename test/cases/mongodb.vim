" MongoDB Completion Test Cases

" Load framework
runtime test/framework.vim

" =============================================================================
" Test Group: DB Method Completion
" =============================================================================

call dbcp#test#group('MongoDB - DB Method Completion')

" Test: db. - should complete db methods and collections
call dbcp#test#register({
      \ 'name': 'db. method and collection completion',
      \ 'db_type': 'mongodb',
      \ 'context': ['db.'],
      \ 'cursor_pos': [1, 4],
      \ 'expected_start': 3,
      \ 'min_count': 1,
      \ 'expected_contains': ['getCollection', 'createCollection']
      \ })

" Test: db. with prefix filter
call dbcp#test#register({
      \ 'name': 'db. with prefix filter',
      \ 'db_type': 'mongodb',
      \ 'context': ['db.get'],
      \ 'cursor_pos': [1, 7],
      \ 'base': 'get',
      \ 'expected_start': 3,
      \ 'expected_contains': ['getCollection']
      \ })

" =============================================================================
" Test Group: Collection Method Completion
" =============================================================================

call dbcp#test#group('MongoDB - Collection Method Completion')

" Test: db.collection. - should complete collection methods
call dbcp#test#register({
      \ 'name': 'db.collection. method completion',
      \ 'db_type': 'mongodb',
      \ 'context': ['db.users.'],
      \ 'cursor_pos': [1, 9],
      \ 'expected_start': 9,
      \ 'min_count': 1,
      \ 'expected_contains': ['find', 'findOne', 'insertOne', 'updateMany']
      \ })

" Test: db.collection. with prefix filter
call dbcp#test#register({
      \ 'name': 'db.collection. with prefix filter',
      \ 'db_type': 'mongodb',
      \ 'context': ['db.users.find'],
      \ 'cursor_pos': [1, 13],
      \ 'base': 'find',
      \ 'expected_start': 9,
      \ 'expected_contains': ['find', 'findOne']
      \ })

" Test: No completion after method with parenthesis
call dbcp#test#register({
      \ 'name': 'No completion after method(',
      \ 'db_type': 'mongodb',
      \ 'context': ['db.users.find('],
      \ 'cursor_pos': [1, 15],
      \ 'expected_start': -1
      \ })

" =============================================================================
" Test Group: Chain Method Completion
" =============================================================================

call dbcp#test#group('MongoDB - Chain Method Completion')

" Test: db.collection.find(). - should complete chain methods
call dbcp#test#register({
      \ 'name': 'db.collection.find(). chain method completion',
      \ 'db_type': 'mongodb',
      \ 'context': ['db.users.find().'],
      \ 'cursor_pos': [1, 16],
      \ 'expected_start': 16,
      \ 'min_count': 1,
      \ 'expected_contains': ['limit', 'skip', 'sort', 'toArray']
      \ })

" Test: db.collection.findOne(). - should complete chain methods
call dbcp#test#register({
      \ 'name': 'db.collection.findOne(). chain method completion',
      \ 'db_type': 'mongodb',
      \ 'context': ['db.users.findOne().'],
      \ 'cursor_pos': [1, 20],
      \ 'expected_start': 20,
      \ 'min_count': 1,
      \ 'expected_contains': ['limit', 'skip', 'sort']
      \ })

" Test: Chain method with arguments
call dbcp#test#register({
      \ 'name': 'Chain method with arguments',
      \ 'db_type': 'mongodb',
      \ 'context': ['db.users.find({age: 25}).'],
      \ 'cursor_pos': [1, 28],
      \ 'expected_start': 28,
      \ 'min_count': 1,
      \ 'expected_contains': ['limit', 'skip']
      \ })

" Test: Chain method with prefix filter
call dbcp#test#register({
      \ 'name': 'Chain method with prefix filter',
      \ 'db_type': 'mongodb',
      \ 'context': ['db.users.find().lim'],
      \ 'cursor_pos': [1, 19],
      \ 'base': 'lim',
      \ 'expected_start': 16,
      \ 'expected_contains': ['limit']
      \ })

" =============================================================================
" Test Group: Operator Completion
" =============================================================================

call dbcp#test#group('MongoDB - Operator Completion')

" Test: $ operator completion
call dbcp#test#register({
      \ 'name': '$ operator completion',
      \ 'db_type': 'mongodb',
      \ 'context': ['{ age: $'],
      \ 'cursor_pos': [1, 9],
      \ 'base': '$',
      \ 'expected_start': 8,
      \ 'min_count': 1,
      \ 'expected_contains': ['$eq', '$gt', '$in', '$match']
      \ })

" Test: $ operator with prefix filter
call dbcp#test#register({
      \ 'name': '$ operator with prefix filter',
      \ 'db_type': 'mongodb',
      \ 'context': ['{ age: $e'],
      \ 'cursor_pos': [1, 10],
      \ 'base': '$e',
      \ 'expected_start': 8,
      \ 'expected_contains': ['$eq', '$exists']
      \ })

" Test: $ operator in nested object
call dbcp#test#register({
      \ 'name': '$ operator in nested object',
      \ 'db_type': 'mongodb',
      \ 'context': ['db.users.find({', '  filter: { status: $'],
      \ 'cursor_pos': [2, 22],
      \ 'base': '$',
      \ 'expected_start': 21,
      \ 'min_count': 1,
      \ 'expected_contains': ['$eq', '$gt']
      \ })

" =============================================================================
" Test Group: Multi-line Context
" =============================================================================

call dbcp#test#group('MongoDB - Multi-line Context')

" Test: Multi-line db method
call dbcp#test#register({
      \ 'name': 'Multi-line db method',
      \ 'db_type': 'mongodb',
      \ 'context': ['db', '.'],
      \ 'cursor_pos': [2, 2],
      \ 'expected_start': 1,
      \ 'min_count': 1
      \ })

" Test: Multi-line collection method
call dbcp#test#register({
      \ 'name': 'Multi-line collection method',
      \ 'db_type': 'mongodb',
      \ 'context': ['db.users', '.'],
      \ 'cursor_pos': [2, 2],
      \ 'expected_start': 1,
      \ 'min_count': 1
      \ })

" Test: Multi-line chain method
call dbcp#test#register({
      \ 'name': 'Multi-line chain method',
      \ 'db_type': 'mongodb',
      \ 'context': ['db.users.find()', '.'],
      \ 'cursor_pos': [2, 2],
      \ 'expected_start': 1,
      \ 'min_count': 1
      \ })

" =============================================================================
" Test Group: Collection Names
" =============================================================================

call dbcp#test#group('MongoDB - Collection Names')

" Test: Collection names in db. completion
call dbcp#test#register({
      \ 'name': 'Collection names in db. completion',
      \ 'db_type': 'mongodb',
      \ 'context': ['db.'],
      \ 'cursor_pos': [1, 4],
      \ 'expected_start': 3,
      \ 'expected_contains': ['users', 'products', 'orders']
      \ })
