from flask import Flask, render_template_string, redirect
import requests

app = Flask(__name__)

# Replace this with the correct IP or hostname of the DB server
DB_SERVICE_URL = "http://<private-ip-of-db-server>:5001"

@app.route('/')
def hello():
    try:
        # Fetch current count from DB service
        response = requests.get(f"{DB_SERVICE_URL}/count")
        count = response.text
    except Exception as e:
        print(f"Error contacting DB service: {e}")
        count = "N/A"

    html = f"""
    <html>
    <head><title>Hello App</title></head>
    <body>
        <h1><a href="/click" style="text-decoration:none;">Hello! Click Me</a></h1>
        <p>Click count: <strong>{count}</strong></p>
    </body>
    </html>
    """
    return render_template_string(html)

@app.route('/click')
def click():
    try:
        # Trigger increment on DB service
        requests.get(f"{DB_SERVICE_URL}/increment")
    except Exception as e:
        print(f"Error contacting DB service: {e}")
    return redirect('/')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
