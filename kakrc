set global makecmd 'make -j8'
set global grepcmd 'ag --column'

set global clang_options '-std=gnu++11'

hook global WinSetOption filetype=cpp %{
    clang-enable-autocomplete 
}
