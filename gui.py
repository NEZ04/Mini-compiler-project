import tkinter as tk
import subprocess
import json

def compile_code():
    code = editor.get("1.0", tk.END)

    result = subprocess.run(
        ["compiler.exe"],
        input=code,
        text=True,
        capture_output=True
    )

    output_box.delete("1.0", tk.END)

    try:
        parsed = json.loads(result.stdout)
        output_box.insert(tk.END, json.dumps(parsed, indent=4))
    except:
        output_box.insert(tk.END, result.stdout + result.stderr)

root = tk.Tk()
root.title("Mini Compiler IDE")

editor = tk.Text(root, height=15, width=60)
editor.pack()

compile_btn = tk.Button(root, text="Compile", command=compile_code)
compile_btn.pack()

output_box = tk.Text(root, height=15, width=60)
output_box.pack()

root.mainloop()