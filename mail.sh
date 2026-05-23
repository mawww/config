alias inbox='mlist ~/mail/Inbox/ | mthread | msort -r -d | mseq -S; mscan'

marchive() {
    seq=$(mktemp /tmp/archive.XXXXX)
    ( [ $# -eq 0 ] && cat || mseq "$@" ) > ${seq}
    cat ${seq} | magrep list-id:busybox | mrefile ~/mail/list/busybox/ &&
    cat ${seq} | magrep list-id:rxvt-unicode | mrefile ~/mail/list/rxvt-unicode/ &&
    cat ${seq} | magrep list-id:lists.x.org | mrefile ~/mail/list/xorg/ &&
    cat ${seq} | magrep list-id:notmuchmail.org | mrefile ~/mail/list/notmuch/ &&
    cat ${seq} | magrep list-id:isocpp.org | mrefile ~/mail/list/isocpp/ &&
    cat ${seq} | magrep list-id:kakoune | mrefile ~/mail/list/kakoune/ &&
    cat ${seq} | magrep '*:~mawww/kakoune@lists\.sr\.ht' | mrefile ~/mail/list/kakoune/ &&
    cat ${seq} | mrefile ~/mail/archived/ &&
    rm ${seq}
}

mdelete() {
    mrefile "$@" ~/mail/Trash/
}

mapplied() {
    mrep -x-sourcehut-patchset-update APPLIED -noquote -- "$@"
}

kmail() {
    kak -e "
        source ~/prj/mblaze.kak/mblaze.kak
        set-option global mblaze_archive_cmd '( . ${BASH_SOURCE}; marchive )'
        set-option global mblaze_delete_cmd '( . ${BASH_SOURCE}; mdelete )'
        map global normal j gd
        map global normal k gu

        set-option global mblaze_show_client content
        new rename-client content
        define-command mblaze-inbox %{mblaze-list mlist ~/mail/Inbox/ | mthread -r -S ~/mail/Sent/ | mseq -S}
        define-command mblaze-search -params .. %{mblaze-list mlist ~/mail/Inbox/ ~/mail/archived/ | magrep %arg{@} | mthread -r -S ~/mail/Sent/ | mseq -S}
        define-command mblaze-sync %{eval -draft -verbatim fifo -name *mblaze-sync* mbsync -a}

        mblaze-inbox
    "
}
