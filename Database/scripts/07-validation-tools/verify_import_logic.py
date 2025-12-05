import pandas as pd
import os
import sys
import uuid

# Mock DB Cursor
class MockCursor:
    def __init__(self):
        self.items = {} # code -> uuid
        self.boms = {} # item_uuid -> bom_uuid
        self.bom_lines = [] # (bom_uuid, line_no, component_uuid)
        
    def execute(self, sql, params=None):
        sql = sql.strip().lower()
        if "select item_uuid from item" in sql:
            code = params[0]
            if code in self.items:
                self.fetchone_result = (self.items[code],)
            else:
                self.fetchone_result = None
        elif "insert into item" in sql:
            # params: uuid, code, ...
            self.items[params[1]] = params[0]
            print(f"[MockDB] Insert Item: {params[1]} ({params[0]})")
            
        elif "select bom_uuid from bom" in sql:
            item_uuid = params[0]
            if item_uuid in self.boms:
                self.fetchone_result = (self.boms[item_uuid],)
            else:
                self.fetchone_result = None
        elif "insert into bom" in sql:
            # params: bom_uuid, item_uuid, code
            self.boms[params[1]] = params[0]
            print(f"[MockDB] Insert BOM: {params[2]} for Item {params[1]}")
            
        elif "select line_uuid from bom_line" in sql:
            # Check if exists
            bom_uuid = params[0]
            comp_uuid = params[1]
            # We don't really track line_uuid in mock for select, just return None to simulate "New"
            # or we could track. For this test, we assume clean state or just always insert/update
            self.fetchone_result = None 
            
        elif "select line_no, component_item_uuid from bom_line" in sql:
            # Return existing lines for this BOM
            bom_uuid = params[0]
            res = []
            for b, l, c in self.bom_lines:
                if b == bom_uuid:
                    res.append((l, c))
            self.fetchall_result = res
            
        elif "insert into bom_line" in sql:
            # params: line_uuid, bom_uuid, line_no, component_item_uuid, ...
            self.bom_lines.append((params[1], params[2], params[3]))
            print(f"[MockDB] Insert BOM Line: No={params[2]}, Comp={params[3]}")
            
        elif "update bom_line" in sql:
            print(f"[MockDB] Update BOM Line: No={params[1]}")

    def fetchone(self):
        return getattr(self, 'fetchone_result', None)
        
    def fetchall(self):
        return getattr(self, 'fetchall_result', [])
        
    def close(self):
        pass

class MockConn:
    def cursor(self):
        return MockCursor()
    def commit(self):
        print("[MockDB] Commit")
    def close(self):
        pass
    def rollback(self):
        print("[MockDB] Rollback")

# Helper functions copied/adapted from script
def clean_value(val):
    if pd.isna(val): return None
    s_val = str(val).strip()
    if s_val.lower() in ['nan', 'null', '', 'none']: return None
    return s_val

def get_or_create_item(cursor, item_code, item_name_zh, item_name_en, item_type, uom=None):
    cursor.execute("SELECT item_uuid FROM item WHERE item_code = %s", (item_code,))
    result = cursor.fetchone()
    if result: return result[0]
    item_uuid = str(uuid.uuid4())
    cursor.execute("INSERT INTO item ...", (item_uuid, item_code))
    return item_uuid

def create_bom_header(cursor, item_uuid, bom_code):
    cursor.execute("SELECT bom_uuid FROM bom WHERE item_uuid = %s", (item_uuid,))
    result = cursor.fetchone()
    if result: return result[0]
    bom_uuid = str(uuid.uuid4())
    cursor.execute("INSERT INTO bom ...", (bom_uuid, item_uuid, bom_code))
    return bom_uuid

def add_bom_line(cursor, bom_uuid, component_item_uuid, qty, line_no, uom):
    cursor.execute("SELECT line_uuid FROM bom_line ...", (bom_uuid, component_item_uuid))
    if cursor.fetchone():
        cursor.execute("UPDATE bom_line ...", (qty, line_no, uom, bom_uuid, component_item_uuid))
    else:
        line_uuid = str(uuid.uuid4())
        cursor.execute("INSERT INTO bom_line ...", (line_uuid, bom_uuid, line_no, component_item_uuid))

def insert_extension_data(cursor, item_uuid, row):
    pass

# Import the logic function
# We will paste the `process_sheet` and `process_excel` logic here or import if possible.
# Since we can't easily import the modified script without running it (and it has main()), 
# I will duplicate the `process_sheet` and `process_excel` logic here for the test.
# This ensures we test the *logic* we just wrote.

def process_sheet(cursor, df, sheet_name, current_assembly_uuid, current_bom_uuid, existing_lines):
    print(f"    Processing Sheet: {sheet_name}")
    df.columns = df.columns.str.strip()
    required_cols = ['Item number', 'Name', 'Quantity']
    missing_cols = [col for col in required_cols if col not in df.columns]
    if missing_cols:
        print(f"      [SKIP] Missing required columns in {sheet_name}: {missing_cols}")
        return

    for index, row in df.iterrows():
        part_raw = row.get('Part')
        item_code_raw = row.get('Item number')
        name_raw = row.get('Name')
        unit_raw = row.get('Unit')
        item_code = clean_value(item_code_raw)
        name = clean_value(name_raw) or ""
        unit = clean_value(unit_raw)
        
        if not item_code: continue

        is_assembly = False
        part_val = clean_value(part_raw)
        if part_val is None: is_assembly = True
        
        name_en = name
        name_zh = name
        item_uuid = None
        
        if is_assembly:
            if current_assembly_uuid: pass
            else:
                print(f"      [Assembly] {item_code} - {name}")
                item_uuid = get_or_create_item(cursor, item_code, name_zh, name_en, 'FG', unit)
        else:
            if not current_bom_uuid:
                print(f"      [WARN] Component found but no BOM Header active. Skipping {item_code}")
                continue
                
            line_no_base = str(part_val).strip()
            if line_no_base.endswith('.0'): line_no_base = line_no_base[:-2]
            
            item_uuid = get_or_create_item(cursor, item_code, name_zh, name_en, 'SEMI', unit)

            final_line_no = line_no_base
            
            def is_conflict(check_line_no):
                if check_line_no in existing_lines:
                    if existing_lines[check_line_no] == item_uuid: return False
                    else: return True
                return False

            if is_conflict(final_line_no):
                sheet_suffix = f"_{sheet_name}"
                candidate = f"{line_no_base}{sheet_suffix}"
                if is_conflict(candidate):
                    count = 1
                    while True:
                        candidate_cnt = f"{line_no_base}{sheet_suffix}_{count}"
                        if not is_conflict(candidate_cnt):
                            final_line_no = candidate_cnt
                            break
                        count += 1
                else:
                    final_line_no = candidate
            
            existing_lines[final_line_no] = item_uuid
            
            qty = 1.0
            try: qty = float(row.get('Quantity'))
            except: pass
            
            add_bom_line(cursor, current_bom_uuid, item_uuid, qty, final_line_no, unit)

def process_excel(file_path, conn):
    print(f"Processing file: {os.path.basename(file_path)}")
    try:
        xl = pd.ExcelFile(file_path)
    except Exception as e:
        print(f"[ERROR] Cannot read Excel: {e}")
        return

    cursor = conn.cursor()
    current_assembly_uuid = None
    current_bom_uuid = None
    existing_lines = {} 

    try:
        first_sheet = xl.sheet_names[0]
        df_temp = pd.read_excel(file_path, sheet_name=first_sheet, header=None, nrows=20)
        header_row_idx = 0
        found_header = False
        for idx, row in df_temp.iterrows():
            row_values = [str(x).strip() for x in row.values if pd.notna(x)]
            if any('Item number' in val for val in row_values) and any('Name' in val for val in row_values):
                header_row_idx = idx
                found_header = True
                break
        
        if found_header:
            df_first = pd.read_excel(file_path, sheet_name=first_sheet, header=header_row_idx)
            df_first.columns = df_first.columns.str.strip()
            for index, row in df_first.iterrows():
                part_val = clean_value(row.get('Part'))
                if part_val is None:
                    item_code = clean_value(row.get('Item number'))
                    name = clean_value(row.get('Name'))
                    unit = clean_value(row.get('Unit'))
                    if item_code:
                        print(f"  [Assembly] {item_code} - {name}")
                        item_uuid = get_or_create_item(cursor, item_code, name, name, 'FG', unit)
                        current_assembly_uuid = item_uuid
                        current_bom_uuid = create_bom_header(cursor, current_assembly_uuid, f"BOM-{item_code}")
                        cursor.execute("SELECT line_no, component_item_uuid FROM bom_line WHERE bom_uuid = %s", (current_bom_uuid,))
                        existing_lines = {row[0]: row[1] for row in cursor.fetchall()}
                        break
    except Exception as e:
        print(f"  [ERROR] Error initializing BOM from first sheet: {e}")
        return

    for sheet_name in xl.sheet_names:
        try:
            df_temp = pd.read_excel(file_path, sheet_name=sheet_name, header=None, nrows=20)
            header_idx = 0
            found = False
            for idx, row in df_temp.iterrows():
                row_values = [str(x).strip() for x in row.values if pd.notna(x)]
                if any('Item number' in val for val in row_values) and any('Name' in val for val in row_values):
                    header_idx = idx
                    found = True
                    break
            
            if found:
                df = pd.read_excel(file_path, sheet_name=sheet_name, header=header_idx)
                process_sheet(cursor, df, sheet_name, current_assembly_uuid, current_bom_uuid, existing_lines)
        except Exception as e:
            print(f"  [ERROR] Failed to process sheet {sheet_name}: {e}")

    conn.commit()

# Run Test
if __name__ == "__main__":
    file_path = r'c:\github\SBIR\Database\data\EMU3000\EMU 3000 維修物料清單\5年維護\01 清潔塊單元--C20、C21--OK\清潔塊單元C20、C21大修料件清單--60個月.xlsx'
    conn = MockConn()
    process_excel(file_path, conn)
