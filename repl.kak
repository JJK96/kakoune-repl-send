# repl bridge1 for executing things interactively

declare-option -hidden str repl_bridge1_folder "/tmp/kakoune_repl_bridge1/%val{session}"
declare-option -hidden str repl_bridge1_in "%opt{repl_bridge1_folder}/in"
declare-option -hidden str repl_bridge1_out "%opt{repl_bridge1_folder}/out"
declare-option -hidden str repl_bridge1_fifo "%opt{repl_bridge1_folder}/fifo"
declare-option -hidden str repl_bridge1_source %sh{echo "${kak_source%/*}"}
declare-option -hidden str repl_bridge1_command "stdbuf -o0 chicken-csi"
declare-option -hidden bool repl_bridge1_running false

define-command -docstring 'Create FIFOs and start repl -i' \
repl-bridge1-start %{
    evaluate-commands %sh{
        if ! $kak_opt_repl_bridge1_running; then
            mkdir -p $kak_opt_repl_bridge1_folder
            mkfifo $kak_opt_repl_bridge1_in
            mkfifo $kak_opt_repl_bridge1_out
            ( tail -f $kak_opt_repl_bridge1_in | eval $kak_opt_repl_bridge1_command > $kak_opt_repl_bridge1_out ) >/dev/null 2>&1 </dev/null &
            echo "terminal cat $kak_opt_repl_bridge1_out"
        fi
    }
    set-option global repl_bridge1_running true
}

define-command -docstring 'Stop repl -i and remove FIFOs' \
repl-bridge1-stop %{
    nop %sh{
        if $kak_opt_repl_bridge1_running; then
            echo "exit()" > $kak_opt_repl_bridge1_in
            rm $kak_opt_repl_bridge1_in
            rm $kak_opt_repl_bridge1_out
            rmdir -p $kak_opt_repl_bridge1_folder
        fi
    }
    set-option global repl_bridge1_running false
}

define-command -docstring 'Evaluate selections or argument using repl-bridge1 return result in " register' \
repl-bridge1-send -params 0..1 %{
    repl-bridge1-start
    evaluate-commands %sh{
        if [ $# -eq 0 ]; then
            eval set -- "$kak_quoted_selections"
        fi
        out=""
        while [ $# -gt 0 ]; do
            echo "$1" > $kak_opt_repl_bridge1_in &
            shift
        done
    }
}

define-command repl-bridge1 -params 1.. -shell-script-candidates %{
    for cmd in start stop send;
        do echo $cmd;
    done
} %{ evaluate-commands "repl-bridge1-%arg{1}" }

hook global KakEnd .* %{
    repl-bridge1-stop
}
