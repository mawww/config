# User preference
# ───────────────

set-option global makecmd 'make -j8'
set-option global grepcmd 'ag --column'
set-option global ui_options terminal_status_on_top=true
hook global ModuleLoaded clang %{ set-option global clang_options -std=c++20 }
hook global ModuleLoaded tmux %{ alias global terminal tmux-terminal-vertical }

colorscheme gruvbox-dark

add-highlighter global/ show-matching -previous

set-face global CurSearch +u

hook global RegisterModified '/' %{ add-highlighter -override global/search regex "%reg{/}" 0:CurSearch }

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

set-face global CurWord +b

hook global NormalIdle .* %{
    eval -draft %{ try %{
        exec ,<a-i>w <a-k>\A\w+\z<ret>
        add-highlighter -override global/curword regex "\b\Q%val{selection}\E\b" 0:CurWord
    } catch %{
        add-highlighter -override global/curword group
    } }
}

# Switch cursor color in insert mode
# ──────────────────────────────────

set-face global InsertCursor default,green+B

hook global ModeChange .*:.*:insert %{
    set-face window PrimaryCursor InsertCursor
    set-face window PrimaryCursorEol InsertCursor
}

hook global ModeChange .*:insert:.* %{ try %{
    unset-face window PrimaryCursor
    unset-face window PrimaryCursorEol
} }

# Custom mappings
# ───────────────

map global normal = ':prompt math: %{exec "a%val{text}<lt>esc>|bc<lt>ret>"}<ret>'

# System clipboard handling
# ─────────────────────────

evaluate-commands %sh{
    if [ -n "$SSH_TTY" ]; then
        copy='printf "\033]52;;%s\033\\" $(base64 | tr -d "\n") > $( [ -n "$kak_client_pid" ] && echo /proc/$kak_client_pid/fd/0 || echo /dev/tty )'
        paste='printf "paste unsupported through ssh"'
        backend="OSC 52"
    else
        case $(uname) in
            Linux)
                if [ -n "$WAYLAND_DISPLAY" ]; then
                    copy="wl-copy -p"; paste="wl-paste -p"; backend=Wayland
                else
                    copy="xclip -i"; paste="xclip -o"; backend=X11
                fi
                ;;
            Darwin)  copy="pbcopy"; paste="pbpaste"; backend=OSX ;;
        esac
    fi

    printf "map global user -docstring 'paste (after) from clipboard' p '<a-!>%s<ret>'\n" "$paste"
    printf "map global user -docstring 'paste (before) from clipboard' P '!%s<ret>'\n" "$paste"
    printf "map global user -docstring 'yank to primary' y '<a-|>%s<ret>:echo -markup %%{{Information}copied selection to %s primary}<ret>'\n" "$copy" "$backend"
    printf "map global user -docstring 'yank to clipboard' Y '<a-|>%s<ret>:echo -markup %%{{Information}copied selection to %s clipboard}<ret>'\n" "$copy -selection clipboard" "$backend"
    printf "map global user -docstring 'replace from clipboard' R '|%s<ret>'\n" "$paste"
    printf "define-command -override echo-to-clipboard -params .. %%{ echo -to-shell-script '%s' -- %%arg{@} }" "$copy"
}

# Various mappings
# ────────────────

map global normal '#' :comment-line<ret>

map global user -docstring 'next lint error' n ':lint-next-error<ret>'
map global normal <c-p> :lint<ret>

map global user -docstring 'gdb helper mode' g ':gdb-helper<ret>'
map global user -docstring 'gdb helper mode (repeat)' G ':gdb-helper-repeat<ret>'

map global user -docstring 'lsp mode' l ':enter-user-mode lsp<ret>'

hook global -always BufOpenFifo '\*grep\*' %{ map global normal <minus> ': grep-next-match<ret>' }
hook global -always BufOpenFifo '\*make\*' %{ map global normal <minus> ': make-next-error<ret>' }

# Enable <tab>/<s-tab> for insert completion selection
# ──────────────────────────────────────────────────────

hook global InsertCompletionShow .* %{ map window insert <tab> <c-n>; map window insert <s-tab> <c-p> }
hook global InsertCompletionHide .* %{ unmap window insert <tab> <c-n>; unmap window insert <s-tab> <c-p> }

# Helper commands
# ───────────────

define-command find -params 1 %{ edit %arg{1} }
complete-command -menu find shell-script-candidates %{ ag -g '' --ignore "$kak_opt_ignored_files" }

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

define-command -override swap-window -params 1 -client-completion -docstring 'swap-window <client>: swap window with client' %{
    # Restore source and target registers
    evaluate-commands -save-regs 'st' %{
        execute-keys '"sZ'
        execute-keys -client %arg{1} '"tZ'
        execute-keys '"tz'
        execute-keys -client %arg{1} '"sz'
    }
}

declare-option int gdb_server_port 5678
declare-option str gdb_server_cmd "gdbserver :%opt{gdb_server_port}"

define-command gdb-server -params .. %{
    fifo %opt{gdb_server_cmd} %arg{@}
    gdb-session-new -ex "target extended-remote :%opt{gdb_server_port}"
}


declare-option str to_asm_cmd 'g++ -O3 -x c++'
declare-option str to_asm_prelude '
#include <utility>
'
declare-option -hidden int to_asm_timestamp 0

define-command to-asm -params .. -docstring %{
    Compile selected text with using the to_asm_cmd option and display assembly in the *asm* buffer
} %{
    evaluate-commands -save-regs 'ab"|' %{
        execute-keys -save-regs '' y
        set-register a %opt{to_asm_prelude}
        set-register b %opt{to_asm_cmd}
        evaluate-commands -try-client %opt{docsclient} %{
            edit -scratch *asm*
            set-option buffer filetype gas
            execute-keys \%R"aP% "|%reg{b} %arg{@} -S - -o - 2>&1|c++filt<ret>" gg
            try %{ execute-keys -draft \%s^\h*\.cfi_<ret>xd }
        }
    }
}

define-command to-asm-enable -docstring %{
    Automatically run to-asm on the whole buffer after each change
} %{
    remove-hooks window to-asm
    hook -group to-asm window NormalIdle .* %{ try %{
        %sh{ [ $kak_opt_to_asm_timestamp -eq $kak_timestamp ] && echo "fail" || echo "nop" }
        set buffer to_asm_timestamp %val{timestamp}
        evaluate-commands -draft %{
            execute-keys '%'
            to-asm
        }
    } }
}

define-command diff-buffers -override -params 2 %{
    evaluate-commands %sh{
        file1=$(mktemp)
        file2=$(mktemp)
        echo "
            evaluate-commands -buffer '$1' write -force $file1
            evaluate-commands -buffer '$2' write -force $file2
            edit! -scratch *diff-buffers*
            set buffer filetype diff
            set-register | 'diff -u $file1 $file2; rm $file1 $file2'
            execute-keys !<ret>gg
        "
}}

complete-command diff-buffers buffer

define-command clang-format-cursor %{
    exec -draft <percent>| "clang-format --lines=%val{cursor_line}:%val{cursor_line}" <ret>
}

hook global GlobalSetOption 'makecmd=ninja(-build)?\b.*' %{ complete-command make shell-script-candidates %{ $kak_opt_makecmd -t targets | cut -f 1 -d : } }
hook global GlobalSetOption 'makecmd=bazel\b.*' %{ complete-command make shell-script-candidates %{ bazel query //... } }

# Mail
# ────

hook global BufOpenFile .*/mail/.*/(cur|new|tmp)/[^/]+ %{ set-option buffer filetype mail }

# Load local Kakoune config file if it exists
# ───────────────────────────────────────────

evaluate-commands %sh{ [ -f $kak_config/local.kak ] && echo "source $kak_config/local.kak" }
