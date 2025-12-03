import psycopg2
import pandas as pd

DB_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'database': 'sbir_equipment_db_v3',
    'user': 'postgres',
    'password': 'willlin07',
    'client_encoding': 'UTF8'
}

# User provided lists
user_replacement = {
    '1': 'C147356/WU', '2': 'C105792/WU', '5': 'C103769/5', '6': 'C101109/0603',
    '7': 'C103770/1', '8': 'B65582/156', '9': 'C103771', '12': 'C104766',
    '19': '469646', '21': 'B65580/71', '22': 'B33793/4', '23': 'B72511',
    '24': '453016', '31': 'B75404', '35': 'B59149/8', '37': 'B65582/102',
    '38': 'C103770/2', '39': '453052'
}

user_inspection = {
    '3': 'C103767/WU', '15': '1150430/1', '18': '470918', '27': 'A39947/9',
    '30': 'B66529/5', '33': 'C105791', '36': 'C103969'
}

def check_db():
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()
        
        print("Querying BOM for II73643/4WU...")
        sql = """
            SELECT bl.line_no, i.item_code, i.item_name_en
            FROM bom_line bl
            JOIN item i ON bl.component_item_uuid = i.item_uuid
            JOIN bom b ON bl.bom_uuid = b.bom_uuid
            JOIN item p ON b.item_uuid = p.item_uuid
            WHERE p.item_code = 'II73643/4WU'
        """
        cursor.execute(sql)
        rows = cursor.fetchall()
        
        db_data = {row[0]: row[1] for row in rows}
        
        print(f"\nFound {len(db_data)} lines in DB.")
        
        print("\n--- Verifying Replacement (定更件) ---")
        for line, code in user_replacement.items():
            # Check for exact match or suffix match
            found = False
            db_line = None
            
            # Direct lookup
            if line in db_data and db_data[line] == code:
                found = True
                db_line = line
            else:
                # Check for suffix
                for d_line, d_code in db_data.items():
                    if d_line.startswith(f"{line}_") and d_code == code:
                        found = True
                        db_line = d_line
                        break
            
            if found:
                print(f"[OK] Line {line} ({code}) -> DB: {db_line}")
            else:
                # Check if code exists under different line
                alt_line = None
                for d_line, d_code in db_data.items():
                    if d_code == code:
                        alt_line = d_line
                        break
                if alt_line:
                    print(f"[MISMATCH] Line {line} ({code}) found at DB Line {alt_line}")
                else:
                    print(f"[MISSING] Line {line} ({code}) NOT FOUND in DB")

        print("\n--- Verifying Inspection (定檢件) ---")
        for line, code in user_inspection.items():
            found = False
            db_line = None
            
            if line in db_data and db_data[line] == code:
                found = True
                db_line = line
            else:
                for d_line, d_code in db_data.items():
                    if d_line.startswith(f"{line}_") and d_code == code:
                        found = True
                        db_line = d_line
                        break
            
            if found:
                print(f"[OK] Line {line} ({code}) -> DB: {db_line}")
            else:
                alt_line = None
                for d_line, d_code in db_data.items():
                    if d_code == code:
                        alt_line = d_line
                        break
                if alt_line:
                    print(f"[MISMATCH] Line {line} ({code}) found at DB Line {alt_line}")
                else:
                    print(f"[MISSING] Line {line} ({code}) NOT FOUND in DB")
                    
        conn.close()
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    check_db()
