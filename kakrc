set global makecmd 'make -j8'
set global grepcmd 'ag --column'

set global clang_options '-std=c++11'

hook global WinSetOption filetype=cpp %{
    clang-enable-autocomplete 
    clang-enable-diagnostics
    map window normal <c-p> :clang-parse<ret>
    %sh{
        if [ $PWD == "/home/mawww/prj/kakoune/src" ]; then
           echo 'set buffer clang_options "%opt{clang_options} -include-pch precomp-header.h.gch"'
        fi
    }
    #ycmd-enable-autocomplete
}

hook global WinSetOption filetype=python %{
    jedi-enable-autocomplete
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

hook global NormalIdle .* %{
    eval -draft %{ try %{
        exec <space><a-i>w <a-k>^\w+$<ret>
        set buffer curword "\b\Q%val{selection}\E\b"
    } catch %{
        set buffer curword ''
    } }
}
map global normal = ':prompt math: m %{exec a<lt>c-r>m<lt>esc>|bc<lt>ret>}<ret>'

hook global BufOpenFifo '\*grep\*' %{ map -- global normal - ':grep-next<ret>' }
hook global BufOpenFifo '\*make\*' %{ map -- global normal - ':make-next<ret>' }

hook global WinCreate ^[^*]+$ %{ addhl number_lines }

set global ycmd_path /home/mawww/prj/ycmd/ycmd/

# set global autoinfo 2

set global ui_options ncurses_status_on_top=yes

def ide %{
    nameclient main
    set global jumpclient main

    new nameclient tools
    set global toolsclient tools

    new nameclient docs
    set global docsclient docs
}

colorscheme zenburn
