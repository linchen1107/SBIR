--
-- PostgreSQL database dump
--

\restrict korAwppXGtCRRSDsm3Zjv6xz0HWaBwfORJLxilMzhdLEG3XsjzIVAdy2LJWKI4b

-- Dumped from database version 16.10
-- Dumped by pg_dump version 16.10

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: BOM_xref; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."BOM_xref" (
    equipment_id character varying(50) NOT NULL,
    item_id character varying(20) NOT NULL,
    installation_qty integer,
    installation_unit character varying(10),
    delivery_time integer,
    failure_rate_per_million numeric(10,4),
    mtbf_hours integer,
    mttr_hours numeric(10,2),
    is_repairable character(1),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_is_repairable CHECK (((is_repairable = ANY (ARRAY['Y'::bpchar, 'N'::bpchar])) OR (is_repairable IS NULL)))
);


ALTER TABLE public."BOM_xref" OWNER TO postgres;

--
-- Name: TABLE "BOM_xref"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public."BOM_xref" IS '裝備品項關聯檔（裝備-品項多對多，含可靠度資料）';


--
-- Name: COLUMN "BOM_xref".equipment_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public."BOM_xref".equipment_id IS '單機識別碼';


--
-- Name: COLUMN "BOM_xref".item_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public."BOM_xref".item_id IS '品項識別碼';


--
-- Name: COLUMN "BOM_xref".installation_qty; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public."BOM_xref".installation_qty IS '單機零附件裝置數';


--
-- Name: COLUMN "BOM_xref".installation_unit; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public."BOM_xref".installation_unit IS '單機零附件裝置單位';


--
-- Name: COLUMN "BOM_xref".delivery_time; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public."BOM_xref".delivery_time IS '交貨時間（天）';


--
-- Name: COLUMN "BOM_xref".failure_rate_per_million; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public."BOM_xref".failure_rate_per_million IS '每百萬小時預估故障次數';


--
-- Name: COLUMN "BOM_xref".mtbf_hours; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public."BOM_xref".mtbf_hours IS '平均故障間隔（小時）';


--
-- Name: COLUMN "BOM_xref".mttr_hours; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public."BOM_xref".mttr_hours IS '平均修護時間（小時）';


--
-- Name: COLUMN "BOM_xref".is_repairable; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public."BOM_xref".is_repairable IS '是否為可修件（Y/N）';


--
-- Name: COLUMN "BOM_xref".created_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public."BOM_xref".created_at IS '建立時間';


--
-- Name: COLUMN "BOM_xref".updated_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public."BOM_xref".updated_at IS '更新時間';


--
-- Name: applicationattachment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.applicationattachment (
    attachment_id integer NOT NULL,
    form_id integer NOT NULL,
    file_name character varying(200) NOT NULL,
    file_type character varying(20),
    file_path character varying(500) NOT NULL,
    file_size integer,
    description character varying(200),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.applicationattachment OWNER TO postgres;

--
-- Name: TABLE applicationattachment; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.applicationattachment IS '申編單附件檔';


--
-- Name: COLUMN applicationattachment.attachment_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.applicationattachment.attachment_id IS '附件ID（自動編號）';


--
-- Name: COLUMN applicationattachment.form_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.applicationattachment.form_id IS '表單ID';


--
-- Name: COLUMN applicationattachment.file_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.applicationattachment.file_name IS '檔案名稱';


--
-- Name: COLUMN applicationattachment.file_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.applicationattachment.file_type IS '檔案類型（PDF/PNG/JPG等）';


--
-- Name: COLUMN applicationattachment.file_path; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.applicationattachment.file_path IS '檔案路徑';


--
-- Name: COLUMN applicationattachment.file_size; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.applicationattachment.file_size IS '檔案大小（bytes）';


--
-- Name: COLUMN applicationattachment.description; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.applicationattachment.description IS '附件說明';


--
-- Name: COLUMN applicationattachment.created_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.applicationattachment.created_at IS '建立時間';


--
-- Name: COLUMN applicationattachment.updated_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.applicationattachment.updated_at IS '更新時間';


--
-- Name: applicationattachment_attachment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.applicationattachment_attachment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.applicationattachment_attachment_id_seq OWNER TO postgres;

--
-- Name: applicationattachment_attachment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.applicationattachment_attachment_id_seq OWNED BY public.applicationattachment.attachment_id;


--
-- Name: applicationform; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.applicationform (
    form_id integer NOT NULL,
    form_no character varying(50),
    item_seq integer,
    submit_status character varying(20),
    applicant_accounting_code character varying(20),
    item_id character varying(20),
    document_source character varying(100),
    created_date date DEFAULT CURRENT_DATE,
    updated_date date DEFAULT CURRENT_DATE,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.applicationform OWNER TO postgres;

--
-- Name: TABLE applicationform; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.applicationform IS '申編單';


--
-- Name: COLUMN applicationform.form_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.applicationform.form_id IS '表單ID（自動編號）';


--
-- Name: COLUMN applicationform.form_no; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.applicationform.form_no IS '表單編號';


--
-- Name: COLUMN applicationform.item_seq; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.applicationform.item_seq IS '項次';


--
-- Name: COLUMN applicationform.submit_status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.applicationform.submit_status IS '申編單提送狀態';


--
-- Name: COLUMN applicationform.applicant_accounting_code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.applicationform.applicant_accounting_code IS '申請單位會計編號';


--
-- Name: COLUMN applicationform.item_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.applicationform.item_id IS '品項識別碼';


--
-- Name: COLUMN applicationform.document_source; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.applicationform.document_source IS '文件來源';


--
-- Name: COLUMN applicationform.created_date; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.applicationform.created_date IS '建立日期';


--
-- Name: COLUMN applicationform.updated_date; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.applicationform.updated_date IS '更新日期';


--
-- Name: COLUMN applicationform.created_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.applicationform.created_at IS '建立時間';


--
-- Name: COLUMN applicationform.updated_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.applicationform.updated_at IS '更新時間';


--
-- Name: applicationform_form_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.applicationform_form_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.applicationform_form_id_seq OWNER TO postgres;

--
-- Name: applicationform_form_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.applicationform_form_id_seq OWNED BY public.applicationform.form_id;


--
-- Name: equipment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.equipment (
    equipment_id character varying(50) NOT NULL,
    equipment_name_zh character varying(100),
    equipment_name_en character varying(200),
    equipment_type character varying(50),
    ship_type character varying(50),
    "position" character varying(100),
    parent_cid character varying(50),
    eswbs_code character varying(20),
    system_function_name character varying(200),
    installation_qty integer,
    total_installation_qty integer,
    maintenance_level character varying(10),
    equipment_serial character varying(50),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    specification text
);


ALTER TABLE public.equipment OWNER TO postgres;

--
-- Name: TABLE equipment; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.equipment IS '裝備主檔（核心表）';


--
-- Name: COLUMN equipment.equipment_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipment.equipment_id IS '單機識別碼（CID）';


--
-- Name: COLUMN equipment.equipment_name_zh; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipment.equipment_name_zh IS '裝備中文名稱';


--
-- Name: COLUMN equipment.equipment_name_en; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipment.equipment_name_en IS '裝備英文名稱';


--
-- Name: COLUMN equipment.equipment_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipment.equipment_type IS '型式';


--
-- Name: COLUMN equipment.ship_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipment.ship_type IS '艦型';


--
-- Name: COLUMN equipment."position"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipment."position" IS '位置';


--
-- Name: COLUMN equipment.parent_cid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipment.parent_cid IS '上層適用裝備單機識別碼';


--
-- Name: COLUMN equipment.eswbs_code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipment.eswbs_code IS 'ESWBS（五碼）/族群結構碼';


--
-- Name: COLUMN equipment.system_function_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipment.system_function_name IS '系統功能名稱';


--
-- Name: COLUMN equipment.installation_qty; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipment.installation_qty IS '裝置數';


--
-- Name: COLUMN equipment.total_installation_qty; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipment.total_installation_qty IS '全艦裝置數';


--
-- Name: COLUMN equipment.maintenance_level; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipment.maintenance_level IS '裝備維修等級代碼';


--
-- Name: COLUMN equipment.equipment_serial; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipment.equipment_serial IS '裝備識別編號';


--
-- Name: COLUMN equipment.created_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipment.created_at IS '建立時間';


--
-- Name: COLUMN equipment.updated_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipment.updated_at IS '更新時間';


--
-- Name: COLUMN equipment.specification; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipment.specification IS '裝備規格說明（原 EquipmentSpecification 表合併）';


--
-- Name: equipment_document_xref; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.equipment_document_xref (
    equipment_id character varying(50) NOT NULL,
    document_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.equipment_document_xref OWNER TO postgres;

--
-- Name: TABLE equipment_document_xref; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.equipment_document_xref IS '裝備文件關聯檔（裝備-技術文件多對多）';


--
-- Name: COLUMN equipment_document_xref.equipment_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipment_document_xref.equipment_id IS '單機識別碼';


--
-- Name: COLUMN equipment_document_xref.document_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipment_document_xref.document_id IS '文件ID';


--
-- Name: COLUMN equipment_document_xref.created_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipment_document_xref.created_at IS '建立時間';


--
-- Name: COLUMN equipment_document_xref.updated_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipment_document_xref.updated_at IS '更新時間';


--
-- Name: equipmentapplication; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.equipmentapplication (
    application_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    seq_no integer,
    suggested_prefix character varying(10),
    approved_cid character varying(50),
    equipment_name_zh character varying(100),
    equipment_name_en character varying(200),
    cage_code character varying(20),
    part_number character varying(50),
    applicant_name character varying(100),
    serial_number character varying(50),
    equipment_id character varying(50)
);


ALTER TABLE public.equipmentapplication OWNER TO postgres;

--
-- Name: TABLE equipmentapplication; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.equipmentapplication IS 'CID申請表：管理裝備識別碼申請流程';


--
-- Name: COLUMN equipmentapplication.application_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipmentapplication.application_id IS '申請單ID (UUID)';


--
-- Name: COLUMN equipmentapplication.seq_no; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipmentapplication.seq_no IS '項次';


--
-- Name: COLUMN equipmentapplication.suggested_prefix; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipmentapplication.suggested_prefix IS '建議前兩碼';


--
-- Name: COLUMN equipmentapplication.approved_cid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipmentapplication.approved_cid IS '核定CID';


--
-- Name: COLUMN equipmentapplication.equipment_name_zh; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipmentapplication.equipment_name_zh IS '裝備中文名稱';


--
-- Name: COLUMN equipmentapplication.equipment_name_en; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipmentapplication.equipment_name_en IS '裝備英文名稱';


--
-- Name: COLUMN equipmentapplication.cage_code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipmentapplication.cage_code IS '廠家代號';


--
-- Name: COLUMN equipmentapplication.part_number; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipmentapplication.part_number IS '配件號碼';


--
-- Name: COLUMN equipmentapplication.applicant_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipmentapplication.applicant_name IS '申請人';


--
-- Name: COLUMN equipmentapplication.serial_number; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipmentapplication.serial_number IS '流水號';


--
-- Name: COLUMN equipmentapplication.equipment_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.equipmentapplication.equipment_id IS '關聯裝備ID';


--
-- Name: item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.item (
    item_id character varying(20) NOT NULL,
    item_id_last5 character varying(5),
    nsn character varying(20),
    item_category character varying(10),
    item_name_zh character varying(100),
    item_name_zh_short character varying(20),
    item_name_en character varying(200),
    item_code character varying(10),
    fiig character varying(10),
    weapon_system_code character varying(20),
    accounting_code character varying(20),
    issue_unit character varying(10),
    unit_price_usd numeric(10,2),
    package_qty integer,
    weight_kg numeric(10,3),
    has_stock boolean DEFAULT false,
    storage_life_code character varying(10),
    file_type_code character varying(10),
    file_type_category character varying(10),
    security_code character varying(10),
    consumable_code character varying(10),
    spec_indicator character varying(10),
    navy_source character varying(50),
    storage_type character varying(20),
    life_process_code character varying(10),
    manufacturing_capacity character varying(10),
    repair_capacity character varying(10),
    source_code character varying(10),
    project_code character varying(20),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_price CHECK ((unit_price_usd >= (0)::numeric)),
    CONSTRAINT chk_weight CHECK ((weight_kg >= (0)::numeric))
);


ALTER TABLE public.item OWNER TO postgres;

--
-- Name: TABLE item; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.item IS '品項主檔（合併ItemAttribute）';


--
-- Name: COLUMN item.item_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.item.item_id IS '品項識別碼';


--
-- Name: COLUMN item.item_id_last5; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.item.item_id_last5 IS '品項識別碼（後五碼）';


--
-- Name: COLUMN item.nsn; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.item.nsn IS 'NSN';


--
-- Name: COLUMN item.item_category; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.item.item_category IS '統一組類別';


--
-- Name: COLUMN item.item_name_zh; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.item.item_name_zh IS '中文品名';


--
-- Name: COLUMN item.item_name_zh_short; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.item.item_name_zh_short IS '中文品名（9字內）';


--
-- Name: COLUMN item.item_name_en; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.item.item_name_en IS '英文品名/INC英文品名';


--
-- Name: COLUMN item.item_code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.item.item_code IS '品名代號';


--
-- Name: COLUMN item.fiig; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.item.fiig IS 'FIIG';


--
-- Name: COLUMN item.weapon_system_code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.item.weapon_system_code IS '武器系統代號';


--
-- Name: COLUMN item.accounting_code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.item.accounting_code IS '會計編號';


--
-- Name: COLUMN item.issue_unit; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.item.issue_unit IS '撥發單位';


--
-- Name: COLUMN item.unit_price_usd; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.item.unit_price_usd IS '美金單價';


--
-- Name: COLUMN item.package_qty; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.item.package_qty IS '單位包裝量';


--
-- Name: COLUMN item.weight_kg; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.item.weight_kg IS '重量（KG）';


--
-- Name: COLUMN item.has_stock; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.item.has_stock IS '有無料號';


--
-- Name: COLUMN item.storage_life_code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.item.storage_life_code IS '存儲壽限代號';


--
-- Name: COLUMN item.file_type_code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.item.file_type_code IS '檔別代號';


--
-- Name: COLUMN item.file_type_category; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.item.file_type_category IS '檔別區分';


--
-- Name: COLUMN item.security_code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.item.security_code IS '機密性代號';


--
-- Name: COLUMN item.consumable_code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.item.consumable_code IS '消耗性代號';


--
-- Name: COLUMN item.spec_indicator; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.item.spec_indicator IS '規格指示';


--
-- Name: COLUMN item.navy_source; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.item.navy_source IS '海軍軍品來源';


--
-- Name: COLUMN item.storage_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.item.storage_type IS '儲存型式';


--
-- Name: COLUMN item.life_process_code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.item.life_process_code IS '壽限處理代號';


--
-- Name: COLUMN item.manufacturing_capacity; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.item.manufacturing_capacity IS '製造能量';


--
-- Name: COLUMN item.repair_capacity; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.item.repair_capacity IS '修理能量';


--
-- Name: COLUMN item.source_code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.item.source_code IS '來源代號';


--
-- Name: COLUMN item.project_code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.item.project_code IS '專案代號';


--
-- Name: COLUMN item.created_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.item.created_at IS '建立時間';


--
-- Name: COLUMN item.updated_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.item.updated_at IS '更新時間';


--
-- Name: itemspecification; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.itemspecification (
    spec_id integer NOT NULL,
    item_id character varying(20),
    spec_no integer,
    spec_abbr character varying(20),
    spec_en character varying(200),
    spec_zh character varying(200),
    answer_en character varying(200),
    answer_zh character varying(200),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.itemspecification OWNER TO postgres;

--
-- Name: TABLE itemspecification; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.itemspecification IS '品項規格檔(MRC)';


--
-- Name: COLUMN itemspecification.spec_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.itemspecification.spec_id IS '規格ID（自動編號）';


--
-- Name: COLUMN itemspecification.item_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.itemspecification.item_id IS '品項識別碼';


--
-- Name: COLUMN itemspecification.spec_no; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.itemspecification.spec_no IS '規格編號（1-5）';


--
-- Name: COLUMN itemspecification.spec_abbr; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.itemspecification.spec_abbr IS '規格資料縮寫';


--
-- Name: COLUMN itemspecification.spec_en; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.itemspecification.spec_en IS '規格資料英文';


--
-- Name: COLUMN itemspecification.spec_zh; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.itemspecification.spec_zh IS '規格資料翻譯';


--
-- Name: COLUMN itemspecification.answer_en; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.itemspecification.answer_en IS '英答';


--
-- Name: COLUMN itemspecification.answer_zh; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.itemspecification.answer_zh IS '中答';


--
-- Name: COLUMN itemspecification.created_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.itemspecification.created_at IS '建立時間';


--
-- Name: COLUMN itemspecification.updated_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.itemspecification.updated_at IS '更新時間';


--
-- Name: itemspecification_spec_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.itemspecification_spec_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.itemspecification_spec_id_seq OWNER TO postgres;

--
-- Name: itemspecification_spec_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.itemspecification_spec_id_seq OWNED BY public.itemspecification.spec_id;


--
-- Name: part_number_xref; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.part_number_xref (
    part_number_id integer NOT NULL,
    part_number character varying(50),
    item_id character varying(20),
    supplier_id integer,
    obtain_level character varying(10),
    obtain_source character varying(50),
    is_primary boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.part_number_xref OWNER TO postgres;

--
-- Name: TABLE part_number_xref; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.part_number_xref IS '零件號碼關聯檔（品項-供應商多對多）';


--
-- Name: COLUMN part_number_xref.part_number_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.part_number_xref.part_number_id IS '零件號碼ID（自動編號）';


--
-- Name: COLUMN part_number_xref.part_number; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.part_number_xref.part_number IS '配件號碼（P/N）';


--
-- Name: COLUMN part_number_xref.item_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.part_number_xref.item_id IS '品項識別碼';


--
-- Name: COLUMN part_number_xref.supplier_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.part_number_xref.supplier_id IS '廠商ID';


--
-- Name: COLUMN part_number_xref.obtain_level; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.part_number_xref.obtain_level IS 'P/N獲得程度/參考號獲得程度';


--
-- Name: COLUMN part_number_xref.obtain_source; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.part_number_xref.obtain_source IS 'P/N獲得來源/參考號獲得來源';


--
-- Name: COLUMN part_number_xref.is_primary; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.part_number_xref.is_primary IS '是否為主要零件號';


--
-- Name: COLUMN part_number_xref.created_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.part_number_xref.created_at IS '建立時間';


--
-- Name: COLUMN part_number_xref.updated_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.part_number_xref.updated_at IS '更新時間';


--
-- Name: part_number_xref_part_number_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.part_number_xref_part_number_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.part_number_xref_part_number_id_seq OWNER TO postgres;

--
-- Name: part_number_xref_part_number_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.part_number_xref_part_number_id_seq OWNED BY public.part_number_xref.part_number_id;


--
-- Name: supplier; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.supplier (
    supplier_id integer NOT NULL,
    supplier_code character varying(20),
    cage_code character varying(20),
    supplier_name_en character varying(200),
    supplier_name_zh character varying(100),
    supplier_type character varying(20),
    country_code character varying(10),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.supplier OWNER TO postgres;

--
-- Name: TABLE supplier; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.supplier IS '廠商主檔';


--
-- Name: COLUMN supplier.supplier_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.supplier.supplier_id IS '廠商ID（自動編號）';


--
-- Name: COLUMN supplier.supplier_code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.supplier.supplier_code IS '廠商來源代號';


--
-- Name: COLUMN supplier.cage_code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.supplier.cage_code IS '廠家登記代號';


--
-- Name: COLUMN supplier.supplier_name_en; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.supplier.supplier_name_en IS '廠家製造商（英文）';


--
-- Name: COLUMN supplier.supplier_name_zh; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.supplier.supplier_name_zh IS '廠商中文名稱';


--
-- Name: COLUMN supplier.supplier_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.supplier.supplier_type IS '廠商類型（製造商/代理商）';


--
-- Name: COLUMN supplier.country_code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.supplier.country_code IS '國家代碼';


--
-- Name: COLUMN supplier.created_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.supplier.created_at IS '建立時間';


--
-- Name: COLUMN supplier.updated_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.supplier.updated_at IS '更新時間';


--
-- Name: supplier_supplier_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.supplier_supplier_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.supplier_supplier_id_seq OWNER TO postgres;

--
-- Name: supplier_supplier_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.supplier_supplier_id_seq OWNED BY public.supplier.supplier_id;


--
-- Name: supplierapplication; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.supplierapplication (
    application_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    seq_no integer,
    equipment_name character varying(200),
    supplier_name character varying(200),
    address character varying(500),
    phone character varying(50),
    business_scope character varying(500),
    cage_code character varying(20),
    applicant_name character varying(100),
    serial_number character varying(50),
    supplier_id integer
);


ALTER TABLE public.supplierapplication OWNER TO postgres;

--
-- Name: TABLE supplierapplication; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.supplierapplication IS '廠商代號申請表：管理廠商代號申請流程';


--
-- Name: COLUMN supplierapplication.application_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.supplierapplication.application_id IS '申請單ID (UUID)';


--
-- Name: COLUMN supplierapplication.seq_no; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.supplierapplication.seq_no IS '項次';


--
-- Name: COLUMN supplierapplication.equipment_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.supplierapplication.equipment_name IS '裝備名稱';


--
-- Name: COLUMN supplierapplication.supplier_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.supplierapplication.supplier_name IS '廠商名稱';


--
-- Name: COLUMN supplierapplication.address; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.supplierapplication.address IS '地址';


--
-- Name: COLUMN supplierapplication.phone; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.supplierapplication.phone IS '電話';


--
-- Name: COLUMN supplierapplication.business_scope; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.supplierapplication.business_scope IS '營業項目';


--
-- Name: COLUMN supplierapplication.cage_code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.supplierapplication.cage_code IS '廠家代號';


--
-- Name: COLUMN supplierapplication.applicant_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.supplierapplication.applicant_name IS '申請人';


--
-- Name: COLUMN supplierapplication.serial_number; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.supplierapplication.serial_number IS '流水號';


--
-- Name: COLUMN supplierapplication.supplier_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.supplierapplication.supplier_id IS '關聯廠商ID';


--
-- Name: technicaldocument; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.technicaldocument (
    document_id integer NOT NULL,
    document_name character varying(200),
    document_version character varying(20),
    shipyard_drawing_no character varying(50),
    design_drawing_no character varying(50),
    document_type character varying(20),
    document_category character varying(20),
    language character varying(10),
    security_level character varying(10),
    eswbs_code character varying(20),
    accounting_code character varying(20),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.technicaldocument OWNER TO postgres;

--
-- Name: TABLE technicaldocument; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.technicaldocument IS '技術文件檔（獨立主檔）';


--
-- Name: COLUMN technicaldocument.document_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.technicaldocument.document_id IS '文件ID（自動編號）';


--
-- Name: COLUMN technicaldocument.document_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.technicaldocument.document_name IS '圖名/書名';


--
-- Name: COLUMN technicaldocument.document_version; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.technicaldocument.document_version IS '技術文件版別/版次';


--
-- Name: COLUMN technicaldocument.shipyard_drawing_no; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.technicaldocument.shipyard_drawing_no IS '船廠圖號';


--
-- Name: COLUMN technicaldocument.design_drawing_no; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.technicaldocument.design_drawing_no IS '設計圖號';


--
-- Name: COLUMN technicaldocument.document_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.technicaldocument.document_type IS '資料類型';


--
-- Name: COLUMN technicaldocument.document_category; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.technicaldocument.document_category IS '資料類別';


--
-- Name: COLUMN technicaldocument.language; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.technicaldocument.language IS '語言';


--
-- Name: COLUMN technicaldocument.security_level; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.technicaldocument.security_level IS '機密等級';


--
-- Name: COLUMN technicaldocument.eswbs_code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.technicaldocument.eswbs_code IS 'ESWBS（五碼）';


--
-- Name: COLUMN technicaldocument.accounting_code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.technicaldocument.accounting_code IS '會計編號';


--
-- Name: COLUMN technicaldocument.created_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.technicaldocument.created_at IS '建立時間';


--
-- Name: COLUMN technicaldocument.updated_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.technicaldocument.updated_at IS '更新時間';


--
-- Name: technicaldocument_document_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.technicaldocument_document_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.technicaldocument_document_id_seq OWNER TO postgres;

--
-- Name: technicaldocument_document_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.technicaldocument_document_id_seq OWNED BY public.technicaldocument.document_id;


--
-- Name: applicationattachment attachment_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.applicationattachment ALTER COLUMN attachment_id SET DEFAULT nextval('public.applicationattachment_attachment_id_seq'::regclass);


--
-- Name: applicationform form_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.applicationform ALTER COLUMN form_id SET DEFAULT nextval('public.applicationform_form_id_seq'::regclass);


--
-- Name: itemspecification spec_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.itemspecification ALTER COLUMN spec_id SET DEFAULT nextval('public.itemspecification_spec_id_seq'::regclass);


--
-- Name: part_number_xref part_number_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.part_number_xref ALTER COLUMN part_number_id SET DEFAULT nextval('public.part_number_xref_part_number_id_seq'::regclass);


--
-- Name: supplier supplier_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.supplier ALTER COLUMN supplier_id SET DEFAULT nextval('public.supplier_supplier_id_seq'::regclass);


--
-- Name: technicaldocument document_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.technicaldocument ALTER COLUMN document_id SET DEFAULT nextval('public.technicaldocument_document_id_seq'::regclass);


--
-- Data for Name: BOM_xref; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."BOM_xref" (equipment_id, item_id, installation_qty, installation_unit, delivery_time, failure_rate_per_million, mtbf_hours, mttr_hours, is_repairable, created_at, updated_at) FROM stdin;
64NYE0002	YETL申請中	1	EA	\N	\N	\N	\N	\N	2025-11-14 20:44:42.241277	2025-11-14 20:44:42.241277
64NYE0002	015448871	1	EA	\N	\N	\N	\N	\N	2025-11-14 20:44:42.241277	2025-11-14 20:44:42.241277
64NYE0002	014408428	1	EA	\N	\N	\N	\N	\N	2025-11-14 20:44:42.241277	2025-11-14 20:44:42.241277
64NYE0002	015974145	2	EA	\N	\N	\N	\N	\N	2025-11-14 20:44:42.241277	2025-11-14 20:44:42.241277
64NYE0002	014485107	2	EA	\N	\N	\N	\N	\N	2025-11-14 20:44:42.241277	2025-11-14 20:44:42.241277
64NYE0002	015723759	10	EA	\N	\N	\N	\N	\N	2025-11-14 20:44:42.241277	2025-11-14 20:44:42.241277
64NYE0002	016780181	1	EA	\N	\N	\N	\N	\N	2025-11-14 20:44:42.241277	2025-11-14 20:44:42.241277
64NYE0002	015650379	1	EA	\N	\N	\N	\N	\N	2025-11-14 20:44:42.241277	2025-11-14 20:44:42.241277
64NYE0002	011664481	2	EA	\N	\N	\N	\N	\N	2025-11-14 20:44:42.241277	2025-11-14 20:44:42.241277
64NYE0002	014408419	1	EA	\N	\N	\N	\N	\N	2025-11-14 20:44:42.241277	2025-11-14 20:44:42.241277
\.


--
-- Data for Name: applicationattachment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.applicationattachment (attachment_id, form_id, file_name, file_type, file_path, file_size, description, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: applicationform; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.applicationform (form_id, form_no, item_seq, submit_status, applicant_accounting_code, item_id, document_source, created_date, updated_date, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: equipment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.equipment (equipment_id, equipment_name_zh, equipment_name_en, equipment_type, ship_type, "position", parent_cid, eswbs_code, system_function_name, installation_qty, total_installation_qty, maintenance_level, equipment_serial, created_at, updated_at, specification) FROM stdin;
64NYE0002	廚房通風煙道及油炸鍋滅火系統	Wet Chemical System For Deep Fat Fryer	R-102	FFG	前/後機艙	0	55561	\N	1	1	O	2	2025-11-14 20:44:42.202884	2025-11-14 21:24:05.314995	\N
\.


--
-- Data for Name: equipment_document_xref; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.equipment_document_xref (equipment_id, document_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: equipmentapplication; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.equipmentapplication (application_id, created_at, updated_at, seq_no, suggested_prefix, approved_cid, equipment_name_zh, equipment_name_en, cage_code, part_number, applicant_name, serial_number, equipment_id) FROM stdin;
\.


--
-- Data for Name: item; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.item (item_id, item_id_last5, nsn, item_category, item_name_zh, item_name_zh_short, item_name_en, item_code, fiig, weapon_system_code, accounting_code, issue_unit, unit_price_usd, package_qty, weight_kg, has_stock, storage_life_code, file_type_code, file_type_category, security_code, consumable_code, spec_indicator, navy_source, storage_type, life_process_code, manufacturing_capacity, repair_capacity, source_code, project_code, created_at, updated_at) FROM stdin;
013699819	99819	\N	4210	廚房用油鍋滅火系統	廚房用油鍋滅火系統	 EXTINGUISHER, FIRE	42700	\N	C35	B21317	SE	15000.00	1	0.000	f	0	E	C	U	N	E	\N	R	0	E	9	C	4	2025-11-14 20:44:42.215843	2025-11-14 20:44:42.215843
YETL申請中	TL申請中	\N	4210	釋放箱含藥劑桶	釋放箱含藥劑桶	\tCONTROL HEAD,MECHANICAL,FIRE SUPPRESSION SYSTEM	39503	\N	C35	B21317	EA	5370.00	1	0.000	f	0	C	C	U	N	E	\N	R	0	E	9	C	4	2025-11-14 20:44:42.215843	2025-11-14 20:44:42.215843
015448871	48871	\N	4210	噴嘴 2W	噴嘴 2W	NOZZLE, FIRE EXTINGUISHER	45023	\N	C35	B21317	EA	250.00	1	0.000	f	0	C	C	U	X	E	\N	R	0	E	0	C	4	2025-11-14 20:44:42.215843	2025-11-14 20:44:42.215843
014408428	08428	\N	4210	低pH濕式化學藥劑	低pH濕式化學藥劑	 FOAM LIQUID, FIRE EXTINGUISHING	6370	\N	C35	B21317	EA	1500.00	1	0.000	f	0	C	C	U	X	E	\N	R	0	E	0	C	4	2025-11-14 20:44:42.215843	2025-11-14 20:44:42.215843
015974145	74145	\N	6350	熱融片剪式聯動夾	熱融片剪式聯動夾	DETECTOR SCISS,SPEC	77777	\N	C35	B21317	EA	300.00	2	0.000	f	0	C	C	U	X	E	\N	R	0	E	0	C	4	2025-11-14 20:44:42.215843	2025-11-14 20:44:42.215843
014485107	85107	\N	4210	熱融片固定座	熱融片固定座	FIRE SYSTE DETECTOR	77777	\N	C35	B21317	EA	500.00	2	0.000	f	0	C	C	U	X	E	\N	R	0	E	0	C	4	2025-11-14 20:44:42.215843	2025-11-14 20:44:42.215843
015723759	23759	\N	3940	滑輪	滑輪	 BLOCK, TACKLE	6117	\N	C35	B21317	EA	100.00	10	0.000	f	0	C	C	U	X	E	\N	R	0	E	0	C	4	2025-11-14 20:44:42.215843	2025-11-14 20:44:42.215843
016780181	80181	\N	6350	遠端手動釋放站	遠端手動釋放站	STATION,FIRE ALARM,MANUAL	39554	\N	C35	B21317	EA	450.00	1	0.000	f	0	C	C	U	X	E	\N	R	0	E	0	C	4	2025-11-14 20:44:42.215843	2025-11-14 20:44:42.215843
015650379	50379	\N	5930	警報開關	警報開關	SWITCH,SENSITIVE	399	\N	C35	B21317	EA	200.00	1	0.000	f	0	C	C	U	X	E	\N	R	0	E	0	C	4	2025-11-14 20:44:42.215843	2025-11-14 20:44:42.215843
011664481	64481	\N	4210	熱融片	熱融片	 LINK, FUSIBLE, FIRE	8199	\N	C35	B21317	EA	50.00	2	0.000	f	0	C	C	U	X	E	\N	R	0	E	0	C	4	2025-11-14 20:44:42.215843	2025-11-14 20:44:42.215843
014408419	08419	\N	9505	鋼索	鋼索	WIRE, NONELECTRICAL	30889	\N	C35	B21317	EA	200.00	1	0.000	f	0	C	C	U	X	E	\N	R	0	E	0	C	4	2025-11-14 20:44:42.215843	2025-11-14 20:44:42.215843
\.


--
-- Data for Name: itemspecification; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.itemspecification (spec_id, item_id, spec_no, spec_abbr, spec_en, spec_zh, answer_en, answer_zh, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: part_number_xref; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.part_number_xref (part_number_id, part_number, item_id, supplier_id, obtain_level, obtain_source, is_primary, created_at, updated_at) FROM stdin;
2	R-102	013699819	\N	\N	\N	t	2025-11-14 20:44:42.224688	2025-11-14 20:44:42.224688
3	430299	YETL申請中	\N	\N	\N	t	2025-11-14 20:44:42.224688	2025-11-14 20:44:42.224688
4	423435	YETL申請中	\N	\N	\N	t	2025-11-14 20:44:42.224688	2025-11-14 20:44:42.224688
5	427929	YETL申請中	\N	\N	\N	t	2025-11-14 20:44:42.224688	2025-11-14 20:44:42.224688
6	419337	015448871	\N	\N	\N	t	2025-11-14 20:44:42.224688	2025-11-14 20:44:42.224688
7	79372	014408428	\N	\N	\N	t	2025-11-14 20:44:42.224688	2025-11-14 20:44:42.224688
8	435547	015974145	\N	\N	\N	t	2025-11-14 20:44:42.224688	2025-11-14 20:44:42.224688
9	435546	014485107	\N	\N	\N	t	2025-11-14 20:44:42.224688	2025-11-14 20:44:42.224688
10	415670	015723759	\N	\N	\N	t	2025-11-14 20:44:42.224688	2025-11-14 20:44:42.224688
11	434618	016780181	\N	\N	\N	t	2025-11-14 20:44:42.224688	2025-11-14 20:44:42.224688
12	423879	015650379	\N	\N	\N	t	2025-11-14 20:44:42.224688	2025-11-14 20:44:42.224688
13	439089	011664481	\N	\N	\N	t	2025-11-14 20:44:42.224688	2025-11-14 20:44:42.224688
14	15821	014408419	\N	\N	\N	t	2025-11-14 20:44:42.224688	2025-11-14 20:44:42.224688
15	419338	YETL申請中	\N	\N	\N	t	2025-11-14 20:44:42.224688	2025-11-14 20:44:42.224688
16	419335	YETL申請中	\N	\N	\N	t	2025-11-14 20:44:42.224688	2025-11-14 20:44:42.224688
17	441041	YETL申請中	\N	\N	\N	t	2025-11-14 20:44:42.224688	2025-11-14 20:44:42.224688
18	204619	YETL申請中	\N	\N	\N	t	2025-11-14 20:44:42.224688	2025-11-14 20:44:42.224688
19	R-102	013699819	\N	2	3	f	2025-11-14 20:44:42.224688	2025-11-14 20:44:42.224688
20	430299	YETL申請中	\N	2	3	f	2025-11-14 20:44:42.224688	2025-11-14 20:44:42.224688
21	423435	YETL申請中	\N	2	3	f	2025-11-14 20:44:42.224688	2025-11-14 20:44:42.224688
22	427929	YETL申請中	\N	2	3	f	2025-11-14 20:44:42.224688	2025-11-14 20:44:42.224688
23	419337	015448871	\N	2	3	f	2025-11-14 20:44:42.224688	2025-11-14 20:44:42.224688
24	79372	014408428	\N	2	3	f	2025-11-14 20:44:42.224688	2025-11-14 20:44:42.224688
25	435547	015974145	\N	2	3	f	2025-11-14 20:44:42.224688	2025-11-14 20:44:42.224688
26	435546	014485107	\N	2	3	f	2025-11-14 20:44:42.224688	2025-11-14 20:44:42.224688
27	415670	015723759	\N	2	3	f	2025-11-14 20:44:42.224688	2025-11-14 20:44:42.224688
28	434618	016780181	\N	2	3	f	2025-11-14 20:44:42.224688	2025-11-14 20:44:42.224688
29	423879	015650379	\N	2	3	f	2025-11-14 20:44:42.224688	2025-11-14 20:44:42.224688
30	439089	011664481	\N	2	3	f	2025-11-14 20:44:42.224688	2025-11-14 20:44:42.224688
31	15821	014408419	\N	2	3	f	2025-11-14 20:44:42.224688	2025-11-14 20:44:42.224688
32	419338	YETL申請中	\N	2	3	f	2025-11-14 20:44:42.224688	2025-11-14 20:44:42.224688
33	419335	YETL申請中	\N	2	3	f	2025-11-14 20:44:42.224688	2025-11-14 20:44:42.224688
34	441041	YETL申請中	\N	2	3	f	2025-11-14 20:44:42.224688	2025-11-14 20:44:42.224688
35	204619	YETL申請中	\N	2	3	f	2025-11-14 20:44:42.224688	2025-11-14 20:44:42.224688
36	R-102	013699819	\N	\N	\N	t	2025-11-14 21:24:05.323944	2025-11-14 21:24:05.323944
37	430299	YETL申請中	\N	\N	\N	t	2025-11-14 21:24:05.323944	2025-11-14 21:24:05.323944
38	423435	YETL申請中	\N	\N	\N	t	2025-11-14 21:24:05.323944	2025-11-14 21:24:05.323944
39	427929	YETL申請中	\N	\N	\N	t	2025-11-14 21:24:05.323944	2025-11-14 21:24:05.323944
40	419337	015448871	\N	\N	\N	t	2025-11-14 21:24:05.323944	2025-11-14 21:24:05.323944
41	79372	014408428	\N	\N	\N	t	2025-11-14 21:24:05.323944	2025-11-14 21:24:05.323944
42	435547	015974145	\N	\N	\N	t	2025-11-14 21:24:05.323944	2025-11-14 21:24:05.323944
43	435546	014485107	\N	\N	\N	t	2025-11-14 21:24:05.323944	2025-11-14 21:24:05.323944
44	415670	015723759	\N	\N	\N	t	2025-11-14 21:24:05.323944	2025-11-14 21:24:05.323944
45	434618	016780181	\N	\N	\N	t	2025-11-14 21:24:05.323944	2025-11-14 21:24:05.323944
46	423879	015650379	\N	\N	\N	t	2025-11-14 21:24:05.323944	2025-11-14 21:24:05.323944
47	439089	011664481	\N	\N	\N	t	2025-11-14 21:24:05.323944	2025-11-14 21:24:05.323944
48	15821	014408419	\N	\N	\N	t	2025-11-14 21:24:05.323944	2025-11-14 21:24:05.323944
49	419338	YETL申請中	\N	\N	\N	t	2025-11-14 21:24:05.323944	2025-11-14 21:24:05.323944
50	419335	YETL申請中	\N	\N	\N	t	2025-11-14 21:24:05.323944	2025-11-14 21:24:05.323944
51	441041	YETL申請中	\N	\N	\N	t	2025-11-14 21:24:05.323944	2025-11-14 21:24:05.323944
52	204619	YETL申請中	\N	\N	\N	t	2025-11-14 21:24:05.323944	2025-11-14 21:24:05.323944
53	R-102	013699819	\N	2	3	f	2025-11-14 21:24:05.323944	2025-11-14 21:24:05.323944
54	430299	YETL申請中	\N	2	3	f	2025-11-14 21:24:05.323944	2025-11-14 21:24:05.323944
55	423435	YETL申請中	\N	2	3	f	2025-11-14 21:24:05.323944	2025-11-14 21:24:05.323944
56	427929	YETL申請中	\N	2	3	f	2025-11-14 21:24:05.323944	2025-11-14 21:24:05.323944
57	419337	015448871	\N	2	3	f	2025-11-14 21:24:05.323944	2025-11-14 21:24:05.323944
58	79372	014408428	\N	2	3	f	2025-11-14 21:24:05.323944	2025-11-14 21:24:05.323944
59	435547	015974145	\N	2	3	f	2025-11-14 21:24:05.323944	2025-11-14 21:24:05.323944
60	435546	014485107	\N	2	3	f	2025-11-14 21:24:05.323944	2025-11-14 21:24:05.323944
61	415670	015723759	\N	2	3	f	2025-11-14 21:24:05.323944	2025-11-14 21:24:05.323944
62	434618	016780181	\N	2	3	f	2025-11-14 21:24:05.323944	2025-11-14 21:24:05.323944
63	423879	015650379	\N	2	3	f	2025-11-14 21:24:05.323944	2025-11-14 21:24:05.323944
64	439089	011664481	\N	2	3	f	2025-11-14 21:24:05.323944	2025-11-14 21:24:05.323944
65	15821	014408419	\N	2	3	f	2025-11-14 21:24:05.323944	2025-11-14 21:24:05.323944
66	419338	YETL申請中	\N	2	3	f	2025-11-14 21:24:05.323944	2025-11-14 21:24:05.323944
67	419335	YETL申請中	\N	2	3	f	2025-11-14 21:24:05.323944	2025-11-14 21:24:05.323944
68	441041	YETL申請中	\N	2	3	f	2025-11-14 21:24:05.323944	2025-11-14 21:24:05.323944
69	204619	YETL申請中	\N	2	3	f	2025-11-14 21:24:05.323944	2025-11-14 21:24:05.323944
\.


--
-- Data for Name: supplier; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.supplier (supplier_id, supplier_code, cage_code, supplier_name_en, supplier_name_zh, supplier_type, country_code, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: supplierapplication; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.supplierapplication (application_id, created_at, updated_at, seq_no, equipment_name, supplier_name, address, phone, business_scope, cage_code, applicant_name, serial_number, supplier_id) FROM stdin;
\.


--
-- Data for Name: technicaldocument; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.technicaldocument (document_id, document_name, document_version, shipyard_drawing_no, design_drawing_no, document_type, document_category, language, security_level, eswbs_code, accounting_code, created_at, updated_at) FROM stdin;
\.


--
-- Name: applicationattachment_attachment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.applicationattachment_attachment_id_seq', 1, false);


--
-- Name: applicationform_form_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.applicationform_form_id_seq', 1, false);


--
-- Name: itemspecification_spec_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.itemspecification_spec_id_seq', 1, false);


--
-- Name: part_number_xref_part_number_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.part_number_xref_part_number_id_seq', 69, true);


--
-- Name: supplier_supplier_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.supplier_supplier_id_seq', 11, true);


--
-- Name: technicaldocument_document_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.technicaldocument_document_id_seq', 3, true);


--
-- Name: applicationattachment applicationattachment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.applicationattachment
    ADD CONSTRAINT applicationattachment_pkey PRIMARY KEY (attachment_id);


--
-- Name: applicationform applicationform_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.applicationform
    ADD CONSTRAINT applicationform_pkey PRIMARY KEY (form_id);


--
-- Name: equipment_document_xref equipment_document_xref_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipment_document_xref
    ADD CONSTRAINT equipment_document_xref_pkey PRIMARY KEY (equipment_id, document_id);


--
-- Name: BOM_xref equipment_item_xref_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."BOM_xref"
    ADD CONSTRAINT equipment_item_xref_pkey PRIMARY KEY (equipment_id, item_id);


--
-- Name: equipment equipment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipment
    ADD CONSTRAINT equipment_pkey PRIMARY KEY (equipment_id);


--
-- Name: equipmentapplication equipmentapplication_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipmentapplication
    ADD CONSTRAINT equipmentapplication_pkey PRIMARY KEY (application_id);


--
-- Name: item item_nsn_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item
    ADD CONSTRAINT item_nsn_key UNIQUE (nsn);


--
-- Name: item item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item
    ADD CONSTRAINT item_pkey PRIMARY KEY (item_id);


--
-- Name: itemspecification itemspecification_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.itemspecification
    ADD CONSTRAINT itemspecification_pkey PRIMARY KEY (spec_id);


--
-- Name: part_number_xref part_number_xref_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.part_number_xref
    ADD CONSTRAINT part_number_xref_pkey PRIMARY KEY (part_number_id);


--
-- Name: supplier supplier_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.supplier
    ADD CONSTRAINT supplier_pkey PRIMARY KEY (supplier_id);


--
-- Name: supplier supplier_supplier_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.supplier
    ADD CONSTRAINT supplier_supplier_code_key UNIQUE (supplier_code);


--
-- Name: supplierapplication supplierapplication_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.supplierapplication
    ADD CONSTRAINT supplierapplication_pkey PRIMARY KEY (application_id);


--
-- Name: technicaldocument technicaldocument_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.technicaldocument
    ADD CONSTRAINT technicaldocument_pkey PRIMARY KEY (document_id);


--
-- Name: supplier uk_cage_code; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.supplier
    ADD CONSTRAINT uk_cage_code UNIQUE (cage_code);


--
-- Name: equipment uk_equipment_serial; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipment
    ADD CONSTRAINT uk_equipment_serial UNIQUE (equipment_serial);


--
-- Name: part_number_xref unique_part; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.part_number_xref
    ADD CONSTRAINT unique_part UNIQUE (part_number, item_id, supplier_id);


--
-- Name: idx_app_form_item; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_app_form_item ON public.applicationform USING btree (item_id);


--
-- Name: idx_app_form_no; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_app_form_no ON public.applicationform USING btree (form_no);


--
-- Name: idx_app_form_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_app_form_status ON public.applicationform USING btree (submit_status);


--
-- Name: idx_attachment_form; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_attachment_form ON public.applicationattachment USING btree (form_id);


--
-- Name: idx_attachment_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_attachment_type ON public.applicationattachment USING btree (file_type);


--
-- Name: idx_equipment_app_approved_cid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_equipment_app_approved_cid ON public.equipmentapplication USING btree (approved_cid);


--
-- Name: idx_equipment_app_cage; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_equipment_app_cage ON public.equipmentapplication USING btree (cage_code);


--
-- Name: idx_equipment_app_serial; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_equipment_app_serial ON public.equipmentapplication USING btree (serial_number);


--
-- Name: idx_equipment_document; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_equipment_document ON public.equipment_document_xref USING btree (equipment_id, document_id);


--
-- Name: idx_equipment_eswbs; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_equipment_eswbs ON public.equipment USING btree (eswbs_code);


--
-- Name: idx_equipment_item; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_equipment_item ON public."BOM_xref" USING btree (equipment_id, item_id);


--
-- Name: idx_equipment_ship_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_equipment_ship_type ON public.equipment USING btree (ship_type);


--
-- Name: idx_item_accounting_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_item_accounting_code ON public.item USING btree (accounting_code);


--
-- Name: idx_item_category; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_item_category ON public.item USING btree (item_category);


--
-- Name: idx_item_nsn; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_item_nsn ON public.item USING btree (nsn);


--
-- Name: idx_item_spec; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_item_spec ON public.itemspecification USING btree (item_id, spec_no);


--
-- Name: idx_item_weapon_system_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_item_weapon_system_code ON public.item USING btree (weapon_system_code);


--
-- Name: idx_part_number; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_part_number ON public.part_number_xref USING btree (part_number);


--
-- Name: idx_part_supplier; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_part_supplier ON public.part_number_xref USING btree (part_number, supplier_id);


--
-- Name: idx_supplier_app_cage; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_supplier_app_cage ON public.supplierapplication USING btree (cage_code);


--
-- Name: idx_supplier_app_serial; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_supplier_app_serial ON public.supplierapplication USING btree (serial_number);


--
-- Name: idx_supplier_cage_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_supplier_cage_code ON public.supplier USING btree (cage_code);


--
-- Name: idx_supplier_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_supplier_code ON public.supplier USING btree (supplier_code);


--
-- Name: idx_tech_doc_eswbs; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tech_doc_eswbs ON public.technicaldocument USING btree (eswbs_code);


--
-- Name: applicationform update_app_form_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_app_form_updated_at BEFORE UPDATE ON public.applicationform FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: applicationattachment update_attachment_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_attachment_updated_at BEFORE UPDATE ON public.applicationattachment FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: equipmentapplication update_equipment_application_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_equipment_application_updated_at BEFORE UPDATE ON public.equipmentapplication FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: equipment_document_xref update_equipment_document_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_equipment_document_updated_at BEFORE UPDATE ON public.equipment_document_xref FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: BOM_xref update_equipment_item_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_equipment_item_updated_at BEFORE UPDATE ON public."BOM_xref" FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: equipment update_equipment_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_equipment_updated_at BEFORE UPDATE ON public.equipment FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: itemspecification update_item_spec_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_item_spec_updated_at BEFORE UPDATE ON public.itemspecification FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: item update_item_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_item_updated_at BEFORE UPDATE ON public.item FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: part_number_xref update_part_number_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_part_number_updated_at BEFORE UPDATE ON public.part_number_xref FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: supplierapplication update_supplier_application_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_supplier_application_updated_at BEFORE UPDATE ON public.supplierapplication FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: supplier update_supplier_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_supplier_updated_at BEFORE UPDATE ON public.supplier FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: technicaldocument update_technical_document_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_technical_document_updated_at BEFORE UPDATE ON public.technicaldocument FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: applicationattachment applicationattachment_form_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.applicationattachment
    ADD CONSTRAINT applicationattachment_form_id_fkey FOREIGN KEY (form_id) REFERENCES public.applicationform(form_id) ON DELETE CASCADE;


--
-- Name: applicationform applicationform_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.applicationform
    ADD CONSTRAINT applicationform_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.item(item_id) ON DELETE SET NULL;


--
-- Name: equipment_document_xref equipment_document_xref_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipment_document_xref
    ADD CONSTRAINT equipment_document_xref_document_id_fkey FOREIGN KEY (document_id) REFERENCES public.technicaldocument(document_id) ON DELETE CASCADE;


--
-- Name: equipment_document_xref equipment_document_xref_equipment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipment_document_xref
    ADD CONSTRAINT equipment_document_xref_equipment_id_fkey FOREIGN KEY (equipment_id) REFERENCES public.equipment(equipment_id) ON DELETE CASCADE;


--
-- Name: BOM_xref equipment_item_xref_equipment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."BOM_xref"
    ADD CONSTRAINT equipment_item_xref_equipment_id_fkey FOREIGN KEY (equipment_id) REFERENCES public.equipment(equipment_id) ON DELETE CASCADE;


--
-- Name: BOM_xref equipment_item_xref_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."BOM_xref"
    ADD CONSTRAINT equipment_item_xref_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.item(item_id) ON DELETE CASCADE;


--
-- Name: equipmentapplication fk_equipment_application_equipment; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipmentapplication
    ADD CONSTRAINT fk_equipment_application_equipment FOREIGN KEY (equipment_id) REFERENCES public.equipment(equipment_id) ON DELETE SET NULL;


--
-- Name: supplierapplication fk_supplier_application_supplier; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.supplierapplication
    ADD CONSTRAINT fk_supplier_application_supplier FOREIGN KEY (supplier_id) REFERENCES public.supplier(supplier_id) ON DELETE SET NULL;


--
-- Name: itemspecification itemspecification_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.itemspecification
    ADD CONSTRAINT itemspecification_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.item(item_id) ON DELETE CASCADE;


--
-- Name: part_number_xref part_number_xref_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.part_number_xref
    ADD CONSTRAINT part_number_xref_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.item(item_id) ON DELETE CASCADE;


--
-- Name: part_number_xref part_number_xref_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.part_number_xref
    ADD CONSTRAINT part_number_xref_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.supplier(supplier_id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

\unrestrict korAwppXGtCRRSDsm3Zjv6xz0HWaBwfORJLxilMzhdLEG3XsjzIVAdy2LJWKI4b

