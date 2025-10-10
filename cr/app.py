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

    # ... your GET handler or template rendering here ...

    return '''
        <h1>Welcome!</h1>
        <form method="POST">
            Name: <input type="text" name="name"><br>
            City: <input type="text" name="city"><br>
            <input type="submit" value="Submit">
        </form>
    '''

if __name__ == "__main__":
    import os
    app.run(debug=os.getenv('FLASK_DEBUG', 'False').lower() == 'true')
