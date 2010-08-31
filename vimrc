set expandtab
set tabstop=4 shiftwidth=4
set hidden wildmenu
set cindent
set nohlsearch incsearch

set t_Co=256

filetype plugin indent on

function! InsertCopyright()
    call append(0, ["# Copyright 2010 Maxime Coste",
                  \ "# Distributed under the terms of the GNU General Public License v2"])
endfunction

au BufNewFile *.exheres call InsertCopyright

" notmuch
let g:notmuch_folders = [
    \ [ 'new', 'tag:inbox and tag:unread' ],
    \ [ 'inbox', 'tag:inbox' ],
    \ [ 'unread', 'tag:unread' ],
    \ [ 'famille', 'tag:famille' ],
    \ [ 'ensimag', 'tag:ensimag' ],
    \ [ 'soulaks', 'tag:soulaks' ],
    \ [ 'exherbo', 'tag:exherbo' ],
    \ ]

" autocomplpop

let g:acp_enableAtStartup = 1
