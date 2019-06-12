This bridge runs a python shell in the background and can send selections through the shell.
This way you can do calculations while keeping memory of previous variables, so this enables you to use variables in later calculations.

# install

The script assumes that `python-repl.py` is located in `%val{config}/plugins/kakoune-python-bridge`

# usage

Select a piece of text that can be interpreted by python, then run `python-bridge-send`.
This will automatically start the interpreter if it is not running.

The interpreter will first try to run the code interactively line by line, if that fails, the whole code will be executed at once.

The interpreter will be shut down when the kakoune server is closed.

# commands

`python-bridge-start` Start the python bridge  
`python-bridge-stop` Stop the python bridge  
`python-bridge-send` Send the current selections through the python bridge  
