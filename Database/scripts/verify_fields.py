import re

def parse_sql_comments(sql_path):
    """Parses SQL file to extract table and column comments."""
    schema = {}
    current_table = None
    
    with open(sql_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        
    for line in lines:
        # Match table comments: COMMENT ON TABLE public.tablename IS 'comment';
        table_match = re.search(r"COMMENT ON TABLE public\.(\w+) IS '([^']+)';", line)
        if table_match:
            table_name = table_match.group(1)
            comment = table_match.group(2)
            if table_name not in schema:
                schema[table_name] = {'comment': comment, 'columns': {}}
            else:
                schema[table_name]['comment'] = comment
                
        # Match column comments: COMMENT ON COLUMN public.tablename.colname IS 'comment';
        col_match = re.search(r"COMMENT ON COLUMN public\.(\w+)\.(\w+) IS '([^']+)';", line)
        if col_match:
            table_name = col_match.group(1)
            col_name = col_match.group(2)
            comment = col_match.group(3)
            
            if table_name not in schema:
                schema[table_name] = {'comment': '', 'columns': {}}
            
            schema[table_name]['columns'][col_name] = comment
            
    return schema

def parse_markdown_fields(md_path):
    """Parses the markdown file to extract field lists for each form."""
    forms = {}
    
    with open(md_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        
    for line in lines:
        if '|' in line:
            parts = line.split('|')
            if len(parts) >= 2:
                form_name = parts[0].strip()
                fields_str = parts[1].strip()
                
                # Split fields by whitespace, handling quotes
                # Simple split might break on spaces inside quotes, but let's try simple first
                # The file seems to use spaces as separators, and quotes for names with spaces?
                # E.g. "適用裝備 名稱"
                
                # Regex to find fields: either quoted string or non-whitespace sequence
                fields = re.findall(r'"([^"]+)"|(\S+)', fields_str)
                # Flatten and clean
                clean_fields = []
                for f in fields:
                    val = f[0] if f[0] else f[1]
                    # Remove leading * (required marker)
                    val = val.lstrip('*')
                    clean_fields.append(val)
                
                forms[form_name] = clean_fields
                
    return forms

def compare_schema(schema, forms):
    """Compares schema comments with form fields."""
    report = []
    
    # Define mappings: Table -> Form(s)
    mappings = {
        'item': ['19M'],
        'equipment': ['3M'], # 16M is characteristics, maybe separate table or json?
        'supplier': ['廠商主檔'], # Not a form in MD, but referenced
        'part_number_xref': ['20M'],
        'technicaldocument': ['書籍檔'],
        'applicationform': ['無料號'], # Maybe?
    }
    
    # Reverse mapping for field lookup
    # We want to check if the SQL comment exists in the Form's field list
    
    for table, form_names in mappings.items():
        if table not in schema:
            continue
            
        table_cols = schema[table]['columns']
        
        for form_name in form_names:
            if form_name not in forms:
                continue
                
            expected_fields = forms[form_name]
            
            # Check each column in the table
            for col, comment in table_cols.items():
                # Normalize comment (remove parentheses, etc. for fuzzy match if needed)
                # For now, exact match or containment
                
                match_found = False
                for field in expected_fields:
                    if field == comment:
                        match_found = True
                        break
                    # Try fuzzy: comment contains field or field contains comment
                    if field in comment or comment in field:
                        # Check for "English" vs "Chinese" distinction
                        if "英文" in field and "英文" not in comment:
                            continue
                        if "中文" in field and "中文" not in comment:
                            continue
                        match_found = True
                        break
                
                status = "Match" if match_found else "Mismatch/Missing in Excel"
                # report.append((table, col, comment, status, form_name))
                
    # Let's do a different check:
    # For each table, list its columns and comments, and try to find the best match in the mapped form.
    
    results = []
    
    for table, form_list in mappings.items():
        if table not in schema:
            results.append(f"Table {table} not found in SQL.")
            continue
            
        results.append(f"## Table: {table} (Mapped to: {', '.join(form_list)})")
        results.append("| Column | SQL Comment | Best Match in Excel | Status |")
        results.append("|---|---|---|---|")
        
        form_fields = []
        for f in form_list:
            if f in forms:
                form_fields.extend(forms[f])
        
        for col, comment in schema[table]['columns'].items():
            best_match = ""
            status = "❌ Mismatch"
            
            # Exact match
            if comment in form_fields:
                best_match = comment
                status = "✅ Match"
            else:
                # Fuzzy match
                candidates = []
                for f in form_fields:
                    # Calculate similarity or just containment
                    if f == comment:
                        candidates.append(f)
                    elif f in comment or comment in f:
                         # Avoid matching "品名" to "英文品名" if comment is "中文品名"
                        if "英文" in f and "英文" not in comment: continue
                        if "中文" in f and "中文" not in comment: continue
                        if "英文" in comment and "英文" not in f: continue
                        if "中文" in comment and "中文" not in f: continue
                        candidates.append(f)
                
                if candidates:
                    best_match = ", ".join(candidates)
                    status = "⚠️ Partial/Fuzzy"
            
            results.append(f"| {col} | {comment} | {best_match} | {status} |")
            
        results.append("")
        
    return "\n".join(results)

if __name__ == "__main__":
    sql_path = r"c:\github\SBIR\Database\backup_sbir_equipment_db_20251119.sql"
    md_path = r"c:\github\SBIR\Database\docs\database_欄位.md"
    
    schema = parse_sql_comments(sql_path)
    forms = parse_markdown_fields(md_path)
    
    report = compare_schema(schema, forms)
    
    # Write report to file
    try:
        with open(r"c:\github\SBIR\Database\scripts\verification_report.md", "w", encoding="utf-8") as f:
            f.write(report)
        print("Report generated at c:\\github\\SBIR\\Database\\scripts\\verification_report.md")
    except Exception as e:
        print(f"Error writing report: {e}")
        # Fallback to printing safe characters
        print(report.encode('cp950', errors='replace').decode('cp950'))
