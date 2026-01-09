" vim-dbcp: Test Framework
" Unified testing framework for database completion scenarios

if exists('g:autoloaded_dbcp_test_framework')
  finish
endif
let g:autoloaded_dbcp_test_framework = 1

" =============================================================================
" Test Framework State
" =============================================================================

let s:test_cases = []
let s:test_results = []
let s:current_group = ''

" =============================================================================
" Test Case Structure
" =============================================================================
" Each test case is a dictionary with:
"   - name: string - Test name
"   - db_type: string - Database type (postgresql, mysql, mongodb, redis, etc.)
"   - context: list<string> - Lines of code for test context
"   - cursor_pos: [line, col] - Cursor position (1-based)
"   - base: string - Base text for completion (optional, auto-detected if empty)
"   - expected_start: number - Expected findstart return value (-1 for no completion)
"   - expected_items: list<string> - Expected completion items (optional)
"   - expected_contains: list<string> - Items that must be present (optional)
"   - expected_not_contains: list<string> - Items that must NOT be present (optional)
"   - expected_count: number - Expected number of items (optional)
"   - min_count: number - Minimum number of items (optional)

" =============================================================================
" Test Registration
" =============================================================================

function! dbcp#test#group(name) abort
  let s:current_group = a:name
endfunction

function! dbcp#test#register(test_case) abort
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
  
  " Set defaults
  if !has_key(l:test, 'base')
    let l:test.base = ''
  endif
  
  call add(s:test_cases, l:test)
endfunction

function! dbcp#test#get_cases(...) abort
  if a:0 > 0
    " Filter by db_type
    let l:db_type = a:1
    return filter(copy(s:test_cases), {_, v -> v.db_type ==# l:db_type})
  endif
  return copy(s:test_cases)
endfunction

function! dbcp#test#clear() abort
  let s:test_cases = []
  let s:test_results = []
  let s:current_group = ''
endfunction

" =============================================================================
" Test Execution
" =============================================================================

function! s:setup_test_buffer(test) abort
  " Create new buffer
  enew!
  
  " Set filetype based on db_type
  if a:test.db_type =~# '^\(postgresql\|mysql\|mariadb\|sqlite\|sqlserver\|oracle\)$'
    setlocal filetype=sql
  elseif a:test.db_type ==# 'mongodb'
    setlocal filetype=javascript
  elseif a:test.db_type ==# 'redis'
    setlocal filetype=redis
  endif
  
  " Set database URL
  let b:db = a:test.db_type . '://test'
  
  " Insert context lines
  if type(a:test.context) == v:t_list
    call setline(1, a:test.context)
  else
    call setline(1, split(a:test.context, "\n"))
  endif
  
  " Move cursor to position
  call cursor(a:test.cursor_pos[0], a:test.cursor_pos[1])
  
  return bufnr('%')
endfunction

function! s:get_completion_function(db_type) abort
  if a:db_type =~# '^\(postgresql\|mysql\|mariadb\|sqlite\|sqlserver\|oracle\)$'
    " SQL databases use adapter-specific complete function
    let l:adapter_func = 'dbcp#adapter#' . a:db_type . '#complete'
    if exists('*' . l:adapter_func)
      return function(l:adapter_func)
    endif
    " Fallback: adapter not loaded, return null to trigger error
    return v:null
  elseif a:db_type ==# 'mongodb'
    return function('dbcp#adapter#mongodb#complete')
  elseif a:db_type ==# 'redis'
    return function('dbcp#adapter#redis#complete')
  else
    return v:null
  endif
endfunction

function! s:extract_base(test) abort
  if !empty(a:test.base)
    return a:test.base
  endif
  
  " Auto-detect base from cursor position and expected_start
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
        \ 'warnings': []
        \ }
  
  try
    " Setup test buffer
    let l:bufnr = s:setup_test_buffer(a:test)
    
    " Get completion function
    let l:complete_func = s:get_completion_function(a:test.db_type)
    if l:complete_func is v:null
      call add(l:result.errors, 'No completion function found for db_type: ' . a:test.db_type)
      let l:result.failed = 1
      return l:result
    endif
    
    " Get database URL
    let l:db_url = get(b:, 'db', '')
    
    " Test findstart
    let l:base = s:extract_base(a:test)
    let l:actual_start = call(l:complete_func, [1, l:base, l:db_url])
    
    " Verify findstart
    if l:actual_start != a:test.expected_start
      call add(l:result.errors, printf('findstart: expected %d, got %d', a:test.expected_start, l:actual_start))
      let l:result.failed = 1
    endif
    
    " If findstart succeeded, test completion items
    if l:actual_start >= 0 && !l:result.failed
      let l:items = call(l:complete_func, [0, l:base, l:db_url])
      let l:item_words = map(copy(l:items), {_, v -> get(v, 'word', get(v, 'abbr', ''))})
      
      " Check expected_items (exact match)
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
      
      " Check expected_contains
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
      
      " Check expected_not_contains
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
      
      " Check expected_count
      if has_key(a:test, 'expected_count')
        if len(l:items) != a:test.expected_count
          call add(l:result.errors, printf('Item count: expected %d, got %d', a:test.expected_count, len(l:items)))
          let l:result.failed = 1
        endif
      endif
      
      " Check min_count
      if has_key(a:test, 'min_count')
        if len(l:items) < a:test.min_count
          call add(l:result.errors, printf('Item count: expected at least %d, got %d', a:test.min_count, len(l:items)))
          let l:result.failed = 1
        endif
      endif
    endif
    
    " Test passed if no errors
    if empty(l:result.errors)
      let l:result.passed = 1
    endif
    
  catch
    call add(l:result.errors, 'Exception: ' . v:exception)
    let l:result.failed = 1
  endtry
  
  return l:result
endfunction

function! dbcp#test#run(...) abort
  " Get test cases to run
  let l:cases = a:0 > 0 ? dbcp#test#get_cases(a:1) : dbcp#test#get_cases()
  
  if empty(l:cases)
    echo 'No test cases to run'
    return
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
      echo printf('  ✓ %s', l:test.name)
    else
      let l:failed += 1
      echo printf('  ✗ %s', l:test.name)
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

" =============================================================================
" Test Results Access
" =============================================================================

function! dbcp#test#get_results() abort
  return copy(s:test_results)
endfunction

function! dbcp#test#get_summary() abort
  let l:passed = 0
  let l:failed = 0
  for l:result in s:test_results
    if l:result.passed
      let l:passed += 1
    else
      let l:failed += 1
    endif
  endfor
  return {
        \ 'passed': l:passed,
        \ 'failed': l:failed,
        \ 'total': len(s:test_results)
        \ }
endfunction
