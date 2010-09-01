set ruler
set expandtab shiftwidth=4 tabstop=4 softtabstop=4
set wildmenu wildmode=longest:full,full
set incsearch nohlsearch
set hidden
set mouse=a
set t_Co=256
set laststatus=2

set showcmd

let g:full_name="Maxime Coste"

set title
set termencoding=utf-8

filetype plugin indent on
syntax on

" use tagjump behaviour by default
nnoremap <C-]> g<C-]>
nnoremap <C-W><C-]> <C-W>g<C-]>
nnoremap <C-W>] <C-W>g]

" C/C++ Options
autocmd FileType c\|cpp setlocal cindent
set cinoptions=:0,g0,(0,w0,Ws

function! InsertGuards() 
    let define = substitute(expand('%'), "[-\\/. ]", "_", "g") . "_INCLUDED"
    call append(0, [ "#ifndef " . define, "#define " . define, ])
    call append(line("$"), "#endif // " . define)
    if line("$") == 3
        call append(2, "")
        call cursor(3, 0)
    endif
endfunction

augroup Cpp
    autocmd!
    autocmd FileType cpp syn keyword cppKeywords2 override sealed
    autocmd FileType cpp hi link cppKeywords2 Keyword
    autocmd BufNewFile *.h call InsertGuards()
augroup end

" connect to cscope.out if possible
if filereadable("cscope.out")
    cscope add cscope.out
endif

" Mr Proper stuffs
augroup Whitespace
    autocmd!
    autocmd Syntax * syn match TrailingWhitespace /\s\+$/
    autocmd Syntax * hi  link TrailingWhitespace Error
augroup end

function! FixBlanks()
    %s/\s\+$//
    retab
endfunction

command! FixBlanks call FixBlanks()

" Eugen Systems stuff
augroup Eugen
    autocmd!
    autocmd VimEnter * if match(getcwd(), "/home/mawww/slayer") != -1 |
        \set tags+=~/slayer/Eugen\\\ Systems\\\ Code/CPP/Projects/tags,
                  \~/slayer/Eugen\\\ Systems\\\ Data/Conflit/Code/Shaders/tags
                  \~/slayer/Eugen\\\ Systems\\\ Code/Python/tags |
        \cscope add ~/slayer/Eugen\ Systems\ Code/CPP/Projects/cscope.out
    \endif
    autocmd BufRead *.eugprj set ft=eugprj
    autocmd BufRead *.ndf    set ft=ndf
augroup end

" Exherbo
function! InsertCopyright()
    call append(0, ["# Copyright 2010 Maxime Coste",
                  \ "# Distributed under the terms of the GNU General Public License v2"])
endfunction

augroup Exherbo
    autocmd!
    autocmd BufNewFile *.exheres-0 call InsertCopyright
augroup end

" AutoComplPop
let g:acp_enableAtStartup = 1
let g:acp_ignorecaseOption=0

colorscheme wombat256
