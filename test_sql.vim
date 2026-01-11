" Simple test for vim-dbcp functions

function! TestFunctions()
  echo 'Testing dbcp functions...'
  
  let l:tests = [['dbcp#sql#complete', 'SQL completion'], ['dbcp#sql#clear_cache', 'SQL clear_cache'], ['dbcp#adapter#postgres#complete', 'PostgreSQL complete'], ['dbcp#adapter#postgres#clear_cache', 'PostgreSQL clear_cache'], ['dbcp#adapter#mysql#complete', 'MySQL complete'], ['dbcp#adapter#mysql#clear_cache', 'MySQL clear_cache'], ['dbcp#adapter#sqlite#complete', 'SQLite complete'], ['dbcp#adapter#sqlite#clear_cache', 'SQLite clear_cache'], ['dbcp#adapter#redis#complete', 'Redis complete'], ['dbcp#adapter#redis#clear_cache', 'Redis clear_cache'], ['dbcp#complete', 'Main complete'], ['dbcp#omnifunc', 'Omni func']]
  
  let l:passed = 0
  for l:t in l:tests
    if exists('*' . l:t[0])
      echo 'PASS: ' . l:t[1]
      let l:passed += 1
    else
      echo 'FAIL: ' . l:t[1]
    endif
  endfor
  
  echo ''
  echo 'Result: ' . l:passed . '/' . len(l:tests) . ' passed'
endfunction

call TestFunctions()
