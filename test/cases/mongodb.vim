" MongoDB Completion Test Cases

" Load framework
runtime test/framework.vim

" =============================================================================
" Test Group: DB Method Completion
" =============================================================================

call TestGroup('MongoDB - DB Method Completion')

" Test: db. - should complete db methods and collections
call TestRegister({
      \ 'name': 'db. method and collection completion',
      \ 'db_type': 'mongodb',
      \ 'context': ['db.'],
      \ 'cursor_pos': [1, 4],
      \ 'expected_start': 3,
      \ 'min_count': 1,
      \ 'expected_contains': ['getCollection', 'createCollection']
      \ })

" Test: db. with prefix filter
call TestRegister({
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

call TestGroup('MongoDB - Collection Method Completion')

" Test: db.collection. - should complete collection methods
call TestRegister({
      \ 'name': 'db.collection. method completion',
      \ 'db_type': 'mongodb',
      \ 'context': ['db.users.'],
      \ 'cursor_pos': [1, 9],
      \ 'expected_start': 9,
      \ 'min_count': 1,
      \ 'expected_contains': ['find', 'findOne', 'insertOne', 'updateMany']
      \ })

" Test: db.collection. with prefix filter
call TestRegister({
      \ 'name': 'db.collection. with prefix filter',
      \ 'db_type': 'mongodb',
      \ 'context': ['db.users.find'],
      \ 'cursor_pos': [1, 13],
      \ 'base': 'find',
      \ 'expected_start': 9,
      \ 'expected_contains': ['find', 'findOne']
      \ })

" Test: No completion after method with parenthesis
call TestRegister({
      \ 'name': 'No completion after method(',
      \ 'db_type': 'mongodb',
      \ 'context': ['db.users.find('],
      \ 'cursor_pos': [1, 15],
      \ 'expected_start': -1
      \ })

" =============================================================================
" Test Group: Chain Method Completion
" =============================================================================

call TestGroup('MongoDB - Chain Method Completion')

" Test: db.collection.find(). - should complete chain methods
call TestRegister({
      \ 'name': 'db.collection.find(). chain method completion',
      \ 'db_type': 'mongodb',
      \ 'context': ['db.users.find().'],
      \ 'cursor_pos': [1, 16],
      \ 'expected_start': 16,
      \ 'min_count': 1,
      \ 'expected_contains': ['limit', 'skip', 'sort', 'toArray']
      \ })

" Test: db.collection.findOne(). - should complete chain methods
call TestRegister({
      \ 'name': 'db.collection.findOne(). chain method completion',
      \ 'db_type': 'mongodb',
      \ 'context': ['db.users.findOne().'],
      \ 'cursor_pos': [1, 20],
      \ 'expected_start': 19,
      \ 'min_count': 1,
      \ 'expected_contains': ['limit', 'skip', 'sort']
      \ })

" Test: Chain method with arguments
call TestRegister({
      \ 'name': 'Chain method with arguments',
      \ 'db_type': 'mongodb',
      \ 'context': ['db.users.find({age: 25}).'],
      \ 'cursor_pos': [1, 28],
      \ 'expected_start': 25,
      \ 'min_count': 1,
      \ 'expected_contains': ['limit', 'skip']
      \ })

" Test: Chain method with prefix filter
call TestRegister({
      \ 'name': 'Chain method with prefix filter',
      \ 'db_type': 'mongodb',
      \ 'context': ['db.users.find().lim'],
      \ 'cursor_pos': [1, 19],
      \ 'base': 'lim',
      \ 'expected_start': 19,
      \ 'expected_contains': ['limit']
      \ })

" =============================================================================
" Test Group: Operator Completion
" =============================================================================

call TestGroup('MongoDB - Operator Completion')

" Test: $ operator
call TestRegister({
      \ 'name': '$ operator',
      \ 'db_type': 'mongodb',
      \ 'context': ['{ $'],
      \ 'cursor_pos': [1, 4],
      \ 'base': '$',
      \ 'expected_start': 3,
      \ 'min_count': 1,
      \ 'expected_contains': ['$eq']
      \ })

" Test: $ operator in nested object
call TestRegister({
      \ 'name': '$ operator in nested object',
      \ 'db_type': 'mongodb',
      \ 'context': ['db.users.find({', '  filter: { status: $'],
      \ 'cursor_pos': [2, 22],
      \ 'base': '$',
      \ 'expected_start': 22,
      \ 'min_count': 1,
      \ 'expected_contains': ['$eq']
      \ })

" =============================================================================
" Test Group: Multi-line Context
" =============================================================================

call TestGroup('MongoDB - Multi-line Context')

" Test: Multi-line db method
call TestRegister({
      \ 'name': 'Multi-line db method',
      \ 'db_type': 'mongodb',
      \ 'context': ['db.'],
      \ 'cursor_pos': [1, 4],
      \ 'expected_start': 3,
      \ 'min_count': 1
      \ })

" Test: Multi-line collection method
call TestRegister({
      \ 'name': 'Multi-line collection method',
      \ 'db_type': 'mongodb',
      \ 'context': ['db.users.'],
      \ 'cursor_pos': [1, 9],
      \ 'expected_start': 9,
      \ 'min_count': 1
      \ })

" Test: Multi-line chain method
call TestRegister({
      \ 'name': 'Multi-line chain method',
      \ 'db_type': 'mongodb',
      \ 'context': ['db.users.find().'],
      \ 'cursor_pos': [1, 16],
      \ 'expected_start': 16,
      \ 'min_count': 1
      \ })

" =============================================================================
" Test Group: Collection Names
" =============================================================================

call TestGroup('MongoDB - Collection Names')

" Test: Collection names in db. completion
call TestRegister({
      \ 'name': 'Collection names in db. completion',
      \ 'db_type': 'mongodb',
      \ 'context': ['db.'],
      \ 'cursor_pos': [1, 4],
      \ 'expected_start': 3,
      \ 'expected_contains': ['users', 'products', 'orders']
      \ })

" =============================================================================
" Test Group: Aggregate Pipeline (High Priority)
" =============================================================================

call TestGroup('MongoDB - Aggregate Pipeline')

" Test: db.collection.aggregate(). chain method completion
call TestRegister({
      \ 'name': 'aggregate(). chain method completion',
      \ 'db_type': 'mongodb',
      \ 'context': ['db.users.aggregate().'],
      \ 'cursor_pos': [1, 23],
      \ 'expected_start': 23,
      \ 'min_count': 1,
      \ 'expected_contains': ['limit', 'skip', 'toArray', 'next']
      \ })

" Test: aggregate() with $match stage
call TestRegister({
      \ 'name': 'aggregate() with $match stage',
      \ 'db_type': 'mongodb',
      \ 'context': ['db.users.aggregate([', '  { $match: { status: }'],
      \ 'cursor_pos': [2, 28],
      \ 'expected_start': 28,
      \ 'min_count': 1,
      \ 'expected_contains': ['$eq']
      \ })

" Test: aggregate() with $group stage
call TestRegister({
      \ 'name': 'aggregate() with $group stage',
      \ 'db_type': 'mongodb',
      \ 'context': ['db.users.aggregate([', '  { $group: { _id: }'],
      \ 'cursor_pos': [2, 29],
      \ 'expected_start': 29,
      \ 'min_count': 1,
      \ 'expected_contains': ['$user_id', '$status']
      \ })

" Test: aggregate() with $sort stage
call TestRegister({
      \ 'name': 'aggregate() with $sort stage',
      \ 'db_type': 'mongodb',
      \ 'context': ['db.users.aggregate([', '  { $sort: { }'],
      \ 'cursor_pos': [2, 21],
      \ 'expected_start': 21,
      \ 'min_count': 1,
      \ 'expected_contains': ['name', 'created_at', 'id']
      \ })

" =============================================================================
" Test Group: Update Methods (Medium Priority)
" =============================================================================

call TestGroup('MongoDB - Update Methods')

" Test: db.collection.updateOne(). chain
call TestRegister({
      \ 'name': 'updateOne(). chain method completion',
      \ 'db_type': 'mongodb',
      \ 'context': ['db.users.updateOne().'],
      \ 'cursor_pos': [1, 23],
      \ 'expected_start': 23,
      \ 'min_count': 1,
      \ 'expected_contains': ['limit']
      \ })

" Test: db.collection.updateMany(). chain
call TestRegister({
      \ 'name': 'updateMany(). chain method completion',
      \ 'db_type': 'mongodb',
      \ 'context': ['db.users.updateMany().'],
      \ 'cursor_pos': [1, 24],
      \ 'expected_start': 24,
      \ 'min_count': 1,
      \ 'expected_contains': ['limit']
      \ })

" =============================================================================
" Test Group: Aggregation Methods (Medium Priority)
" =============================================================================

call TestGroup('MongoDB - Aggregation Methods')

" Test: db.collection.distinct() completion
call TestRegister({
      \ 'name': 'distinct() method completion',
      \ 'db_type': 'mongodb',
      \ 'context': ['db.users.distinct('],
      \ 'cursor_pos': [1, 20],
      \ 'expected_start': -1
      \ })

" Test: db.collection.countDocuments() completion
call TestRegister({
      \ 'name': 'countDocuments() method completion',
      \ 'db_type': 'mongodb',
      \ 'context': ['db.users.countDocuments('],
      \ 'cursor_pos': [1, 27],
      \ 'expected_start': -1
      \ })

" Test: db.collection.estimatedDocumentCount() completion
call TestRegister({
      \ 'name': 'estimatedDocumentCount() method completion',
      \ 'db_type': 'mongodb',
      \ 'context': ['db.users.estimatedDocumentCount('],
      \ 'cursor_pos': [1, 35],
      \ 'expected_start': -1
      \ })
