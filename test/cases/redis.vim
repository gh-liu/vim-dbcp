" Redis Completion Test Cases

" Load framework
source test/framework.vim

" =============================================================================
" Test Group: Command Completion
" =============================================================================

call TestGroup('Redis - Command Completion')

" Test: Command at line start
call TestRegister({
      \ 'name': 'Command at line start',
      \ 'db_type': 'redis',
      \ 'context': ['GE'],
      \ 'cursor_pos': [1, 3],
      \ 'base': 'GE',
      \ 'expected_start': 0,
      \ 'min_count': 1,
      \ 'expected_contains': ['GET']
      \ })

" Test: Command with prefix filter
call TestRegister({
      \ 'name': 'Command with prefix filter',
      \ 'db_type': 'redis',
      \ 'context': ['HS'],
      \ 'cursor_pos': [1, 3],
      \ 'base': 'HS',
      \ 'expected_start': 0,
      \ 'min_count': 1
      \ })

" Test: Command at start with whitespace
call TestRegister({
      \ 'name': 'Command at start with whitespace',
      \ 'db_type': 'redis',
      \ 'context': ['  SE'],
      \ 'cursor_pos': [1, 5],
      \ 'base': 'SE',
      \ 'expected_start': 0,
      \ 'min_count': 1,
      \ 'expected_contains': ['SET']
      \ })

" =============================================================================
" Test Group: Subcommand Completion
" =============================================================================

call TestGroup('Redis - Subcommand Completion')

" Test: CLIENT command
call TestRegister({
      \ 'name': 'CLIENT command completion',
      \ 'db_type': 'redis',
      \ 'context': ['CL'],
      \ 'cursor_pos': [1, 3],
      \ 'base': 'CL',
      \ 'expected_start': 0,
      \ 'min_count': 1,
      \ 'expected_contains': ['CLIENT']
      \ })

" Test: CONFIG command
call TestRegister({
      \ 'name': 'CONFIG command completion',
      \ 'db_type': 'redis',
      \ 'context': ['CO'],
      \ 'cursor_pos': [1, 3],
      \ 'base': 'CO',
      \ 'expected_start': 0,
      \ 'min_count': 1,
      \ 'expected_contains': ['CONFIG']
      \ })

" Test: ACL command
call TestRegister({
      \ 'name': 'ACL command completion',
      \ 'db_type': 'redis',
      \ 'context': ['AC'],
      \ 'cursor_pos': [1, 3],
      \ 'base': 'AC',
      \ 'expected_start': 0,
      \ 'min_count': 1,
      \ 'expected_contains': ['ACL']
      \ })

" =============================================================================
" Test Group: Option Completion
" =============================================================================

call TestGroup('Redis - Option Completion')

" Test: SET command options
call TestRegister({
      \ 'name': 'SET command options',
      \ 'db_type': 'redis',
      \ 'context': ['SET key value EX'],
      \ 'cursor_pos': [1, 18],
      \ 'base': 'EX',
      \ 'expected_start': 15,
      \ 'expected_contains': ['EX']
      \ })

" Test: SET command options with prefix filter
call TestRegister({
      \ 'name': 'SET command options with prefix filter',
      \ 'db_type': 'redis',
      \ 'context': ['SET key value E'],
      \ 'cursor_pos': [1, 17],
      \ 'base': 'E',
      \ 'expected_start': 15,
      \ 'expected_contains': ['EX']
      \ })

" =============================================================================
" Test Group: Key Completion
" =============================================================================

call TestGroup('Redis - Key Completion')

" Test: Key completion with GET
call TestRegister({
      \ 'name': 'Key completion with GET',
      \ 'db_type': 'redis',
      \ 'context': ['GET'],
      \ 'cursor_pos': [1, 4],
      \ 'expected_start': 0
      \ })

" =============================================================================
" Test Group: Hash Field Completion
" =============================================================================

call TestGroup('Redis - Hash Field Completion')

" Test: Hash field with HGET
call TestRegister({
      \ 'name': 'Hash field with HGET',
      \ 'db_type': 'redis',
      \ 'context': ['HGET'],
      \ 'cursor_pos': [1, 5],
      \ 'expected_start': 0
      \ })

" =============================================================================
" Test Group: Multi-line Context
" =============================================================================

call TestGroup('Redis - Multi-line Context')

" Test: Multi-line command
call TestRegister({
      \ 'name': 'Multi-line command',
      \ 'db_type': 'redis',
      \ 'context': ['GE'],
      \ 'cursor_pos': [1, 3],
      \ 'base': 'GE',
      \ 'expected_start': 0,
      \ 'min_count': 1
      \ })

" =============================================================================
" Test Group: No Completion Contexts
" =============================================================================

call TestGroup('Redis - No Completion Contexts')

" Test: No completion in middle of command
call TestRegister({
      \ 'name': 'No completion in middle of command',
      \ 'db_type': 'redis',
      \ 'context': ['GET key value'],
      \ 'cursor_pos': [1, 9],
      \ 'expected_start': -1
      \ })

" =============================================================================
" Test Group: KEY Commands (High Priority)
" =============================================================================

call TestGroup('Redis - KEY Commands')

" Test: DEL key completion
call TestRegister({
      \ 'name': 'DEL key completion',
      \ 'db_type': 'redis',
      \ 'context': ['DEL '],
      \ 'cursor_pos': [1, 4],
      \ 'expected_start': -1
      \ })

" Test: EXISTS key completion
call TestRegister({
      \ 'name': 'EXISTS key completion',
      \ 'db_type': 'redis',
      \ 'context': ['EXISTS '],
      \ 'cursor_pos': [1, 7],
      \ 'expected_start': -1
      \ })

" Test: MGET key completion
call TestRegister({
      \ 'name': 'MGET key completion',
      \ 'db_type': 'redis',
      \ 'context': ['MGET '],
      \ 'cursor_pos': [1, 5],
      \ 'expected_start': -1
      \ })

" Test: MSET key completion
call TestRegister({
      \ 'name': 'MSET key completion',
      \ 'db_type': 'redis',
      \ 'context': ['MSET '],
      \ 'cursor_pos': [1, 5],
      \ 'expected_start': -1
      \ })

" =============================================================================
" Test Group: ZSET Commands (Medium Priority)
" =============================================================================

call TestGroup('Redis - ZSET Commands')

" Test: ZADD command completion
call TestRegister({
      \ 'name': 'ZADD command completion',
      \ 'db_type': 'redis',
      \ 'context': ['ZA'],
      \ 'cursor_pos': [1, 3],
      \ 'base': 'ZA',
      \ 'expected_start': 0,
      \ 'min_count': 1,
      \ 'expected_contains': ['ZADD']
      \ })

" Test: ZRANGE command completion
call TestRegister({
      \ 'name': 'ZRANGE command completion',
      \ 'db_type': 'redis',
      \ 'context': ['ZR'],
      \ 'cursor_pos': [1, 3],
      \ 'base': 'ZR',
      \ 'expected_start': 0,
      \ 'min_count': 1,
      \ 'expected_contains': ['ZRANGE']
      \ })

" =============================================================================
" Test Group: Bit Operations (Low Priority)
" =============================================================================

call TestGroup('Redis - Bit Operations')

" Test: SETBIT option completion
call TestRegister({
      \ 'name': 'SETBIT option completion',
      \ 'db_type': 'redis',
      \ 'context': ['SETBIT key '],
      \ 'cursor_pos': [1, 13],
      \ 'expected_start': 0,
      \ 'min_count': 1
      \ })

" =============================================================================
" Test Group: PubSub Commands (Low Priority)
" =============================================================================

call TestGroup('Redis - PubSub Commands')

" Test: PUBSUB command completion
call TestRegister({
      \ 'name': 'PUBSUB command completion',
      \ 'db_type': 'redis',
      \ 'context': ['PU'],
      \ 'cursor_pos': [1, 3],
      \ 'base': 'PU',
      \ 'expected_start': 0,
      \ 'min_count': 1
      \ })

" =============================================================================
" Test Group: Script Commands (Low Priority)
" =============================================================================

call TestGroup('Redis - Script Commands')

" Test: SCRIPT command completion
call TestRegister({
      \ 'name': 'SCRIPT command completion',
      \ 'db_type': 'redis',
      \ 'context': ['SC'],
      \ 'cursor_pos': [1, 3],
      \ 'base': 'SC',
      \ 'expected_start': 0,
      \ 'min_count': 1
      \ })

" Test: SCRIPT subcommand completion
call TestRegister({
      \ 'name': 'SCRIPT subcommand completion',
      \ 'db_type': 'redis',
      \ 'context': ['SCRIPT '],
      \ 'cursor_pos': [1, 8],
      \ 'expected_start': 0,
      \ 'min_count': 1,
      \ 'expected_contains': ['LOAD', 'EXISTS', 'FLUSH']
      \ })

" =============================================================================
" Test Group: Debug Commands (Low Priority)
" =============================================================================

call TestGroup('Redis - Debug Commands')

" Test: DEBUG command completion
call TestRegister({
      \ 'name': 'DEBUG command completion',
      \ 'db_type': 'redis',
      \ 'context': ['DE'],
      \ 'cursor_pos': [1, 3],
      \ 'base': 'DE',
      \ 'expected_start': 0,
      \ 'min_count': 1,
      \ 'expected_contains': ['DEBUG']
      \ })

" Test: MEMORY command completion
call TestRegister({
      \ 'name': 'MEMORY command completion',
      \ 'db_type': 'redis',
      \ 'context': ['ME'],
      \ 'cursor_pos': [1, 3],
      \ 'base': 'ME',
      \ 'expected_start': 0,
      \ 'min_count': 1,
      \ 'expected_contains': ['MEMORY']
      \ })

" =============================================================================
" Test Group: Error Handling (High Priority)
" =============================================================================

call TestGroup('Redis - Error Handling')

call TestRegister({
      \ 'name': 'Pure whitespace no completion',
      \ 'db_type': 'redis',
      \ 'context': ['   '],
      \ 'cursor_pos': [1, 4],
      \ 'expected_start': -1
      \ })

call TestRegister({
      \ 'name': 'Comment line no completion',
      \ 'db_type': 'redis',
      \ 'context': ['# This is a comment GE'],
      \ 'cursor_pos': [1, 26],
      \ 'expected_start': -1
      \ })

call TestRegister({
      \ 'name': 'Semicolon separated no completion',
      \ 'db_type': 'redis',
      \ 'context': ['GET key; SE'],
      \ 'cursor_pos': [1, 13],
      \ 'expected_start': -1
      \ })

call TestRegister({
      \ 'name': 'Middle of value no completion',
      \ 'db_type': 'redis',
      \ 'context': ['SET key some_value GE'],
      \ 'cursor_pos': [1, 21],
      \ 'expected_start': -1
      \ })

call TestRegister({
      \ 'name': 'String literal context',
      \ 'db_type': 'redis',
      \ 'context': ['SET key "GE'],
      \ 'cursor_pos': [1, 13],
      \ 'expected_start': -1
      \ })

call TestRegister({
      \ 'name': 'Invalid command prefix',
      \ 'db_type': 'redis',
      \ 'context': ['XYZ'],
      \ 'cursor_pos': [1, 4],
      \ 'expected_start': 0,
      \ 'min_count': 0
      \ })

" =============================================================================
" Test Group: Edge Cases (High Priority)
" =============================================================================

call TestGroup('Redis - Edge Cases')

call TestRegister({
      \ 'name': 'Single character command',
      \ 'db_type': 'redis',
      \ 'context': ['G'],
      \ 'cursor_pos': [1, 2],
      \ 'expected_start': 0,
      \ 'min_count': 1
      \ })

call TestRegister({
      \ 'name': 'Case insensitive commands',
      \ 'db_type': 'redis',
      \ 'context': ['get'],
      \ 'cursor_pos': [1, 4],
      \ 'expected_start': 0
      \ })

call TestRegister({
      \ 'name': 'Long command prefix',
      \ 'db_type': 'redis',
      \ 'context': ['PERSIS'],
      \ 'cursor_pos': [1, 6],
      \ 'base': 'PERSIS',
      \ 'expected_start': 0
      \ })

call TestRegister({
      \ 'name': 'Whitespace before command',
      \ 'db_type': 'redis',
      \ 'context': ['  GET'],
      \ 'cursor_pos': [1, 5],
      \ 'expected_start': 0
      \ })

call TestRegister({
      \ 'name': 'Tab before command',
      \ 'db_type': 'redis',
      \ 'context': ['\tSE'],
      \ 'cursor_pos': [1, 4],
      \ 'base': 'SE',
      \ 'expected_start': 0,
      \ 'min_count': 1,
      \ 'expected_contains': ['SET', 'SELECT']
      \ })

" =============================================================================
" Test Group: Cluster Commands (Medium Priority)
" =============================================================================

call TestGroup('Redis - Cluster Commands')

call TestRegister({
      \ 'name': 'CLUSTER subcommand completion',
      \ 'db_type': 'redis',
      \ 'context': ['CLUSTER '],
      \ 'cursor_pos': [1, 9],
      \ 'expected_start': 0
      \ })

call TestRegister({
      \ 'name': 'CLUSTER INFO',
      \ 'db_type': 'redis',
      \ 'context': ['CLUSTER INFO'],
      \ 'cursor_pos': [1, 12],
      \ 'expected_start': 0,
      \ 'min_count': 0
      \ })

call TestRegister({
      \ 'name': 'CLUSTER NODES',
      \ 'db_type': 'redis',
      \ 'context': ['CLUSTER NODES'],
      \ 'cursor_pos': [1, 13],
      \ 'expected_start': 0,
      \ 'min_count': 0
      \ })

call TestRegister({
      \ 'name': 'CLUSTER REPLICAS',
      \ 'db_type': 'redis',
      \ 'context': ['CLUSTER REP'],
      \ 'cursor_pos': [1, 12],
      \ 'base': 'REP',
      \ 'expected_start': 0
      \ })

" =============================================================================
" Test Group: Server Commands (Medium Priority)
" =============================================================================

call TestGroup('Redis - Server Commands')

call TestRegister({
       \ 'name': 'SERVER command completion',
      \ 'db_type': 'redis',
      \ 'context': ['SER'],
      \ 'cursor_pos': [1, 4],
      \ 'base': 'SER',
      \ 'expected_start': 0
      \ })

call TestRegister({
      \ 'name': 'CLIENT subcommand completion',
      \ 'db_type': 'redis',
      \ 'context': ['CLIENT '],
      \ 'cursor_pos': [1, 8],
      \ 'expected_start': 0
      \ })

call TestRegister({
      \ 'name': 'CONFIG subcommand completion',
      \ 'db_type': 'redis',
      \ 'context': ['CONFIG '],
      \ 'cursor_pos': [1, 7],
      \ 'expected_start': 0
      \ })

call TestRegister({
      \ 'name': 'MODULE subcommand completion',
      \ 'db_type': 'redis',
      \ 'context': ['MODULE '],
      \ 'cursor_pos': [1, 8],
      \ 'expected_start': 0
      \ })

" =============================================================================
" Test Group: Geo Commands (Low Priority)
" =============================================================================

call TestGroup('Redis - Geo Commands')

call TestRegister({
      \ 'name': 'GEOADD command',
      \ 'db_type': 'redis',
      \ 'context': ['GEO'],
      \ 'cursor_pos': [1, 4],
      \ 'expected_start': 0,
      \ 'min_count': 1
      \ })

call TestRegister({
      \ 'name': 'GEORADIUS options',
      \ 'db_type': 'redis',
      \ 'context': ['GEORADIUS key 10 20 50 km WI'],
      \ 'cursor_pos': [1, 27],
      \ 'base': 'WI',
      \ 'expected_start': 24,
      \ 'expected_contains': ['WITHCOORD', 'WITHDIST']
      \ })

" =============================================================================
" Test Group: Stream Commands (Low Priority)
" =============================================================================

call TestGroup('Redis - Stream Commands')

call TestRegister({
      \ 'name': 'XREAD command',
      \ 'db_type': 'redis',
      \ 'context': ['XRE'],
      \ 'cursor_pos': [1, 4],
      \ 'base': 'XRE',
      \ 'expected_start': 0,
      \ 'min_count': 1
      \ })

call TestRegister({
      \ 'name': 'XGROUP subcommand',
      \ 'db_type': 'redis',
      \ 'context': ['XGROUP '],
      \ 'cursor_pos': [1, 7],
      \ 'expected_start': 0,
      \ 'min_count': 1,
      \ 'expected_contains': ['CREATE', 'SETID', 'DESTROY']
      \ })

" =============================================================================
" Test Group: Replication Commands (Low Priority)
" =============================================================================

call TestGroup('Redis - Replication Commands')

call TestRegister({
      \ 'name': 'REPLICAOF command',
      \ 'db_type': 'redis',
      \ 'context': ['REPLI'],
      \ 'cursor_pos': [1, 6],
      \ 'base': 'REPLI',
      \ 'expected_start': 0,
      \ 'expected_contains': ['REPLICAOF']
      \ })

call TestRegister({
      \ 'name': 'SLAVEOF command',
      \ 'db_type': 'redis',
      \ 'context': ['SLAVEOF '],
      \ 'cursor_pos': [1, 9],
      \ 'expected_start': 0,
      \ 'min_count': 0
      \ })

call TestRegister({
      \ 'name': 'ROLE command',
      \ 'db_type': 'redis',
      \ 'context': ['ROLE'],
      \ 'cursor_pos': [1, 5],
      \ 'expected_start': 0,
      \ 'min_count': 0
      \ })

" =============================================================================
" Test Group: Connection Commands (Low Priority)
" =============================================================================

call TestGroup('Redis - Connection Commands')

call TestRegister({
      \ 'name': 'ECHO with filter',
      \ 'db_type': 'redis',
      \ 'context': ['EC'],
      \ 'cursor_pos': [1, 3],
      \ 'base': 'EC',
      \ 'expected_start': 0,
      \ 'expected_contains': ['ECHO']
      \ })

call TestRegister({
      \ 'name': 'PING command',
      \ 'db_type': 'redis',
      \ 'context': ['PI'],
      \ 'cursor_pos': [1, 3],
      \ 'base': 'PI',
      \ 'expected_start': 0,
      \ 'expected_contains': ['PING']
      \ })

call TestRegister({
      \ 'name': 'QUIT command',
      \ 'db_type': 'redis',
      \ 'context': ['QU'],
      \ 'cursor_pos': [1, 3],
      \ 'base': 'QU',
      \ 'expected_start': 0,
      \ 'expected_contains': ['QUIT']
      \ })

call TestRegister({
      \ 'name': 'SELECT database',
      \ 'db_type': 'redis',
      \ 'context': ['SELE'],
      \ 'cursor_pos': [1, 5],
      \ 'base': 'SELE',
      \ 'expected_start': 0,
      \ 'expected_contains': ['SELECT']
      \ })

