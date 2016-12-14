rename-client main
new rename-client docs
new rename-client tools
set global docsclient docs
set global toolsclient tools
set global jumpclient main

nop %sh{
    if [[ -n $TMUX ]]; then
        tmux select-layout tiled
        tmux resize-pane -t 0 -y 90
        tmux resize-pane -t 1 -x 140
        tmux select-pane -t 0
    fi
}

def ide-place-tmux-shell-pane %{ %sh{
    tmux move-pane -s 3 -t 1
    tmux resize-pane -t 2 -y 20
    tmux select-pane -t 0
} }
