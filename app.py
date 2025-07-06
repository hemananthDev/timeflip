from flask import Flask, render_template, request
from converter import convert_time

app = Flask(__name__)

@app.route("/", methods=["GET", "POST"])
def index():
    result = None
    if request.method == "POST":
        input_time = request.form["input_time"]
        from_zone = request.form["from_zone"]
        to_zone = request.form["to_zone"]

        try:
            output_time = convert_time(input_time, from_zone, to_zone)
            result = f"{input_time} ({from_zone}) → {output_time} ({to_zone})"
        except Exception as e:
            result = f"Error: {str(e)}"

    return render_template("index.html", result=result)

if __name__ == "__main__":
    print("🚀 Starting Flask on http://localhost:5000")
    app.run(debug=True, host="0.0.0.0", port=5000)
