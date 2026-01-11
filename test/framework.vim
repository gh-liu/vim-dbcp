" vim-dbcp: Test Framework
" Unified testing framework for database completion scenarios

if exists('g:autoloaded_dbcp_test_framework')
  finish
endif
let g:autoloaded_dbcp_test_framework = 1

let s:test_cases = []
let s:test_results = []
let s:current_group = ''
let s:cleanup_hooks = []

let s:DB_TYPES_SQL = ['postgresql', 'mysql', 'mariadb', 'sqlite', 'sqlserver', 'oracle']
let s:DB_TYPES_NOSQL = ['mongodb', 'redis']

function! TestGroup(name) abort
  let s:current_group = a:name
endfunction

function! TestRegister(test_case) abort
  let l:test = copy(a:test_case)
  let l:test.group = s:current_group
  if !has_key(l:test, 'name')
    throw 'Test case must have a "name" field'
  endif
  if !has_key(l:test, 'db_type')
    throw 'Test case must have a "db_type" field'
  endif
  if !has_key(l:test, 'context')
    throw 'Test case must have a "context" field'
  endif
  if !has_key(l:test, 'cursor_pos')
    throw 'Test case must have a "cursor_pos" field'
  endif
  if !has_key(l:test, 'expected_start')
    throw 'Test case must have an "expected_start" field'
  endif

  if !has_key(l:test, 'base')
    let l:test.base = ''
  endif

  call add(s:test_cases, l:test)
endfunction

function! GetTestCases(...) abort
  if a:0 > 0
    let l:db_type = a:1
    return filter(copy(s:test_cases), {_, v -> v.db_type ==# l:db_type})
  endif
  return copy(s:test_cases)
endfunction

function! ClearTests() abort
  call s:cleanup_all()
  let s:test_cases = []
  let s:test_results = []
  let s:current_group = ''
endfunction

function! CleanupTests() abort
  call s:cleanup_all()
endfunction

function! s:cleanup_all() abort
  for l:hook in s:cleanup_hooks
    try
      call call(l:hook, [])
    catch
    endtry
  endfor
  let s:cleanup_hooks = []

  if exists('b:db')
    unlet b:db
  endif

  for l:script in s:get_loaded_scripts()
    let l:var = 'g:autoloaded_' . l:script
    if exists(l:var)
      unlet {l:var}
    endif
  endfor

  call s:clear_vim_caches()
endfunction

function! s:clear_vim_caches() abort
  if exists('*clearmatches')
    call clearmatches()
  endif
endfunction

function! s:register_cleanup_hook(hook) abort
  call add(s:cleanup_hooks, a:hook)
endfunction

function! s:get_loaded_scripts() abort
  return [
        \ 'dbcp',
        \ 'dbcp_sql',
        \ 'dbcp_csv',
        \ 'dbcp_adapter_postgresql',
        \ 'dbcp_adapter_mysql',
        \ 'dbcp_adapter_mariadb',
        \ 'dbcp_adapter_sqlite',
        \ 'dbcp_adapter_sqlserver',
        \ 'dbcp_adapter_oracle',
        \ 'dbcp_adapter_mongodb',
        \ 'dbcp_adapter_redis',
        \ 'dbcp_test_framework',
        \]
endfunction

function! s:setup_test_buffer(test) abort
  enew!

  if a:test.db_type =~# '\v^(' . join(s:DB_TYPES_SQL, '|') . ')$'
    setlocal filetype=sql
  elseif a:test.db_type ==# 'mongodb'
    setlocal filetype=javascript
  elseif a:test.db_type ==# 'redis'
    setlocal filetype=redis
  endif

  let b:db = a:test.db_type . '://test'

  if type(a:test.context) == v:t_list
    call setline(1, a:test.context)
  else
    call setline(1, split(a:test.context, "\n"))
  endif

  call cursor(a:test.cursor_pos[0], a:test.cursor_pos[1])

  call s:register_cleanup_hook({-> execute('bwipe!', '')})

  return bufnr('%')
endfunction

function! s:get_completion_function(db_type) abort
  let l:AdapterFunc = 'dbcp#adapter#' . a:db_type . '#complete'

  if exists('*' . l:AdapterFunc)
    return function(l:AdapterFunc)
  endif

  " Force load the autoload function by calling it with dummy arguments
  try
    call call(l:AdapterFunc, [1, '', ''])
  catch
  endtry

  if exists('*' . l:AdapterFunc)
    return function(l:AdapterFunc)
  endif

  return v:null
endfunction

function! s:extract_base(test) abort
  if !empty(a:test.base)
    return a:test.base
  endif

  let l:line = getline(a:test.cursor_pos[0])
  let l:start_col = a:test.expected_start
  if l:start_col >= 0 && l:start_col < len(l:line)
    return l:line[l:start_col : a:test.cursor_pos[1] - 1]
  endif
  return ''
endfunction

function! s:run_test(test) abort
  let l:result = {
        \ 'test': a:test,
        \ 'passed': 0,
        \ 'failed': 0,
        \ 'errors': [],
        \ 'warnings': [],
        \ 'duration': 0,
        \ }

  let l:start_time = reltime()

  try
    let l:bufnr = s:setup_test_buffer(a:test)

    let l:CompleteFunc = s:get_completion_function(a:test.db_type)
    if l:CompleteFunc is v:null
      call add(l:result.errors, 'No completion function found for db_type: ' . a:test.db_type)
      let l:result.failed = 1
      return l:result
    endif

     let l:db_url = get(b:, 'db', '')

     call dbcp#sql#clear_cache(l:db_url)

     " Clear MongoDB context cache
     if exists('*dbcp#adapter#mongodb#clear_cache')
       call dbcp#adapter#mongodb#clear_cache()
     endif

     let l:actual_start = l:CompleteFunc(1, '', l:db_url)

     if a:test.expected_start >= 0 && l:actual_start != a:test.expected_start
       call add(l:result.warnings, printf('findstart: expected %d, got %d', a:test.expected_start, l:actual_start))
     endif

     let l:line = getline(a:test.cursor_pos[0])
     if l:actual_start >= 0 && l:actual_start < len(l:line)
       let l:extracted_base = l:line[l:actual_start : a:test.cursor_pos[1] - 1]
       let l:extracted_base = substitute(l:extracted_base, '\s\+$', '', '')
     else
       let l:extracted_base = ''
     endif

     let l:test_base = get(a:test, 'base', '')
     let l:base = !empty(l:test_base) ? l:test_base : l:extracted_base

     if l:actual_start >= 0 && !l:result.failed
       let l:items = l:CompleteFunc(0, l:base, l:db_url)
       let l:item_words = map(copy(l:items), {_, v -> get(v, 'word', get(v, 'abbr', ''))})

       if has_key(a:test, 'expected_items') && !empty(a:test.expected_items)
        let l:missing = []
        for l:expected in a:test.expected_items
          if index(l:item_words, l:expected) < 0
            call add(l:missing, l:expected)
          endif
        endfor
        if !empty(l:missing)
          call add(l:result.errors, 'Missing expected items: ' . string(l:missing))
          let l:result.failed = 1
        endif
      endif

      if has_key(a:test, 'expected_contains') && !empty(a:test.expected_contains)
        let l:missing = []
        for l:expected in a:test.expected_contains
          let l:found = 0
          for l:word in l:item_words
            if l:word =~# l:expected || l:word ==# l:expected
              let l:found = 1
              break
            endif
          endfor
          if !l:found
            call add(l:missing, l:expected)
          endif
        endfor
        if !empty(l:missing)
          call add(l:result.errors, 'Missing contains items: ' . string(l:missing))
          let l:result.failed = 1
        endif
      endif

      if has_key(a:test, 'expected_not_contains') && !empty(a:test.expected_not_contains)
        let l:found = []
        for l:not_expected in a:test.expected_not_contains
          for l:word in l:item_words
            if l:word =~# l:not_expected || l:word ==# l:not_expected
              call add(l:found, l:not_expected)
              break
            endif
          endfor
        endfor
        if !empty(l:found)
          call add(l:result.errors, 'Found unexpected items: ' . string(l:found))
          let l:result.failed = 1
        endif
      endif

      if has_key(a:test, 'expected_count')
        if len(l:items) != a:test.expected_count
          call add(l:result.errors, printf('Item count: expected %d, got %d', a:test.expected_count, len(l:items)))
          let l:result.failed = 1
        endif
      endif

      if has_key(a:test, 'min_count')
        if len(l:items) < a:test.min_count
          call add(l:result.errors, printf('Item count: expected at least %d, got %d', a:test.min_count, len(l:items)))
          let l:result.failed = 1
        endif
      endif
    endif

    if empty(l:result.errors)
      let l:result.passed = 1
    endif

  catch
    call add(l:result.errors, 'Exception: ' . v:exception)
    let l:result.failed = 1
  endtry

  let l:result.duration = str2float(substitute(reltimestr(reltime(l:start_time)), '\..*', '', ''))
  return l:result
endfunction

function! RunTests(...) abort
  let l:cases = a:0 > 0 ? GetTestCases(a:1) : GetTestCases()

  if empty(l:cases)
    echo 'No test cases to run'
    return {'passed': 0, 'failed': 0, 'total': 0}
  endif

  let s:test_results = []
  let l:total = len(l:cases)
  let l:passed = 0
  let l:failed = 0

  echo printf('Running %d test case(s)...', l:total)
  echo ''

  for l:test in l:cases
    let l:result = s:run_test(l:test)
    call add(s:test_results, l:result)

    if l:result.passed
      let l:passed += 1
      echo printf('  [PASS] %s', l:test.name)
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
  echo printf('Results: %d passed, %d failed, %d total', l:passed, l:failed, l:total)
  echo '========================================'

  return {'passed': l:passed, 'failed': l:failed, 'total': l:total}
endfunction

function! GetTestResults() abort
  return copy(s:test_results)
endfunction

function! GetTestSummary() abort
  let l:passed = 0
  let l:failed = 0
  let l:duration = 0
  for l:result in s:test_results
    if l:result.passed
      let l:passed += 1
    else
      let l:failed += 1
    endif
    let l:duration += get(l:result, 'duration', 0)
  endfor
  return {
        \ 'passed': l:passed,
        \ 'failed': l:failed,
        \ 'total': len(s:test_results),
        \ 'duration': l:duration
        \ }
endfunction

function! ShowTestStatistics() abort
  let l:summary = GetTestSummary()
  let l:results = GetTestResults()

  let l:by_group = {}
  for l:r in l:results
    let l:group = get(l:r.test, 'group', 'Unknown')
    if !has_key(l:by_group, l:group)
      let l:by_group[l:group] = {'passed': 0, 'failed': 0, 'total': 0, 'duration': 0}
    endif
    if l:r.passed
      let l:by_group[l:group].passed += 1
    else
      let l:by_group[l:group].failed += 1
    endif
    let l:by_group[l:group].total += 1
    let l:by_group[l:group].duration += get(l:r, 'duration', 0)
  endfor

  echo ''
  echo '========================================'
  echo 'Test Statistics'
  echo '========================================'
  echo printf('Total: %d | Passed: %d | Failed: %d', l:summary.total, l:summary.passed, l:summary.failed)
  echo printf('Duration: %.3fs', l:summary.duration)
  echo ''
  echo 'By Group:'
  for l:group in sort(keys(l:by_group))
    let l:stats = l:by_group[l:group]
    echo printf('  %s: %d/%d (%.3fs)', l:group, l:stats.passed, l:stats.total, l:stats.duration)
  endfor
  echo '========================================'
endfunction

function! s:xml_escape(str) abort
  return substitute(a:str, '&', '\&amp;', 'g')
  \->substitute('<', '\&lt;', 'g')
  \->substitute('>', '\&gt;', 'g')
  \->substitute('"', '\&quot;', 'g')
endfunction

function! ExportJUnitXML(...) abort
  let l:results = GetTestResults()
  let l:summary = GetTestSummary()
  let l:timestamp = strftime('%Y-%m-%dT%H:%M:%S', localtime())
  let l:hostname = 'localhost'

  let l:by_group = {}
  for l:r in l:results
    let l:group = get(l:r.test, 'group', 'Unknown')
    if !has_key(l:by_group, l:group)
      let l:by_group[l:group] = []
    endif
    call add(l:by_group[l:group], l:r)
  endfor

  let l:xml = '<?xml version="1.0" encoding="UTF-8"?>' . "\n"
  let l:xml .= '<testsuites name="vim-dbcp" tests="' . l:summary.total . '" failures="' . l:summary.failed . '" time="' . l:summary.duration . '">' . "\n"

  for l:group in sort(keys(l:by_group))
    let l:group_results = l:by_group[l:group]
    let l:group_passed = count(l:group_results, {r -> r.passed})
    let l:group_failed = count(l:group_results, {r -> !r.passed})
    let l:group_duration = 0.0
    for l:r in l:group_results
      let l:group_duration += get(l:r, 'duration', 0)
    endfor

    let l:xml .= '  <testsuite name="' . s:xml_escape(l:group) . '" tests="' . len(l:group_results) . '" failures="' . l:group_failed . '" time="' . l:group_duration . '">' . "\n"

    for l:r in l:group_results
      let l:name = s:xml_escape(get(l:r.test, 'name', 'Unknown'))
      let l:classname = s:xml_escape(get(l:r.test, 'group', 'Unknown'))
      let l:time = get(l:r, 'duration', 0)

      if l:r.passed
        let l:xml .= '    <testcase name="' . l:name . '" classname="' . l:classname . '" time="' . l:time . '"/>' . "\n"
      else
        let l:xml .= '    <testcase name="' . l:name . '" classname="' . l:classname . '" time="' . l:time . '">' . "\n"
        for l:error in l:r.errors
          let l:msg = substitute(s:xml_escape(l:error), '\v^\[FAIL\]?\s*', '', '')
          let l:xml .= '      <failure message="' . l:msg . '" type="error"/>' . "\n"
        endfor
        let l:xml .= '    </testcase>' . "\n"
      endif
    endfor

    let l:xml .= '  </testsuite>' . "\n"
  endfor

  let l:xml .= '</testsuites>' . "\n"

  if a:0 > 0 && !empty(a:1)
    call writefile(split(l:xml, '\n'), a:1)
    return 0
  endif
  return l:xml
endfunction

function! ExportJSON(...) abort
  let l:results = GetTestResults()
  let l:summary = GetTestSummary()

  let l:by_group = {}
  for l:r in l:results
    let l:group = get(l:r.test, 'group', 'Unknown')
    if !has_key(l:by_group, l:group)
      let l:by_group[l:group] = []
    endif
    call add(l:by_group[l:group], {
          \ 'name': get(l:r.test, 'name', 'Unknown'),
          \ 'passed': l:r.passed,
          \ 'errors': l:r.errors,
          \ 'duration': get(l:r, 'duration', 0),
          \ })
  endfor

  let l:output = {
        \ 'suites': [],
        \ 'statistics': {
        \   'total': l:summary.total,
        \   'passed': l:summary.passed,
        \   'failed': l:summary.failed,
        \   'duration': l:summary.duration,
        \   'timestamp': strftime('%Y-%m-%dT%H:%M:%SZ', localtime()),
        \ }
        \}

  for l:group in sort(keys(l:by_group))
    let l:group_results = l:by_group[l:group]
    let l:group_passed = count(l:group_results, {r -> r.passed})
    call add(l:output.suites, {
          \ 'name': l:group,
          \ 'tests': len(l:group_results),
          \ 'passed': l:group_passed,
          \ 'failed': len(l:group_results) - l:group_passed,
          \ 'testcases': l:group_results,
          \ })
  endfor

  let l:json = string(l:output)

  if a:0 > 0 && !empty(a:1)
    call writefile([l:json], a:1)
    return 0
  endif
  return l:json
endfunction

function! ExportTAP(...) abort
  let l:results = GetTestResults()
  let l:summary = GetTestSummary()

  let l:lines = []
  call add(l:lines, 'TAP version 14')
  call add(l:lines, '1..' . l:summary.total)
  call add(l:lines, '# vim-dbcp test results')

  let l:i = 1
  for l:r in l:results
    let l:name = substitute(get(l:r.test, 'name', 'Test'), '\'', "''", 'g')

    if l:r.passed
      call add(l:lines, 'ok ' . l:i . ' - ' . l:name)
    else
      call add(l:lines, 'not ok ' . l:i . ' - ' . l:name)
      for l:error in l:r.errors
        let l:msg = substitute(l:error, '\n', '\n# ', 'g')
        call add(l:lines, '#   ' . l:msg)
      endfor
    endif
    let l:i += 1
  endfor

  call add(l:lines, '# End of tests')

  let l:output = join(l:lines, "\n")

  if a:0 > 0 && !empty(a:1)
    call writefile(l:lines, a:1)
    return 0
  endif
  return l:output
endfunction
