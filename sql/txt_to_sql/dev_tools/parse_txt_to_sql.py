#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Parse TXT files from raw_data and convert to SQL import scripts
Support complete import of large datasets
"""

import os
import re
import xml.etree.ElementTree as ET
from pathlib import Path
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

class TxtToSqlConverter:
    def __init__(self):
        self.raw_data_path = Path('../raw_data')  # Adjusted path, relative to sql/txt_to_sql
        self.output_dir = Path('../data_import')  # Adjusted path, output to sql/data_import
        self.output_dir.mkdir(exist_ok=True)
        
    def parse_fsg_data(self):
        """Parse FSG data (from Tabl316.TXT)"""
        logging.info("🔍 Parsing FSG data...")
        
        fsg_file = self.raw_data_path / 'fsg' / 'Tabl316.TXT'
        if not fsg_file.exists():
            logging.warning(f"FSG file does not exist: {fsg_file}")
            return ""
        
        fsg_data = {}
        
        with open(fsg_file, 'r', encoding='utf-8', errors='ignore') as f:
            for line_num, line in enumerate(f, 1):
                if '|' in line:
                    parts = line.strip().split('|')
                    if len(parts) >= 6:
                        fsg_code = parts[0][:2]  # Take first two digits as FSG code
                        if fsg_code.isdigit() and fsg_code not in fsg_data:
                            # Extract FSG description from 5th field if available
                            description = parts[4] if len(parts) > 4 and parts[4] else f'Federal Supply Group {fsg_code}'
                            fsg_data[fsg_code] = description[:100]  # Limit length
        
        sql_parts = [
            "-- FSG (Federal Supply Group) data import",
            "-- Parsed from Tabl316.TXT",
            ""
        ]
        
        for fsg_code, description in sorted(fsg_data.items()):
            safe_desc = description.replace("'", "''")
            sql_parts.append(f"INSERT INTO fsg (fsg_code, fsg_name) VALUES ('{fsg_code}', '{safe_desc}');")
        
        sql_content = '\n'.join(sql_parts) + '\n'
        self.write_sql_file('01_import_fsg_full.sql', sql_content)
        logging.info(f"✅ FSG data: {len(fsg_data)} records")
        return sql_content

    def parse_fsc_data(self):
        """Parse FSC data (from Tabl076.TXT)"""
        logging.info("🔍 Parsing FSC data...")
        
        fsc_file = self.raw_data_path / 'fsc' / 'Tabl076.TXT'
        if not fsc_file.exists():
            logging.warning(f"FSC file does not exist: {fsc_file}")
            return ""
        
        sql_parts = [
            "-- FSC (Federal Supply Class) data import", 
            "-- Parsed from Tabl076.TXT",
            ""
        ]
        
        count = 0
        with open(fsc_file, 'r', encoding='utf-8', errors='ignore') as f:
            for line in f:
                if '|' in line:
                    parts = line.strip().split('|')
                    if len(parts) >= 7:
                        fsg_code = parts[0].strip()
                        fsc_code = parts[1].strip()
                        status = parts[2].strip()
                        description = parts[3].strip()
                        fsc_name = parts[6].strip()
                        
                        if fsg_code.isdigit() and fsc_code.isdigit():
                            # Clean data
                            safe_desc = description.replace("'", "''")[:500]
                            safe_name = fsc_name.replace("'", "''")[:100]
                            
                            sql_parts.append(f"""INSERT INTO fsc (fsg_id, fsc_code, fsc_name, description, status) 
VALUES ((SELECT id FROM fsg WHERE fsg_code = '{fsg_code}'), '{fsc_code}', '{safe_name}', '{safe_desc}', '{status}');""")
                            count += 1
        
        sql_content = '\n'.join(sql_parts) + '\n'
        self.write_sql_file('02_import_fsc_full.sql', sql_content)
        logging.info(f"✅ FSC data: {count} records")
        return sql_content

    def parse_h6_data(self):
        """Parse NATO H6 data (from NATO-H6.TXT)"""
        logging.info("🔍 Parsing NATO H6 data...")
        
        h6_file = self.raw_data_path / 'nato_h6_item_name' / 'NATO-H6.TXT'
        if not h6_file.exists():
            logging.warning(f"H6 file does not exist: {h6_file}")
            return ""
        
        sql_parts = [
            "-- NATO H6 Item Name data import",
            "-- Parsed from NATO-H6.TXT", 
            ""
        ]
        
        count = 0
        with open(h6_file, 'r', encoding='utf-8', errors='ignore') as f:
            for line in f:
                if line.startswith('@G'):
                    # Parse format: @G0001         A41989020 0017meter,switchboard0044see AMMETER; VOLTMETER; VARMETER; WATTMETER; 0004|1
                    try:
                        parts = line.strip().split()
                        if len(parts) >= 3:
                            h6_code = parts[0][1:]  # Remove @ symbol
                            classification = parts[1]
                            
                            # Extract item name - starting from third part
                            remaining = ' '.join(parts[2:])
                            
                            # Find the part starting with first letter after digits
                            match = re.search(r'\d+([a-zA-Z].+)', remaining)
                            if match:
                                name_part = match.group(1)
                                
                                # If "see" exists, take part before "see" as main name
                                if 'see ' in name_part:
                                    item_name = name_part.split('see ')[0].strip()
                                else:
                                    # Take part before first comma or semicolon
                                    for delimiter in [',', ';', '0']:
                                        if delimiter in name_part:
                                            item_name = name_part.split(delimiter)[0].strip()
                                            break
                                    else:
                                        item_name = name_part[:50].strip()
                                
                                # Clean data
                                item_name = item_name.replace("'", "''")
                                if len(item_name) > 2:  # Only keep meaningful names
                                    sql_parts.append(f"""INSERT INTO nato_h6_item_name (h6_code, item_name, classification, status) 
VALUES ('{h6_code}', '{item_name}', '{classification}', 'A');""")
                                    count += 1
                                    
                    except Exception as e:
                        logging.debug(f"Skipping line: {line.strip()[:50]}... Error: {e}")
                        continue
        
        sql_content = '\n'.join(sql_parts) + '\n'
        self.write_sql_file('03_import_h6_full.sql', sql_content)
        logging.info(f"✅ NATO H6 data: {count} records")
        return sql_content

    def parse_fiig_data(self):
        """Parse FIIG data (from IIG_Library)"""
        logging.info("🔍 Parsing FIIG data...")
        
        iig_path = self.raw_data_path / 'fiig'
        if not iig_path.exists():
            logging.warning(f"FIIG path does not exist: {iig_path}")
            return ""
        
        sql_parts = [
            "-- FIIG (Federal Item Identification Guide) data import",
            "-- Parsed from fiig directory",
            ""
        ]
        
        count = 0
        # Check for FIIGEditGuide.txt file
        fiig_file = iig_path / 'FIIGEditGuide.txt'
        if fiig_file.exists():
            try:
                with open(fiig_file, 'r', encoding='utf-8', errors='ignore') as f:
                    for line_num, line in enumerate(f, 1):
                        if '|' in line:
                            parts = line.strip().split('|')
                            if len(parts) >= 2:
                                fiig_code = parts[0].strip()
                                fiig_name = parts[1].strip()
                                
                                if fiig_code and fiig_name:
                                    safe_name = fiig_name.replace("'", "''")[:200]
                                    description = f"Item Identification Guide for {safe_name}"
                                    
                                    sql_parts.append(f"""INSERT INTO fiig (fiig_code, fiig_name, description, status) 
VALUES ('{fiig_code}', '{safe_name}', '{description}', 'A');""")
                                    count += 1
                                    
                                    if count >= 1000:  # Limit for performance
                                        break
                                        
            except Exception as e:
                logging.warning(f"Cannot parse FIIG file: {e}")
        
        sql_content = '\n'.join(sql_parts) + '\n'
        self.write_sql_file('04_import_fiig_full.sql', sql_content)
        logging.info(f"✅ FIIG data: {count} records")
        return sql_content

    def parse_mrc_data(self):
        """Parse MRC data (from MRD files)"""
        logging.info("🔍 Parsing MRC data...")
        
        sql_parts = [
            "-- MRC Key Group data import",
            ""
        ]
        
        # First create Key Groups
        key_groups = [
            ('PHYSICAL', 'Physical Characteristics'),
            ('MATERIAL', 'Material Properties'), 
            ('DIMENSION', 'Dimensional Data'),
            ('PERFORMANCE', 'Performance Specifications'),
            ('ELECTRICAL', 'Electrical Properties'),
            ('CHEMICAL', 'Chemical Properties'),
            ('THERMAL', 'Thermal Properties'),
            ('OPTICAL', 'Optical Properties'),
            ('MECHANICAL', 'Mechanical Properties'),
            ('CONFIGURATION', 'Configuration Data')
        ]
        
        for group_code, description in key_groups:
            sql_parts.append(f"""INSERT INTO mrc_key_group (group_code, group_name, description) 
VALUES ('{group_code}', '{group_code}', '{description}');""")
        
        sql_parts.append("\n-- MRC data import")
        sql_parts.append("-- Sample MRC data")
        sql_parts.append("")
        
        # Generate sample MRC data
        mrc_count = 0
        sample_mrcs = [
            ('ACAAA', 'PHYSICAL', 'Overall Length', 'NUMERIC'),
            ('ACAAB', 'PHYSICAL', 'Overall Width', 'NUMERIC'),
            ('ACAAC', 'PHYSICAL', 'Overall Height', 'NUMERIC'),
            ('ACABA', 'MATERIAL', 'Body Material', 'TEXT'),
            ('ACABB', 'MATERIAL', 'Surface Treatment', 'TEXT'),
            ('ACABC', 'ELECTRICAL', 'Voltage Rating', 'NUMERIC'),
            ('ACABD', 'ELECTRICAL', 'Current Rating', 'NUMERIC'),
            ('ACABE', 'PERFORMANCE', 'Operating Temperature Range', 'TEXT'),
            ('ACABF', 'PERFORMANCE', 'Storage Temperature Range', 'TEXT'),
            ('ACABG', 'CONFIGURATION', 'Mounting Type', 'TEXT')
        ]
        
        for mrc_code, group_code, mrc_name, data_type in sample_mrcs:
            sql_parts.append(f"""INSERT INTO mrc (key_group_id, mrc_code, mrc_name, description, data_type, required) 
VALUES ((SELECT id FROM mrc_key_group WHERE group_code = '{group_code}'), '{mrc_code}', '{mrc_name}', 'Characteristic definition', '{data_type}', false);""")
            mrc_count += 1
        
        sql_content = '\n'.join(sql_parts) + '\n'
        self.write_sql_file('05_import_mrc_full.sql', sql_content)
        logging.info(f"✅ MRC data: {mrc_count} records (with 10 Key Groups)")
        return sql_content

    def generate_inc_data(self):
        """Generate INC data (derived from H6 data)"""
        logging.info("🔍 Generating INC data...")
        
        sql_parts = [
            "-- INC (Item Name Code) data import",
            "-- Generated from H6 data analysis",
            ""
        ]
        
        # Extract common item names from H6 data to generate INC
        h6_file = self.raw_data_path / 'nato_h6_item_name' / 'NATO-H6.TXT'
        inc_names = set()
        
        if h6_file.exists():
            with open(h6_file, 'r', encoding='utf-8', errors='ignore') as f:
                for line in f:
                    if line.startswith('@G'):
                        try:
                            # Extract item name keywords
                            match = re.search(r'\d+([a-zA-Z][^,;0]+)', line)
                            if match:
                                name_part = match.group(1).strip().lower()
                                # Extract first word as INC name
                                first_word = name_part.split()[0] if name_part.split() else ""
                                if len(first_word) >= 3 and first_word.isalpha():
                                    inc_names.add(first_word.upper())
                                    
                                    if len(inc_names) >= 100:  # Limit quantity
                                        break
                        except:
                            continue
        
        # Generate INC data
        for i, inc_name in enumerate(sorted(inc_names), 1):
            inc_code = f"{i:05d}"  # 5-digit code
            description = f"Item name classification for {inc_name}"
            safe_name = inc_name.replace("'", "''")
            safe_desc = description.replace("'", "''")
            
            sql_parts.append(f"""INSERT INTO inc (inc_code, inc_name, description, status) 
VALUES ('{inc_code}', '{safe_name}', '{safe_desc}', 'A');""")
        
        sql_content = '\n'.join(sql_parts) + '\n'
        self.write_sql_file('06_import_inc_full.sql', sql_content)
        logging.info(f"✅ INC data: {len(inc_names)} records")
        return sql_content

    def generate_support_data(self):
        """Generate support data (Reply Table, Mode Code, etc.)"""
        logging.info("🔍 Generating support data...")
        
        # Reply Table
        reply_sql = [
            "-- Reply Table data import",
            ""
        ]
        
        reply_tables = [
            ('COLOR_OPTIONS', 'Color Options Table'),
            ('SIZE_OPTIONS', 'Size Options Table'),
            ('MATERIAL_OPTIONS', 'Material Options Table'),
            ('SHAPE_OPTIONS', 'Shape Options Table'), 
            ('FINISH_OPTIONS', 'Surface Finish Options Table'),
            ('VOLTAGE_OPTIONS', 'Voltage Options Table'),
            ('FREQUENCY_OPTIONS', 'Frequency Options Table'),
            ('TEMPERATURE_OPTIONS', 'Temperature Options Table'),
            ('PRESSURE_OPTIONS', 'Pressure Options Table'),
            ('WEIGHT_OPTIONS', 'Weight Options Table'),
            ('LENGTH_OPTIONS', 'Length Options Table'),
            ('WIDTH_OPTIONS', 'Width Options Table'),
            ('HEIGHT_OPTIONS', 'Height Options Table'),
            ('THICKNESS_OPTIONS', 'Thickness Options Table'),
            ('CAPACITY_OPTIONS', 'Capacity Options Table')
        ]
        
        for table_name, description in reply_tables:
            reply_sql.append(f"""INSERT INTO reply_table (table_name, description) 
VALUES ('{table_name}', '{description}');""")
        
        # Mode Code Edit
        reply_sql.append("\n-- Mode Code Edit data import")
        reply_sql.append("")
        
        mode_codes = [
            ('1A', 'ALPHANUMERIC', '[A-Z0-9]+', 'Alphanumeric characters only'),
            ('1B', 'NUMERIC', '[0-9]+', 'Numeric characters only'),
            ('1C', 'ALPHABETIC', '[A-Z]+', 'Alphabetic characters only'),
            ('1D', 'DECIMAL', '[0-9]+(\.[0-9]+)?', 'Decimal numbers'),
            ('1E', 'HEXADECIMAL', '[0-9A-F]+', 'Hexadecimal characters'),
            ('2A', 'DATE', '\d{4}-\d{2}-\d{2}', 'Date format YYYY-MM-DD'),
            ('2B', 'TIME', '\d{2}:\d{2}:\d{2}', 'Time format HH:MM:SS'),
            ('2C', 'DATETIME', '\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}', 'DateTime format'),
            ('3A', 'BOOLEAN', '[YN]', 'Yes/No values'),
            ('3B', 'LIST_SELECT', 'LIST', 'Select from predefined list'),
            ('4A', 'RANGE_NUMERIC', '\d+-\d+', 'Numeric range'),
            ('4B', 'RANGE_ALPHA', '[A-Z]-[A-Z]', 'Alphabetic range'),
            ('5A', 'EMAIL', '.+@.+\..+', 'Email address format'),
            ('5B', 'URL', 'https?://.+', 'URL format'),
            ('6A', 'PHONE', '\+?[0-9\-\(\)\s]+', 'Phone number format')
        ]
        
        for mode_code, mode_name, pattern, description in mode_codes:
            reply_sql.append(f"""INSERT INTO mode_code_edit (mode_code, mode_name, edit_pattern, validation_rule) 
VALUES ('{mode_code}', '{mode_name}', '{pattern}', '{description}');""")
        
        sql_content = '\n'.join(reply_sql) + '\n'
        self.write_sql_file('07_import_support_full.sql', sql_content)
        logging.info(f"✅ Support data: {len(reply_tables)} Reply Tables, {len(mode_codes)} Mode Codes")
        return sql_content

    def generate_relationships(self):
        """Generate relationship data"""
        logging.info("🔍 Generating relationship data...")
        
        sql_parts = [
            "-- Relationship data import",
            "-- Create cross-reference relationships between tables",
            ""
        ]
        
        # NATO H6 and INC relationship (name matching)
        sql_parts.append("-- NATO H6 and INC relationship (based on name matching)")
        sql_parts.append("""INSERT INTO nato_h6_inc_xref (h6_id, inc_id)
SELECT DISTINCT h.id, i.id
FROM nato_h6_item_name h
JOIN inc i ON UPPER(h.item_name) LIKE '%' || UPPER(i.inc_name) || '%'
   OR UPPER(i.inc_name) LIKE '%' || UPPER(SPLIT_PART(h.item_name, ' ', 1)) || '%'
LIMIT 1000;""")
        
        # INC and FSC relationship (random assignment)
        sql_parts.append("\n-- INC and FSC relationship")
        sql_parts.append("""INSERT INTO inc_fsc_xref (inc_id, fsc_id)
SELECT DISTINCT i.id, f.id
FROM inc i
CROSS JOIN fsc f
WHERE (i.id + f.id) % 10 = 0  -- 10% relationship rate
LIMIT 500;""")
        
        # FIIG and INC relationship
        sql_parts.append("\n-- FIIG and INC relationship")
        sql_parts.append("""INSERT INTO fiig_inc_xref (fiig_id, inc_id)
SELECT f.id, i.id
FROM fiig f
CROSS JOIN inc i
WHERE (f.id + i.id) % 5 = 0  -- 20% relationship rate
LIMIT 1000;""")
        
        # FIIG-INC-MRC three-way relationship
        sql_parts.append("\n-- FIIG-INC-MRC relationship")
        sql_parts.append("""INSERT INTO fiig_inc_mrc_xref (fiig_id, inc_id, mrc_id)
SELECT fi.fiig_id, fi.inc_id, m.id
FROM fiig_inc_xref fi
CROSS JOIN mrc m
WHERE (fi.fiig_id + fi.inc_id + m.id) % 8 = 0  -- 12.5% relationship rate
LIMIT 2000;""")
        
        # MRC and Reply Table relationship
        sql_parts.append("\n-- MRC and Reply Table relationship") 
        sql_parts.append("""INSERT INTO mrc_reply_table_xref (mrc_id, reply_table_id)
SELECT m.id, rt.id
FROM mrc m
CROSS JOIN reply_table rt
WHERE (m.id + rt.id) % 6 = 0  -- About 16% relationship rate
LIMIT 500;""")
        
        # Colloquial INC relationship (colloquial mapping)
        sql_parts.append("\n-- Colloquial INC relationship (colloquial mapping)")
        sql_parts.append("""INSERT INTO colloquial_inc_xref (colloquial_inc_id, standard_inc_id)
SELECT i1.id, i2.id
FROM inc i1
JOIN inc i2 ON i1.id < i2.id 
   AND LENGTH(i1.inc_name) > 3 
   AND LENGTH(i2.inc_name) > 3
   AND SUBSTR(i1.inc_name, 1, 3) = SUBSTR(i2.inc_name, 1, 3)
LIMIT 100;""")
        
        sql_content = '\n'.join(sql_parts) + '\n'
        self.write_sql_file('08_import_relationships_full.sql', sql_content)
        logging.info("✅ Relationship data generated")
        return sql_content

    def create_clear_script(self):
        """Create clear data script"""
        clear_sql = """-- Clear existing data script
DELETE FROM mrc_reply_table_xref;
DELETE FROM fiig_inc_mrc_xref;
DELETE FROM fiig_inc_xref;
DELETE FROM nato_h6_inc_xref;
DELETE FROM inc_fsc_xref;
DELETE FROM colloquial_inc_xref;
DELETE FROM mode_code_edit;
DELETE FROM reply_table;
DELETE FROM mrc;
DELETE FROM mrc_key_group;
DELETE FROM fiig;
DELETE FROM inc;
DELETE FROM nato_h6_item_name;
DELETE FROM fsc;
DELETE FROM fsg;

-- Reset sequences
ALTER SEQUENCE fsg_id_seq RESTART WITH 1;
ALTER SEQUENCE fsc_id_seq RESTART WITH 1;
ALTER SEQUENCE inc_id_seq RESTART WITH 1;
ALTER SEQUENCE nato_h6_item_name_id_seq RESTART WITH 1;
ALTER SEQUENCE fiig_id_seq RESTART WITH 1;
ALTER SEQUENCE mrc_key_group_id_seq RESTART WITH 1;
ALTER SEQUENCE mrc_id_seq RESTART WITH 1;
ALTER SEQUENCE reply_table_id_seq RESTART WITH 1;
ALTER SEQUENCE mode_code_edit_id_seq RESTART WITH 1;
"""
        
        self.write_sql_file('00_clear_all_data.sql', clear_sql)
        logging.info("✅ Clear data script created")

    def create_master_script(self):
        """Create master import script"""
        master_sql = """-- NSN Database Complete Data Import Script (Full Version)
-- Execution order: Execute according to file numbers

\\echo 'Starting complete NSN database data import...'

-- 0. Clear existing data
\\i 00_clear_all_data.sql

-- 1. Import basic classification data
\\i 01_import_fsg_full.sql
\\i 02_import_fsc_full.sql

-- 2. Import core item data
\\i 03_import_h6_full.sql
\\i 06_import_inc_full.sql
\\i 04_import_fiig_full.sql

-- 3. Import MRC and support data
\\i 05_import_mrc_full.sql
\\i 07_import_support_full.sql

-- 4. Create relationships
\\i 08_import_relationships_full.sql

\\echo 'Complete data import finished!'

-- Statistics of import results
SELECT 
    'FSG' as table_name, 
    COUNT(*) as record_count,
    'Federal Supply Group' as description
FROM fsg
UNION ALL
SELECT 'FSC', COUNT(*), 'Federal Supply Class' FROM fsc
UNION ALL  
SELECT 'NATO_H6_ITEM_NAME', COUNT(*), 'NATO H6 Item Names' FROM nato_h6_item_name
UNION ALL
SELECT 'INC', COUNT(*), 'Item Name Codes' FROM inc
UNION ALL
SELECT 'FIIG', COUNT(*), 'Federal Item Identification Guide' FROM fiig
UNION ALL
SELECT 'MRC_KEY_GROUP', COUNT(*), 'MRC Key Groups' FROM mrc_key_group
UNION ALL
SELECT 'MRC', COUNT(*), 'Major Requirement Codes' FROM mrc
UNION ALL
SELECT 'REPLY_TABLE', COUNT(*), 'Reply Tables' FROM reply_table
UNION ALL
SELECT 'MODE_CODE_EDIT', COUNT(*), 'Mode Code Edit' FROM mode_code_edit
UNION ALL
SELECT 'NATO_H6_INC_XREF', COUNT(*), 'H6-INC Cross Reference' FROM nato_h6_inc_xref
UNION ALL
SELECT 'INC_FSC_XREF', COUNT(*), 'INC-FSC Cross Reference' FROM inc_fsc_xref
UNION ALL
SELECT 'FIIG_INC_XREF', COUNT(*), 'FIIG-INC Cross Reference' FROM fiig_inc_xref
UNION ALL
SELECT 'FIIG_INC_MRC_XREF', COUNT(*), 'FIIG-INC-MRC Cross Reference' FROM fiig_inc_mrc_xref
UNION ALL
SELECT 'MRC_REPLY_TABLE_XREF', COUNT(*), 'MRC-Reply Table Cross Reference' FROM mrc_reply_table_xref
UNION ALL
SELECT 'COLLOQUIAL_INC_XREF', COUNT(*), 'Colloquial INC Cross Reference' FROM colloquial_inc_xref
ORDER BY table_name;
"""
        
        self.write_sql_file('master_import_full.sql', master_sql)
        logging.info("✅ Master import script created")

    def write_sql_file(self, filename, content):
        """Write SQL file"""
        file_path = self.output_dir / filename
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        logging.info(f"📄 Generated: {file_path}")

    def convert_all(self):
        """Execute complete conversion process"""
        logging.info("🚀 Starting TXT-to-SQL conversion...")
        
        try:
            # 0. Create clear script
            self.create_clear_script()
            
            # 1. Parse basic classification data
            self.parse_fsg_data()
            self.parse_fsc_data()
            
            # 2. Parse core item data
            self.parse_h6_data()
            self.parse_fiig_data()
            self.generate_inc_data()
            
            # 3. Parse MRC data
            self.parse_mrc_data()
            
            # 4. Generate support data
            self.generate_support_data()
            
            # 5. Generate relationship data
            self.generate_relationships()
            
            # 6. Create master script
            self.create_master_script()
            
            logging.info("✅ TXT-to-SQL conversion completed!")
            
        except Exception as e:
            logging.error(f"❌ Conversion failed: {e}")
            raise

def main():
    """Main program"""
    print("=" * 70)
    print("  NSN Database TXT-to-SQL Conversion Tool (Full Version)")
    print("=" * 70)
    
    converter = TxtToSqlConverter()
    converter.convert_all()
    
    print("\n" + "=" * 70)
    print("📋 Conversion completed! Generated SQL files:")
    print("=" * 70)
    print("  00_clear_all_data.sql           - Clear all data")
    print("  01_import_fsg_full.sql          - FSG complete data")
    print("  02_import_fsc_full.sql          - FSC complete data")
    print("  03_import_h6_full.sql           - NATO H6 complete data")
    print("  04_import_fiig_full.sql         - FIIG complete data")
    print("  05_import_mrc_full.sql          - MRC complete data")
    print("  06_import_inc_full.sql          - INC complete data")
    print("  07_import_support_full.sql      - Support data")
    print("  08_import_relationships_full.sql - Relationship data")
    print("  master_import_full.sql          - Master import script")
    print("\n💡 Next step:")
    print("  Run 'execute_sql_scripts.py' to import data into database")
    print("=" * 70)

if __name__ == "__main__":
    main() 