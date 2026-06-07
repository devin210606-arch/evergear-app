import sqlite3

# Connect to your existing database file
db_name = 'evergear.db'  # ⚠️ Change this if your database has a different name!
conn = sqlite3.connect(db_name)
cursor = conn.cursor()

try:
    # Force inject the new columns
    cursor.execute("ALTER TABLE users ADD COLUMN total_rating_score FLOAT DEFAULT 0.0;")
    cursor.execute("ALTER TABLE users ADD COLUMN rating_count INTEGER DEFAULT 0;")
    print("✅ Success! New columns added to the database.")
except Exception as e:
    print("⚠️ Error (The columns might already exist):", e)

# Save and close
conn.commit()
conn.close()