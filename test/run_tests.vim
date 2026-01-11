" vim-dbcp: Test Runner
" Main entry point for running all database completion tests
"
" Usage:
"   vim -S test/run_tests.vim                    # Run all tests
"   vim -S test/run_tests.vim postgresql         # Run PostgreSQL tests only
"   vim -S test/run_tests.vim -- --format=junit  # JUnit XML output
"   vim -S test/run_tests.vim -- --format=json --output=results.json
"   vim -S test/run_tests.vim -- --verbose       # Detailed output
"
" Options:
"   --format=FORMAT   Output format: junit, json, tap, default
"   --output=FILE     Write output to file
"   --verbose         Show detailed output
"   --quiet           Show only summary
"   --filter=TYPE     Run tests for specific database type
"   --help            Show this help message

let s:test_dir = fnamemodify(expand('<sfile>'), ':p:h')
let s:project_root = fnamemodify(s:test_dir, ':h')

let s:options = {
      \ 'filter': '',
      \ 'format': 'default',
      \ 'output': '',
      \ 'verbose': 0,
      \ 'quiet': 0,
      \ 'help': 0,
      \ }

let s:adapters = ['postgresql', 'mysql', 'mariadb', 'sqlite', 'sqlserver', 'oracle', 'mongodb', 'redis']
let s:loaded_scripts = [
      \ 'dbcp', 'dbcp_sql', 'dbcp_csv',
      \ 'dbcp_adapter_postgresql', 'dbcp_adapter_mysql', 'dbcp_adapter_mariadb',
      \ 'dbcp_adapter_sqlite', 'dbcp_adapter_sqlserver', 'dbcp_adapter_oracle',
      \ 'dbcp_adapter_mongodb', 'dbcp_adapter_redis',
      \ 'dbcp_test_framework',
      \]

function! s:show_help() abort
  echo 'vim-dbcp Test Runner'
  echo ''
  echo 'Usage: vim -S test/run_tests.vim [filter] [options]'
  echo ''
  echo 'Arguments:'
  echo '  filter              Database type to test (e.g., postgresql, mongodb)'
  echo ''
  echo 'Options:'
  echo '  --format=FORMAT     Output format: junit, json, tap, default'
  echo '  --output=FILE       Write output to file'
  echo '  --verbose           Show detailed output'
  echo '  --quiet             Show only summary'
  echo '  --filter=TYPE       Run tests for specific database type'
  echo '  --help              Show this help message'
  echo ''
  echo 'Examples:'
  echo '  vim -S test/run_tests.vim'
  echo '  vim -S test/run_tests.vim postgresql'
  echo '  vim -S test/run_tests.vim -- --format=junit --output=junit.xml'
  echo '  vim -S test/run_tests.vim -- --format=json --output=results.json'
  echo '  vim -S test/run_tests.vim mongodb -- --quiet'
  cquit!
endfunction

function! s:parse_options() abort
  for l:arg in argv()
    if l:arg ==# '--help' || l:arg ==# '-h'
      let s:options.help = 1
    elseif l:arg =~# '^--filter=' || l:arg =~# '^--db='
      let s:options.filter = substitute(l:arg, '^--filter=\|^--db=', '', '')
    elseif l:arg =~# '^--format='
      let s:options.format = substitute(l:arg, '^--format=', '', '')
    elseif l:arg =~# '^--output='
      let s:options.output = substitute(l:arg, '^--output=', '', '')
    elseif l:arg =~# '^--verbose$'
      let s:options.verbose = 1
    elseif l:arg =~# '^--quiet$'
      let s:options.quiet = 1
    elseif l:arg !~# '^--'
      let s:options.filter = l:arg
    endif
  endfor
endfunction

function! s:setup_runtimepath() abort
  execute 'set runtimepath+=' . s:project_root
  call mkdir(s:test_dir . '/tmp/autoload/db', 'p')

  let l:mock = readfile(s:test_dir . '/mock_adapter.vim')
  call writefile(l:mock, s:test_dir . '/tmp/autoload/db/adapter.vim')
  execute 'set runtimepath+=' . s:test_dir . '/tmp'
endfunction

function! s:reload_scripts() abort
  for l:name in s:loaded_scripts
    let l:var = 'g:autoloaded_' . l:name
    if exists(l:var)
      unlet {l:var}
    endif
  endfor
endfunction

function! s:load_framework() abort
  execute 'source ' . s:test_dir . '/framework.vim'

  if !exists('*TestRegister')
    if !s:options.quiet
      echoerr 'Failed to load test framework'
    endif
    cquit! 1
  endif
endfunction

function! s:load_test_cases() abort
  let l:cases_files = {
        \ 'sql': s:test_dir . '/cases/sql.vim',
        \ 'mongodb': s:test_dir . '/cases/mongodb.vim',
        \ 'redis': s:test_dir . '/cases/redis.vim',
        \ }

  for [l:name, l:path] in items(l:cases_files)
    try
      execute 'source ' . l:path
      if !s:options.quiet
        echo '  [OK] ' . toupper(l:name) . ' test cases'
      endif
    catch
      echoerr '  [FAIL] Failed to load ' . l:name . ' test cases: ' . v:exception
      cquit! 1
    endtry
  endfor
endfunction

function! s:run_tests() abort
  if s:options.filter != ''
    if !s:options.quiet
      echo '========================================'
      echo 'Running tests for: ' . s:options.filter
      echo '========================================'
      echo ''
    endif
    return RunTests(s:options.filter)
  endif

  if !s:options.quiet
    echo '========================================'
    echo 'Running all tests'
    echo '========================================'
    echo ''
  endif
  return RunTests()
endfunction

function! s:show_statistics() abort
  if s:options.verbose || !s:options.quiet
    call ShowTestStatistics()
  endif
endfunction

function! s:output_results(result) abort
  if !empty(s:options.output) || s:options.format !=# 'default'
    let l:content = ''

    if s:options.format ==# 'junit'
      let l:content = ExportJUnitXML()
    elseif s:options.format ==# 'json'
      let l:content = ExportJSON()
    elseif s:options.format ==# 'tap'
      let l:content = ExportTAP()
    endif

    if !empty(s:options.output)
      call writefile(split(l:content, '\n'), s:options.output)
      if !s:options.quiet
        echo ''
        echo 'Wrote ' . s:options.format . ' output to: ' . s:options.output
      endif
    else
      echo ''
      echo '--- ' . s:options.format . ' output ---'
      echo l:content
      echo '--- end ---'
    endif
  endif
endfunction

function! s:exit_with_result(result) abort
  if a:result.failed > 0
    if !s:options.quiet
      echo ''
      echoerr printf('%d test(s) failed!', a:result.failed)
    endif
    cquit! 1
  else
    if !s:options.quiet
      echo ''
      echo 'All tests passed!'
    endif
    quit!
  endif
endfunction

" Main execution
call s:parse_options()

if s:options.help
  call s:show_help()
endif

call s:setup_runtimepath()
call s:reload_scripts()
call s:load_framework()

if !s:options.quiet
  echo 'Loading test cases...'
  echo ''
endif

call s:load_test_cases()

echo ''

let l:result = s:run_tests()

call s:show_statistics()
call s:output_results(l:result)

call s:exit_with_result(l:result)
