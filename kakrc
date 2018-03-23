set global makecmd 'make -j8'
set global grepcmd 'ag --column'
map global normal <c-p> :lint<ret>

hook global WinSetOption filetype=(c|cpp) %{
    clang-enable-autocomplete 
    clang-enable-diagnostics
    alias window lint clang-parse
    alias window lint-next-error clang-diagnostics-next
    %sh{
        if [ $PWD = "/home/mawww/prj/kakoune/src" ]; then
           echo "set buffer clang_options '-std=c++14 -include-pch precomp-header.h.gch -DKAK_DEBUG'"
        fi
    }
}

hook global WinSetOption filetype=python %{
    jedi-enable-autocomplete
    # flake8-enable-diagnostics
    alias window lint flake8-lint
    alias window lint-next-error flake8-diagnostics-next
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
    add-highlighter window show_matching
    add-highlighter window dynregex '%reg{/}' 0:+u

    # Highlight the word under the cursor
    add-highlighter window dynregex '%opt{curword}' 0:CurWord
}

hook global NormalIdle .* %{
    eval -draft %{ try %{
        exec <space><a-i>w <a-k>\A\w+\z<ret>
        set buffer curword "\b\Q%val{selection}\E\b"
    } catch %{
        set buffer curword ''
    } }
}
map global normal = ':prompt math: %{exec "a%val{text}<lt>esc>|bc<lt>ret>"}<ret>'

map global user n ':lint-next-error<ret>'
map global user p '!xclip -o<ret>'
map global user P '<a-!>xclip -o<ret>'
map global user y '<a-|>xclip -i<ret>; :echo -markup "{Information}copied selection to X11 clipboard"<ret>'
map global user R '|xclip -o<ret>'

map global user g ':gdb-helper<ret>'
map global user G ':gdb-helper-repeat<ret>'

hook global BufOpenFifo '\*grep\*' %{ map -- global normal - ':grep-next-match<ret>' }
hook global BufOpenFifo '\*make\*' %{ map -- global normal - ':make-next-error<ret>' }

hook global WinCreate ^[^*]+$ %{ add-highlighter window number_lines }

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

def find -params 1 -shell-candidates %{ ag -g '' --ignore "$kak_opt_ignored_files" } %{ edit %arg{1} }

colorscheme base16
