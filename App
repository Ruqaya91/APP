from flask import Flask, request, render_template_string
import sqlite3

app = Flask(__name__)

# Set up database
def init_db():
    conn = sqlite3.connect("users.db")
    cursor = conn.cursor()
    cursor.execute("CREATE TABLE IF NOT EXISTS users (username TEXT, password TEXT)")
    cursor.execute("INSERT INTO users VALUES ('admin', 'admin123')")
    conn.commit()
    conn.close()

@app.route('/')
def home():
    return '''
        <h2>Login</h2>
        <form method="POST" action="/login">
            Username: <input name="username"><br>
            Password: <input name="password"><br>
            <input type="submit" value="Login">
        </form>
        <br>
        <h2>Search</h2>
        <form method="GET" action="/search">
            Query: <input name="q">
            <input type="submit" value="Search">
        </form>
    '''

@app.route('/login', methods=['POST'])
def login():
    username = request.form['username']
    password = request.form['password']
    query = f"SELECT * FROM users WHERE username = '{username}' AND password = '{password}'"
    print("DEBUG QUERY:", query)  # <-- Add this line to see what is being executed

    conn = sqlite3.connect("users.db")
    cursor = conn.cursor()
    cursor.execute(query)
    result = cursor.fetchone()
    conn.close()

    if result:
        return f"<h2>Welcome, {username}!</h2>"
    else:
        return "<h2>Invalid credentials</h2>"

@app.route('/search')
def search():
    q = request.args.get('q', '')
    return render_template_string(f"<p>You searched for: {q}</p>")  # XSS vulnerable

if __name__ == "__main__":
    init_db()
    app.run(debug=True)
