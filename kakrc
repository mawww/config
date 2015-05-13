set global makecmd 'make -j8'
set global grepcmd 'ag --column'

set global clang_options '-std=gnu++11'

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
}

hook global WinCreate .* %{
    addhl show_matching
    addhl search
}

map global normal = ':prompt math: m %{exec a<lt>c-r>m<lt>esc>|bc<lt>ret>}<ret>'

hook global BufOpenFifo '\*grep\*' %{ map -- global normal - ':next<ret>' }
hook global BufOpenFifo '\*make\*' %{ map -- global normal - ':errnext<ret>' }

hook global WinCreate ^[^*]+$ %{ addhl number_lines }

set global ycmd_path /home/mawww/prj/ycmd/ycmd/

# set global autoinfo 2
