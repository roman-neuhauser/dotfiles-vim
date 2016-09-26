function! PDFoldText()
  if -1 == match(getline(v:foldstart), '/\*\*')
    return foldtext()
    return getline(v:foldstart)
  endif

  let ln     = v:foldstart
  let params = ''
  let access = 'public '
  let type   = ''
  let static = ''
  let var    = ''
  let name   = ''
  while ln <= v:foldend
    let line = getline(ln)
    let ln = 1 + ln
    let pos = stridx(line, '*/')
    if -1 == pos
      let text = line
    else
      let text = strpart(line, 0, pos - 1)
    endif
    let m = matchstr(text, '\(@access\s\+\)\@<=\(\w\+\)')
    if '' != m
      let access = m . ' '
    endif
    let m = matchstr(text, '\(@\)\@<=\(static\)\>')
    if '' != m
      let static = m . ' '
    endif
    let m = matchstr(text, '\(@return\s\+\)\@<=\(\w\+\)')
    if '' != m
      let type = m . ' '
    endif
    let m = matchstr(text, '\(@param\s\+\)\@<=\(\w\+\(\s\+\$\w\+\)\?\)')
    if '' != m
      let params = params . ', ' . m
    endif
    let m = matchstr(text, '\(@var\s\+\)\@<=\(\w\+\)')
    if '' != m
      let var = m . ' '
    endif
    if -1 != pos
      break
    endif
  endwhile
  if '' == var
    let params = '(' . strpart(params, 2) . ')'
  endif
  " sooo, we have the pd comment string.
  " lets see if it documents a method
  if '' != var
    let type = var
    let expr = '\(var\s\+\)\@<=\(\$\w\+\)'
  else
    let expr = '\(function\s\+\)\@<=\(\(&\s\+\)\?\w\+\)'
  endif
  while ln <= v:foldend
    let line = getline(ln)
    let ln = 1 + ln
    let name = matchstr(line, expr)
    if '' != name
      break
    endif
  endwhile
  return '    ' . access . static . type . name . params
endfunction

set foldtext=PDFoldText()
