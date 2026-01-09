" vim-dbcp: Test Runner
" Main entry point for running all database completion tests
" Usage: vim -S test/run_tests.vim
"        vim -S test/run_tests.vim postgresql  (run only PostgreSQL tests)
"        vim -S test/run_tests.vim mongodb    (run only MongoDB tests)

" =============================================================================
" Setup
" =============================================================================

" Get test directory and project root
let s:test_dir = fnamemodify(expand('<sfile>'), ':p:h')
let s:project_root = fnamemodify(s:test_dir, ':h')

" Setup runtimepath
execute 'set runtimepath+=' . s:project_root

" Create mock adapter directory
call mkdir(s:test_dir . '/tmp/autoload/db', 'p')

" Write mock adapter to tmp location
let l:mock_content = readfile(s:test_dir . '/mock_adapter.vim')
call writefile(l:mock_content, s:test_dir . '/tmp/autoload/db/adapter.vim')
execute 'set runtimepath+=' . s:test_dir . '/tmp'

" Force reload autoload scripts
if exists('g:autoloaded_dbcp')
  unlet g:autoloaded_dbcp
endif
if exists('g:autoloaded_dbcp_sql')
  unlet g:autoloaded_dbcp_sql
endif
if exists('g:autoloaded_dbcp_adapter_postgresql')
  unlet g:autoloaded_dbcp_adapter_postgresql
endif
if exists('g:autoloaded_dbcp_adapter_mysql')
  unlet g:autoloaded_dbcp_adapter_mysql
endif
if exists('g:autoloaded_dbcp_adapter_mariadb')
  unlet g:autoloaded_dbcp_adapter_mariadb
endif
if exists('g:autoloaded_dbcp_adapter_sqlite')
  unlet g:autoloaded_dbcp_adapter_sqlite
endif
if exists('g:autoloaded_dbcp_adapter_sqlserver')
  unlet g:autoloaded_dbcp_adapter_sqlserver
endif
if exists('g:autoloaded_dbcp_adapter_oracle')
  unlet g:autoloaded_dbcp_adapter_oracle
endif
if exists('g:autoloaded_dbcp_adapter_mongodb')
  unlet g:autoloaded_dbcp_adapter_mongodb
endif
if exists('g:autoloaded_dbcp_adapter_redis')
  unlet g:autoloaded_dbcp_adapter_redis
endif
if exists('g:autoloaded_dbcp_test_framework')
  unlet g:autoloaded_dbcp_test_framework
endif

" Load framework
execute 'source ' . s:test_dir . '/framework.vim'

" Verify framework loaded
if !exists('*dbcp#test#register')
  echoerr 'Failed to load test framework'
  cquit! 1
endif

" Load adapters (they will be autoloaded, but we can preload if needed)
" The adapters will be loaded automatically when test cases run

" =============================================================================
" Load Test Cases
" =============================================================================

echo 'Loading test cases...'
echo ''

" Load SQL test cases
try
  execute 'source ' . s:test_dir . '/cases/sql.vim'
  echo '  ✓ Loaded SQL test cases'
catch
  echoerr '  ✗ Failed to load SQL test cases: ' . v:exception
  cquit! 1
endtry

" Load MongoDB test cases
try
  execute 'source ' . s:test_dir . '/cases/mongodb.vim'
  echo '  ✓ Loaded MongoDB test cases'
catch
  echoerr '  ✗ Failed to load MongoDB test cases: ' . v:exception
  cquit! 1
endtry

" Load Redis test cases
try
  execute 'source ' . s:test_dir . '/cases/redis.vim'
  echo '  ✓ Loaded Redis test cases'
catch
  echoerr '  ✗ Failed to load Redis test cases: ' . v:exception
  cquit! 1
endtry

echo ''

" =============================================================================
" Run Tests
" =============================================================================

" Get filter argument (if any)
let l:filter_db = argc() > 0 ? argv(0) : ''

if l:filter_db != ''
  echo '========================================'
  echo printf('Running tests for: %s', l:filter_db)
  echo '========================================'
  echo ''
  let l:result = dbcp#test#run(l:filter_db)
else
  echo '========================================'
  echo 'Running all tests'
  echo '========================================'
  echo ''
  let l:result = dbcp#test#run()
endif

" =============================================================================
" Summary
" =============================================================================

echo ''
echo '========================================'
echo 'Test Summary'
echo '========================================'
echo printf('Total: %d', l:result.total)
echo printf('Passed: %d', l:result.passed)
echo printf('Failed: %d', l:result.failed)
echo '========================================'

" Group results by database type
let l:results = dbcp#test#get_results()
let l:by_db = {}
for l:r in l:results
  let l:db = l:r.test.db_type
  if !has_key(l:by_db, l:db)
    let l:by_db[l:db] = {'passed': 0, 'failed': 0, 'total': 0}
  endif
  if l:r.passed
    let l:by_db[l:db].passed += 1
  else
    let l:by_db[l:db].failed += 1
  endif
  let l:by_db[l:db].total += 1
endfor

if !empty(l:by_db)
  echo ''
  echo 'By Database Type:'
  for l:db in sort(keys(l:by_db))
    let l:stats = l:by_db[l:db]
    echo printf('  %s: %d passed, %d failed, %d total', l:db, l:stats.passed, l:stats.failed, l:stats.total)
  endfor
endif

" Exit with appropriate code
if l:result.failed > 0
  echo ''
  echoerr printf('%d test(s) failed!', l:result.failed)
  cquit! 1
else
  echo ''
  echo 'All tests passed! ✓'
  quit!
endif
