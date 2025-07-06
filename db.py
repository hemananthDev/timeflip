import pymysql
import os

# Use environment variables or hardcoded fallback for development
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_USER = os.getenv("DB_USER", "root")
DB_PASS = os.getenv("DB_PASS", "password")
DB_NAME = os.getenv("DB_NAME", "timeflip")

def get_connection():
    return pymysql.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASS,
        database=DB_NAME,
        cursorclass=pymysql.cursors.DictCursor
    )

def init_db():
    try:
        conn = get_connection()
        with conn.cursor() as cursor:
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS conversions (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    input_time VARCHAR(10),
                    from_zone VARCHAR(50),
                    to_zone VARCHAR(50),
                    output_time VARCHAR(10),
                    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
                )
            """)
            conn.commit()
        conn.close()
        print("✅ Database table checked/created.")
    except Exception as e:
        print(f"❌ Error initializing database: {e}")
