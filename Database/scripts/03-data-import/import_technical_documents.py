#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
从 Excel 文件的"書籍檔建置"工作表导入技术文件到 TechnicalDocument 表

数据库: sbir_equipment_db_v3
表: TechnicalDocument

用法:
    python import_technical_documents.py [--clear] [--yes]

参数:
    --clear: 导入前清空表
    --yes: 自动确认，不提示
"""

import pandas as pd
import psycopg2
from psycopg2.extras import execute_values
import sys
import argparse
from pathlib import Path
import io

# Set UTF-8 encoding for stdout on Windows
if sys.platform == 'win32':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

# 数据库连接配置
DB_CONFIG = {
    'dbname': 'sbir_equipment_db_v3',
    'user': 'postgres',
    'password': 'willlin07',
    'host': 'localhost',
    'port': '5432'
}

# Excel 文件路径
EXCEL_FILE = r'c:/github/SBIR/Database/data/海軍/總表-範例/廚房滅火系統ILS及APL_版4.1.xlsx'
SHEET_NAME = '書籍檔建置'


def read_excel_data():
    """读取 Excel 文件中的书籍档数据"""
    print(f"正在读取文件: {EXCEL_FILE}")
    print(f"工作表: {SHEET_NAME}")

    # 读取数据，使用第3行作为表头（索引2，第0行是中文说明，第1行是代码，第2行是英文列名）
    df = pd.read_excel(EXCEL_FILE, sheet_name=SHEET_NAME, header=2)

    print(f"总行数: {len(df)}")

    # 过滤有效数据（书名不为空且不为0）
    valid_df = df[df['BLUEPRINT_BOOK_NAME'].notna() & (df['BLUEPRINT_BOOK_NAME'] != 0)].copy()

    print(f"有效数据行数: {len(valid_df)}")

    return valid_df


def map_excel_to_db(df):
    """
    将 Excel 数据映射到数据库字段

    Excel -> DB 映射:
    - BLUEPRINT_BOOK_NAME -> document_name (书名)
    - DOC_VSERION -> document_version (版次)
    - BOOK_BLUEPRINT_NO -> shipyard_drawing_no (船厂图号)
    - (无对应字段) -> design_drawing_no (设计图号)
    - DATA_TYPE -> document_type (资料类型)
    - DATA_CLASS -> document_category (资料类别)
    - BOOK_LANGUAGE -> language (语言)
    - CONFIDENCIAL_LEVEL -> security_level (机密等级)
    - ESWBS -> eswbs_code (族群结构码)
    - UNIT_ID -> accounting_code (会计编号)
    """

    records = []

    for idx, row in df.iterrows():
        record = {
            'document_name': str(row.get('BLUEPRINT_BOOK_NAME', '')).strip(),
            'document_version': str(row.get('DOC_VSERION', '')).strip() if pd.notna(row.get('DOC_VSERION')) else None,
            'shipyard_drawing_no': str(row.get('BOOK_BLUEPRINT_NO', '')).strip() if pd.notna(row.get('BOOK_BLUEPRINT_NO')) else None,
            'design_drawing_no': None,  # Excel 中无此字段
            'document_type': str(int(row.get('DATA_TYPE', 0))) if pd.notna(row.get('DATA_TYPE')) and row.get('DATA_TYPE') != 0 else None,
            'document_category': str(int(row.get('DATA_CLASS', 0))) if pd.notna(row.get('DATA_CLASS')) and row.get('DATA_CLASS') != 0 else None,
            'language': str(int(row.get('BOOK_LANGUAGE', 0))) if pd.notna(row.get('BOOK_LANGUAGE')) and row.get('BOOK_LANGUAGE') != 0 else None,
            'security_level': str(int(row.get('CONFIDENCIAL_LEVEL', 0))) if pd.notna(row.get('CONFIDENCIAL_LEVEL')) and row.get('CONFIDENCIAL_LEVEL') != 0 else None,
            'eswbs_code': str(row.get('ESWBS', '')).strip() if pd.notna(row.get('ESWBS')) and str(row.get('ESWBS')).strip() != '0' else None,
            'accounting_code': str(row.get('UNIT_ID', '')).strip() if pd.notna(row.get('UNIT_ID')) else None,
        }

        # 只添加书名不为空的记录
        if record['document_name']:
            records.append(record)

    return records


def insert_to_database(records, clear_table=False):
    """插入数据到数据库"""
    if not records:
        print("没有要插入的数据")
        return 0

    print(f"\n准备插入 {len(records)} 笔数据到 TechnicalDocument 表...")

    conn = None
    try:
        # 连接数据库
        conn = psycopg2.connect(**DB_CONFIG)
        cur = conn.cursor()

        # 清空表（如果需要重新导入）
        if clear_table:
            cur.execute("TRUNCATE TABLE TechnicalDocument RESTART IDENTITY CASCADE;")
            print("已清空 TechnicalDocument 表")

        # 准备插入语句
        insert_query = """
            INSERT INTO TechnicalDocument (
                document_name,
                document_version,
                shipyard_drawing_no,
                design_drawing_no,
                document_type,
                document_category,
                language,
                security_level,
                eswbs_code,
                accounting_code,
                date_created,
                date_updated
            ) VALUES (
                %(document_name)s,
                %(document_version)s,
                %(shipyard_drawing_no)s,
                %(design_drawing_no)s,
                %(document_type)s,
                %(document_category)s,
                %(language)s,
                %(security_level)s,
                %(eswbs_code)s,
                %(accounting_code)s,
                CURRENT_TIMESTAMP,
                CURRENT_TIMESTAMP
            )
            RETURNING document_id, document_name;
        """

        # 执行插入
        inserted_count = 0
        for record in records:
            cur.execute(insert_query, record)
            result = cur.fetchone()
            inserted_count += 1
            if inserted_count <= 5 or inserted_count % 10 == 0:
                print(f"已插入 {inserted_count}/{len(records)}: ID={result[0]}, 书名={result[1][:50]}")

        # 提交事务
        conn.commit()
        print(f"\n✓ 成功插入 {inserted_count} 笔技术文件数据")

        # 显示统计信息
        cur.execute("SELECT COUNT(*) FROM TechnicalDocument;")
        total = cur.fetchone()[0]
        print(f"\nTechnicalDocument 表目前共有 {total} 笔数据")

        # 显示示例数据
        print("\n示例数据:")
        cur.execute("""
            SELECT document_id, document_name, document_version, document_type, language
            FROM TechnicalDocument
            ORDER BY document_id
            LIMIT 5;
        """)
        for row in cur.fetchall():
            print(f"  ID={row[0]}: {row[1]} (版次: {row[2]}, 类型: {row[3]}, 语言: {row[4]})")

        cur.close()
        return inserted_count

    except psycopg2.Error as e:
        print(f"\n✗ 数据库错误: {e}")
        if conn:
            conn.rollback()
        raise

    finally:
        if conn:
            conn.close()


def parse_args():
    """解析命令行参数"""
    parser = argparse.ArgumentParser(
        description='从 Excel 导入技术文件数据到 TechnicalDocument 表'
    )
    parser.add_argument(
        '--clear',
        action='store_true',
        help='导入前清空表'
    )
    parser.add_argument(
        '--yes', '-y',
        action='store_true',
        help='自动确认，不提示'
    )
    return parser.parse_args()


def main():
    """主函数"""
    args = parse_args()

    print("=" * 70)
    print("技术文件数据导入工具")
    print("=" * 70)

    try:
        # 1. 读取 Excel 数据
        df = read_excel_data()

        if df.empty:
            print("没有找到有效数据")
            return

        # 显示数据预览
        print("\n数据预览:")
        print(df[['BLUEPRINT_BOOK_NAME', 'DOC_VSERION', 'DATA_TYPE', 'ESWBS']].head(10).to_string())

        # 2. 映射数据
        print("\n正在映射数据...")
        records = map_excel_to_db(df)
        print(f"映射完成，共 {len(records)} 笔记录")

        # 显示映射后的示例
        if records:
            print("\n映射后示例:")
            for i, rec in enumerate(records[:3]):
                print(f"\n记录 {i+1}:")
                for key, value in rec.items():
                    if value:
                        print(f"  {key}: {value}")

        # 3. 插入数据库
        if args.yes:
            insert_to_database(records, clear_table=args.clear)
        else:
            proceed = input("\n是否继续导入到数据库？ (y/n): ").strip().lower()
            if proceed == 'y':
                if args.clear:
                    insert_to_database(records, clear_table=True)
                else:
                    clear = input("是否清空 TechnicalDocument 表后再导入？ (y/n): ").strip().lower()
                    insert_to_database(records, clear_table=(clear == 'y'))
            else:
                print("已取消导入")

        print("\n完成!")

    except FileNotFoundError:
        print(f"\n✗ 错误: 找不到文件 {EXCEL_FILE}")
        return 1
    except Exception as e:
        print(f"\n✗ 错误: {e}")
        import traceback
        traceback.print_exc()
        return 1

    return 0


if __name__ == '__main__':
    sys.exit(main())
