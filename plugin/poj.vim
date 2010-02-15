let s:curl = 'curl'
let s:path_separator = has('win32') ? '\\' : '/'
let s:cookie_file = substitute(expand('<sfile>:p:h'), 'plugin$', 'cookie', '') . s:path_separator . 'poj.cookie'

function! s:login()
  if !exists('g:poj_user')
    let g:poj_user = input('User ID: ')
  endif
  if !exists('g:poj_password')
    let g:poj_password = inputsecret('Password: ')
  endif
  call system(printf('%s -c %s -d user_id1=%s -d password1=%s -d url=/JudgeOnline/ http://acm.pku.edu.cn/JudgeOnline/login',
        \ s:curl, s:cookie_file, g:poj_user, g:poj_password))
endfunction

function! s:get_user_status(user)
  let conn = system(printf('%s -s -G -d user_id=%s http://acm.pku.edu.cn/JudgeOnline/status', s:curl, a:user))

  let lines = []
  for l in split(conn, '\n')
    let l = s:remove_tags(s:remove_tags(s:remove_tags(l, 'tr'), 'a'), 'font')
    let l = substitute(l, '</td>', '', 'g')
    if l[0:3] == '<td>'
      call add(lines, substitute(l[4:], '<td>', '\t', 'g'))
    endif
  endfor

  if !exists('s:bufnr_' . a:user)
    let s:bufnr_{a:user} = -1
  endif
  if !bufexists(s:bufnr_{a:user})
    execute 'new poj-' . a:user . '-status'
    let s:bufnr_{a:user} = bufnr('%')
    setlocal buftype=nofile filetype=pojstatus
    execute 'nnoremap <buffer> <silent> <Leader><Leader> :call <SID>get_user_status("' . a:user . '")<CR>'
  elseif bufwinnr(s:bufnr_{a:user}) != -1
    execute bufwinnr(s:bufnr_{a:user}) 'wincmd w'
  else
    execute 'sbuffer' s:bufnr_{a:user}
  endif

  call s:setup_syntax()
  call setline(1, lines)
endfunction

function! s:submit(problem_id)
  call s:login()

  let src = s:urlencode(join(getline(1, '$'), "\n"))

  let lang2nr = {
        \ 'G++': 0,
        \ 'GCC': 1,
        \ 'Java': 2,
        \ 'Pascal': 3,
        \ 'C++': 4,
        \ 'C': 5,
        \ 'Fortran': 6 }

  let lang = ''
  if &filetype == 'cpp'
    if exists('g:poj_prefer_cpp') && g:poj_prefer_cpp
      let lang = 'C++'
    else
      let lang = 'G++'
    endif
  elseif &filetype == 'java'
    let lang = 'Java'
  elseif &filetype == 'c'
    if exists('g:poj_prefer_c') && g:poj_prefer_c
      let lang = 'C'
    else
      let lang = 'GCC'
    endif
  elseif &filetype == 'fortran'
    let lang = 'Fortran'
  elseif &filetype == 'pascal'
    let lang = 'Pascal'
  else
    let lang = input('Language: ')
    if !has_key(lang2nr, lang)
      echoerr 'No such language: ' . lang
      return
    endif
  endif

  call system(printf('%s -b %s -d problem_id=%s -d language=%d -d source=%s http://acm.pku.edu.cn/JudgeOnline/submit',
        \ s:curl, s:cookie_file, a:problem_id, lang2nr[lang], src))

  call s:get_user_status(g:poj_user)
endfunction

function! s:setup_syntax()
  syntax clear
  syntax match pojstatusAC /Accepted/
  syntax match pojstatusPE /Presentation Error/
  syntax match pojstatusTLE /Time Limit Exceeded/
  syntax match pojstatusMLE /Memory Limit Exceeded/
  syntax match pojstatusWA /Wrong Answer/
  syntax match pojstatusRE /Runtime Error/
  syntax match pojstatusOLE /Output Limit Exceeded/
  syntax match pojstatusCE /Compile Error/
  syntax match pojstatusSE /System Error/
  syntax match pojstatusVE /Validation Error/
  highlight pojstatusAC ctermfg=Blue guifg=Blue
  highlight pojstatusPE ctermfg=Red guifg=Red
  highlight default link pojstatusTLE pojstatusPE
  highlight default link pojstatusMLE pojstatusPE
  highlight default link pojstatusWA pojstatusPE
  highlight default link pojstatusRE pojstatusPE
  highlight default link pojstatusOLE pojstatusPE
  highlight pojstatusCE ctermfg=Green guifg=Green
  highlight default link pojstatusSE pojstatusCE
  highlight default link pojstatusVE pojstatusVE
endfunction

function! s:urlencode(s)
  return substitute(a:s, '[^a-zA-Z0-9_-]', '\=printf("%%%02X", char2nr(submatch(0)))', 'g')
endfunction

function! s:remove_tags(s, name)
  return substitute(substitute(a:s, '<' . a:name . ' [^>]\+>', '', 'g'), '</' . a:name . '>', '', 'g')
endfunction

command! -nargs=1 POJUserStatus call <SID>get_user_status(<q-args>)
command! -nargs=1 POJSubmit call <SID>submit(<q-args>)

