This bridge runs a shell in the background and can send selections to the shell.
The results are shown in a separate terminal.

This way it differs from [kakoune-repl-bridge](https://github.com/jjk96/kakoune-repl-bridge) which also returns the output of the executed expression.
The benefit of this plugin is that due to its simpler nature it works with more shells.

# Install

Add this repository to your autoload dir: `~/.config/kak/autoload/`.

Or via [plug.kak](https://github.com/andreyorst/plug.kak):

```
plug 'JJK96/kakoune-repl-send' %{
  # Suggested mapping
  map global normal <backspace> ': repl-send<ret>'
}
```

# Configuration

Before you are able to use the plugin you need to set the `repl_send_command` and `repl_send_exit_command` which are used to run the repl and exit it respectively

## Examples

```
hook global WinSetOption filetype=python %{
    set window repl_send_command "python -i"
    set window repl_send_exit_command "exit()"
}
```   

```
hook global WinSetOption filetype=scheme %{
    # stdbuf is used to disable buffering
    set window repl_send_command "stdbuf -o0 chicken-csi"
    set window repl_send_exit_command "(exit)"
}
```

# usage

1. Select a piece of text that can be interpreted by the interpreter you set for the buffer in the configuration step, then run `repl-send`.

or

2. run `:repl-send expr` where `expr` can be any code that can be interpreted by your interpreter.

This will automatically start the repl if it is not running.

The repl will be shut down using the `repl_send_exit_command` when the kakoune server is closed.

# commands

`repl-send-start` Start the repl  
`repl-send-stop [exit_command]` Stop repl and remove FIFOs  
`repl-send [expression]` Send the current selections or argument to the repl  
