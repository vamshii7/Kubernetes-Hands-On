import requests
from flask import Flask, Response

app = Flask(__name__)

@app.route('/metrics')
def metrics():
    try:
        json_data = requests.get("http://localhost:8080/metrics-json").json()
        output = ""
        for key, value in json_data.items():
            output += f"# HELP {key} Custom metric\n"
            output += f"# TYPE {key} gauge\n"
            output += f"{key} {value}\n"
        return Response(output, mimetype='text/plain')
    except Exception as e:
        return Response(f"# Error: {e}", mimetype='text/plain')

app.run(host='0.0.0.0', port=9100)