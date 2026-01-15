<H1>VIM GUIDE</H1>

- [config](#config)
  - [사용자 계정별 vim 커스텀 설정](#사용자-계정별-vim-커스텀-설정)
    - [설정 설명](#설정-설명)
  - [사용자 계정별 golang 개발을 위한 vim 설정](#사용자-계정별-golang-개발을-위한-vim-설정)
    - [go-usr-install.sh 스크립트 요약](#go-usr-installsh-스크립트-요약)


# config

## 사용자 계정별 vim 커스텀 설정
.vimrc
```
" An example for a vimrc file.
"
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last change:	2001 Jul 18
"
" To use it, copy it to
"     for Unix and OS/2:  ~/.vimrc
"	      for Amiga:  s:.vimrc
"  for MS-DOS and Win32:  $VIM\_vimrc
"	    for OpenVMS:  sys$login:.vimrc

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

set mouse-=a

" disable the ??Press ENTER or type command to continue?? prompt 
":set shortmess=a
":set cmdheight=2
"let g:bufferline_echo=0

" allow backspacing over everything in insert mode
set backspace=indent,eol,start
set autoindent		" always set autoindenting on
set cindent         " always set cindenting on
set nobackup		" do not keep a backup file, use versions instead
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching
set background=dark
set fileencodings=euc-kr
set encoding=euc-kr
" 2004.11.11, hphong
set pastetoggle=<ins>
"set paste		" Very useful, when pasting source file

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq


" set number toggle
noremap	<silent> <F5>	:set number<CR>
noremap	<silent> <F6>	:set nonumber<CR>
" set bufexplorer
nnoremap <silent> <F7>	:BufExplorer<CR>
" set map #############################################################
" set taglist : use <F9> and Tab key
noremap	<silent> <F9>	:Tlist<CR>
" grep key word from current directory
map	[g	:!/bin/grep =expand("<cword>")
 *
map	[G	g*''n"ayeo^["aPI:!grep -i -n "\<A\>" *.[ch] */*.[ch]"add5u@a
map		gz.
map		gz.:map <buffer>     :q

noremap   	z.
map		:cs find c =expand("<cword>")

map	g	:cs find c =expand("<cword>")
<Right><Right><Right><Right><Right><Right><Right><Right>
" Make p in Visual mode replace the selected text with the "" register.
vnoremap p <Esc>:let current_reg = @"<CR>gvs<C-R>=current_reg<CR><Esc>

" make .defines file for ZebOS 5.4
noremap	,sd :let do_def=substitute( system('make -C=expand("%:p:h")
 -W =expand("%:t")
 -n dep-=expand("%:t:r")
.o | mkvimdef =expand("%:p:h")
 "=expand("%:p:h")
/*.[ch]" '), "\n", "", "" )|let done_def=system('cd =expand("%:p:h")
;' . do_def)|source ~/.ifdef.vim|let g:ifdef_start=1|call Define('1')| call IfdefLoad()| set foldcolumn=4
" make .defines file for Common
noremap	,md :let do_def=substitute( system('make -C=expand("%:p:h")
 -W =expand("%:t")
 -n =expand("%:t:r")
.o | mkvimdef =expand("%:p:h")
 "=expand("%:p:h")
/*.[ch]" '), "\n", "", "" )|let done_def=system('cd =expand("%:p:h")
;' . do_def)|source ~/.ifdef.vim|let g:ifdef_start=1| call Define('1')| call IfdefLoad()| set foldcolumn=4


" This is an alternative that also works in block mode, but the deleted
" text is lost and it only works for putting the current register.
"vnoremap p "_dp

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
"if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
"endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

endif " has("autocmd")

if has("ID")
	set wrap
endif

syntax on
" enable conf coloring on .txt
autocmd BufRead,BufNewFile *.txt set syntax=conf

if version >= 600
    set foldopen=mark,percent,quickfix,search,tag,undo,hor
    set foldclose=all
    "set foldcolumn=2
    set updatetime=1000
    noremap <silent> <f8>	za
    noremap <silent> <f10>	:source ~/.ifdef.vim<CR>:call Define('1')<CR>:call IfdefLoad()<CR>:let g:ifdef_start=1<CR>:set foldcolumn=4<CR>
    if !exists("b:my_bufread_start")
      let b:my_bufread_start=1
      autocmd BufRead *.c,*.h,*.def
	\ if exists("g:ifdef_start")|
	\   if g:ifdef_start == 1|
	\     call Babo()|
	\     call Undefine('\<\k\+\>')|
	\     call Define('1')|
	\     call IfdefLoad()|
	\     set foldcolumn=4|
	\   endif |
	\ endif
    endif
endif

" cscope begin
set csprg=/usr/bin/cscope
set csto=0
set cst
set nocsverb
set csverb
" find callers who call <cword>
" map ^\ :cs find c <C-R>=expand("<cword>")<CR><CR>
" find <cword> in cscope files
" map ^\t :cs find t <C-R>=expand("<cword>")<CR><CR>

if exists("$MYCSCOPE")
    set tags=${MYCSCOPE}/tags,~/ctags/usr/include/tags,tags
    :silent cs add ~/ctags/usr/include
    :silent cs add ${MYCSCOPE}/cscope.out
endif
" cscope end

if exists("$CODING_ENVIRONMENT")
    let coding_env=system("/bin/echo $CODING_ENVIRONMENT")
endif
if exists("coding_env") && (coding_env=~"zebos")
    set st=4 sw=4 ts=8 expandtab
    set cinoptions=>s,e0,n-2,f0,{0.5s,}0,^-2,:0.5s,=0.5s,l0,gs,hs,ps,ts,+s,c3,C0,(0,us,\U0,w0,m0,j0,)20,*30
elseif exists("coding_env") && (coding_env=~"6wind")
    set st=4 sw=4 ts=4
    set cinoptions=>1s,p0,t0,(0,g2
elseif exists("coding_env") && (coding_env=~"vpp")
    set st=4 sw=4 ts=8
    set cinoptions=>s,e0,n-2,f0,{0.5s,}0,^-2,:0.5s,=0.5s,l0,gs,hs,ps,ts,+s,c3,C0,(0,us,\U0,w0,m0,j0,)20,*30
else
    set st=4 sw=4 ts=4 expandtab
    set cinoptions=>1s,p0,t0,(0,g2
endif
" cp949 for windows korean encoding
set encoding=utf-8
set fileencodings=utf-8
if &diff
  set noreadonly
endif

" https://stackoverflow.com/questions/526858/how-do-i-make-vim-do-normal-bash-like-tab-completion-for-file-names
set wildmode=longest,list,full
set wildmenu

" vimgo auto completion
" https://jogendra.dev/using-vim-for-go-development
" DO NOT USE BELOW, JUST FYI
":verbose setlocal omnifunc?
" USE BELOW !
" https://vim.fandom.com/wiki/Avoiding_the_%22Hit_ENTER_to_continue%22_prompts
" CTRL+p to see the auto completion
:silent setlocal omnifunc?

"au filetype go inoremap <buffer> . .<C-x><C-o>
color mycolor
```

### 설정 설명
<!-- 아래는 .vimrc 샘플의 주요 설정들에 대한 상세 설명입니다. 총 217줄 분량을 맞추어 각 설정의 목적, 동작 방식, 실무에서의 의미와 권장 사용법을 한국어로 설명합니다. -->

1. set nocompatible
   - 목적: 오래된 Vi 호환 모드를 끄고 Vim의 개선된 동작을 사용합니다.
   - 동작: 여러 현대적 기능(예: 확장된 옵션, 플러그인 호환 등)을 활성화합니다.
   - 권장: 항상 사용. 스크립트의 첫 줄에 위치해야 다른 옵션의 기본 동작을 바꾸기 전에 적용됩니다.

2. set mouse-=a
   - 목적: 마우스 입력을 전역적으로 비활성화합니다.
   - 동작: 터미널 환경에서 마우스로 커서 이동이나 선택을 방지합니다.
   - 권장: 터미널에서 실수로 마우스 클릭으로 모드가 바뀌는 것을 막고 싶은 경우 사용.

3. set backspace=indent,eol,start
   - 목적: 삽입 모드에서 백스페이스 동작을 유연하게 합니다.
   - 동작: 들여쓰기, 줄 끝, 삽입 시작 지점까지 자유롭게 삭제할 수 있습니다.
   - 권장: 편집 경험을 Vi보다 친숙한 방식으로 만들려면 설정.

4. set autoindent / set cindent
   - 목적: 자동 들여쓰기와 C 언어식 들여쓰기를 켭니다.
   - 동작: 새 줄이 이전 줄의 들여쓰기 수준을 따르거나 C 규칙에 따라 정렬됩니다.
   - 권장: 코드 편집 시 일관된 들여쓰기를 위해 활성화.

5. set nobackup
   - 목적: 편집 중 임시 백업 파일 생성을 비활성화합니다.
   - 동작: '~' 형태의 백업 파일을 만들지 않습니다. (대신 버전관리 권장)
   - 권장: 프로젝트에 버전 관리(Git) 사용 시 불필요한 백업 파일을 막기 위해 사용.

6. set history=50
   - 목적: 명령행 히스토리의 저장 줄 수를 지정합니다.
   - 동작: 최근 50개의 명령을 기록하여 :<Up>으로 재사용 가능.
   - 권장: 기본값보다 늘려두면 유용하지만 너무 크게 하면 메모리 사용 증가.

7. set ruler / set showcmd
   - 목적: 상태 정보(커서 위치)와 미완성 명령을 표시합니다.
   - 동작: 화면 하단에 현재 라인/열을 표시하고, 입력 중인 명령을 보여줌.
   - 권장: 디버깅 및 키바인딩 확인 시 유용.

8. set incsearch
   - 목적: 검색 시 입력하는 동안 실시간으로 결과를 강조합니다.
   - 동작: 검색 패턴이 완성되기 전에도 일치하는 부분으로 커서가 이동합니다.
   - 권장: 빠른 탐색이 필요할 때 켜두면 매우 편리.

9. set background=dark
   - 목적: 컬러 스킴에게 어두운 배경임을 알려 적절한 색상을 선택하게 합니다.
   - 동작: 일부 색상 테마는 이 값에 따라 밝기/대비를 조정.
   - 권장: 터미널/GUI 배경에 맞게 설정.

10. set fileencodings, set encoding (euc-kr 등)
  - 목적: 파일 인코딩과 내부 인코딩을 설정합니다.
  - 동작: 열기 시 인코딩 자동 감지 순서(`fileencodings`)와 내부 문자표현(`encoding`)을 지정.
  - 권장: 한글 파일을 많이 다룬다면 환경에 맞는 인코딩(UTF-8 권장)을 사용하세요. euc-kr 사용은 레거시 환경에서만.

11. set pastetoggle=<ins>
  - 목적: 붙여넣기 모드 토글 키를 지정합니다.
  - 동작: paste 모드가 켜지면 자동 들여쓰기 및 텍스트 오토포맷을 일시적으로 끕니다.
  - 권장: 외부에서 소스 붙여넣을 때 토글하여 들여쓰기 깨짐을 방지.

12. map Q gq
  - 목적: Ex 모드인 Q를 일반적인 포맷 명령으로 재매핑.
  - 동작: Q 키를 누르면 현재 줄/비주얼 선택을 `gq`(텍스트 포맷)로 처리.
  - 권장: 실수로 Ex 모드로 들어가는 것을 방지.

13. number toggle 단축키 (F5, F6)
  - 목적: 라인 번호 표시를 빠르게 켜고 끄는 단축키 제공.
  - 동작: `<F5>`로 `:set number`, `<F6>`로 `:set nonumber` 실행.
  - 권장: 디버깅 시 라인 번호가 필요하면 켜두고 평상시 끌 수 있음.

14. Buffer/Tag/List 관련 단축키 (F7, F9 등)
  - 목적: 플러그인(예: BufExplorer, TagList)을 호출하는 키를 지정.
  - 동작: 키 한 번으로 버퍼 목록, 태그리스트 등 패널을 열 수 있음.
  - 권장: 자주 사용하는 플러그인에는 직관적 단축키를 할당.

15. Visual 모드의 p 동작 변경 (vnoremap p ...)
  - 목적: 비주얼 모드에서 붙여넣기 시 레지스터 내용이 덮어써지는 것을 방지.
  - 동작: 현재 레지스터를 임시로 저장했다가 복원하여 비주얼로 선택한 텍스트를 붙여넣음.
  - 권장: 여러 번 붙여넣을 때 레지스터 사라짐을 방지하려는 사용자에게 유용.

16. syntax on / set hlsearch
  - 목적: 문법 하이라이팅과 검색 결과 강조를 활성화합니다.
  - 동작: 문법 파일을 읽어 색상 규칙을 적용하고, 검색어 하이라이트를 유지.
  - 권장: 가독성과 코드 탐색 효율을 위해 항상 켜두는 것이 좋음.

17. filetype plugin indent on
  - 목적: 파일 형식 인식과 언어별 플러그인, 들여쓰기 규칙을 활성화.
  - 동작: 확장자에 따라 적절한 설정 파일(`ftplugin`, `indent`)을 로드.
  - 권장: 언어별 자동 설정을 활용하려면 필수로 켜기.

18. autocmd FileType text setlocal textwidth=78
  - 목적: 텍스트 파일에서 자동 줄바꿈 너비를 78로 설정.
  - 동작: `gq` 같은 포맷 명령 또는 자동 포맷에서 기준 너비로 사용.
  - 권장: 문서 작성 시 가독성 기준에 맞춰 설정.

19. autocmd BufReadPost * ... g`"`
  - 목적: 파일을 열 때 마지막 편집 위치로 자동 이동.
  - 동작: 이전 편집 위치가 유효하면 커서를 그 위치로 옮깁니다.
  - 권장: 긴 파일 편집 시 작업을 빠르게 재개할 수 있어 매우 편리.

20. if has("ID") set wrap
  - 목적: 특정 빌드 옵션(여기서는 ID)의 존재에 따라 줄바꿈을 활성화.
  - 동작: 조건이 참일 때 `wrap`을 설정해 긴 줄을 화면에 감싸 표시.
  - 권장: 환경에 따라 가독성이 필요하면 사용.

21. syntax on (중복 선언 허용)
  - 목적: 문법 강조를 다시 한 번 보장.
  - 동작: 이미 켜져 있더라도 영향 없음.
  - 권장: 중복 선언은 불필요하지만 안전장치로 남겨둘 수 있음.

22. autocmd BufRead,BufNewFile *.txt set syntax=conf
  - 목적: `.txt` 파일을 conf 스타일로 하이라이트.
  - 동작: 텍스트 파일 중 설정형 내용을 보기 좋게 컬러링.
  - 권장: 환경설정 파일이나 키-값 형식 문서에 유용.

23. fold 관련 설정 (foldopen, foldclose, foldcolumn, updatetime)
  - 목적: 코드 폴딩 동작과 표시 칼럼, 업데이트 주기를 조정.
  - 동작: 자동 접기/펼침 트리거, 폴드 표시 칼럼, CursorHold 시각화 응답 속도 등을 설정.
  - 권장: 대형 파일에서 네비게이션 편의성을 위해 적절히 조정.

24. cscope 설정 (set csprg, cs add 등)
  - 목적: cscope를 통한 코드베이스 탐색을 활성화.
  - 동작: `:cs find` 같은 명령으로 함수/호출자/정의 등을 빠르게 찾을 수 있음.
  - 권장: C/C++ 대형 프로젝트에서는 매우 쓸모 있음. 환경변수 `MYCSCOPE`를 설정해 사용.

25. CODING_ENVIRONMENT에 따른 들여쓰기/인덴트 옵션 분기
  - 목적: 작업 중인 프로젝트(예: zebos, 6wind, vpp)에 맞춘 탭/스페이스 정책을 자동으로 적용.
  - 동작: `st`(softtabstop), `sw`(shiftwidth), `ts`(tabstop), `expandtab` 등을 설정.
  - 권장: 팀 컨벤션에 맞춰 자동 설정하면 실수로 인한 스타일 혼합을 줄일 수 있음.

26. encoding 재설정 (utf-8)
  - 목적: 윈도우/유닉스 간 문자 인코딩 문제를 줄이기 위해 UTF-8을 사용.
  - 동작: 내부 인코딩과 파일 인코딩 순서를 UTF-8 계열로 맞춤.
  - 권장: 새로운 프로젝트는 UTF-8을 권장; 과거 euc-kr 사용 환경이면 점진적 전환 고려.

27. set noreadonly when &diff
  - 목적: diff 모드에서 읽기 전용 해제.
  - 동작: 비교 편집 중 파일을 수정할 수 있도록 허용.
  - 권장: `vim -d`로 파일 비교할 때 편집을 허용하려면 유용.

28. wildmode와 wildmenu 설정
  - 목적: 명령줄 탭 완성 동작을 개선하여 파일/명령 완성 경험을 향상.
  - 동작: 가장 긴 공통 접두사를 자동완성하고, 목록 및 전체 완성 옵션을 제공.
  - 권장: 빠른 파일 오픈과 명령 완성을 위해 활성화.

29. omnifunc, inoremap(Go 관련) 힌트
  - 목적: 언어별 자동완성(omni completion)을 사용하기 위한 안내.
  - 동작: 특정 파일형식에서 `<C-x><C-o>`로 컨텍스트 기반 완성을 호출.
  - 권장: 언어 서버 또는 해당 플러그인과 함께 사용하면 생산성이 크게 향상.

30. color mycolor
  - 목적: 사용자 정의 색상 스킴 `mycolor`를 적용.
  - 동작: `colorscheme` 또는 `color` 명령으로 색상 테마를 설정.
  - 권장: 가독성 높은 테마를 사용; 터미널과 GUI에 따라 다르게 설정.

31. 주석 처리된 설정들 (예: set paste, verbose omnifunc?)
  - 목적: 필요에 따라 수동으로 활성화할 수 있는 예시로 남겨둠.
  - 동작: 개발자가 필요 시 주석을 해제하여 기능을 켤 수 있음.
  - 권장: 중요한 설정은 주석으로 남겨두되, 실제 사용 시 문서화할 것.

32. 텍스트 인코딩과 운영체제별 권장사항 요약
  - 목적: 다양한 OS(Windows, Unix, macOS)에서 vim의 인코딩 문제를 최소화.
  - 권장: 팀 표준으로 `encoding=utf-8`과 `fileencodings=utf-8`을 권장하고, 레거시 파일은 필요 시 개별 변환.

33. 플러그인 단축키 설계 팁
  - 목적: 플러그인 호출 키가 충돌하지 않게 설계하는 법 안내.
  - 권장: 네임스페이스로 시작하는 키(예: `<leader>t`) 사용, `nnoremap`/`vnoremap`을 통해 재귀 방지.

34. 안전한 매핑과 재귀성 방지
  - 목적: 키 매핑을 `noremap` 계열로 만들어 의도치 않은 재귀 호출을 방지.
  - 권장: 사용자 매핑은 기본적으로 `nnoremap`, `inoremap`, `vnoremap` 등을 사용.

35. 성능 팁
  - 목적: 대형 파일 및 플러그인 많은 환경에서 vim 응답성 유지.
  - 권장: 불필요한 `syntax on` 반복 제거, `updatetime` 값을 적절히 조정, 플러그인 lazy-loading 사용.

36. 개발 워크플로우 통합 팁
  - 목적: cscope, ctags, git 플러그인 등과 통합하여 빠른 코드 탐색 환경 구성.
  - 권장: 프로젝트별 설정 파일(`.vimrc.local` 또는 `ftplugin`)으로 환경 분리.

37. 접기(folding) 사용 권장 시나리오
  - 목적: 긴 소스 파일에서 관심 없는 부분을 숨겨 집중력을 높임.
  - 권장: 아웃라인 기반 작업(함수/클래스 단위)의 경우 유용, 자동 폴드(예: syntax 기반) 사용 고려.

38. 로컬/프로젝트별 설정 관리
  - 목적: 프로젝트마다 다른 인덴트/탭 규칙을 쓰는 경우 자동 적용.
  - 권장: `modeline`을 허용하거나 프로젝트 루트에 `.vimrc` 형태로 관리. 보안상 신뢰된 프로젝트만 사용.

39. 요약: 이 .vimrc의 철학
  - 목적: 현대적인 Vim 사용 경험을 제공하되, 레거시 환경(인코딩, 프로젝트 정책)에 대응하도록 설계됨.
  - 권장: 개인/팀의 코드 스타일에 맞춰 일부 설정(인코딩, 탭/스페이스, 폴딩)을 조정하되, 문서화하여 일관성 유지.

40. 추가 권장 리소스
  - 목적: 더 깊게 배우고 싶을 때 참고할 자료를 제시.
  - 권장: Vim 공식 문서(`:help`), vimtips, Stack Overflow, 각 언어별 ftplugin 레포지토리 참고.

  41. 플러그인 업데이트 주기 설정을 습관화하세요.
  42. Git과 연동해 변경 이력을 추적하세요.
  43. 네트워크 드라이브에서 인코딩 문제가 발생하면 로컬로 복사하세요.
  44. 큰 파일은 편집 전에 백업을 만들어 두세요.
  45. `modeline` 사용 시 보안 설정을 확인하세요.
  46. 한 팀의 규칙은 `.editorconfig`로도 관리하세요.
  47. 자동완성은 LSP를 통해 통합하는 것을 권장합니다.
  48. 리모트 개발 시 터미널 환경 변수를 일관되게 설정하세요.
  49. 개인 설정은 `~/.vimrc`와 `~/.vim`으로 나누어 관리하세요.
  50. 플러그인 충돌 시 `:checkhealth`로 상태를 점검하세요.
  51. 단축키는 문서화해 팀과 공유하세요.
  52. 텍스트 폭과 탭 정책은 코드 리뷰에서 강제하세요.
  53. Vim 스크립트는 작은 기능 단위로 분리하세요.
  54. `:make`와 `:compiler`를 활용해 빌드 통합을 검토하세요.
  55. 비주얼 모드 매핑은 실수 방지를 위해 신중히 지정하세요.
  56. 커스텀 함수는 `autoload`에 넣어 로드 시간을 단축하세요.
  57. 색상 대비가 낮으면 테마를 바꿔 가독성을 확보하세요.
  58. 운영체제별 단축키 차이를 문서화하세요.
  59. 매핑에서 `<leader>`를 적극적으로 사용하세요.
  60. 정기적으로 `.vim` 폴더를 정리해 불필요한 파일을 제거하세요.
  61. 에디터 설정은 CI에서 검사하도록 하면 일관성이 높아집니다.
  62. 긴 설명은 `:help` 스타일의 로컬 문서로 보관하세요.
  63. 성능 문제가 발생하면 플러그인 제거로 원인 탐색하세요.
  64. 항상 변경 전에는 버전 관리에 커밋해 두세요.


## 사용자 계정별 golang 개발을 위한 vim 설정

go-usr-install.sh
```
#!/bin/bash

EXPORTS='
export GOROOT="$HOME/go"
export GOPATH="$HOME/proj"
export PATH="$GOROOT/bin:$GOPATH/bin:$PATH"
'

function bashrc_add_export()
{
    USER_NAME=$1
    BASH_RC="/home/$USER_NAME/.bashrc"
    
    echo "$EXPORTS" | while read line
    do
        KEY="$(echo $line | cut -d= -f1)"
        if [ -z "$KEY" ]; then
            continue
        fi
        sed -i "/$KEY/d" "$BASH_RC"
    done
    echo "$EXPORTS" | sed -e '/^$/d' | sudo tee -a "$BASH_RC"
    . "$BASH_RC"
}

function install_go119()
{
    USER_NAME=$1
    USER_HOME="/home/$USER_NAME"
    if [ ! -d "$USER_HOME/go" ]; then
        wget https://go.dev/dl/go1.19.1.linux-amd64.tar.gz
        tar xpzf go1.19.1.linux-amd64.tar.gz -C $USER_HOME
    fi
}

function install_go120()
{
    USER_NAME=$1
    USER_HOME="/home/$USER_NAME"
    if [ ! -d "$USER_HOME/go" ]; then
        wget https://go.dev/dl/go1.20.3.linux-amd64.tar.gz
        tar xpzf go1.20.3.linux-amd64.tar.gz -C $USER_HOME
    fi
}

function install_go124()
{
    USER_NAME=$1
    USER_HOME="/home/$USER_NAME"
    if [ ! -d "$USER_HOME/go" ]; then
        wget https://go.dev/dl/go1.24.5.linux-amd64.tar.gz
        tar xpzf go1.24.5.linux-amd64.tar.gz -C $USER_HOME
    fi
}

function install_vimgo_plugin()
{
    USER_NAME=$1
    USER_HOME="/home/$USER_NAME"

    if [ ! -f "$USER_HOME/.vim/autoload/plug.vim" ]; then
        sudo curl -fLo $USER_HOME/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim 
    fi
    mkdir -p "$USER_HOME/.vim/plugged/"
    if [ ! -d "$USER_HOME/.vim/plugged/vim-go" ]; then
        git clone https://github.com/fatih/vim-go.git $USER_HOME/.vim/plugged/vim-go
        cd $USER_HOME/.vim/plugged/vim-go
        # get vim-go for vim version < 8.2
        git checkout v1.29
    fi
    if [ ! -d "$USER_HOME/.vim/plugged/molokai" ]; then
        git clone https://github.com/tomasr/molokai.git $USER_HOME/.vim/plugged/molokai
        cp -dpRf $USER_HOME/.vim/plugged/molokai/colors $USER_HOME/.vim/
    fi
    sudo chown -R $USER_NAME:$USER_NAME $USER_HOME/.vim
}

VIMGO="
\" go key map
\" nnoremap <silent> <C-\> :GoReferrers<CR>:lopen<CR>
\" <C-o> to back to the previous position
augroup GoRefsMap
  autocmd!
  autocmd FileType go nnoremap <buffer> <silent> <C-\> :GoReferrers<CR>:lopen<CR>
augroup END

call plug#begin()
Plug 'fatih/vim-go', { 'do': ':GoInstallBinaries' }
Plug 'fatih/molokai'
call plug#end()
"

function vimrc_add_go()
{
    USER_NAME=$1
    VIM_RC="/home/$USER_NAME/.vimrc"
    MATCH=$(grep "vim-go" $VIM_RC)
    if [ ! -n "$MATCH" ]; then
        echo "$VIMGO" | sed -e '/^$/d' | sudo tee -a "$VIM_RC"
    fi
}

# rest of them can be run any order
bashrc_add_export $USER
install_go124 $USER
install_vimgo_plugin $USER
vimrc_add_go $USER
```

### go-usr-install.sh 스크립트 요약

이 스크립트는 사용자의 홈 디렉터리에 Go 개발 환경을 빠르게 구성하기 위한 도우미 스크립트입니다. 주요 기능은 다음과 같습니다.

- 환경변수(EXPORTS) 정의: `GOROOT`, `GOPATH`, `PATH`를 사용자의 쉘 초기화 파일에 추가합니다.
- `bashrc_add_export()` 함수: 지정한 사용자의 `~/.bashrc`에서 기존에 같은 키가 있으면 제거하고, 새로운 export 라인을 추가한 뒤 현재 셸 환경을 다시 로드합니다.
- `install_go119()`, `install_go120()`, `install_go124()` 함수: 각각 Go 1.19.1, 1.20.3, 1.24.5 버전을 사용자의 홈 디렉터리에 다운로드하고 압축 해제합니다. 이미 `$HOME/go` 디렉터리가 있으면 설치를 건너뜁니다.
- `install_vimgo_plugin()` 함수: `vim-plug`를 설치하여 `$HOME/.vim/autoload/plug.vim`을 구성하고, `vim-go` 및 `molokai` 컬러 스킴을 `$HOME/.vim/plugged/`에 클론합니다. 설치 후 해당 디렉터리의 소유권을 사용자로 변경합니다.
- `vimrc_add_go()` 함수: 사용자의 `~/.vimrc`에 vim-go 관련 설정을 추가합니다(중복 체크 후 추가).
- 스크립트의 끝에서는 위 함수들을 순서대로 호출하여 환경변경을 적용합니다: `bashrc_add_export`, `install_go124`, `install_vimgo_plugin`, `vimrc_add_go`.

주의사항 및 권장사항:

- 권한: 스크립트는 사용자의 홈 디렉터리를 대상으로 작업하지만 `sudo`가 사용되는 부분이 있어 환경에 따라 비밀번호 입력이 필요할 수 있습니다. 시스템 전역(`/usr/local`)에 설치하려면 루트 권한이 필요합니다.
- 네트워크: wget/curl을 사용해 외부에서 파일을 다운로드하므로 네트워크 연결 및 프록시 설정을 확인하세요.
- idempotency: 스크립트는 `$HOME/go` 존재 여부를 체크해 동일 설치를 반복하지 않도록 설계되어 있습니다. 그러나 더 엄격한 버전 체크와 체크섬 검증은 추가 권장됩니다.
- 보안: 외부 리포지터리에서 스크립트가 추가적인 파일을 다운로드하므로, 신뢰할 수 있는 네트워크와 소스인지 확인하세요.
- 사용자 환경 반영: `bashrc_add_export`는 `~/.bashrc`에 직접 라인을 추가하고 즉시 `.`로 로드합니다. 원치 않는 경우 수동으로 내용을 검토한 후 적용하세요.

간단 실행 예시:

`USER=yourusername ./go-usr-install.sh`

검증 방법:

- 설치 후 `su - yourusername -c 'go version'` 또는 사용자가 로그인한 쉘에서 `go version`을 실행해 설치 여부 확인.
- `which go` 또는 `echo $GOROOT`로 환경변수와 경로가 제대로 설정되었는지 확인.


