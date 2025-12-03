import psycopg2
import sys

DB_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'database': 'sbir_equipment_db_v3',
    'user': 'postgres',
    'password': 'willlin07',
    'client_encoding': 'UTF8'
}

def connect_db():
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        return conn
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

def update_schema():
    conn = connect_db()
    cursor = conn.cursor()
    
    print("Updating schema for item_emu3000_maintenance_ext...")
    
    try:
        # Drop table
        cursor.execute("DROP TABLE IF EXISTS item_emu3000_maintenance_ext CASCADE")
        
        # Create table with new schema
        # ext_uuid as PK, item_uuid as FK (not unique)
        cursor.execute("""
            CREATE TABLE item_emu3000_maintenance_ext (
                ext_uuid UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                item_uuid UUID NOT NULL REFERENCES item(item_uuid) ON DELETE CASCADE,
                part VARCHAR(255),
                quantity DECIMAL(10, 4),
                unit VARCHAR(50),
                name VARCHAR(255),
                wec VARCHAR(100),
                notes TEXT,
                kit_no VARCHAR(100),
                date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                date_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """)
        
        # Add index on item_uuid for performance
        cursor.execute("CREATE INDEX idx_emu3000_item_uuid ON item_emu3000_maintenance_ext(item_uuid)")
        
        conn.commit()
        print("[OK] Schema updated successfully.")
        
    except Exception as e:
        print(f"[ERROR] Schema update failed: {e}")
        conn.rollback()
        
    conn.close()

if __name__ == '__main__':
    update_schema()
