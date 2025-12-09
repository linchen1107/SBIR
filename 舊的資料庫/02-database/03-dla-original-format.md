# 附件四：DLA 原始檔案欄位定義 (技術參考)

> **ℹ️ 技術參考文件**
>
> 本檔案提供了 DLA (美國國防後勤局) 原始資料檔的欄位定義，主要作為資料溯源和底層數據結構的技術參考。
>
> - **用途**: 在進行資料轉換 (ETL) 或需要理解原始資料來源時，可參考此文件。
> - **非當前架構**: 本文件內容**不直接對應**資料庫中的表格結構。
>
> 如需了解目前的資料庫架構，請查閱：
> - **`docs/01_Database_Architecture.md`**: 了解最新的資料庫架構與建置流程。
> - **`docs/02_Schema_Public_Tables.md`**: 查看當前 `public` schema 中15張核心表的詳細欄位定義。

---

### Item Name Tables

#### Table 091 COLLOQ_XREF
Contains the Item Name Code (INC) for the colloquial item name and cross references the related INC.

- **File Name**: `Tabl091` (Zip Version)
- **File Size**: 170,137 Bytes
- **Date Last Updated**: 5/7/2025
- **Record Layout**: [TABL091-RL.TXT](https://www.dla.mil/Portals/104/Documents/InformationOperations/LogisticsInformationServices/CatalogTools%20Tables/TABL091-RL.TXT?ver=2019-06-25-091850-533)

| Field Name        | Length     |
|-------------------|------------|
| NM_CD_2303        | VAR/DLM(|) |
| REL_INC_2926      | VAR/DLM(|) |
| DT_ESTB_CANC_0308 | VAR/DLM(|) |
| EFF_DT_2128       | VAR/DLM(|) |

---

#### Table 098 NAMES_BY_TYPE
Contains all the INCs, colloquial names and basic names.

- **File Name**: `Tabl098` (Zip Version)
- **File Size**: 3,836,948 Bytes
- **Date Last Updated**: 5/7/2025
- **Record Layout**: [TABL098-RL.TXT](https://www.dla.mil/Portals/104/Documents/InformationOperations/LogisticsInformationServices/CatalogTools%20Tables/TABL098-RL.TXT?ver=2018-10-22-083843-990)

| Field Name         | Length     |
|--------------------|------------|
| NM_CD_2303         | VAR/DLM(|) |
| APPLB_KEY_CD_0103  | VAR/DLM(|) |
| DT_ESTB_CANC_0308  | VAR/DLM(|) |
| STA_CD_NM_FSC_0320 | VAR/DLM(|) |
| SHRT_NM_2301       | VAR/DLM(|) |
| NM_PREFIX_2516     | VAR/DLM(|) |
| NM_ROOT_RMDR_2517  | VAR/DLM(|) |
| FSC_COND_CD_2607   | VAR/DLM(|) |
| ITM_NM_TYP_CD_3308 | VAR/DLM(|) |
| FIIG_4065          | VAR/DLM(|) |
| CONCEPT_NBR_4488   | VAR/DLM(|) |
| ITM_NM_DEF_5015    | VAR/DLM(|) |

---

#### Table 099 NM_CD_FSC_XREF
Identifies the Federal Supply Class (FSC) allowed for a specific INC.

- **File Name**: `Tabl099` (Zip Version)
- **File Size**: 336,347 Bytes
- **Date Last Updated**: 5/7/2025
- **Record Layout**: [TABL099-RL.TXT](https://www.dla.mil/Portals/104/Documents/InformationOperations/LogisticsInformationServices/CatalogTools%20Tables/TABL099-RL.TXT?ver=2019-06-25-091847-347)

| Field Name         | Length     |
|--------------------|------------|
| NM_CD_2303         | VAR/DLM(|) |
| FSG_3994           | VAR/DLM(|) |
| FSC_WI_FSG_3996    | VAR/DLM(|) |
| DT_ESTB_CANC_0308  | VAR/DLM(|) |
| EFF_DT_2128        | VAR/DLM(|) |
| CL_ASST_MODH2_9554 | VAR/DLM(|) |

---

#### Table 363 UNAPPRV_ITEM_NM_DT
Contains all of the Non-Approved Item Names (NAINs).

- **File Name**: `Tabl363` (Zip Version)
- **File Size**: 6,076,232 Bytes
- **Date Last Updated**: 5/7/2025
- **Record Layout**: `TABL363-RL.TXT`

| Field Name        | Length     |
|-------------------|------------|
| NAIN_CD_3237      | VAR/DLM(|) |
| DT_ESTB_CANC_0308 | VAR/DLM(|) |
| NAIN_5020         | VAR/DLM(|) |
| NAIN_RMDR_2177    | CHAR(971)  |

---

#### Table 364 KEYWORD_INDEX
Contains each word from all item names, cross-referenced to the Pseudo INC (PINC).

- **File Name**: `Tabl364` (Zip Version)
- **File Size**: 12,846,717 Bytes
- **Date Last Updated**: 5/7/2025
- **Record Layout**: `TABL364-RL.TXT`

| Field Name         | Length     |
|--------------------|------------|
| ITEM_NM_KY_WD_4401 | VAR/DLM(|) |
| PINC_3084          | CHAR(7)    |

---

#### Table 557 NAIN_WORDS
Contains approved words for Non-Approved Item Names and Word Types.

- **File Name**: `Tabl557` (Zip Version)
- **File Size**: 52,212 Bytes
- **Date Last Updated**: 6/01/2025
- **Record Layout**: `TABL557-RL.TXT`

| Field Name         | Length     |
|--------------------|------------|
| APPRVD_WORD_6588   | VAR/DLM(|) |
| WORD_TYPE_6586     | VAR/DLM    |

---

#### Table 990 REPLACEMENT_INCS
Contains replacement INCs for cancelled INCs.

- **File Name**: `Tabl990` (Zip Version)
- **File Size**: 17,919 Bytes
- **Date Last Updated**: 5/7/2025
- **Record Layout**: `TABL990-RL.TXT`

| Field Name      | Length  |
|-----------------|---------|
| NM_CD_2303      | CHAR(5) |
| RPLD_INC_2646   | CHAR(5) |

---

### Federal Supply Class (FSC)/ Federal Supply Group (FSG) Tables

#### Table 076 FSC_NOTE_DAT_GROUP
Contains all active FSCs.

- **File Name**: `Tabl076` (Zip Version)
- **File Size**: 65,126 Bytes
- **Date Last Updated**: 5/7/2025
- **Record Layout**: `TABL076-RL.TXT`

| Field Name         | Length     |
|--------------------|------------|
| FSG_3994           | VAR/DLM(|) |
| FSC_WI_FSG_3996    | VAR/DLM(|) |
| STA_CD_NM_FSC_0320 | VAR/DLM(|) |
| FSC_INCL_NAR_0375  | VAR/DLM(|) |
| FSC_EXCL_NAR_0376  | VAR/DLM(|) |
| FSC_NOTE_4962      | VAR/DLM(|) |
| FSC_TI_4970        | VAR/DLM(|) |
| FSC_DT_E_C_RC_5182 | VAR/DLM(|) |

---

#### Table 316 FSG_NOTE_DAT_GROUP
Contains all active FSGs.

- **File Name**: `Tabl316` (Zip Version)
- **File Size**: 5,885 Bytes
- **Date Last Updated**: 5/7/2025
- **Record Layout**: `TABL316-RL.TXT`

| Field Name         | Length     |
|--------------------|------------|
| FSG_3994           | VAR/DLM(|) |
| STA_CD_NM_FSC_0320 | VAR/DLM(|) |
| FSG_NOTE_4965      | VAR/DLM(|) |
| FSG_TI_4972        | VAR/DLM(|) |
| FSG_DT_E_C_RC_5183 | VAR/DLM(|) |

---

#### Table 120 EDIT_GUIDE_1
Contains edits for Item Name Code Requirements (LGD).

- **File Name**: `Tabl120` (Zip Version)
- **File Size**: 6,524,169 Bytes
- **Date Last Updated**: 5/7/2025
- **Record Layout**: `TABL120-RL.TXT`

| Field Name         | Length     |
|--------------------|------------|
| FIIG_4065          | VAR/DLM(|) |
| INC_4080           | VAR/DLM(|) |
| MRC_3445           | VAR/DLM(|) |
| SAC_CDNG_IND_0115  | VAR/DLM(|) |
| DIML_MRC_IND_0326  | VAR/DLM(|) |
| PRPTN_EDIT_CD_0762 | VAR/DLM(|) |
| ISAC_IND_CD_0826   | VAR/DLM(|) |
| SCR_KEY_CD_1047    | VAR/DLM(|) |
| RPLY_TBL_DCOD_3845 | VAR/DLM(|) |
| TAIL_SEQ_NO_4403   | VAR/DLM(|) |
| FIIG_SEQ_NO_4404   | VAR/DLM(|) |
| MRC_IND_CD_8450    | VAR/DLM(|) |

---

#### Table 121 EDIT_GUIDE_2
Contains LGA (technical edits), LGB (relationship edits) and LGC (proportional/Identified Secondary Address Coding edits).

- **File Name**: `Tabl121` (Zip Version)
- **File Size**: 31,225,129
- **Date Last Updated**: 5/7/2025
- **Record Layout**: `TABL121-RL.TXT`

> A recent (12/19/10) system change resulted in a data structure change within the source database (Federal Logistics Information System-FLIS) used to create the TABL121.TXT file. This change required the addition of the Item Name Code (INC_4080) field within the TABL121.TXT file and the record layout below has been adjusted accordingly.
> Because of the potential length of the last data element (ED_CRITE_STMT_4129), each logical FIIG_4065 record is split across two physical records. The first nine data elements are displayed together on one line and the following line contains the associated ED_CRITE_STMT_4129 value.

**First Record**
| Field Name        | Length     |
|-------------------|------------|
| INC_4080          | VAR/DLM(|) |
| FIIG_4065         | VAR/DLM(|) |
| DIC_3920          | VAR/DLM(|) |
| MRC_3445          | VAR/DLM(|) |
| MODE_CD_4735      | VAR/DLM(|) |
| ISAC_LMTN_CD_0825 | VAR/DLM(|) |
| ISAC_PRES_CD_2348 | VAR/DLM(|) |
| PROP_CHAR_CD_2514 | VAR/DLM(|) |
| REF_MRC_4475      | VAR/DLM(|) |
| CRD_SEQ_CD_8264   | VAR/DLM(|) |

**Second Record**
| Field Name         | Length     |
|--------------------|------------|
| ED_CRITE_STMT_4129 | VAR/DLM(|) |

---

#### Table 122 EDIT_GUIDE_3
Contains Federal Item Identification Guide (FIIG) to INC cross-reference.

- **File Name**: `Tabl122` (Zip Version)
- **File Size**: 128,216 Bytes
- **Date Last Updated**: 5/7/2025
- **Record Layout**: `TABL122-RL.TXT`

| Field Name         | Length     |
|--------------------|------------|
| FIIG_4065          | VAR/DLM(|) |
| INC_4080           | VAR/DLM(|) |
| INC_LOCKT_IND_0583 | VAR/DLM(|) |
| TAIL_ACT_CD_2513   | VAR/DLM(|) |
| INC_APPL_IND_4405  | CHAR(1)    |

---

### Master Requirements Directory (MRD) Tables

#### Table 124 NATO_ISAC_EXTRACT table
Contains the entire Master Requirements Directory.

- **File Name**: `Tabl124` (Zip Version)
- **File Size**: 51,085 Bytes
- **Date Last Updated**: 5/7/2025
- **Record Layout**: [TABL124-RL.TXT](https://www.dla.mil/Portals/104/Documents/InformationOperations/LogisticsInformationServices/CatalogTools%20Tables/Tabl124.txt?ver=2019-06-11-133523-330) (Page not found)

---

#### Table 125 ISAC_RPLY_TAB
Contains ISAC table numbers, ISAC codes and ISAC replies.

- **File Name**: `Tabl125` (Zip Version)
- **File Size**: 214,191 Bytes
- **Date Last Updated**: 5/7/2025
- **Record Layout**: [TABL125-RL.TXT](https://www.dla.mil/Portals/104/Documents/InformationOperations/LogisticsInformationServices/CatalogTools%20Tables/Tabl125.txt?ver=2019-06-11-133524-423) (Page not found)

---

#### Table 126 MRC_RPLY_TAB
Contains Master Requirement Codes (MRCs) with assigned reply table numbers.

- **File Name**: `Tabl126` (Zip Version)
- **File Size**: 104,288 Bytes
- **Date Last Updated**: 5/7/2025
- **Record Layout**: [TABL126-RL.TXT](https://www.dla.mil/Portals/104/Documents/InformationOperations/LogisticsInformationServices/CatalogTools%20Tables/TABL126-RL.TXT?ver=2019-06-25-091848-440)

| Field Name         | Length     |
|--------------------|------------|
| MRC_3445           | VAR/DLM(|) |
| RPLY_DCOD_SEQ_0510 | VAR/DLM(|) |
| CD_F_LGT_RPLY_0365 | VAR/DLM(|) |
| RPLY_TBL_MRD_8254  | VAR/DLM(|) |

---

#### Table 127 MRD_DECODE
Contains MRCs, assigned Mode Codes, reply to formats and Requirement Titles.

- **File Name**: `Tabl127` (Zip Version)
- **File Size**: 486,029 Bytes
- **Date Last Updated**: 5/7/2025
- **Record Layout**: [TABL127-RL.TXT](https://www.dla.mil/Portals/104/Documents/InformationOperations/LogisticsInformationServices/CatalogTools%20Tables/TABL127-RL.TXT?ver=2019-06-25-091848-673)

| Field Name          | Length     |
|---------------------|------------|
| MRC_3445            | VAR/DLM(|) |
| PRT_SKLTN_CD_0368   | VAR/DLM(|) |
| MRD_STATUS_CD_0816  | VAR/DLM(|) |
| MRC_USG_DESI_0847   | VAR/DLM(|) |
| KEYWRD_MOD_ST_2033  | VAR/DLM(|) |
| KEYWRD_GRP_CD_2034  | VAR/DLM(|) |
| RQMT_RPY_INST_2648  | VAR/DLM(|) |
| RQMT_STMT_3614      | VAR/DLM(|) |
| FIIG_4065           | VAR/DLM(|) |
| MODE_CD_4735        | VAR/DLM(|) |

---

#### Table 128 REPLY_TABLE
Contains Reply Tables and Codes.

- **File Name**: `Tabl128` (Zip Version)
- **File Size**: 1,366,854 Bytes
- **Date Last Updated**: 5/7/2025
- **Record Layout**: [TABL128-RL.TXT](https://www.dla.mil/Portals/104/Documents/InformationOperations/LogisticsInformationServices/CatalogTools%20Tables/TABL128-RL.TXT?ver=2019-06-25-091848-643)

| Field Name         | Length     |
|--------------------|------------|
| RPLY_TBL_MRD_8254  | VAR/DLM(|) |
| CDD_RPLY_3465      | VAR/DLM(|) |
| RPLY_STAT_IND_2498 | VAR/DLM(|) |
| DCOD_RPLY_ST_3864  | VAR/DLM(|) |

---

#### Table 131 STYL_RPLY_TAB
Contains Styles and Titles.

- **File Name**: `Tabl131` (Zip Version)
- **File Size**: 1,615,352 Bytes
- **Date Last Updated**: 5/7/2025
- **Record Layout**: [TABL131-RL.TXT](https://www.dla.mil/Portals/104/Documents/InformationOperations/LogisticsInformationServices/CatalogTools%20Tables/TABL131-RL.TXT?ver=2019-06-25-091848-673)

> A recent (12/19/10) system change resulted in a data structure change within the source database (Federal Logistics Information System-FLIS) used to create the TABL131.TXT file. This change required the addition of the Item Name Code (INC_4080) and Physical Drawing Identification Number (PHYS_DWG_ID_5037) fields within the TABL131.TXT file and the record layout below has been adjusted accordingly.

| Field Name         | Length     |
|--------------------|------------|
| INC_4080           | VAR/DLM(|) |
| FIIG_4065          | VAR/DLM(|) |
| MRC_3445           | VAR/DLM(|) |
| STYL_NBR_FIIG_0768 | VAR/DLM(|) |
| PHYS_DWG_ID_5037   | VAR/DLM(|) |
| DCOD_STYL_RPY_2309 | VAR/DLM(|) |

---

#### Table 347 MRD_REQ_STMT_DEF
Contains MRC Requirement definitions.

- **File Name**: `Tabl347` (Zip Version)
- **File Size**: 394,931 Bytes
- **Date Last Updated**: 5/7/2025
- **Record Layout**: [TABL347-RL.TXT](https://www.dla.mil/Portals/104/Documents/InformationOperations/LogisticsInformationServices/CatalogTools%20Tables/Tabl347.txt?ver=2019-04-22-075630-583) (Page not found)

---

#### Table 390 MODE_CD_EDIT
Contains reply formats for each Mode Code.

- **File Name**: `Tabl390` (Zip Version)
- **File Size**: 442 Bytes
- **Date Last Updated**: 5/7/2025
- **Record Layout**: `TABL390-RL.TXT`

| Field Name         | Length     |
|--------------------|------------|
| MODE_CD_4735       | VAR/DLM(|) |
| RQMT_RPY_INST_2648 | VAR/DLM(|) |
| NBR_OF_TBLS_4444   | VAR/DLM(|) |
| PRT_SKLTN_1_4445   | VAR/DLM(|) |
| PRT_SKLTN_2_4446   | VAR/DLM(|) |
| PRT_SKLTN_3_4447   | CHAR(1)    |

---

#### Table 391 MRD_KEY_GRP_CD
Contains the nineteen basic requirement categories.

- **File Name**: `Tabl391` (Zip Version)
- **File Size**: 395 Bytes
- **Date Last Updated**: 5/7/2025
- **Record Layout**: [TABL391-RL.TXT](https://www.dla.mil/Portals/104/Documents/InformationOperations/LogisticsInformationServices/CatalogTools%20Tables/Tabl391.txt?ver=2019-06-20-125907-173) (Page not found)
- **Zip file**: [Tabl391.zip](https://www.dla.mil/Portals/104/Documents/InformationOperations/LogisticsInformationServices/CatalogTools%20Tables/Tabl391.zip?ver=0ZyZMDIUbdmAO0UEeCcLJw%3d%3d)

---

### Drawing Cross Reference Tables (DCR)
Drawing Cross Reference Tables will no longer be provided as they have become obsolete as a result of Edit Guide Simplification Phase 4 (e.g., No longer utilizing Reference Drawing Groups or Section ID's within IIG Documents). The files below remain for historical purposes only. See Master Requirement Directory Table 131 STYL_RPLY_TAB for FIIG, INC, MRC, Style Number, Title and Physical Drawing ID for all answerable drawing images. Send all inquiries to FIIGS@DLA.MIL

#### Item Identification Guide Drawing Image Library
Contains the full set of drawings for all Item Identification Guides. A second file, 'change.txt', is also shown below. If it is empty, there were no changes or updates for this month's file.

- **File Name**: IIG Lib Images (Zip Version)
- **File Size**: 161,931,891 Bytes
- **Date Last Updated**: 5/2/2025

- **File Name**: Change (Text Version)
- **File Size**: 0 Bytes
- **Date Last Updated**: 5/6/2024

---

### MRD Files Traditional (MRDT)
Contains the entire Master Requirements Directory (Traditional Version).

- **File Name**: `MRD` (Zip Version)
- **File Size**: 4,485,973 Bytes
- **Date Last Updated**: 06/05/2025
- **Record Layout**: [MRD-RL.TXT](https://www.dla.mil/Portals/104/Documents/InformationOperations/LogisticsInformationServices/CatalogTools%20Tables/MRD-RL.TXT?ver=2018-10-22-105614-460)

#### MRD SECTION 1 AND 7 RECORD LAYOUT - FILE NAME `SECT0107.TXT`

| Positions | Length | DB2 Field Name      |
|:----------|:-------|:--------------------|
| 001 - 004 | 4      | MRC_3445            |
| 005 - 005 | 1      | MODE_CD_4735        |
| 006 - 006 | 1      | MRC_USG_DESI_0847   |
| 007 - 009 | 3      | MRD_STATUS_CD_0816  |
| 010 - 010 | 1      | PRT_SKLTN_CD_0368   |
| 011 - 012 | 2      | KEYWRD_GRP_CD_2034  |
| 013 - 120 | 108    | KEYWRD_MOD_ST_2033  |
| 121 - 230 | 110    | RQMT_STMT_3614      |
| 231 - 730 | 500    | RQMT_STMT_DEF_5027  |
| 731 - 750 | 20     | RQMT_RPY_INST_2648  |
| 751 - 751 | 1      | MRC_TBL_CT_0848     |
| 752 - 752 | 1      | CD_F_LGT_RPLY_0365  |
| 753 - 756 | 4      | * RPLY_TBL_MRD_8254 |
| 757 - 757 | 1      | ** CD_F_LGT_RPLY_0365|
| 758 - 761 | 4      | ** RPLY_TBL_MRD_8254 |
| 762 - 762 | 1      | ** CD_F_LGT_RPLY_0365|
| 763 - 766 | 4      | ** RPLY_TBL_MRD_8254 |
| 767 - 767 | 1      | ** CD_F_LGT_RPLY_0365|
| 768 - 771 | 4      | ** RPLY_TBL_MRD_8254 |
| 772 - 772 | 1      | ** CD_F_LGT_RPLY_0365|
| 773 - 776 | 4      | ** RPLY_TBL_MRD_8254 |
| 777 - 777 | 1      | ** CD_F_LGT_RPLY_0365|
| 778 - 781 | 4      | ** RPLY_TBL_MRD_8254 |
| 782 - 782 | 1      | ** CD_F_LGT_RPLY_0365|
| 783 - 786 | 4      | ** RPLY_TBL_MRD_8254 |
| 787 - 787 | 1      | ** CD_F_LGT_RPLY_0365|
| 788 - 791 | 4      | ** RPLY_TBL_MRD_8254 |

> `*` This field will be generated from the number of reply table entries for mode codes D, H, and J. For all other mode codes, this value will be zero "0".
>
> `**` These two fields can occur from one to eight times for mode codes 'D', 'H', or 'J'. On all other mode codes, the DRN CD_F_LGT_RPLY_0365 will contain zero "0" and the DRN RPLY_TBL_MRD_8254 will contain blanks.

#### MRD SECTION 3 RECORD LAYOUT - FILE NAME `SECT0300.TXT`

| Positions | Length | DB2 Field Name      |
|:----------|:-------|:--------------------|
| 001 - 004 | 4      | RPLY_TBL_MRD_8254   |
| 005 - 010 | 6      | CDD_RPLY_3465       |
| 011 - 013 | 3      | RPLY_STAT_IND_2498  |
| 014 - 392 | 379    | DCOD_RPLY_ST_3864   |

#### MRD SECTION 5 RECORD LAYOUT - FILE NAME `SECT0500.TXT`

| Positions | Length | DB2 Field Name      |
|:----------|:-------|:--------------------|
| 001 - 005 | 5      | INC_4080            |
| 006 - 011 | 6      | FIIG_4065           |
| 012 - 015 | 4      | MRC_3445            |
| 016 - 020 | 5      | STYL_NBR_FIIG_0768  |
| 021 - 028 | 8      | PHYS_DWG_ID_5037    |
| 029 - 407 | 379    | DCOD_STYL_RPY_2309  |

#### MRD SECTION 6 PART 1 RECORD LAYOUT - FILE NAME `SECT06P1.TXT`

| Positions | Length | DB2 Field Name      |
|:----------|:-------|:--------------------|
| 001 - 006 | 6      | FIIG_4065           |
| 007 - 011 | 5      | INC_4080            |
| 012 - 015 | 4      | MRC_3445            |
| 016 - 019 | 4      | RPLY_TBL_DCOD_3845  |

#### MRD SECTION 6 PART 2 RECORD LAYOUT - FILE NAME `SECT06P2.TXT`

| Positions | Length | DB2 Field Name      |
|:----------|:-------|:--------------------|
| 001 - 004 | 4      | RPLY_TBL_DCOD_3845  |
| 005 - 005 | 1      | SEC_AD_IND_CD_9485  |
| 006 - 008 | 3      | SAC_8990            |
| 009 - 387 | 379    | DCOD_ISAC_RPY_2308  |

---

### FIIG EDIT GUIDE
Contains Edit Guide 1 and Edit Guide 2 data (LGA, LGB, LGC, and LGD) in 85 card column format.

- **File Name**: `FIIGEditGuide` (Zip Version)
- **File Size**: 50,302,276 Bytes
- **Date Last Updated**: 5/12/2025
- **Record Layout**: `FIIGEditGuide-RL.TXT`

#### FIIG EDIT GUIDE RECORD LAYOUT - FILE NAME `FIIGEditGuide.txt`

**(a) Technical Edit Data Group: This data group is required for DIC LGA.**

| DATA ELEMENT/DRN                 | CARD COLUMN | DESCRIPTION                                                                 |
|:---------------------------------|:------------|:----------------------------------------------------------------------------|
| Document Identifier Code (DIC) (DRN 3920) | 1-3         | Must be LGA.                                                                |
| FIIG Lockout Indicator (DRN 0583) | 4           | Must be a L, U or blank.                                                    |
| Guide Number, FIIG (DRN 4065)    | 5-10        | Must be A or T FIIG Number.                                                 |
| Item Name Code, INC (DRN 4080)   | 11-15       |                                                                             |
| Master Requirement Code (MRC) (DRN 3445) | 16-19       | Must be MRC or blank, except when DRN 0760 is applied.                      |
| Federal Item Identification Edit Guide Deletion Designator (DRN 0760) | 16-27       | Must contain word DELETE in cc 16-21 and the FIIG Number cited in cc 5-10 and cc 22-27. |
| Mode Code (DRN 4735)             | 20          | Must be Mode Code(s) or blank, except when DRN 0584 or 0760 is applied.      |
| Mode Code (4735)                 | 21          | Must be Mode Code(s) or blank, except when DRN 0584 or 0760 is applied.      |
| Third Mode Code Indicator (DRN 0584) | 21          | Must contain an asterisk () if three Mode Codes are applicable to MRC in cc 16-19. |
| Technical Edit Criteria Statement (DRN 8452) | 22-80       | Must be present or blank, except when DRN 8268 is used in cc 22 or DRN 0760 is applied in cc 16-27. |
| Data Element Terminator Code (DRN 8268) | 22-80       | Must be present when cc 81 is blank except when DRN 0760 is applied.        |
| Line Continuation Code (DRN 8263) | 81          | Must contain x or blank.                                                    |
| Card/Sequence Code (DRN 8264)    | 82-85       | Must be present. Cc 82-84 denotes sequence in which line of data will appear. |

**(b) Relationship Edit Data Group: This data group is required for DIC LGB.**

| DATA ELEMENT/DRN                 | CARD COLUMN | DESCRIPTION                                                                 |
|:---------------------------------|:------------|:----------------------------------------------------------------------------|
| Document Identifier Code (DIC) (DRN 3920) | 1-3         | Must be LGB.                                                                |
| Blank                            | 4           | Space filled.                                                               |
| Guide Number, FIIG (DRN 4065)    | 5-10        | Must be A or T FIIG Number.                                                 |
| Item Name Code, INC (DRN 4080)   | 11-15       |                                                                             |
| Master Requirement Code (MRC) (DRN 3445) | 16-19       | Must be MRC or blank.                                                       |
| Mode Code (DRN 4735)             | 20          | Must be Mode Code(s) or blank.                                              |
| ISAC Presence Code (DRN 2348)    | 21          | Must be an I or blank.                                                      |
| Relationship Edit Criteria Statement (DRN 8454) | 22-80       | Must be present or blank except when DRN 8268 is applied in cc 22.          |
| Data Element Terminator Code (DRN 8268) | 22-80       | Must be present when cc 81 is blank.                                        |
| Line Continuation Code (DRN 8263) | 81          | Must contain x or blank.                                                    |
| Card/Sequence Code (DRN 8264)    | 82-85       | Must be present. Cc 82-84 denotes sequence in which line of data will appear. |

**(c) Relationship Edit Data Group: This data group is required for DIC LGC.**

| DATA ELEMENT/DRN                 | CARD COLUMN | DESCRIPTION                                                                 |
|:---------------------------------|:------------|:----------------------------------------------------------------------------|
| Document Identifier Code (DIC) (DRN 3920) | 1-3         | Must be LGC.                                                                |
| Blank                            | 4           | Space filled.                                                               |
| Guide Number, FIIG (DRN 4065)    | 5-10        | Must be A or T FIIG Number.                                                 |
| Item Name Code, INC (DRN 4080)   | 11-15       |                                                                             |
| Master Requirement Code (MRC) (DRN 3445) | 16-19       | Must be MRC or blank.                                                       |
| Mode Code (DRN 4735)             | 20          | Must be Mode Code(s) or blank.                                              |
| Proportion Edit Symbol (DRN 2514) | 21          | Must contain valid special character or blank.                              |
| ISAC Limitation Code             | 20-21       | Must be a valid ISAC Limitation Code.                                       |
| Proportion Edit Criteria Statement (DRN 0304) | 22-80       | Must be present or blank except when DRN 8268 is applied in cc 22.          |
| Data Element Terminator Code (DRN 8268) | 22-80       | Must be present when cc 81 is blank.                                        |
| Line Continuation Code (DRN 8263) | 81          | Must contain x or blank.                                                    |
| Card/Sequence Code (DRN 8264)    | 82-85       | Must be present. Cc 82-84 denotes sequence in which line of data will appear. |

**(d) Relationship Edit Data Group: This data group is required for DIC LGD.**

| DATA ELEMENT/DRN                 | CARD COLUMN | DESCRIPTION                                                                 |
|:---------------------------------|:------------|:----------------------------------------------------------------------------|
| Document Identifier Code (DIC) (DRN 3920) | 1-3         | Must be LGD.                                                                |
| Blank                            | 4           | Space filled.                                                               |
| Guide Number, FIIG (DRN 4065)    | 5-10        | Must be A or T FIIG Number.                                                 |
| Item Name Code (INC) (DRN 4080)  | 11-15       | Must contain INC.                                                           |
| Master Requirement Code MRC (DRN 3445) | 16-19       | Must contain MRC or blank, except when DRN 0758 is applied.                 |
| Data Terminator Associated with INC (DRN 0758) | 16-19       | Must contain END . Note: For cc 16-19 only, DRN 0758 may be used in conjunction with DRN 0761 in cc 76. |
| Optional/Mandatory MRC Indicator Code (DRN 8450) | 20          | Must be one (1) or nine (9) or blank.                                       |
| Screening/Search Key Code (DRN 1047) | 21          | Must be 1 or 3.                                                             |
| Secondary Address Coding or AND/OR Coding Indicator (DRN 0115) | 22          | Must be A, C, N, R, T, W, Z or $.                                           |
| Dimensional Master Requirement Code Indicator (DRN 0326) | 23          | Must be J, G, Y or N.                                                       |
| ISAC Indicator Code (DRN 0826)   | 24          | Must be R, M, P, W or blank.                                                |
| Proportion Characteristic Code (DRN 2514) | 25          | Must be a P or R.                                                           |
| Reserved                         | 76-80       | Must contain blanks.                                                        |
| Line Continuation Code (DRN 8263) | 81          | Must contain X or blank.                                                    |
| Card/Sequence Code (DRN 8264)    | 82-85       | Must be present. Cc 82-84 denotes sequence in which line of data will appear in edit. |
> 16-25 repeated for card column 26-35, 36-45, 46-55, 56-65 and 66-75.
> When all MRCs have been entered for the applicable Item Name, then 16-19 or the other corresponding positions in the repeated 5 groups must contain END*.

---

### NATO H6 Item Name File (NH6)
Contains NATO H6 Item Name data in variable length format.

- **File Name**: `NATO-H6` (Zip Version)
- **File Size**: 4,187,072 Bytes
- **Date Last Updated**: 5/12/2025
- **Record Layout**: `NATO-H6-RL.TXT`

#### NATO H6 ITEM NAME RECORD LAYOUT - FILE NAME `NATO-H6.TXT`

| Position | Length   | Field Name            | Description                                                               |
|:---------|:---------|:----------------------|:--------------------------------------------------------------------------|
| 1        | 1        | Delimiter             | @ Sign                                                                    |
| 2-6      | 5        | NM_CD_2303            |                                                                           |
| 7-12     | 6        | FIIG_4065             | Federal Item Identification Guide (FIIG)                                  |
| 13-15    | 3        | APPLB_KEY_CD_0103     |                                                                           |
| 16       | 1        | STA_CD_NM_FSC_0320    | Status Code Name/Federal Supply Class (FSC)                               |
| 17       | 1        | ITM_NM_TYP_CD_3308    |                                                                           |
| 18-24    | 7        | DT_ESTB_CANC_0308     | Date Established, Canceled Record DIDs                                    |
| 25       | 1        | CONCEPT_NBR_4488      |                                                                           |
| 26-29    | 4        | Counter               | Counter for Item Name. The counter indicates the length of the item name. |
| 30       | Variable | Item Name             | The Item Name consist of three DRNs: NM_PREFIX_2516, SHRT_NM_2301, NM_ROOT_RMDR_2517 |
|          | 4        | Counter               | Counter for the Item Name definition. Indicates length of the definition. |
|          | Variable | Item Name Definition  | ITM_NM_DEF_5015                                                           |
|          | 1        | FSC_COND_CD_2607      |                                                                           |
|          | 2        | FSC Counter           | Counter for the DRNs with asterisks(\*). The data repeats accordingly.    |
|          | 2        | FSG_3994              | Federal Supply Group                                                      |
|          | 2        | \*FSC_WI_FSG_3996     | Assigned FSC within Federal Supply Group                                  |
|          | 4        | \*Class Mod Counter   | \*Counter indicates the length of the FSC modifier.                       |
|          | Variable | \*CL_ASST_MODH2_9554  | \*Class_Asst_Mod_H2                                                       |
|          | 2        | \*Related INC Counter | \*Counter indicates the number of Related INCs                            |
|          | 1        | \*Delimiter           | \* \| Pipe Sign                                                           |
|          | 5        | \*REL_INC_2926        | \*Related Item Name Code                                                  |

---

### Taxonomy
Contains the tables associated with decoding data to derive Schedule B codes.

- **File Name**: `Taxonomy_Tables` (Zip Version)
- **File Size**: 4,060,162 Bytes
- **Date Last Updated**: 3/10/2024
- **Record Layout**: `TAXONOMY.doc`

- **TXNMY_RQMT_J_355**: Used by Taxonomy decode process when Mode Code ‘J’ mapping is required.
- **TXNMY_RQMT_GEN_706**: Used by Taxonomy decode process to indicate general MRC requirements.
- **TXNMY_RQMT_SAC_707**: Used by Taxonomy decode process to indicate required ISAC.
- **TXNMY_RQMT_D_708**: Used by Taxonomy decode process when Mode D/H/L mapping data is required.
- **TAXONOMY_DECODE_740**: Contains Schedule B codes and their definitions
- **TAXONOMY_BY_FSC_745**: Used by Taxonomy decode process where a NIIN decodes to this table.
- **TAXONOMY_BASIC_747**: Used by Taxonomy decode process where a NIIN decodes to this table.
- **TAXONOMY_BY_NIIN_748**: Used by Taxonomy decode process where a NIIN decodes to this table.
- **TXNMY_MRC_RUL_XREF_766**: Used by the Taxonomy decode process to indicate what conversion rule applies to a specific MRC as it relates to the unit of measurement being converted.
- **TXNMY_CONV_TYP_791**: Displays conversion rule and what is being converted in plain text.
- **TXNMY_CONV_RUL_793**: Displays conversion rule and multiplication factor.
- **TXNMY_RQMT_BF_799**: Used by Taxonomy decode process when Mode Code ‘B’ or ‘F’ mapping rules are required.

---

### Item Identification Guides (IIG)

- **IIGXML_Library** (Zip): 574,876,625 Bytes (Updated: 5/2/2025)
- **IIGXML_Monthly_Additions** (Zip): 34,769 Bytes (Updated: 5/2/2025)
- **IIGXML_Monthly_Updates** (Zip): 178,887,482 Bytes (Updated: 5/2/2025)
- **IIG_Library** (Zip): 611,244,162 Bytes (Updated: 5/2/2025)
- **IIG_Monthly_Additions** (Zip): 1,816,926 Bytes (Updated: 5/2/2025)
- **IIG_Monthly_Updates** (Zip): 192,917,311 Bytes (Updated: 5/2/2025)
