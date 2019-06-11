# python bridge for executing things interactively

declare-option str python_bridge_in /tmp/python-bridge-in
declare-option str python_bridge_out /tmp/python-bridge-out

define-command -docstring 'Create FIFOs and start python -i' \
python-bridge-start %{
    nop %sh{
        mkfifo $kak_opt_python_bridge_in
        mkfifo $kak_opt_python_bridge_out
        ( python $kak_config/plugins/kakoune-python-bridge/python-repl.py $kak_opt_python_bridge_in $kak_opt_python_bridge_out 2>/tmp/err) >/dev/null 2>&1 </dev/null &
    }
}

define-command -docstring 'Stop python -i and remove FIFOs' \
python-bridge-stop %{
    nop %sh{
        echo "exit()" > $kak_opt_python_bridge_in
        rm $kak_opt_python_bridge_in
        rm $kak_opt_python_bridge_out
    }
}

define-command -docstring 'Evaluate selections using python-bridge' \
python-bridge-send %{
    evaluate-commands %sh{
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
