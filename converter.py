from flask import Flask, render_template, request
from converter import convert_time
import mysql.connector

app = Flask(__name__)

db_config = {
    "host": "timeflip-db.cbqg886m8na4.ap-south-1.rds.amazonaws.com",
    "user": "admin",
    "password": "Admin12345!",
    "database": "timeflip_db"
}

@app.route('/', methods=['GET', 'POST'])
def index():
    result = None
    if request.method == 'POST':
        input_time_str = request.form['input_time']
        from_tz = request.form['from_timezone']
        to_tz = request.form['to_timezone']

        try:
            result, dt_input, dt_output = convert_time(input_time_str, from_tz, to_tz)

            # Log to RDS
            try:
                conn = mysql.connector.connect(**db_config)
                cursor = conn.cursor()
                cursor.execute("""
                    INSERT INTO conversions (input_time, input_timezone, output_time, output_timezone)
                    VALUES (%s, %s, %s, %s)
                """, (
                    dt_input.strftime("%Y-%m-%d %H:%M:%S"),
                    from_tz,
                    dt_output.strftime("%Y-%m-%d %H:%M:%S"),
                    to_tz
                ))
                conn.commit()
                cursor.close()
                conn.close()
            except Exception as db_error:
                print(f"[DB ERROR] {db_error}")

        except Exception as e:
            result = f"❌ Error: {e}"

    return render_template("index.html", result=result)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
