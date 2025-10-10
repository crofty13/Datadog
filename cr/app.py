from flask import Flask, request
from markupsafe import escape

app = Flask(__name__)

@app.route("/", methods=["GET", "POST"])
def index():
    if request.method == "POST":
        name = request.form.get("name", "")
        city = request.form.get("city", "")

        return f"""
            <h1>Hello, {escape(name)} from {escape(city)}!</h1>
            <p><a href="/">Go back</a></p>
        """


def goodbye():
    if request.method == "GET":
        
        return f"""
            <h1>Goodbye!</h1>
            <p><a href="/">Go back</a></p>
        """




    # ... your GET handler or template rendering here ...
if __name__ == "__main__":
    import os
    app.run(debug=os.getenv('FLASK_DEBUG', 'False').lower() == 'true')
