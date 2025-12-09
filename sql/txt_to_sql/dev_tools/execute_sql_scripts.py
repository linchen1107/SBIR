#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Execute SQL scripts to import NSN database
Execute all SQL files in sequence
"""

import psycopg2
import os
import time
from pathlib import Path
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('sql_execution.log', encoding='utf-8'),
        logging.StreamHandler()
    ]
)

# Database connection configuration
DB_CONFIG = {
    'host': 'localhost',
    'port': 5433,
    'database': 'nsn_database',
    'user': 'postgres',
    'password': 'postgres'
}

class SqlExecutor:
    def __init__(self):
        self.sql_dir = Path('../data_import')  # Adjusted path, relative to sql/txt_to_sql
        self.conn = None
        self.cursor = None
        
    def connect_database(self):
        """Connect to database"""
        try:
            logging.info("🔗 Connecting to database...")
            self.conn = psycopg2.connect(**DB_CONFIG)
            self.conn.autocommit = True
            self.cursor = self.conn.cursor()
            logging.info("✅ Database connection successful")
            return True
        except Exception as e:
            logging.error(f"❌ Database connection failed: {e}")
            return False
    
    def disconnect_database(self):
        """Disconnect from database"""
        if self.cursor:
            self.cursor.close()
        if self.conn:
            self.conn.close()
        logging.info("🔌 Database connection closed")
    
    def execute_sql_file(self, file_path):
        """Execute a single SQL file"""
        logging.info(f"📄 Executing: {file_path.name}")
        start_time = time.time()
        
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                sql_content = f.read()
            
            # Remove comment lines and empty lines
            lines = [line.strip() for line in sql_content.split('\n') 
                    if line.strip() and not line.strip().startswith('--')]
            
            if not lines:
                logging.info(f"⚠️ {file_path.name} has no executable SQL statements")
                return True
            
            # Combine all lines and split by semicolon
            full_sql = ' '.join(lines)
            statements = [stmt.strip() for stmt in full_sql.split(';') if stmt.strip()]
            
            executed_count = 0
            error_count = 0
            
            for i, stmt in enumerate(statements):
                try:
                    # Skip psql specific commands
                    if stmt.startswith('\\'):
                        continue
                        
                    self.cursor.execute(stmt)
                    executed_count += 1
                    
                    # Show progress (every 100 statements)
                    if executed_count % 100 == 0:
                        logging.info(f"  ⏳ Executed {executed_count} statements...")
                        
                except Exception as e:
                    error_count += 1
                    logging.warning(f"  ⚠️ Statement {i+1} execution failed: {str(e)[:100]}...")
                    
                    # Stop if too many errors
                    if error_count > 50:
                        logging.error("❌ Too many errors, stopping execution of this file")
                        return False
            
            execution_time = time.time() - start_time
            logging.info(f"✅ Completed: {file_path.name} (executed {executed_count}, errors {error_count}, time {execution_time:.2f}s)")
            return True
            
        except Exception as e:
            logging.error(f"❌ File execution failed: {file_path.name} - {e}")
            return False
    
    def get_table_counts(self):
        """Get record counts for each table"""
        tables = [
            'fsg', 'fsc', 'nato_h6_item_name', 'inc', 'fiig',
            'mrc_key_group', 'mrc', 'reply_table', 'mode_code_edit',
            'nato_h6_inc_xref', 'inc_fsc_xref', 'fiig_inc_xref',
            'fiig_inc_mrc_xref', 'mrc_reply_table_xref', 'colloquial_inc_xref'
        ]
        
        results = {}
        total_records = 0
        
        for table in tables:
            try:
                self.cursor.execute(f"SELECT COUNT(*) FROM {table}")
                count = self.cursor.fetchone()[0]
                results[table] = count
                total_records += count
            except Exception as e:
                logging.warning(f"Unable to query table {table}: {e}")
                results[table] = 0
        
        return results, total_records
    
    def execute_all_files(self):
        """Execute all SQL files"""
        if not self.sql_dir.exists():
            logging.error(f"❌ SQL directory does not exist: {self.sql_dir}")
            return False
        
        # Execute in filename order
        sql_files = sorted([f for f in self.sql_dir.glob('*.sql') 
                           if not f.name.startswith('master')])
        
        if not sql_files:
            logging.error("❌ No SQL files found")
            return False
        
        logging.info(f"📋 Found {len(sql_files)} SQL files")
        
        success_count = 0
        total_start_time = time.time()
        
        for sql_file in sql_files:
            if self.execute_sql_file(sql_file):
                success_count += 1
            else:
                logging.error(f"❌ {sql_file.name} execution failed")
                
                # Ask whether to continue
                response = input(f"\nContinue with other files? (y/n): ").lower()
                if response != 'y':
                    break
        
        total_execution_time = time.time() - total_start_time
        
        logging.info(f"\n📊 Execution Summary:")
        logging.info(f"  Successfully executed: {success_count}/{len(sql_files)} files")
        logging.info(f"  Total time: {total_execution_time:.2f} seconds")
        
        return success_count == len(sql_files)
    
    def run_import(self):
        """Execute complete import process"""
        logging.info("🚀 Starting SQL script execution...")
        
        try:
            # 1. Connect to database
            if not self.connect_database():
                return False
            
            # 2. Check pre-import status
            logging.info("📊 Checking pre-import status...")
            before_counts, before_total = self.get_table_counts()
            logging.info(f"  Pre-import total records: {before_total}")
            
            # 3. Execute all SQL files
            success = self.execute_all_files()
            
            # 4. Check post-import status
            logging.info("\n📊 Checking post-import status...")
            after_counts, after_total = self.get_table_counts()
            
            # 5. Display detailed results
            print("\n" + "=" * 80)
            print("📋 Data Import Results")
            print("=" * 80)
            
            table_descriptions = {
                'fsg': 'FSG (Federal Supply Group)',
                'fsc': 'FSC (Federal Supply Class)',
                'nato_h6_item_name': 'NATO H6 (Item Names)',
                'inc': 'INC (Item Name Codes)',
                'fiig': 'FIIG (Federal Item Identification Guide)',
                'mrc_key_group': 'MRC Key Group',
                'mrc': 'MRC (Major Requirement Code)',
                'reply_table': 'Reply Table',
                'mode_code_edit': 'Mode Code Edit',
                'nato_h6_inc_xref': 'H6-INC Cross Reference',
                'inc_fsc_xref': 'INC-FSC Cross Reference',
                'fiig_inc_xref': 'FIIG-INC Cross Reference',
                'fiig_inc_mrc_xref': 'FIIG-INC-MRC Cross Reference',
                'mrc_reply_table_xref': 'MRC-Reply Table Cross Reference',
                'colloquial_inc_xref': 'Colloquial INC Cross Reference'
            }
            
            for table, description in table_descriptions.items():
                before = before_counts.get(table, 0)
                after = after_counts.get(table, 0)
                change = after - before
                change_str = f"(+{change})" if change > 0 else f"({change})" if change < 0 else "(no change)"
                
                print(f"{description:35} : {after:6d} records {change_str}")
            
            print("-" * 80)
            print(f"{'Total Records':35} : {after_total:6d} records (+{after_total - before_total})")
            print("=" * 80)
            
            if success:
                logging.info("✅ All SQL scripts executed successfully!")
            else:
                logging.warning("⚠️ Some SQL scripts failed to execute")
            
            return success
            
        except Exception as e:
            logging.error(f"❌ Error during execution: {e}")
            return False
        finally:
            self.disconnect_database()

def main():
    """Main program"""
    print("=" * 80)
    print("  NSN Database SQL Script Execution Tool")
    print("=" * 80)
    
    executor = SqlExecutor()
    
    # Check if SQL files exist
    if not executor.sql_dir.exists():
        print(f"❌ SQL directory does not exist: {executor.sql_dir}")
        print("💡 Please run TXT-to-SQL conversion scripts first")
        return
    
    sql_files = list(executor.sql_dir.glob('*.sql'))
    if not sql_files:
        print("❌ No SQL files found")
        print("💡 Please run TXT-to-SQL conversion scripts first")
        return
    
    print(f"📋 Found {len(sql_files)} SQL files")
    print("🚀 Starting execution...")
    
    success = executor.run_import()
    
    if success:
        print("\n🎉 Data import completed!")
    else:
        print("\n⚠️ Data import had errors, please check logs")
    
    print("\n📄 Detailed logs available in: sql_execution.log")

if __name__ == "__main__":
    main() 