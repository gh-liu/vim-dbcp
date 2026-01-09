" Redis Completion Test Cases

" Load framework
runtime test/framework.vim

" =============================================================================
" Test Group: Command Completion
" =============================================================================

call dbcp#test#group('Redis - Command Completion')

" Test: Command at line start
call dbcp#test#register({
      \ 'name': 'Command at line start',
      \ 'db_type': 'redis',
      \ 'context': ['GE'],
      \ 'cursor_pos': [1, 3],
      \ 'base': 'GE',
      \ 'expected_start': 0,
      \ 'min_count': 1,
      \ 'expected_contains': ['GET', 'GETSET']
      \ })

" Test: Command with prefix filter
call dbcp#test#register({
      \ 'name': 'Command with prefix filter',
      \ 'db_type': 'redis',
      \ 'context': ['HS'],
      \ 'cursor_pos': [1, 3],
      \ 'base': 'HS',
      \ 'expected_start': 0,
      \ 'expected_contains': ['HSET', 'HGET', 'HSETNX']
      \ })

" Test: Command at start with whitespace
call dbcp#test#register({
      \ 'name': 'Command at start with whitespace',
      \ 'db_type': 'redis',
      \ 'context': ['  SE'],
      \ 'cursor_pos': [1, 5],
      \ 'base': 'SE',
      \ 'expected_start': 2,
      \ 'min_count': 1,
      \ 'expected_contains': ['SET', 'SETEX', 'SETNX']
      \ })

" =============================================================================
" Test Group: Subcommand Completion
" =============================================================================

call dbcp#test#group('Redis - Subcommand Completion')

" Test: CLIENT subcommand
call dbcp#test#register({
      \ 'name': 'CLIENT subcommand completion',
      \ 'db_type': 'redis',
      \ 'context': ['CLIENT '],
      \ 'cursor_pos': [1, 8],
      \ 'expected_start': 7,
      \ 'min_count': 1,
      \ 'expected_contains': ['LIST', 'KILL', 'SETNAME']
      \ })

" Test: CONFIG subcommand
call dbcp#test#register({
      \ 'name': 'CONFIG subcommand completion',
      \ 'db_type': 'redis',
      \ 'context': ['CONFIG '],
      \ 'cursor_pos': [1, 8],
      \ 'expected_start': 7,
      \ 'min_count': 1,
      \ 'expected_contains': ['GET', 'SET', 'REWRITE']
      \ })

" Test: ACL subcommand
call dbcp#test#register({
      \ 'name': 'ACL subcommand completion',
      \ 'db_type': 'redis',
      \ 'context': ['ACL '],
      \ 'cursor_pos': [1, 5],
      \ 'expected_start': 4,
      \ 'min_count': 1,
      \ 'expected_contains': ['LIST', 'GETUSER', 'SETUSER']
      \ })

" Test: Subcommand with prefix filter
call dbcp#test#register({
      \ 'name': 'Subcommand with prefix filter',
      \ 'db_type': 'redis',
      \ 'context': ['CLIENT LI'],
      \ 'cursor_pos': [1, 10],
      \ 'base': 'LI',
      \ 'expected_start': 7,
      \ 'expected_contains': ['LIST']
      \ })

" =============================================================================
" Test Group: Option Completion
" =============================================================================

call dbcp#test#group('Redis - Option Completion')

" Test: SET command options
call dbcp#test#register({
      \ 'name': 'SET command options',
      \ 'db_type': 'redis',
      \ 'context': ['SET key value '],
      \ 'cursor_pos': [1, 16],
      \ 'expected_start': 15,
      \ 'min_count': 1,
      \ 'expected_contains': ['EX', 'PX', 'NX', 'XX']
      \ })

" Test: SET command options with prefix filter
call dbcp#test#register({
      \ 'name': 'SET command options with prefix filter',
      \ 'db_type': 'redis',
      \ 'context': ['SET key value E'],
      \ 'cursor_pos': [1, 17],
      \ 'base': 'E',
      \ 'expected_start': 15,
      \ 'expected_contains': ['EX', 'EXAT']
      \ })

" =============================================================================
" Test Group: Key Completion
" =============================================================================

call dbcp#test#group('Redis - Key Completion')

" Test: Key completion after GET
call dbcp#test#register({
      \ 'name': 'Key completion after GET',
      \ 'db_type': 'redis',
      \ 'context': ['GET '],
      \ 'cursor_pos': [1, 5],
      \ 'expected_start': 4,
      \ 'min_count': 1,
      \ 'expected_contains': ['user:1', 'user:2', 'session:abc']
      \ })

" Test: Key completion after SET
call dbcp#test#register({
      \ 'name': 'Key completion after SET',
      \ 'db_type': 'redis',
      \ 'context': ['SET '],
      \ 'cursor_pos': [1, 5],
      \ 'expected_start': 4,
      \ 'min_count': 1,
      \ 'expected_contains': ['user:1', 'user:2']
      \ })

" Test: Key completion with prefix filter
call dbcp#test#register({
      \ 'name': 'Key completion with prefix filter',
      \ 'db_type': 'redis',
      \ 'context': ['GET user:'],
      \ 'cursor_pos': [1, 10],
      \ 'base': 'user:',
      \ 'expected_start': 4,
      \ 'expected_contains': ['user:1', 'user:2', 'user:3']
      \ })

" Test: Key completion with pattern
call dbcp#test#register({
      \ 'name': 'Key completion with pattern',
      \ 'db_type': 'redis',
      \ 'context': ['GET session:'],
      \ 'cursor_pos': [1, 13],
      \ 'base': 'session:',
      \ 'expected_start': 4,
      \ 'expected_contains': ['session:abc', 'session:def']
      \ })

" =============================================================================
" Test Group: Hash Field Completion
" =============================================================================

call dbcp#test#group('Redis - Hash Field Completion')

" Test: Hash field after HGET
call dbcp#test#register({
      \ 'name': 'Hash field after HGET',
      \ 'db_type': 'redis',
      \ 'context': ['HGET user:1 '],
      \ 'cursor_pos': [1, 13],
      \ 'expected_start': 12,
      \ 'min_count': 1,
      \ 'expected_contains': ['name', 'email', 'age']
      \ })

" Test: Hash field after HSET
call dbcp#test#register({
      \ 'name': 'Hash field after HSET',
      \ 'db_type': 'redis',
      \ 'context': ['HSET user:2 '],
      \ 'cursor_pos': [1, 13],
      \ 'expected_start': 12,
      \ 'min_count': 1,
      \ 'expected_contains': ['name', 'email', 'age']
      \ })

" Test: Hash field with prefix filter
call dbcp#test#register({
      \ 'name': 'Hash field with prefix filter',
      \ 'db_type': 'redis',
      \ 'context': ['HGET user:1 na'],
      \ 'cursor_pos': [1, 15],
      \ 'base': 'na',
      \ 'expected_start': 12,
      \ 'expected_contains': ['name']
      \ })

" Test: Hash field for different key
call dbcp#test#register({
      \ 'name': 'Hash field for different key',
      \ 'db_type': 'redis',
      \ 'context': ['HGET session:abc '],
      \ 'cursor_pos': [1, 17],
      \ 'expected_start': 16,
      \ 'min_count': 1,
      \ 'expected_contains': ['token', 'expires', 'user_id']
      \ })

" =============================================================================
" Test Group: Multi-line Context
" =============================================================================

call dbcp#test#group('Redis - Multi-line Context')

" Test: Multi-line command
call dbcp#test#register({
      \ 'name': 'Multi-line command',
      \ 'db_type': 'redis',
      \ 'context': ['GE'],
      \ 'cursor_pos': [1, 3],
      \ 'base': 'GE',
      \ 'expected_start': 0,
      \ 'min_count': 1
      \ })

" Test: Multi-line with key
call dbcp#test#register({
      \ 'name': 'Multi-line with key',
      \ 'db_type': 'redis',
      \ 'context': ['GET', 'user:'],
      \ 'cursor_pos': [2, 6],
      \ 'base': 'user:',
      \ 'expected_start': 0,
      \ 'min_count': 1
      \ })

" =============================================================================
" Test Group: No Completion Contexts
" =============================================================================

call dbcp#test#group('Redis - No Completion Contexts')

" Test: No completion in middle of command
call dbcp#test#register({
      \ 'name': 'No completion in middle of command',
      \ 'db_type': 'redis',
      \ 'context': ['GET key value'],
      \ 'cursor_pos': [1, 9],
      \ 'expected_start': -1
      \ })
