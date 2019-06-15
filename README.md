This bridge runs a python shell in the background and can send selections through the shell.
This way you can do calculations while keeping memory of previous variables, so this enables you to use variables in later calculations.

# Install

Add this repository to your autoload dir: `~/.config/kak/autoload/`.

Or via [plug.kak](https://github.com/andreyorst/plug.kak):

```
plug 'JJK96/kakoune-python-bridge' %{
  # Suggested mapping
  map global normal = ': python-bridge-send<ret>'
  # run some python code initially
  python-bridge-send %{
from math import *
  }
  
}
```

# usage

1. Select a piece of text that can be interpreted by python, then run `python-bridge-send`.

or

2. run `:python-bridge-send expr` where `expr` can be any python code.

This will automatically start the interpreter if it is not running.
Then it will execute the code using python and return the output in place of the selection or using an info box for option 1 and 2 respectively

The interpreter will first try to run the code interactively line by line, if that fails, the whole code will be executed at once.

The interpreter will be shut down when the kakoune server is closed.

# commands

`python-bridge-start` Start the python bridge  
`python-bridge-stop` Stop the python bridge  
`python-bridge-send` Send the current selections through the python bridge  
