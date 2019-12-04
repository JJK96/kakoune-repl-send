# send commands to repl for evaluation
declare-option str repl_send_command
declare-option str repl_send_exit_command

declare-option -hidden str repl_send_folder "/tmp/kakoune_repl_send/%val{session}"
declare-option -hidden str repl_send_in 
declare-option -hidden str repl_send_out 
declare-option -hidden str repl_send_source %sh{echo "${kak_source%/*}"}
declare-option -hidden bool repl_send_running false

define-command -docstring 'Create FIFOs and start repl' \
repl-send-start %{
    evaluate-commands %sh{
        name=$(echo $kak_bufname | base64)
        mkdir -p "$kak_opt_repl_send_folder/$name"
        echo "set-option buffer repl_send_in $kak_opt_repl_send_folder/$name/in"
        echo "set-option buffer repl_send_out $kak_opt_repl_send_folder/$name/out"
    }
    evaluate-commands %sh{
        mkfifo $kak_opt_repl_send_in
        mkfifo $kak_opt_repl_send_out
        ( tail -f $kak_opt_repl_send_in | eval $kak_opt_repl_send_command > $kak_opt_repl_send_out 2>&1 ) >/dev/null 2>&1 </dev/null &
        echo "terminal cat $kak_opt_repl_send_out"
    }
    hook buffer BufClose .* %{
        repl-send-stop
    }
    set-option buffer repl_send_running true
}

define-command -docstring 'Stop repl and remove FIFOs' \
repl-send-stop %{
    nop %sh{
        if $kak_opt_repl_send_running; then
            echo "$kak_opt_repl_send_exit_command" > $kak_opt_repl_send_in
            rm $kak_opt_repl_send_in
            rm $kak_opt_repl_send_out
            rmdir -pr $kak_opt_repl_send_folder
        fi
    }
    set-option buffer repl_send_running false
}

define-command -docstring 'Send selections or argument using repl-send' \
repl-send -params 0..1 %{
    evaluate-commands %sh{
        if ! $kak_opt_repl_send_running; then
            echo repl-send-start
        fi
    }
    evaluate-commands %sh{
        if [ $# -eq 0 ]; then
            eval set -- "$kak_quoted_selections"
        fi
        out=""
        while [ $# -gt 0 ]; do
            echo "$1" > $kak_opt_repl_send_in &
            shift
        done
    }
}

