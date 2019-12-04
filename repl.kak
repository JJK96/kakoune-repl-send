# send commands to repl for evaluation

declare-option -hidden str repl_send_folder "/tmp/kakoune_repl_send/%val{session}"
declare-option -hidden str repl_send_in "%opt{repl_send_folder}/in"
declare-option -hidden str repl_send_out "%opt{repl_send_folder}/out"
declare-option -hidden str repl_send_source %sh{echo "${kak_source%/*}"}
declare-option -hidden str repl_send_command "stdbuf -o0 chicken-csi"
declare-option -hidden bool repl_send_running false

define-command -docstring 'Create FIFOs and start repl -i' \
repl-send-start %{
    evaluate-commands %sh{
        if ! $kak_opt_repl_send_running; then
            mkdir -p $kak_opt_repl_send_folder
            mkfifo $kak_opt_repl_send_in
            mkfifo $kak_opt_repl_send_out
            ( tail -f $kak_opt_repl_send_in | eval $kak_opt_repl_send_command > $kak_opt_repl_send_out 2>&1 ) >/dev/null 2>&1 </dev/null &
            echo "terminal cat $kak_opt_repl_send_out"
        fi
    }
    set-option global repl_send_running true
}

define-command -docstring 'Stop repl -i and remove FIFOs' \
repl-send-stop %{
    nop %sh{
        if $kak_opt_repl_send_running; then
            echo "exit()" > $kak_opt_repl_send_in
            rm $kak_opt_repl_send_in
            rm $kak_opt_repl_send_out
            rmdir -p $kak_opt_repl_send_folder
        fi
    }
    set-option global repl_send_running false
}

define-command -docstring 'Evaluate selections or argument using repl-send return result in " register' \
repl-send -params 0..1 %{
    repl-send-start
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

hook global KakEnd .* %{
    repl-send-stop
}
