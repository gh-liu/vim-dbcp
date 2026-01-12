" vim-dbcp: Integration Tests (Optional)
" Tests with real database connections
"
" Usage:
"   vim -S test/integration.vim                    # Run all available tests
"   vim -S test/integration.vim -- --verbose       # Detailed output
"   vim -S test/integration.vim postgresql         # Run PostgreSQL only
"
" Environment variables (optional - set to run real database tests):
"   POSTGRES_TEST_DB_URL   - PostgreSQL connection URL
"   MYSQL_TEST_DB_URL      - MySQL connection URL
"   MONGODB_TEST_DB_URL    - MongoDB connection URL
"   REDIS_TEST_DB_URL      - Redis connection URL
"
" Examples:
"   export POSTGRES_TEST_DB_URL="postgresql://user:pass@localhost/testdb"
"   vim -S test/integration.vim
"

let s:test_dir = fnamemodify(expand('<sfile>'), ':p:h')
let s:project_root = fnamemodify(s:test_dir, ':h')
let s:options = {'verbose': 0, 'filter': ''}

let s:integration_results = []

function! s:parse_args() abort
  for arg in argv()
    if arg =~# '^--verbose$'
      let s:options.verbose = 1
    elseif arg !~# '^--'
      let s:options.filter = arg
    endif
  endfor
endfunction

function! s:get_db_url(db_type) abort
  let env_var = toupper(a:db_type) . '_TEST_DB_URL'
  let url = getenv(env_var)
  if empty(url)
    echo printf('[SKIP] %s integration test (set %s to run)', a:db_type, env_var)
    return ''
  endif
  return url
endfunction

function! s:setup_runtimepath() abort
  execute 'set runtimepath+=' . s:project_root
endfunction

function! s:run_integration_test(test_def) abort
  let l:result = {
        \ 'name': a:test_def.name,
        \ 'db_type': a:test_def.db_type,
        \ 'passed': 0,
        \ 'errors': [],
        \ 'duration': 0,
        \ }

  let l:start_time = reltime()

  try
    enew!
    setlocal filetype=sql
    let b:db = a:test_def.db_url

    if type(a:test_def.context) == v:t_list
      call setline(1, a:test_def.context)
    else
      call setline(1, split(a:test_def.context, "\n"))
    endif

    call cursor(a:test_def.cursor_pos[0], a:test_def.cursor_pos[1])

    let l:AdapterFunc = 'dbcp#adapter#' . a:test_def.db_type . '#complete'

    if !exists('*' . l:AdapterFunc)
      call add(l:result.errors, 'No completion function found: ' . l:AdapterFunc)
      let l:result.failed = 1
      return l:result
    endif

    let l:CompleteFunc = function(l:AdapterFunc)
    let l:db_url = b:db

    let l:actual_start = l:CompleteFunc(1, '', l:db_url)

    if has_key(a:test_def, 'expected_start')
      if l:actual_start != a:test_def.expected_start
        call add(l:result.errors, printf('findstart: expected %d, got %d', a:test_def.expected_start, l:actual_start))
      endif
    endif

    if l:actual_start >= 0
      let l:line = getline(a:test_def.cursor_pos[0])
      let l:base = ''
      if a:test_def.cursor_pos[1] > l:actual_start
        let l:base = l:line[l:actual_start : a:test_def.cursor_pos[1] - 1]
      endif

      let l:items = l:CompleteFunc(0, l:base, l:db_url)
      let l:item_words = map(copy(l:items), {_, v -> get(v, 'word', get(v, 'abbr', ''))})

      if has_key(a:test_def, 'expected_contains')
        for l:expected in a:test_def.expected_contains
          if index(l:item_words, l:expected) < 0
            call add(l:result.errors, 'Missing: ' . l:expected)
          endif
        endfor
      endif

      if has_key(a:test_def, 'min_count')
        if len(l:items) < a:test_def.min_count
          call add(l:result.errors, printf('Expected at least %d items, got %d', a:test_def.min_count, len(l:items)))
        endif
      endif
    endif

    if empty(l:result.errors)
      let l:result.passed = 1
    endif

  catch
    call add(l:result.errors, 'Exception: ' . v:exception)
  endtry

  let l:result.duration = str2float(substitute(reltimestr(reltime(l:start_time)), '\..*', '', ''))
  bwipe!
  return l:result
endfunction

function! s:register_integration_tests() abort
  let l:tests = []

  let l:postgres_url = s:get_db_url('postgresql')
  if !empty(l:postgres_url)
    call add(l:tests, {
          \ 'name': 'PostgreSQL table list',
          \ 'db_type': 'postgresql',
          \ 'db_url': l:postgres_url,
          \ 'context': ['SELECT * FROM '],
          \ 'cursor_pos': [1, 17],
          \ 'expected_start': 13,
          \ 'min_count': 1,
          \ })
    call add(l:tests, {
          \ 'name': 'PostgreSQL column completion',
          \ 'db_type': 'postgresql',
          \ 'db_url': l:postgres_url,
          \ 'context': ['SELECT * FROM users WHERE users.'],
          \ 'cursor_pos': [1, 32],
          \ 'expected_start': 32,
          \ 'min_count': 1,
          \ })
  endif

  let l:mysql_url = s:get_db_url('mysql')
  if !empty(l:mysql_url)
    call add(l:tests, {
          \ 'name': 'MySQL table list',
          \ 'db_type': 'mysql',
          \ 'db_url': l:mysql_url,
          \ 'context': ['SELECT * FROM '],
          \ 'cursor_pos': [1, 17],
          \ 'expected_start': 13,
          \ 'min_count': 1,
          \ })
  endif

  let l:mongodb_url = s:get_db_url('mongodb')
  if !empty(l:mongodb_url)
    call add(l:tests, {
          \ 'name': 'MongoDB collection completion',
          \ 'db_type': 'mongodb',
          \ 'db_url': l:mongodb_url,
          \ 'context': ['db.'],
          \ 'cursor_pos': [1, 4],
          \ 'expected_start': 3,
          \ 'min_count': 1,
          })
  endif

  let l:redis_url = s:get_db_url('redis')
  if !empty(l:redis_url)
    call add(l:tests, {
          \ 'name': 'Redis command completion',
          \ 'db_type': 'redis',
          \ 'db_url': l:redis_url,
          \ 'context': ['GE'],
          \ 'cursor_pos': [1, 3],
          \ 'base': 'GE',
          \ 'expected_start': 0,
          \ 'min_count': 1,
          \ 'expected_contains': ['GET'],
          \ })
  endif

  if !empty(s:options.filter)
    call filter(l:tests, {_, v -> v.db_type ==# s:options.filter})
  endif

  return l:tests
endfunction

function! s:run_all_integration_tests() abort
  call s:parse_args()
  call s:setup_runtimepath()

  echo '========================================'
  echo 'Running vim-dbcp Integration Tests'
  echo '========================================'
  echo ''
  echo 'Note: Set environment variables to enable real database tests:'
  echo '  POSTGRES_TEST_DB_URL'
  echo '  MYSQL_TEST_DB_URL'
  echo '  MONGODB_TEST_DB_URL'
  echo '  REDIS_TEST_DB_URL'
  echo ''

  let l:tests = s:register_integration_tests()

  if empty(l:tests)
    echo ''
    echo 'No integration tests configured. Set at least one TEST_DB_URL environment variable.'
    quit!
    return
  endif

  echo printf('Running %d integration test(s)...', len(l:tests))
  echo ''

  let l:passed = 0
  let l:failed = 0

  for l:test in l:tests
    let l:result = s:run_integration_test(l:test)
    call add(s:integration_results, l:result)

    if l:result.passed
      let l:passed += 1
      echo printf('  [PASS] %s', l:test.name)
      if s:options.verbose
        echo printf('    Duration: %ss', l:result.duration)
      endif
    else
      let l:failed += 1
      echo printf('  [FAIL] %s', l:test.name)
      for l:error in l:result.errors
        echo printf('    ERROR: %s', l:error)
      endfor
    endif
  endfor

  echo ''
  echo '========================================'
  echo printf('Results: %d passed, %d failed, %d total', l:passed, l:failed, len(l:tests))
  echo '========================================'

  if l:failed > 0
    cquit! 1
  else
    quit!
  endif
endfunction

call s:run_all_integration_tests()
