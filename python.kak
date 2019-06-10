# python bridge for executing things interactively

declare-option str python_bridge_in /tmp/python-bridge-in
declare-option str python_bridge_out /tmp/python-bridge-out

define-command python-bridge-start %{
    nop %sh{
        mkfifo $kak_opt_python_bridge_in
        mkfifo $kak_opt_python_bridge_out
        ( tail -f $kak_opt_python_bridge_in | python -i > $kak_opt_python_bridge_out ) >/dev/null 2>&1 </dev/null &
    }
}

define-command python-bridge-stop %{
    nop %sh{
        echo "exit()" > $kak_opt_python_bridge_in
        rm $kak_opt_python_bridge_in
        rm $kak_opt_python_bridge_out
    }
}

define-command python-bridge-send %{
    evaluate-commands %sh{
        echo "set-register | %{ cat > $kak_opt_python_bridge_in; while IFS= read -t 0.1 response; do echo \$response; done < $kak_opt_python_bridge_out}"
    }
    execute-keys -itersel "|<ret>"
}
