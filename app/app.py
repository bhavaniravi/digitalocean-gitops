from flask import Flask

app = Flask(__name__)

@app.route('/')
def index():
    return 'Web App with Python Flask!'

@app.route('/name')
def name():
    return "naming new Api!!"

app.run(host='0.0.0.0', port=8000, debug=True)
