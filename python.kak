# python bridge for executing things interactively

declare-option -hidden str python_bridge_folder %sh{echo /tmp/kakoune_python_bridge/$kak_session}
declare-option -hidden str python_bridge_in %sh{echo $kak_opt_python_bridge_folder/in}
declare-option -hidden str python_bridge_out %sh{echo $kak_opt_python_bridge_folder/out}
declare-option -hidden str python_bridge_fifo %sh{echo $kak_opt_python_bridge_folder/fifo}
declare-option -hidden str python_bridge_source %sh{printf '%s' "${kak_source%/*}"}
declare-option bool python_bridge_fifo_enabled false
declare-option -hidden bool python_bridge_running false
declare-option -hidden str-list python_bridge_output

hook global GlobalSetOption python_bridge_fifo_enabled=true %{
    nop %sh{
        mkfifo $kak_opt_python_bridge_fifo
    }
    terminal tail -f %opt{python_bridge_fifo}
}

hook global GlobalSetOption python_bridge_fifo_enabled=false %{
    nop %sh{
        rm $kak_opt_python_bridge_fifo
    }
}

define-command -docstring 'Create FIFOs and start python -i' \
python-bridge-start %{
    nop %sh{
        if ! $kak_opt_python_bridge_running; then
            mkdir -p $kak_opt_python_bridge_folder
            mkfifo $kak_opt_python_bridge_in
            mkfifo $kak_opt_python_bridge_out
            ( python $kak_opt_python_bridge_source/python-repl.py $kak_opt_python_bridge_in $kak_opt_python_bridge_out) >/dev/null 2>&1 </dev/null &
        fi
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
            rmdir -p $kak_opt_python_bridge_folder
        fi
    }
    set-option global python_bridge_fifo_enabled false
    set-option global python_bridge_running false
}

define-command -docstring 'Evaluate selections or argument using python-bridge return result in " register' \
python-bridge-send -params 0..1 %{
    python-bridge-start
    set-option global python_bridge_output
    evaluate-commands %sh{
        cat_command="cat $kak_opt_python_bridge_out"
        if $kak_opt_python_bridge_fifo_enabled; then
            cat_command="$cat_command | tee -a $kak_opt_python_bridge_fifo"
        fi

        if [ $# -eq 0 ]; then
            eval set -- "$kak_quoted_selections"
        fi
        out=""
        while [ $# -gt 0 ]; do
            output=$(eval $cat_command) && echo "set-option -add global python_bridge_output $output" &
            echo "$1" > $kak_opt_python_bridge_in &
            wait
            shift
        done
    }
    set-register dquote %opt{python_bridge_output}
}

define-command python-bridge -params 1.. -shell-script-candidates %{
    for cmd in start stop send;
        do echo $cmd;
    done
} %{ evaluate-commands "python-bridge-%arg{1}" }

hook global KakEnd .* %{
    python-bridge-stop
}
