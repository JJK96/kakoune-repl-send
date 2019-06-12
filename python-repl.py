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
            kakoune_python_bridge_failure = False
            for kakoune_python_bridge_line in kakoune_python_bridge_lines:
                try:
                    print(eval(kakoune_python_bridge_line))
                except Exception:
                    exec(kakoune_python_bridge_line)
        except Exception:
            try:
                exec(kakoune_python_bridge_c)
            except Exception as e:
                e.__cause__ = None
                kakoune_python_bridge_sys.stderr = kakoune_python_bridge_sys.stdout
                kakoune_python_bridge_traceback.print_exc()
        except KeyboardInterrupt:
            pass
        finally:
            kakoune_python_bridge_sys.stdout.close()
