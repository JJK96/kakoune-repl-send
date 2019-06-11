import sys as kakoune_python_bridge_sys
import code as kakoune_python_bridge_code
import traceback as kakoune_python_bridge_traceback

kakoune_python_bridge_input = kakoune_python_bridge_sys.argv[1]
kakoune_python_bridge_output = kakoune_python_bridge_sys.argv[2]

kakoune_python_bridge_i = kakoune_python_bridge_code.InteractiveInterpreter()
while True:
    with open(kakoune_python_bridge_input, 'r') as kakoune_python_bridge_f:
        kakoune_python_bridge_c = kakoune_python_bridge_f.read()
        try:
            kakoune_python_bridge_sys.stdout = open(kakoune_python_bridge_output, 'w')
            if not kakoune_python_bridge_i.runsource(kakoune_python_bridge_c):
                try:
                    exec(kakoune_python_bridge_c)
                except Exception:
                    kakoune_python_bridge_sys.stderr = kakoune_python_bridge_sys.stdout
                    kakoune_python_bridge_traceback.print_exc()
        except KeyboardInterrupt:
            pass
        finally:
            kakoune_python_bridge_sys.stdout.close()
