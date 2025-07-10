from flask import Flask, render_template, request
from datetime import datetime
import pytz
import mysql.connector

app = Flask(__name__)

# 🔐 RDS MySQL Configuration
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
        input_time_str = request.form.get('input_time')
        from_tz = request.form.get('from_timezone')
        to_tz = request.form.get('to_timezone')

        if not input_time_str or not from_tz or not to_tz:
            result = "⚠️ Missing form fields. Please fill in all values."
        else:
            try:
                # 🔄 Parse input time and convert between time zones
                input_format = "%Y-%m-%dT%H:%M"  # HTML datetime-local format
                input_time = datetime.strptime(input_time_str, input_format)

                from_zone = pytz.timezone(from_tz)
                to_zone = pytz.timezone(to_tz)

                from_time = from_zone.localize(input_time)
                to_time = from_time.astimezone(to_zone)

                result = to_time.strftime("%Y-%m-%d %H:%M %Z")

                # 🗃️ Log conversion to MySQL RDS
                try:
                    conn = mysql.connector.connect(**db_config)
                    cursor = conn.cursor()

                    insert_query = """
                    INSERT INTO conversions (input_time, input_timezone, output_time, output_timezone)
                    VALUES (%s, %s, %s, %s)
                    """
                    cursor.execute(insert_query, (
                        input_time.strftime("%Y-%m-%d %H:%M:%S"),
                        from_tz,
                        to_time.strftime("%Y-%m-%d %H:%M:%S"),
                        to_tz
                    ))

                    conn.commit()
                    cursor.close()
                    conn.close()
                except Exception as db_error:
                    print(f"[DB Error] {db_error}")

            except Exception as e:
                result = f"❌ Error: {str(e)}"

    return render_template('index.html', result=result)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
