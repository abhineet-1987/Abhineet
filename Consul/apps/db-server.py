from flask import Flask
import sqlite3
import threading

app = Flask(__name__)
DB_FILE = 'clicks.db'
lock = threading.Lock()

def init_db():
    conn = sqlite3.connect(DB_FILE)
    cursor = conn.cursor()
    cursor.execute("CREATE TABLE IF NOT EXISTS click_counter (id INTEGER PRIMARY KEY, count INTEGER)")
    cursor.execute("INSERT OR IGNORE INTO click_counter (id, count) VALUES (1, 0)")
    conn.commit()
    conn.close()

@app.route('/increment')
def increment():
    with lock:
        conn = sqlite3.connect(DB_FILE)
        cursor = conn.cursor()
        cursor.execute("UPDATE click_counter SET count = count + 1 WHERE id = 1")
        conn.commit()
        cursor.execute("SELECT count FROM click_counter WHERE id = 1")
        count = cursor.fetchone()[0]
        conn.close()
    return f"{count}"

@app.route('/count')
def count():
    with lock:
        conn = sqlite3.connect(DB_FILE)
        cursor = conn.cursor()
        cursor.execute("SELECT count FROM click_counter WHERE id = 1")
        count = cursor.fetchone()[0]
        conn.close()
    return f"{count}"

if __name__ == '__main__':
    init_db()
    app.run(host='0.0.0.0', port=5001)
