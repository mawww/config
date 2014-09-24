set global makecmd 'make -j8'
set global grepcmd 'ag --column'

set global clang_options '-std=gnu++11'

hook global WinSetOption filetype=cpp %{
    clang-enable-autocomplete 
}

hook global WinCreate .* %{
    addhl show_matching
    addhl search
}

map global normal = ':prompt math: m %{exec a<lt>c-r>m<lt>esc>|bc<lt>ret>}<ret>'

hook global BufCreate '\*grep\*' %{ map -- global normal - ':next<ret>' }
hook global BufCreate '\*make\*' %{ map -- global normal - ':errnext<ret>' }
