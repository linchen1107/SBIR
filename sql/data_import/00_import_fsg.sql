-- =================================================================
-- 階段1: FSG (聯邦供應組別) 資料匯入
-- 對應檔案: raw_data/fsg/Tabl316.TXT
-- 目標表格: fsg
-- 依賴: 無
-- =================================================================

BEGIN;

-- 清除現有資料
DELETE FROM fsg;

-- 重設序列
-- ALTER SEQUENCE fsg_id_seq RESTART WITH 1;

INSERT INTO fsg (fsg_code, fsg_title) VALUES ('10', 'Weapons');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('11', 'Nuclear Ordnance');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('12', 'Fire Control Equipment');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('13', 'Ammunition and Explosives');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('14', 'Guided Missiles');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('15', 'Aerospace Craft and Structural Components');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('16', 'Aerospace Craft Components and Accessories');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('17', 'Aerospace Craft Launching, Landing, Ground Handling, and Servicing Equipment');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('18', 'Space Vehicles');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('19', 'Ships, Small Craft, Pontoons, and Floating Docks');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('20', 'Ship and Marine Equipment');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('21', 'Historical FSG');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('22', 'Railway Equipment');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('23', 'Ground Effect Vehicles, Motor Vehicles, Trailers, and Cycles');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('24', 'Tractors');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('25', 'Vehicular Equipment Components');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('26', 'Tires and Tubes');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('28', 'Engines, Turbines, and Components');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('29', 'Engine Accessories');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('30', 'Mechanical Power Transmission Equipment');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('31', 'Bearings');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('32', 'Woodworking Machinery and Equipment');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('33', 'Historical FSG');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('34', 'Metalworking Machinery');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('35', 'Service and Trade Equipment');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('36', 'Special Industry Machinery');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('37', 'Agricultural Machinery and Equipment');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('38', 'Construction, Mining, Excavating, and Highway Maintenance Equipment');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('39', 'Materials Handling Equipment');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('40', 'Rope, Cable, Chain, and Fittings');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('41', 'Refrigeration, Air Conditioning, and Air Circulating Equipment');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('42', 'Firefighting, Rescue, and Safety Equipment; and Environmental Protection Equipment and Materials');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('43', 'Pumps and Compressors');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('44', 'Furnace, Steam Plant, and Drying Equipment; and Nuclear Reactors');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('45', 'Plumbing, Heating, and Waste Disposal Equipment');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('46', 'Water Purification and Sewage Treatment Equipment');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('47', 'Pipe, Tubing, Hose, and Fittings');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('48', 'Valves');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('49', 'Maintenance and Repair Shop Equipment');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('51', 'Hand Tools');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('52', 'Measuring Tools');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('53', 'Hardware and Abrasives');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('54', 'Prefabricated Structures and Scaffolding');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('55', 'Lumber, Millwork, Plywood, and Veneer');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('56', 'Construction and Building Materials');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('58', 'Communication, Detection, and Coherent Radiation Equipment');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('59', 'Electrical and Electronic Equipment Components');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('60', 'Fiber Optics Materials, Components, Assemblies, and Accessories');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('61', 'Electric Wire, and Power and Distribution Equipment');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('62', 'Lighting Fixtures and Lamps');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('63', 'Alarm, Signal and Security Detection Systems');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('65', 'Medical, Dental, and Veterinary Equipment and Supplies');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('66', 'Instruments and Laboratory Equipment');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('67', 'Photographic Equipment');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('68', 'Chemicals and Chemical Products');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('69', 'Training Aids and Devices');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('70', 'Information Technology Equipment (Including Firmware), Software, Supplies and Support Equipment');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('71', 'Furniture');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('72', 'Household and Commercial Furnishings and Appliances');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('73', 'Food Preparation and Serving Equipment');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('74', 'Office Machines, Text Processing Systems and Visible Record Equipment');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('75', 'Office Supplies and Devices');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('76', 'Books, Maps, and Other Publications');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('77', 'Musical Instruments, Phonographs, and Home-Type Radios');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('78', 'Recreational and Athletic Equipment');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('79', 'Cleaning Equipment and Supplies');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('80', 'Brushes, Paints, Sealers, and Adhesives');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('81', 'Containers, Packaging, and Packing Supplies');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('83', 'Textiles, Leather, Furs, Apparel and Shoe Findings, Tents and Flags');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('84', 'Clothing, Individual Equipment, Insignia, and Jewelry');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('85', 'Toiletries');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('87', 'Agricultural Supplies');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('88', 'Live Animals');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('89', 'Subsistence');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('91', 'Fuels, Lubricants, Oils, and Waxes');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('93', 'Nonmetallic Fabricated Materials');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('94', 'Nonmetallic Crude Materials');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('95', 'Metal Bars, Sheets, and Shapes');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('96', 'Ores, Minerals, and Their Primary Products');
INSERT INTO fsg (fsg_code, fsg_title) VALUES ('99', 'Miscellaneous');

COMMIT;

-- 統計: 成功匯入 80 筆FSG資料
