# python bridge for executing things interactively

declare-option -hidden str python_bridge_in %sh{echo /tmp/kakoune-$kak_session-python-bridge-in}
declare-option -hidden str python_bridge_out %sh{echo /tmp/kakoune-$kak_session-python-bridge-out}
declare-option -hidden str python_bridge_source %sh{printf '%s' "${kak_source%/*}"}
declare-option -hidden bool python_bridge_running false

define-command -docstring 'Create FIFOs and start python -i' \
python-bridge-start %{
    nop %sh{
        mkfifo $kak_opt_python_bridge_in
        mkfifo $kak_opt_python_bridge_out
        ( python $kak_opt_python_bridge_source/python-repl.py $kak_opt_python_bridge_in $kak_opt_python_bridge_out 2>/tmp/err) >/dev/null 2>&1 </dev/null &
    }
    set-option global python_bridge_running true
}

define-command -docstring 'Stop python -i and remove FIFOs' \
python-bridge-stop %{
    nop %sh{
        if $kak_opt_python_bridge_running; then
            cat $kak_opt_python_bridge_out &
            echo "exit()" > $kak_opt_python_bridge_in
            rm $kak_opt_python_bridge_in
            rm $kak_opt_python_bridge_out
        fi
    }
    set-option global python_bridge_running false
}

define-command -docstring 'Evaluate selections using python-bridge' \
python-bridge-send %{
    evaluate-commands %sh{
        if ! $kak_opt_python_bridge_running; then
            echo python-bridge-start
        fi
        echo "set-register | %{ input=\$(cat); cat $kak_opt_python_bridge_out & echo \"\$input\" > $kak_opt_python_bridge_in & wait}"
    }
    execute-keys -itersel "|<ret>"
}

define-command python-bridge -params 1.. -shell-script-candidates %{
    for cmd in start stop send;
        do echo $cmd;
    done
} %{ evaluate-commands "python-bridge-%arg{1}" }

hook global KakEnd .* %{
    python-bridge-stop
}
