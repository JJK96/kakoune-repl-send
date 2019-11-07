import sys as kakoune_python_bridge_sys
import traceback as kakoune_python_bridge_traceback

kakoune_python_bridge_input = kakoune_python_bridge_sys.argv[1]
kakoune_python_bridge_output = kakoune_python_bridge_sys.argv[2]

while True:
    with open(kakoune_python_bridge_input, 'r') as kakoune_python_bridge_f:
        kakoune_python_bridge_c = kakoune_python_bridge_f.read()
        kakoune_python_bridge_lines = kakoune_python_bridge_c.splitlines()
        try:
            kakoune_python_bridge_sys.stdout = open(kakoune_python_bridge_output, 'w')
            if len(kakoune_python_bridge_lines) == 1 or \
                    (len(kakoune_python_bridge_lines) == 2 and kakoune_python_bridge_lines[1] == ''):
                kakoune_python_bridge_failure = False
                try:
                    kakoun_python_bridge_output = eval(kakoune_python_bridge_lines[0])
                    if kakoun_python_bridge_output is not None:
                        print(kakoun_python_bridge_output)
                except SyntaxError:
                    exec(kakoune_python_bridge_c)
            else:
                exec(kakoune_python_bridge_c)
        except KeyboardInterrupt:
            pass
        except Exception as e:
            e.__cause__ = None
            kakoune_python_bridge_sys.stderr = kakoune_python_bridge_sys.stdout
            kakoune_python_bridge_traceback.print_exc()
        finally:
            kakoune_python_bridge_sys.stdout.close()
