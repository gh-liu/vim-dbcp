" vim-dbcp: CSV Loading Utilities
" Shared CSV loading functions for adapters

if exists('g:autoloaded_dbcp_csv')
  finish
endif
let g:autoloaded_dbcp_csv = 1

" =============================================================================
" CSV Loading Functions
" =============================================================================

" Load CSV file and return list of rows (each row is a list of fields)
" CSV format: content,description,type[,parent_command] (with header row)
" Returns: list of [content, description, type, ...] or v:null if file not found
function! dbcp#csv#load(filename, script_path) abort
  " Get directory from script path
  let l:script_dir = fnamemodify(a:script_path, ':h')
  let l:csv_path = l:script_dir . '/' . a:filename
  
  if !filereadable(l:csv_path)
    return v:null
  endif
  
  let l:lines = readfile(l:csv_path)
  if empty(l:lines)
    return []
  endif
  
  " Skip header row
  let l:data = []
  for l:line in l:lines[1:]
    " Skip empty lines
    if l:line =~# '^\s*$'
      continue
    endif
    
    " Parse CSV line (handle quoted fields)
    let l:fields = dbcp#csv#parse_line(l:line)
    if len(l:fields) >= 2
      call add(l:data, l:fields)
    endif
  endfor
  
  return l:data
endfunction

" Simple CSV line parser (handles quoted fields)
function! dbcp#csv#parse_line(line) abort
  let l:fields = []
  let l:current = ''
  let l:in_quotes = 0
  let l:i = 0
  
  while l:i < len(a:line)
    let l:char = a:line[l:i]
    
    if l:char == '"'
      if l:in_quotes && l:i + 1 < len(a:line) && a:line[l:i + 1] == '"'
        " Escaped quote
        let l:current .= '"'
        let l:i += 2
        continue
      else
        " Toggle quote state
        let l:in_quotes = !l:in_quotes
      endif
    elseif l:char == ',' && !l:in_quotes
      " Field separator
      call add(l:fields, l:current)
      let l:current = ''
    else
      let l:current .= l:char
    endif
    
    let l:i += 1
  endwhile
  
  " Add last field
  call add(l:fields, l:current)
  
  " Trim whitespace
  return map(l:fields, {_, v -> substitute(v, '^\s\+\|\s\+$', '', 'g')})
endfunction
