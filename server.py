from flask import Flask, request, jsonify, send_from_directory
import subprocess
import json
import os

app = Flask(__name__)

# 🔥 ADD THIS ROUTE
@app.route("/")
def home():
    return send_from_directory(os.getcwd(), "index.html")

@app.route("/compile", methods=["POST"])
def compile_code():
    code = request.json.get("code")

    result = subprocess.run(
        ["compiler.exe"],
        input=code,
        text=True,
        capture_output=True
    )

    try:
        return jsonify(json.loads(result.stdout))
    except:
        return jsonify({"error": result.stdout + result.stderr})

app.run(debug=True)