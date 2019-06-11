import sys
import code

input = sys.argv[1]
output = sys.argv[2]

i = code.InteractiveInterpreter()
while True:
    with open(input, 'r') as f:
        c = f.read()
        sys.stdout = open(output, 'w')
        i.runsource(c)
        sys.stdout.close()
