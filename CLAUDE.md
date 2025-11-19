# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SBIR equipment database for Taiwan Navy equipment management. PostgreSQL database with V3.0 architecture featuring:
- Item self-referencing BOM structure (multi-level hierarchy)
- UUID primary keys for core tables
- Extension table pattern (reduces NULL columns)
- BOM version control with history tracking

## Database Commands

### PostgreSQL Connection
```bash
PGPASSWORD=willlin07 "/c/Program Files/PostgreSQL/16/bin/psql.exe" -U postgres -h localhost -p 5432 -d sbir_equipment_db_v2
```

### Create/Reset Database
```bash
# Create database with V3.0 structure
PGPASSWORD=willlin07 "/c/Program Files/PostgreSQL/16/bin/psql.exe" -U postgres -h localhost -p 5432 -f "c:/github/SBIR/Database/scripts/create_database_v2.sql"

# Insert test data (電笛 system)
PGPASSWORD=willlin07 "/c/Program Files/PostgreSQL/16/bin/psql.exe" -U postgres -h localhost -p 5432 -d sbir_equipment_db_v2 -f "c:/github/SBIR/Database/scripts/insert_電笛_data_v2.sql"
```

### Backup Database
```bash
PGPASSWORD=willlin07 "/c/Program Files/PostgreSQL/16/bin/pg_dump.exe" -U postgres -h localhost -p 5432 sbir_equipment_db_v2 > backup.sql
```

## Architecture

### Core Tables (12 total)

**Main Tables:**
- `Item` - Central table with UUID PK, types: FG (成品), SEMI (半成品), RM (原物料)
- `Item_Equipment_Ext` - Extension for FG type (艦型, ESWBS, etc.)
- `Item_Material_Ext` - Extension for SEMI/RM type (NSN, 單價, etc.)
- `Supplier` - Manufacturer/vendor data

**BOM Structure (Self-Reference):**
- `BOM` - Version control (revision, effective_from/to, status)
- `BOM_LINE` - Item→Item relationships via `component_item_uuid`
- `MRC` - Item specifications (規格資料)

**Supporting Tables:**
- `Part_Number_xref` - Item-PartNumber-Supplier relationships
- `TechnicalDocument`, `Item_Document_xref` - Technical documentation
- `ApplicationForm`, `ApplicationFormDetail` - Application forms

### BOM Self-Reference Pattern

```
Item (FG: 電笛系統)
  └─ BOM v1.0
       └─ BOM_LINE → Item (SEMI: 電笛系統主機)
                        └─ BOM v1.0
                             ├─ BOM_LINE → Item (RM: 電笛喇叭) x2
                             ├─ BOM_LINE → Item (RM: 電笛控制面板)
                             └─ BOM_LINE → Item (RM: 電源供應器)
```

## Key Files

- `Database/scripts/create_database_v2.sql` - V3.0 schema creation
- `Database/scripts/insert_電笛_data_v2.sql` - Test data
- `Database/docs/資料庫中英文對照表.md` - Complete field reference (Chinese/English)
- `Database/diagrams/` - ER diagrams

## Important Notes

- Always use UUID for Item, BOM, BOM_LINE primary keys
- Use extension tables instead of adding NULL columns to Item
- BOM versioning: Released/Draft status with effective_from/to dates
- Chinese comments in SQL may cause encoding issues - use UTF-8 or separate statements
- Close DBeaver connections before dropping/recreating database
