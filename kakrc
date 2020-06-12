# User preference
# ───────────────

set-option global makecmd 'make -j8'
set-option global grepcmd 'ag --column'
set-option global ui_options terminal_status_on_top=true
hook global ModuleLoaded clang %{ set-option global clang_options -std=c++17 }

colorscheme gruvbox

add-highlighter global/ show-matching
add-highlighter global/ dynregex '%reg{/}' 0:+u

hook global WinCreate ^[^*]+$ %{ add-highlighter window/ number-lines -hlcursor }

# Enable editor config
# ────────────────────

hook global BufOpenFile .* %{ editorconfig-load }
hook global BufNewFile .* %{ editorconfig-load }

# Filetype specific hooks
# ───────────────────────

hook global WinSetOption filetype=(c|cpp) %{
    clang-enable-autocomplete 
    clang-enable-diagnostics
    alias window lint clang-parse
    alias window lint-next-error clang-diagnostics-next
}

hook global WinSetOption filetype=python %{
    jedi-enable-autocomplete
    lint-enable
    set-option global lintcmd 'flake8'
}

map -docstring "xml tag objet" global object t %{c<lt>([\w.]+)\b[^>]*?(?<lt>!/)>,<lt>/([\w.]+)\b[^>]*?(?<lt>!/)><ret>}

# Highlight the word under the cursor
# ───────────────────────────────────

declare-option -hidden regex curword
set-face global CurWord default,rgba:80808040

hook global NormalIdle .* %{
    eval -draft %{ try %{
        exec <space><a-i>w <a-k>\A\w+\z<ret>
        set-option buffer curword "\b\Q%val{selection}\E\b"
    } catch %{
        set-option buffer curword ''
    } }
}
add-highlighter global/ dynregex '%opt{curword}' 0:CurWord

# Custom mappings
# ───────────────

map global normal = ':prompt math: %{exec "a%val{text}<lt>esc>|bc<lt>ret>"}<ret>'

# System clipboard handling
# ─────────────────────────

evaluate-commands %sh{
    case $(uname) in
        Linux) copy="xclip -i"; paste="xclip -o" ;;
        Darwin)  copy="pbcopy"; paste="pbpaste" ;;
    esac

    printf "map global user -docstring 'paste (after) from clipboard' p '!%s<ret>'\n" "$paste"
    printf "map global user -docstring 'paste (before) from clipboard' P '<a-!>%s<ret>'\n" "$paste"
    printf "map global user -docstring 'yank to primary' y '<a-|>%s<ret>:echo -markup %%{{Information}copied selection to X11 primary}<ret>'\n" "$copy"
    printf "map global user -docstring 'yank to clipboard' Y '<a-|>%s<ret>:echo -markup %%{{Information}copied selection to X11 clipboard}<ret>'\n" "$copy -selection clipboard"
    printf "map global user -docstring 'replace from clipboard' R '|%s<ret>'\n" "$paste"
}

# Various mappings
# ────────────────

map global normal '#' :comment-line<ret>

map global user -docstring 'next lint error' n ':lint-next-error<ret>'
map global normal <c-p> :lint<ret>

map global user -docstring 'gdb helper mode' g ':gdb-helper<ret>'
map global user -docstring 'gdb helper mode (repeat)' G ':gdb-helper-repeat<ret>'

hook global -always BufOpenFifo '\*grep\*' %{ map -- global normal - ': grep-next-match<ret>' }
hook global -always BufOpenFifo '\*make\*' %{ map -- global normal - ': make-next-error<ret>' }

# Enable <tab>/<s-tab> for insert completion selection
# ──────────────────────────────────────────────────────

hook global InsertCompletionShow .* %{ map window insert <tab> <c-n>; map window insert <s-tab> <c-p> }
hook global InsertCompletionHide .* %{ unmap window insert <tab> <c-n>; unmap window insert <s-tab> <c-p> }

# Helper commands
# ───────────────

define-command find -menu -params 1 -shell-script-candidates %{ ag -g '' --ignore "$kak_opt_ignored_files" } %{ edit %arg{1} }

define-command mkdir %{ nop %sh{ mkdir -p $(dirname $kak_buffile) } }

define-command ide -params 0..1 %{
    try %{ rename-session %arg{1} }

    rename-client main
    set-option global jumpclient main

    new rename-client tools
    set-option global toolsclient tools

    new rename-client docs
    set-option global docsclient docs
}

define-command delete-buffers-matching -params 1 %{
    evaluate-commands -buffer * %{
        evaluate-commands %sh{ case "$kak_buffile" in $1) echo "delete-buffer" ;; esac }
    }
}

declare-option -hidden str swap_buffer_target
define-command swap-buffer-with -override -params 1 -client-completion %{
    set-option global swap_buffer_target %val{bufname}
    edit -scratch # release current window for other client
    evaluate-commands -client %arg{1} "
        set-option global swap_buffer_target %%val{bufname}
        buffer %opt{swap_buffer_target}
    "
    delete-buffer # delete the temporary scratch buffer
    buffer %opt{swap_buffer_target}
}

define-command -params .. fifo %{ evaluate-commands %sh{
     output=$(mktemp -d "${TMPDIR:-/tmp}"/kak-fifo.XXXXXXXX)/fifo
     mkfifo ${output}
     ( eval "$@" > ${output} 2>&1 & ) > /dev/null 2>&1 < /dev/null

     printf %s\\n "evaluate-commands -try-client '$kak_opt_toolsclient' %{
               edit! -fifo ${output} *fifo*
               hook -always -once buffer BufCloseFifo .* %{ nop %sh{ rm -r $(dirname ${output}) } }
           }"
}}

declare-option int gdb_server_port 5678
declare-option str gdb_server_cmd "gdbserver :%opt{gdb_server_port}"

define-command gdb-server -params .. %{
    fifo %opt{gdb_server_cmd} %arg{@}
    gdb-session-new -ex "target extended-remote :%opt{gdb_server_port}"
}


# Load local Kakoune config file if it exists
# ───────────────────────────────────────────

evaluate-commands %sh{ [ -f $kak_config/local.kak ] && echo "source $kak_config/local.kak" }
