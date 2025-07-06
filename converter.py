from datetime import datetime
import pytz

def convert_time(input_time, from_zone, to_zone):
    try:
        input_time = input_time.strip().replace(" ", "")
        dt = datetime.strptime(input_time, "%H:%M")

        from_tz = pytz.timezone(from_zone)
        to_tz = pytz.timezone(to_zone)

        dt_with_tz = from_tz.localize(dt)
        converted = dt_with_tz.astimezone(to_tz)

        return converted.strftime("%H:%M")
    except Exception as e:
        raise ValueError(f"Invalid input: {e}")
