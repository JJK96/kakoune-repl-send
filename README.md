This bridge runs a python shell in the background and can send selections through the shell.
This way you can do calculations while keeping memory of previous variables, so this enables you to use variables in later calculations.

# install

The script assumes that `python-repl.py` is located in `%val{config}/plugins/kakoune-python-bridge`

# commands

`python-bridge-start` Start the python bridge  
`python-bridge-stop` Stop the python bridge  
`python-bridge-send` Send the current selections through the python bridge  
