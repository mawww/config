set global makecmd 'make -j8'
set global grepcmd 'ag --column'
map global normal <c-p> :lint<ret>

hook global WinSetOption filetype=(c|cpp) %{
    clang-enable-autocomplete 
    clang-enable-diagnostics
    alias window lint clang-parse
    alias window lint-next clang-diagnostics-next
    %sh{
        if [ $PWD = "/home/mawww/prj/kakoune/src" ]; then
           echo "set buffer clang_options '-std=c++14 -include-pch precomp-header.h.gch -DKAK_DEBUG'"
        fi
    }
    #ycmd-enable-autocomplete
}

hook global WinSetOption filetype=python %{
    jedi-enable-autocomplete
    flake8-enable-diagnostics
    alias window lint flake8-lint
    alias window lint-next flake8-diagnostics-next
    %sh{
        if [ $PWD = "/home/mawww/prj/kakoune/src" ]; then
           echo "set buffer jedi_python_path '/usr/share/gdb/python'"
           echo "set buffer path './:/usr/share/gdb/python'"
        fi
    }
}

decl -hidden regex curword
face CurWord default,rgb:4a4a4a

hook global WinCreate .* %{
    addhl show_matching
    addhl dynregex '%reg{/}' 0:+u

    # Highlight the word under the cursor
    addhl dynregex '%opt{curword}' 0:CurWord
}

def -hidden _update_curword %{
    eval -no-hooks -draft %{ try %{
        exec <space><a-i>w <a-k>\`\w+\'<ret>
        set buffer curword "\b\Q%val{selection}\E\b"
    } catch %{
        set buffer curword ''
    } }
}

hook global NormalIdle .* _update_curword
hook global NormalKey .* _update_curword

map global normal = ':prompt math: %{exec "a%val{text}<lt>esc>|bc<lt>ret>"}<ret>'

map global user n ':lint-next<ret>'
map global user p '!xclip -o<ret>'
map global user y '<a-|>xclip -i<ret>; :echo -color Information "copied selection to X11 clipboard"<ret>'
map global user R '|xclip -o<ret>'

hook global BufOpenFifo '\*grep\*' %{ map -- global normal - ':grep-next<ret>' }
hook global BufOpenFifo '\*make\*' %{ map -- global normal - ':make-next<ret>' }

hook global WinCreate ^[^*]+$ %{ addhl number_lines }

set global ycmd_path /home/mawww/prj/ycmd/ycmd/

# set global autoinfo 2

set global ui_options ncurses_status_on_top=true

map global normal '#' :comment-line<ret>

def ide %{
    rename-client main
    set global jumpclient main

    new rename-client tools
    set global toolsclient tools

    new rename-client docs
    set global docsclient docs
}

hook global InsertCompletionShow .* %{ map window insert <tab> <c-n>; map window insert <backtab> <c-p> }
hook global InsertCompletionHide .* %{ unmap window insert <tab> <c-n>; unmap window insert <backtab> <c-p> }

def find -params 1 -shell-candidates %{ find . -type f } %{ edit %arg{1} }

colorscheme base16
