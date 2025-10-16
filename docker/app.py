from flask import Flask, jsonify
app = Flask(__name__)

@app.route('/metrics-json')
def metrics_json():
    return jsonify(cpu=0.42, memory=256)

app.run(host='0.0.0.0', port=8080)