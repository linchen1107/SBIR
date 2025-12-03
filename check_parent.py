import psycopg2

DB_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'database': 'sbir_equipment_db_v3',
    'user': 'postgres',
    'password': 'willlin07',
    'client_encoding': 'UTF8'
}

def check_parent():
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()
        
        print("Checking parent for C96271/1...")
        sql = """
            SELECT child.item_code, parent.item_code, parent.item_name_zh
            FROM bom_line bl
            JOIN item child ON bl.component_item_uuid = child.item_uuid
            JOIN bom b ON bl.bom_uuid = b.bom_uuid
            JOIN item parent ON b.item_uuid = parent.item_uuid
            WHERE child.item_code = 'C96271/1'
        """
        cursor.execute(sql)
        rows = cursor.fetchall()
        
        if rows:
            for row in rows:
                print(f"Child: {row[0]} -> Parent: {row[1]} ({row[2]})")
        else:
            print("C96271/1 not found in any BOM.")
            
        print("\nChecking parent for C99474/1...")
        cursor.execute(sql.replace('C96271/1', 'C99474/1'))
        rows = cursor.fetchall()
        if rows:
            for row in rows:
                print(f"Child: {row[0]} -> Parent: {row[1]} ({row[2]})")
        else:
            print("C99474/1 not found in any BOM.")

        conn.close()
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    check_parent()
