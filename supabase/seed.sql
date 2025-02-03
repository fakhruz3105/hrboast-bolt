SET session_replication_role = replica;

--
-- PostgreSQL database dump
--

-- Dumped from database version 15.8
-- Dumped by pg_dump version 15.8

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
-- Data for Name: companies; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."companies" ("id", "name", "email", "phone", "address", "subscription_status", "trial_ends_at", "is_active", "created_at", "updated_at", "password_hash", "schema_name", "ssm", "logo_url") VALUES
	('08adba96-a442-4873-aa4c-d858c0d34758', 'Muslimtravelbug Sdn Bhd', 'admin@muslimtravelbug.com', '03 95441442', '28-3 Jalan Equine 1D Taman Equine 43300 Seri Kembangan Selangor', 'active', NULL, true, '2025-02-03 02:48:54.742474+00', '2025-02-03 03:59:36.014211+00', NULL, 'company_08adba96_a442_4873_aa4c_d858c0d34758', '1186376T', 'https://muslimtravelbug.com/wp-content/uploads/2023/12/mtb-logo.png');


--
-- Data for Name: benefits; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."benefits" ("id", "company_id", "name", "description", "amount", "status", "frequency", "created_at", "updated_at") VALUES
	('ebc3b678-d4ba-4abe-a8de-cd1c731dc629', '08adba96-a442-4873-aa4c-d858c0d34758', 'Medical Insurance', 'Annual medical coverage including hospitalization and outpatient care', 5000.00, true, 'Annual coverage', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('6b37d433-241c-417f-9661-60ac4a49d68a', '08adba96-a442-4873-aa4c-d858c0d34758', 'Dental Coverage', 'Annual dental care coverage including routine checkups', 1000.00, true, 'Annual coverage', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('7ebce7d3-7f39-412b-b84d-12c7c064d9dd', '08adba96-a442-4873-aa4c-d858c0d34758', 'Professional Development', 'Annual allowance for courses and certifications', 2000.00, true, 'Annual coverage', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('ede14737-730b-4337-a07e-b73533e78f1b', '08adba96-a442-4873-aa4c-d858c0d34758', 'Gym Membership', 'Monthly gym membership reimbursement', 100.00, true, 'Monthly', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('d531cfb6-9c6d-4a86-94d4-6c7b01a3ee39', '08adba96-a442-4873-aa4c-d858c0d34758', 'Work From Home Setup', 'One-time allowance for home office setup', 1500.00, true, 'Once per employment', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('557d67dd-a52a-4b2e-9b15-eaa6dc7e17d2', '08adba96-a442-4873-aa4c-d858c0d34758', 'Transportation', 'Monthly transportation allowance', 200.00, true, 'Monthly', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('41cca790-c44b-4f7c-bff5-a1b5170974d4', '08adba96-a442-4873-aa4c-d858c0d34758', 'Wellness Program', 'Annual wellness program including health screenings', 800.00, true, 'Annual coverage', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('05998e6d-73af-4280-a0b2-39fd635b449c', '08adba96-a442-4873-aa4c-d858c0d34758', 'Education Subsidy', 'Support for continuing education', 5000.00, true, 'Annual coverage', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('359dfc85-9c5a-4222-ae8c-9be8ebb258ff', '08adba96-a442-4873-aa4c-d858c0d34758', 'Parental Leave', 'Paid parental leave benefit', 3000.00, true, 'Per child', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('e0b2dd3e-6d67-468a-90f8-c45d941caddd', '08adba96-a442-4873-aa4c-d858c0d34758', 'Marriage Allowance', 'One-time marriage celebration allowance', 1000.00, true, 'Once per employment', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00');


--
-- Data for Name: staff_levels; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."staff_levels" ("id", "name", "description", "rank", "created_at", "updated_at") VALUES
	('d4efa598-dcd0-42ad-a04c-c814af7ec48c', 'Director', 'Company leadership and strategic direction', 1, '2025-02-03 02:48:54.193813+00', '2025-02-03 02:48:54.193813+00'),
	('b64835fc-cc41-4dfe-ac4e-2a0427afdb72', 'C-Suite', 'Executive management and decision making', 2, '2025-02-03 02:48:54.193813+00', '2025-02-03 02:48:54.193813+00'),
	('898b6a03-20e4-41cd-8ce6-a478aaf5c574', 'HOD/Manager', 'Departmental management and team leadership', 3, '2025-02-03 02:48:54.193813+00', '2025-02-03 02:48:54.193813+00'),
	('e856be5d-ae8d-4dcc-9e33-f2cb24ee950d', 'HR', 'Human resources management and administration', 4, '2025-02-03 02:48:54.193813+00', '2025-02-03 02:48:54.193813+00'),
	('648a96dc-18fe-429a-85e8-4cfd44723d2f', 'Staff', 'Regular full-time employees', 5, '2025-02-03 02:48:54.193813+00', '2025-02-03 02:48:54.193813+00'),
	('fd37847d-f258-4880-8cfa-e7437ae18c72', 'Practical', 'Interns and temporary staff', 6, '2025-02-03 02:48:54.193813+00', '2025-02-03 02:48:54.193813+00');


--
-- Data for Name: role_mappings; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."role_mappings" ("id", "staff_level_id", "role", "created_at", "updated_at") VALUES
	('735e449f-f7d2-42bc-b776-8cb8f57c3bf0', 'b64835fc-cc41-4dfe-ac4e-2a0427afdb72', 'admin', '2025-02-03 02:48:54.283467+00', '2025-02-03 02:48:54.283467+00'),
	('03b70f66-9768-4163-b449-c2f3eca3f6ff', 'e856be5d-ae8d-4dcc-9e33-f2cb24ee950d', 'hr', '2025-02-03 02:48:54.283467+00', '2025-02-03 02:48:54.283467+00'),
	('e2e7179c-013a-41a9-9fd6-09e055150ed7', 'fd37847d-f258-4880-8cfa-e7437ae18c72', 'staff', '2025-02-03 02:48:54.283467+00', '2025-02-03 02:48:54.283467+00'),
	('514be92e-59d2-4d1d-8441-d8852ba47818', '898b6a03-20e4-41cd-8ce6-a478aaf5c574', 'staff', '2025-02-03 02:48:54.304437+00', '2025-02-03 02:48:54.304437+00'),
	('bc10b253-3d14-4759-86e7-7a887ca38fa6', '648a96dc-18fe-429a-85e8-4cfd44723d2f', 'staff', '2025-02-03 02:48:54.283467+00', '2025-02-03 02:48:54.283467+00');


--
-- Data for Name: staff; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."staff" ("id", "name", "phone_number", "email", "join_date", "status", "created_at", "updated_at", "role_id", "is_active", "company_id", "password") VALUES
	('b27ebf3f-32b4-44a9-8b80-3078c28f5f4a', 'LIYANA SYAZANA BINTI KAMARUDIN', '+60123456799', 'liyana@muslimtravelbug.com', '2024-01-30', 'permanent', '2025-02-03 02:48:54.999231+00', '2025-02-03 02:48:54.999231+00', 'bc10b253-3d14-4759-86e7-7a887ca38fa6', true, '08adba96-a442-4873-aa4c-d858c0d34758', 'kertas12'),
	('7104e3de-3569-4ecf-b293-1a3b58ccf430', 'HANIS MUNIRAH BINTI ZAKARIA@HASBULLAH', '+60123456790', 'hanis@muslimtravelbug.com', '2024-11-04', 'probation', '2025-02-03 02:48:54.986177+00', '2025-02-03 02:48:54.986177+00', 'bc10b253-3d14-4759-86e7-7a887ca38fa6', true, '08adba96-a442-4873-aa4c-d858c0d34758', 'kertas12'),
	('a422cfeb-2c59-4d61-a556-80864c2c1ac5', 'NADIA NAJWA BINTI HUSSIN', '+60123456791', 'nadia@muslimtravelbug.com', '2024-04-22', 'permanent', '2025-02-03 02:48:54.986177+00', '2025-02-03 02:48:54.986177+00', 'bc10b253-3d14-4759-86e7-7a887ca38fa6', true, '08adba96-a442-4873-aa4c-d858c0d34758', 'kertas12'),
	('c68fb6fc-eeaf-4d6a-8610-c0441f1afdd4', 'BASHIER BIN OMAR', '+60123456800', 'bashier@muslimtravelbug.com', '2022-10-25', 'permanent', '2025-02-03 02:48:54.999231+00', '2025-02-03 02:48:54.999231+00', '514be92e-59d2-4d1d-8441-d8852ba47818', true, '08adba96-a442-4873-aa4c-d858c0d34758', 'kertas12'),
	('ab2e9680-47e3-4e5d-98c9-fd29b652ee61', 'NABILAH ALISYA BINTI NORZAIDI', '+60123456792', 'nabilah@muslimtravelbug.com', '2024-11-04', 'probation', '2025-02-03 02:48:54.986177+00', '2025-02-03 02:48:54.986177+00', 'bc10b253-3d14-4759-86e7-7a887ca38fa6', true, '08adba96-a442-4873-aa4c-d858c0d34758', 'kertas12'),
	('333f1da0-1407-4b57-b756-55f67562eabe', 'NUR IMAN NABEISYA BINTI NOR AZRI', '+60123456793', 'iman@muslimtravelbug.com', '2024-07-15', 'probation', '2025-02-03 02:48:54.986177+00', '2025-02-03 02:48:54.986177+00', '03b70f66-9768-4163-b449-c2f3eca3f6ff', true, '08adba96-a442-4873-aa4c-d858c0d34758', 'kertas12'),
	('4d92a4e1-cfc3-484a-92f6-7ca062772d4e', 'NUR SUHAILI BINTI MOHD SANI', '+60123456794', 'suhaili@muslimtravelbug.com', '2021-02-27', 'permanent', '2025-02-03 02:48:54.986177+00', '2025-02-03 02:48:54.986177+00', 'bc10b253-3d14-4759-86e7-7a887ca38fa6', true, '08adba96-a442-4873-aa4c-d858c0d34758', 'kertas12'),
	('d8daf0a1-c4e0-40e3-9777-ae8ce1b909d9', 'NUR SHAHIRA BINTI OTHMAN', '+60123456801', 'shahira@muslimtravelbug.com', '2022-08-19', 'permanent', '2025-02-03 02:48:54.999231+00', '2025-02-03 02:48:54.999231+00', 'bc10b253-3d14-4759-86e7-7a887ca38fa6', true, '08adba96-a442-4873-aa4c-d858c0d34758', 'kertas12'),
	('b73a5465-7b8c-4515-9df4-d2cbceb37368', 'MUHAMMAD FAKHRUZ RAZI BIN MUTUSSIN', '+60123456789', 'fakhruz@muslimtravelbug.com', '2023-10-11', 'permanent', '2025-02-03 02:48:54.993505+00', '2025-02-03 02:48:54.993505+00', '735e449f-f7d2-42bc-b776-8cb8f57c3bf0', true, '08adba96-a442-4873-aa4c-d858c0d34758', 'kertas12'),
	('10a9e90e-12df-4236-b9ef-ac0c8d7f28c0', 'SYAZA RAKIN BIN DARSONO', '+60123456802', 'syaza@muslimtravelbug.com', '2023-02-27', 'permanent', '2025-02-03 02:48:54.999231+00', '2025-02-03 02:48:54.999231+00', 'bc10b253-3d14-4759-86e7-7a887ca38fa6', true, '08adba96-a442-4873-aa4c-d858c0d34758', 'kertas12'),
	('328c86c7-3422-4048-9863-8b5106d0b088', 'ISMAIL BIN SJAFRIAL', '+60123456795', 'ismail@muslimtravelbug.com', '2017-09-18', 'permanent', '2025-02-03 02:48:54.993505+00', '2025-02-03 02:48:54.993505+00', '514be92e-59d2-4d1d-8441-d8852ba47818', true, '08adba96-a442-4873-aa4c-d858c0d34758', 'kertas12'),
	('cbcfb369-ce5a-44df-8c65-c51ee52a4d30', 'SITI MAHIRAH BINTI HANUDDIN', '+60123456796', 'mahirah@muslimtravelbug.com', '2022-07-25', 'permanent', '2025-02-03 02:48:54.993505+00', '2025-02-03 02:48:54.993505+00', 'bc10b253-3d14-4759-86e7-7a887ca38fa6', true, '08adba96-a442-4873-aa4c-d858c0d34758', 'kertas12'),
	('41d049a6-d094-4ae5-81ef-6d867fa96cf3', 'MUHAMMAD RIDZWAN BIN MOHD ANNUAR', '+60123456797', 'ridzwan@muslimtravelbug.com', '2024-09-23', 'probation', '2025-02-03 02:48:54.993505+00', '2025-02-03 02:48:54.993505+00', '514be92e-59d2-4d1d-8441-d8852ba47818', true, '08adba96-a442-4873-aa4c-d858c0d34758', 'kertas12'),
	('0bdb8f3f-ae86-4630-bc48-e828d9ba179e', 'NURAZEHAN BINTI MUHAMMAD', '+60123456798', 'azehan@muslimtravelbug.com', '2022-09-26', 'permanent', '2025-02-03 02:48:54.993505+00', '2025-02-03 02:48:54.993505+00', 'bc10b253-3d14-4759-86e7-7a887ca38fa6', true, '08adba96-a442-4873-aa4c-d858c0d34758', 'kertas12'),
	('b4185cf1-ca0d-408e-a8eb-353fcb42ab65', 'MUHAMMAD AMMAR BIN MOHD AZIS', '+60123456803', 'ammar@muslimtravelbug.com', '2022-12-27', 'permanent', '2025-02-03 02:48:54.999231+00', '2025-02-03 02:48:54.999231+00', 'bc10b253-3d14-4759-86e7-7a887ca38fa6', true, '08adba96-a442-4873-aa4c-d858c0d34758', 'kertas12'),
	('a4582de1-5d17-4526-ac78-69d76390dab0', 'NUR FAZIELA BINTI ISDAM', '+60123456804', 'faziela@muslimtravelbug.com', '2021-07-12', 'permanent', '2025-02-03 02:48:54.999231+00', '2025-02-03 02:48:54.999231+00', 'bc10b253-3d14-4759-86e7-7a887ca38fa6', true, '08adba96-a442-4873-aa4c-d858c0d34758', 'kertas12'),
	('5477fced-418d-488f-a1f8-ca243c01cc53', 'NURHANI IZNI BINTI JA''APAR', '+60123456805', 'hani@muslimtravelbug.com', '2023-07-03', 'permanent', '2025-02-03 02:48:54.999231+00', '2025-02-03 02:48:54.999231+00', 'bc10b253-3d14-4759-86e7-7a887ca38fa6', true, '08adba96-a442-4873-aa4c-d858c0d34758', 'kertas12'),
	('c7d284db-cd13-4c33-995c-4b5f35b23858', 'MAZLON BINTI NAIM', '+60123456806', 'mazlon@muslimtravelbug.com', '2022-06-24', 'permanent', '2025-02-03 02:48:54.999231+00', '2025-02-03 02:48:54.999231+00', '514be92e-59d2-4d1d-8441-d8852ba47818', true, '08adba96-a442-4873-aa4c-d858c0d34758', 'kertas12'),
	('e6b1b224-c940-42e5-bc71-856b38c20e34', 'MURSYID BIN AZMI', '+60123456807', 'mursyid@muslimtravelbug.com', '2022-06-24', 'permanent', '2025-02-03 02:48:54.999231+00', '2025-02-03 02:48:54.999231+00', 'bc10b253-3d14-4759-86e7-7a887ca38fa6', true, '08adba96-a442-4873-aa4c-d858c0d34758', 'kertas12'),
	('92ab14a1-15ee-439c-b991-6ac990a97eb1', 'NURUL HIDAYAH BINTI ABD HAMID', '+60123456808', 'hidayah@muslimtravelbug.com', '2024-11-18', 'probation', '2025-02-03 02:48:54.999231+00', '2025-02-03 02:48:54.999231+00', '514be92e-59d2-4d1d-8441-d8852ba47818', true, '08adba96-a442-4873-aa4c-d858c0d34758', 'kertas12'),
	('59d76036-b107-4608-a7e5-22ab57c6fae3', 'ALIF ASYRAAF BIN MOHD FADHIL SAMUEL', '+60123456809', 'alif@muslimtravelbug.com', '2023-08-15', 'permanent', '2025-02-03 02:48:54.999231+00', '2025-02-03 02:48:54.999231+00', 'bc10b253-3d14-4759-86e7-7a887ca38fa6', true, '08adba96-a442-4873-aa4c-d858c0d34758', 'kertas12'),
	('cfd94f9b-5a11-4b01-b236-72080870e2ad', 'DZULAIFATUN NUHA BINTI ZOLKIFLI', '+60123456810', 'nuha@muslimtravelbug.com', '2023-03-24', 'permanent', '2025-02-03 02:48:54.999231+00', '2025-02-03 02:48:54.999231+00', 'bc10b253-3d14-4759-86e7-7a887ca38fa6', true, '08adba96-a442-4873-aa4c-d858c0d34758', 'kertas12'),
	('aec8cca1-13aa-4a42-980a-eec2081ffe2b', 'NUR ZUHRIYANA BTE JAMALUDIN', '+60123456811', 'zuhriyana@muslimtravelbug.com', '2024-04-16', 'permanent', '2025-02-03 02:48:54.999231+00', '2025-02-03 02:48:54.999231+00', 'bc10b253-3d14-4759-86e7-7a887ca38fa6', true, '08adba96-a442-4873-aa4c-d858c0d34758', 'kertas12'),
	('26f14468-5a05-4349-991d-a2529ee017ed', 'HR Admin', '+60123456789', 'hr@muslimtravelbug.com', '2025-02-03', 'permanent', '2025-02-03 02:48:54.343264+00', '2025-02-03 04:05:42.44554+00', '735e449f-f7d2-42bc-b776-8cb8f57c3bf0', true, '08adba96-a442-4873-aa4c-d858c0d34758', 'kertas12');


--
-- Data for Name: benefit_claims; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: benefit_eligibility; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."benefit_eligibility" ("id", "benefit_id", "level_id", "created_at", "updated_at") VALUES
	('c323ef95-dd0d-49f8-ba89-4499cee4ef5a', 'ebc3b678-d4ba-4abe-a8de-cd1c731dc629', 'd4efa598-dcd0-42ad-a04c-c814af7ec48c', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('5a98279d-36ac-4974-83b3-e99040b263e4', '6b37d433-241c-417f-9661-60ac4a49d68a', 'd4efa598-dcd0-42ad-a04c-c814af7ec48c', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('8d50e140-9e7e-4b9f-a6e7-bf25110bc4a0', '7ebce7d3-7f39-412b-b84d-12c7c064d9dd', 'd4efa598-dcd0-42ad-a04c-c814af7ec48c', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('70390f38-489b-43e2-ab0e-d1dc42016839', 'ede14737-730b-4337-a07e-b73533e78f1b', 'd4efa598-dcd0-42ad-a04c-c814af7ec48c', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('50a0acf2-6077-4e92-9d58-8b2fe0837b43', 'd531cfb6-9c6d-4a86-94d4-6c7b01a3ee39', 'd4efa598-dcd0-42ad-a04c-c814af7ec48c', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('ab9537c3-c83e-4f37-a91b-08c288a25d29', '557d67dd-a52a-4b2e-9b15-eaa6dc7e17d2', 'd4efa598-dcd0-42ad-a04c-c814af7ec48c', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('9973a463-18b7-4b89-bc4e-b09c5d352ff8', '41cca790-c44b-4f7c-bff5-a1b5170974d4', 'd4efa598-dcd0-42ad-a04c-c814af7ec48c', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('86c3d703-2697-4154-9aa1-178d150c0b74', '05998e6d-73af-4280-a0b2-39fd635b449c', 'd4efa598-dcd0-42ad-a04c-c814af7ec48c', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('66268ba7-c49d-4037-bfcc-3938859191b8', '359dfc85-9c5a-4222-ae8c-9be8ebb258ff', 'd4efa598-dcd0-42ad-a04c-c814af7ec48c', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('20a259c3-f881-4eff-947d-2222082e0dd7', 'e0b2dd3e-6d67-468a-90f8-c45d941caddd', 'd4efa598-dcd0-42ad-a04c-c814af7ec48c', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('560c8a8b-b860-4d48-b62e-2d8fcc5a31f5', 'ebc3b678-d4ba-4abe-a8de-cd1c731dc629', 'b64835fc-cc41-4dfe-ac4e-2a0427afdb72', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('14ce034a-c6f9-4ce2-8c63-6d4560c50294', '6b37d433-241c-417f-9661-60ac4a49d68a', 'b64835fc-cc41-4dfe-ac4e-2a0427afdb72', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('f7f1bcec-e612-42fa-9479-4b858f312515', '7ebce7d3-7f39-412b-b84d-12c7c064d9dd', 'b64835fc-cc41-4dfe-ac4e-2a0427afdb72', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('b3b01bc3-a5bc-4fd5-bfd3-d6477424cf06', 'ede14737-730b-4337-a07e-b73533e78f1b', 'b64835fc-cc41-4dfe-ac4e-2a0427afdb72', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('2e451d0f-5cfa-4e98-af7b-23e1095dc972', 'd531cfb6-9c6d-4a86-94d4-6c7b01a3ee39', 'b64835fc-cc41-4dfe-ac4e-2a0427afdb72', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('febe123f-d428-4d12-9fc6-5bf3fcd5438a', '557d67dd-a52a-4b2e-9b15-eaa6dc7e17d2', 'b64835fc-cc41-4dfe-ac4e-2a0427afdb72', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('6764aef3-0411-43e5-b6b0-140e56efd0e8', '41cca790-c44b-4f7c-bff5-a1b5170974d4', 'b64835fc-cc41-4dfe-ac4e-2a0427afdb72', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('9c4b6c8b-7710-4ffb-bfad-e477d4f6aa15', '05998e6d-73af-4280-a0b2-39fd635b449c', 'b64835fc-cc41-4dfe-ac4e-2a0427afdb72', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('0ad27bfa-bae2-44f2-8f27-d2c0d679c674', '359dfc85-9c5a-4222-ae8c-9be8ebb258ff', 'b64835fc-cc41-4dfe-ac4e-2a0427afdb72', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('de906c91-7844-490c-97c1-0687e7b94f16', 'e0b2dd3e-6d67-468a-90f8-c45d941caddd', 'b64835fc-cc41-4dfe-ac4e-2a0427afdb72', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('f2d41322-710f-46b2-9635-ec9abb4d5c82', 'ebc3b678-d4ba-4abe-a8de-cd1c731dc629', '898b6a03-20e4-41cd-8ce6-a478aaf5c574', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('2704a8a9-cff3-4234-97b8-fabb5e8faa7e', '6b37d433-241c-417f-9661-60ac4a49d68a', '898b6a03-20e4-41cd-8ce6-a478aaf5c574', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('75399be6-d003-4348-8b9e-596acd1d6cdc', '7ebce7d3-7f39-412b-b84d-12c7c064d9dd', '898b6a03-20e4-41cd-8ce6-a478aaf5c574', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('a53ca152-0086-4d1e-a97e-bb319ef4a28b', 'ede14737-730b-4337-a07e-b73533e78f1b', '898b6a03-20e4-41cd-8ce6-a478aaf5c574', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('0e5b12b8-888f-422e-852c-4e480929fe41', 'd531cfb6-9c6d-4a86-94d4-6c7b01a3ee39', '898b6a03-20e4-41cd-8ce6-a478aaf5c574', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('b9d0267b-8324-409b-b621-75c55265ff42', '557d67dd-a52a-4b2e-9b15-eaa6dc7e17d2', '898b6a03-20e4-41cd-8ce6-a478aaf5c574', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('75645fdc-f01c-47cb-bc53-879dfdc03a3f', '41cca790-c44b-4f7c-bff5-a1b5170974d4', '898b6a03-20e4-41cd-8ce6-a478aaf5c574', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('45343a1d-afc4-4750-a896-163b379ee514', '05998e6d-73af-4280-a0b2-39fd635b449c', '898b6a03-20e4-41cd-8ce6-a478aaf5c574', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('eeaf7e36-0304-4f87-bb10-529f9991ccfb', '359dfc85-9c5a-4222-ae8c-9be8ebb258ff', '898b6a03-20e4-41cd-8ce6-a478aaf5c574', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('25c5a35b-8506-4bc6-9558-a40542308001', 'e0b2dd3e-6d67-468a-90f8-c45d941caddd', '898b6a03-20e4-41cd-8ce6-a478aaf5c574', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('b9289ce8-8576-4bed-86ad-b0917925c9b1', 'ebc3b678-d4ba-4abe-a8de-cd1c731dc629', 'e856be5d-ae8d-4dcc-9e33-f2cb24ee950d', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('6b429e66-4b13-4d4d-8907-5a63b6ae42db', '6b37d433-241c-417f-9661-60ac4a49d68a', 'e856be5d-ae8d-4dcc-9e33-f2cb24ee950d', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('5834d123-e151-452f-b485-bc44b9ef5c86', '7ebce7d3-7f39-412b-b84d-12c7c064d9dd', 'e856be5d-ae8d-4dcc-9e33-f2cb24ee950d', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('f48ca9f1-6693-404d-9a7b-f2c462776bc2', 'ede14737-730b-4337-a07e-b73533e78f1b', 'e856be5d-ae8d-4dcc-9e33-f2cb24ee950d', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('c66c2887-92eb-40b8-8f43-bef979b2383f', 'd531cfb6-9c6d-4a86-94d4-6c7b01a3ee39', 'e856be5d-ae8d-4dcc-9e33-f2cb24ee950d', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('610a680e-3839-40d3-902e-edc2bd734ede', '557d67dd-a52a-4b2e-9b15-eaa6dc7e17d2', 'e856be5d-ae8d-4dcc-9e33-f2cb24ee950d', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('6735ba85-d740-4ef9-ac2b-605766257263', '41cca790-c44b-4f7c-bff5-a1b5170974d4', 'e856be5d-ae8d-4dcc-9e33-f2cb24ee950d', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('efe2683a-c91e-4cdc-b00b-1906f6068863', '05998e6d-73af-4280-a0b2-39fd635b449c', 'e856be5d-ae8d-4dcc-9e33-f2cb24ee950d', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('00511e07-586d-48e7-840b-24a0b8000dd3', '359dfc85-9c5a-4222-ae8c-9be8ebb258ff', 'e856be5d-ae8d-4dcc-9e33-f2cb24ee950d', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('3a96a339-c29d-4704-9cbd-7c3807c2e77d', 'e0b2dd3e-6d67-468a-90f8-c45d941caddd', 'e856be5d-ae8d-4dcc-9e33-f2cb24ee950d', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('39d42ad7-223c-40ae-af1e-9951c9726804', 'ebc3b678-d4ba-4abe-a8de-cd1c731dc629', '648a96dc-18fe-429a-85e8-4cfd44723d2f', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('9b253197-30ce-4fe2-98a7-776dd32bfdb7', '6b37d433-241c-417f-9661-60ac4a49d68a', '648a96dc-18fe-429a-85e8-4cfd44723d2f', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('cfe9ac43-06a6-4a30-8477-b7734898a998', '7ebce7d3-7f39-412b-b84d-12c7c064d9dd', '648a96dc-18fe-429a-85e8-4cfd44723d2f', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('3076b114-bbe3-4882-9c82-2abd9d242b3d', 'ede14737-730b-4337-a07e-b73533e78f1b', '648a96dc-18fe-429a-85e8-4cfd44723d2f', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('e147b9cd-f648-475c-b153-5f3b54fe374c', 'd531cfb6-9c6d-4a86-94d4-6c7b01a3ee39', '648a96dc-18fe-429a-85e8-4cfd44723d2f', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('26726dec-b69d-4ee9-bb86-fd48728b725c', '557d67dd-a52a-4b2e-9b15-eaa6dc7e17d2', '648a96dc-18fe-429a-85e8-4cfd44723d2f', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('f066cc64-5830-42b0-b25d-d1c0fe5ba098', '41cca790-c44b-4f7c-bff5-a1b5170974d4', '648a96dc-18fe-429a-85e8-4cfd44723d2f', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('5f2673e9-a2b8-48bb-8f97-1749ab0c1c3d', '05998e6d-73af-4280-a0b2-39fd635b449c', '648a96dc-18fe-429a-85e8-4cfd44723d2f', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('05f6f973-ea91-4ea0-bfb8-1881d98f828b', '359dfc85-9c5a-4222-ae8c-9be8ebb258ff', '648a96dc-18fe-429a-85e8-4cfd44723d2f', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('11452088-3950-450c-9605-6af1734831b7', 'e0b2dd3e-6d67-468a-90f8-c45d941caddd', '648a96dc-18fe-429a-85e8-4cfd44723d2f', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('1889dc2d-7fac-4c01-a15e-1808dc3fe5c1', 'ebc3b678-d4ba-4abe-a8de-cd1c731dc629', 'fd37847d-f258-4880-8cfa-e7437ae18c72', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('707529c3-c4b9-4157-9d7c-06c4edd394a7', '6b37d433-241c-417f-9661-60ac4a49d68a', 'fd37847d-f258-4880-8cfa-e7437ae18c72', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('fb1a03a2-21c6-4a23-9192-799ad9fa998b', '7ebce7d3-7f39-412b-b84d-12c7c064d9dd', 'fd37847d-f258-4880-8cfa-e7437ae18c72', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('86dd9841-9e76-43ce-9fec-258c4fb85d7a', 'ede14737-730b-4337-a07e-b73533e78f1b', 'fd37847d-f258-4880-8cfa-e7437ae18c72', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('f48168f3-aee1-4d48-aaea-bc235b13c82f', 'd531cfb6-9c6d-4a86-94d4-6c7b01a3ee39', 'fd37847d-f258-4880-8cfa-e7437ae18c72', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('9a0ce895-f7c0-4632-ad88-a8c327398358', '557d67dd-a52a-4b2e-9b15-eaa6dc7e17d2', 'fd37847d-f258-4880-8cfa-e7437ae18c72', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('841489a2-a8c6-480b-99d3-e1ba96fb9c3e', '41cca790-c44b-4f7c-bff5-a1b5170974d4', 'fd37847d-f258-4880-8cfa-e7437ae18c72', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('4a6d5be1-9676-476a-85ae-4f16eea05070', '05998e6d-73af-4280-a0b2-39fd635b449c', 'fd37847d-f258-4880-8cfa-e7437ae18c72', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('ca44f740-97ac-430f-81b0-72d12b5e3268', '359dfc85-9c5a-4222-ae8c-9be8ebb258ff', 'fd37847d-f258-4880-8cfa-e7437ae18c72', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00'),
	('cdaf0f09-0534-45ba-b301-f95e5bd82428', 'e0b2dd3e-6d67-468a-90f8-c45d941caddd', 'fd37847d-f258-4880-8cfa-e7437ae18c72', '2025-02-03 02:48:55.011768+00', '2025-02-03 02:48:55.011768+00');


--
-- Data for Name: company_events; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: departments; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."departments" ("id", "name", "description", "created_at", "updated_at") VALUES
	('44bb1ddc-c983-4848-ba68-b398a0f1e3be', 'C-Suite Department', 'Executive leadership and strategic decision making', '2025-02-03 02:48:54.621631+00', '2025-02-03 02:48:54.621631+00'),
	('abaf8769-76f5-49e5-bed7-b7c9d2767240', 'Management Department', 'Organizational management and team leadership', '2025-02-03 02:48:54.621631+00', '2025-02-03 02:48:54.621631+00'),
	('6ccc8a69-20a6-49dd-ad4d-94f0490116b9', 'Finance Department', 'Financial planning, accounting, and reporting', '2025-02-03 02:48:54.621631+00', '2025-02-03 02:48:54.621631+00'),
	('2817ed28-9232-47c8-b13f-1846e659258c', 'HR Department', 'Human resources management and employee relations', '2025-02-03 02:48:54.621631+00', '2025-02-03 02:48:54.621631+00'),
	('3464d856-44ae-44ac-a9ca-1d44bbfad589', 'Tour Department', 'Tour planning and management', '2025-02-03 02:48:54.621631+00', '2025-02-03 02:48:54.621631+00'),
	('4904c08c-8372-4372-b273-482aa76e55f2', 'Tour Sales Department', 'Tour package sales and customer service', '2025-02-03 02:48:54.621631+00', '2025-02-03 02:48:54.621631+00'),
	('2772d7ff-6a08-4cb9-988f-d6d1edb3bfb9', 'Operation Series Department', 'Operational management and logistics', '2025-02-03 02:48:54.621631+00', '2025-02-03 02:48:54.621631+00'),
	('78e3b530-c1c6-4658-bc2f-718234daba91', 'Ticketing Department', 'Ticket booking and management', '2025-02-03 02:48:54.621631+00', '2025-02-03 02:48:54.621631+00'),
	('d279cb45-647f-4df5-81a9-44a67dbb1534', 'B2B Partner Department', 'Business partnership management', '2025-02-03 02:48:54.621631+00', '2025-02-03 02:48:54.621631+00'),
	('a649e408-5e64-44f6-af08-75b37c115569', 'Business Development Department', 'Business growth and development strategies', '2025-02-03 02:48:54.621631+00', '2025-02-03 02:48:54.621631+00'),
	('59c29eff-0cf3-4ca2-a439-09814e08968e', 'Operations Department', 'Travel operations and logistics', '2025-02-03 02:48:55.094453+00', '2025-02-03 02:48:55.094453+00'),
	('d239ce1b-4fda-4599-b636-ae04885a0d4c', 'Sales Department', 'Sales and customer service', '2025-02-03 02:48:55.094453+00', '2025-02-03 02:48:55.094453+00');


--
-- Data for Name: department_default_levels; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: employee_form_requests; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."employee_form_requests" ("id", "staff_name", "email", "phone_number", "department_id", "level_id", "form_link", "status", "created_at", "expires_at", "company_id") VALUES
	('fb27417b-5e3e-4b0e-bb47-24ac4d4d3201', 'Razi Mutussin', 'fakhruz@muslimtravelbug.com', '0142720349', '44bb1ddc-c983-4848-ba68-b398a0f1e3be', 'b64835fc-cc41-4dfe-ac4e-2a0427afdb72', 'f47057ca-eaa7-4caa-8187-de328b5e78b0', 'completed', '2025-02-03 03:21:22.838967+00', '2025-02-10 03:21:22.82+00', '08adba96-a442-4873-aa4c-d858c0d34758');


--
-- Data for Name: employee_form_responses; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."employee_form_responses" ("id", "request_id", "personal_info", "education_history", "employment_history", "emergency_contacts", "submitted_at") VALUES
	('f0a189e9-b8c2-4b2d-94de-ae69b6383d9a', 'fb27417b-5e3e-4b0e-bb47-24ac4d4d3201', '{"email": "fakhruz@muslimtravelbug.com", "phone": "0142720349", "gender": "male", "address": "C1-14-1, Flora Rosa,\nJalan P11J, Precint 11", "fullName": "Razi Mutussin", "dateOfBirth": "1991-05-31", "nationality": "Malaysian", "nricPassport": "910531125463"}', '[{"institution": "Test", "fieldOfStudy": "Test", "qualification": "Test", "graduationYear": "2014"}]', '[{"company": "Muslimtravelbug", "endDate": "2024-06-12", "position": "Test", "startDate": "2023-03-01", "responsibilities": "Test"}]', '[{"name": "Razi Mutussin", "phone": "0142720349", "address": "C1-14-1, Flora Rosa,\nJalan P11J, Precint 11", "relationship": "Test"}]', '2025-02-03 03:28:06.662929+00');


--
-- Data for Name: evaluation_departments; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: evaluation_forms; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: evaluation_form_departments; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: evaluation_form_levels; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: evaluation_responses; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: exit_interviews; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: hr_letters; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."hr_letters" ("id", "staff_id", "title", "type", "content", "document_url", "issued_date", "status", "created_at", "updated_at") VALUES
	('aba3f6bb-1d48-4426-8903-b905b402a3d1', NULL, 'Employee Information Form', 'interview', '{"type": "employee", "status": "pending", "form_request_id": "fb27417b-5e3e-4b0e-bb47-24ac4d4d3201"}', NULL, '2025-02-03 03:21:22.848+00', 'pending', '2025-02-03 03:21:22.863105+00', '2025-02-03 03:21:22.863105+00');


--
-- Data for Name: inventory_items; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: kpis; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: kpi_feedback; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: kpi_updates; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: memos; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: schema_backups; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: show_cause_letters; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: staff_departments; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."staff_departments" ("id", "staff_id", "department_id", "is_primary", "created_at", "updated_at") VALUES
	('5046c171-129e-4458-8d5b-5c0456e3274a', '7104e3de-3569-4ecf-b293-1a3b58ccf430', '6ccc8a69-20a6-49dd-ad4d-94f0490116b9', true, '2025-02-03 02:48:54.986177+00', '2025-02-03 02:48:54.986177+00'),
	('f68ae50d-82b0-452b-9fd4-8b2c815b29f2', 'a422cfeb-2c59-4d61-a556-80864c2c1ac5', '6ccc8a69-20a6-49dd-ad4d-94f0490116b9', true, '2025-02-03 02:48:54.986177+00', '2025-02-03 02:48:54.986177+00'),
	('d841920b-36ba-4b1c-acbc-109365132701', 'ab2e9680-47e3-4e5d-98c9-fd29b652ee61', 'abaf8769-76f5-49e5-bed7-b7c9d2767240', true, '2025-02-03 02:48:54.986177+00', '2025-02-03 02:48:54.986177+00'),
	('ad09fbc1-ca97-448b-9e10-49425ef19a2c', '333f1da0-1407-4b57-b756-55f67562eabe', '2817ed28-9232-47c8-b13f-1846e659258c', true, '2025-02-03 02:48:54.986177+00', '2025-02-03 02:48:54.986177+00'),
	('e151e9b2-9d5b-4545-8a41-530d308283eb', '4d92a4e1-cfc3-484a-92f6-7ca062772d4e', 'd279cb45-647f-4df5-81a9-44a67dbb1534', true, '2025-02-03 02:48:54.986177+00', '2025-02-03 02:48:54.986177+00'),
	('952ba1fd-9aec-472e-a8c9-bb7012605e60', 'b73a5465-7b8c-4515-9df4-d2cbceb37368', '44bb1ddc-c983-4848-ba68-b398a0f1e3be', true, '2025-02-03 02:48:54.993505+00', '2025-02-03 02:48:54.993505+00'),
	('4572e191-fde2-488f-9da1-4369109913b4', '328c86c7-3422-4048-9863-8b5106d0b088', '3464d856-44ae-44ac-a9ca-1d44bbfad589', true, '2025-02-03 02:48:54.993505+00', '2025-02-03 02:48:54.993505+00'),
	('63d37ff5-c643-4ec3-bbc4-3ba333f8af24', 'cbcfb369-ce5a-44df-8c65-c51ee52a4d30', '2772d7ff-6a08-4cb9-988f-d6d1edb3bfb9', true, '2025-02-03 02:48:54.993505+00', '2025-02-03 02:48:54.993505+00'),
	('0e1fd851-c7cd-4330-b1af-2d9e9330e3f5', '41d049a6-d094-4ae5-81ef-6d867fa96cf3', '78e3b530-c1c6-4658-bc2f-718234daba91', true, '2025-02-03 02:48:54.993505+00', '2025-02-03 02:48:54.993505+00'),
	('3a363242-5c6c-4b66-9239-d367ee8e2955', '0bdb8f3f-ae86-4630-bc48-e828d9ba179e', '78e3b530-c1c6-4658-bc2f-718234daba91', true, '2025-02-03 02:48:54.993505+00', '2025-02-03 02:48:54.993505+00'),
	('853d9eb2-c38b-4002-98e4-dcd9c3d749ed', 'b27ebf3f-32b4-44a9-8b80-3078c28f5f4a', '78e3b530-c1c6-4658-bc2f-718234daba91', true, '2025-02-03 02:48:54.999231+00', '2025-02-03 02:48:54.999231+00'),
	('a48f2103-1cf7-42c1-9e22-0dcf9b3f1474', 'c68fb6fc-eeaf-4d6a-8610-c0441f1afdd4', '4904c08c-8372-4372-b273-482aa76e55f2', true, '2025-02-03 02:48:54.999231+00', '2025-02-03 02:48:54.999231+00'),
	('52885bf7-96a4-480f-bb1a-cec1e9311ae8', 'd8daf0a1-c4e0-40e3-9777-ae8ce1b909d9', '4904c08c-8372-4372-b273-482aa76e55f2', true, '2025-02-03 02:48:54.999231+00', '2025-02-03 02:48:54.999231+00'),
	('7f99eead-89ce-4d49-847c-eab45709346f', '10a9e90e-12df-4236-b9ef-ac0c8d7f28c0', '4904c08c-8372-4372-b273-482aa76e55f2', true, '2025-02-03 02:48:54.999231+00', '2025-02-03 02:48:54.999231+00'),
	('f7b016e5-4893-4aa5-add1-bb28a83ae54d', 'b4185cf1-ca0d-408e-a8eb-353fcb42ab65', '4904c08c-8372-4372-b273-482aa76e55f2', true, '2025-02-03 02:48:54.999231+00', '2025-02-03 02:48:54.999231+00'),
	('63a072e0-2d28-491e-83d7-8d1cd7845a0a', 'a4582de1-5d17-4526-ac78-69d76390dab0', '4904c08c-8372-4372-b273-482aa76e55f2', true, '2025-02-03 02:48:54.999231+00', '2025-02-03 02:48:54.999231+00'),
	('4dbcdb39-7970-4332-a04c-93a7bd81d622', '5477fced-418d-488f-a1f8-ca243c01cc53', '4904c08c-8372-4372-b273-482aa76e55f2', true, '2025-02-03 02:48:54.999231+00', '2025-02-03 02:48:54.999231+00'),
	('471ad708-cfd9-484e-a0c6-9a71ae2554b4', 'c7d284db-cd13-4c33-995c-4b5f35b23858', 'd279cb45-647f-4df5-81a9-44a67dbb1534', true, '2025-02-03 02:48:54.999231+00', '2025-02-03 02:48:54.999231+00'),
	('36010961-83f1-427e-bad7-632984527172', 'e6b1b224-c940-42e5-bc71-856b38c20e34', 'd279cb45-647f-4df5-81a9-44a67dbb1534', true, '2025-02-03 02:48:54.999231+00', '2025-02-03 02:48:54.999231+00'),
	('c2f8e8d1-4e5b-47ed-901b-1f46122f2f1d', '92ab14a1-15ee-439c-b991-6ac990a97eb1', '3464d856-44ae-44ac-a9ca-1d44bbfad589', true, '2025-02-03 02:48:54.999231+00', '2025-02-03 02:48:54.999231+00'),
	('9954668c-a7bc-45c0-8da0-8dca6510a1ef', '59d76036-b107-4608-a7e5-22ab57c6fae3', '3464d856-44ae-44ac-a9ca-1d44bbfad589', true, '2025-02-03 02:48:54.999231+00', '2025-02-03 02:48:54.999231+00'),
	('5ee5066d-e40e-4dc5-974f-70c5d2117042', 'cfd94f9b-5a11-4b01-b236-72080870e2ad', '3464d856-44ae-44ac-a9ca-1d44bbfad589', true, '2025-02-03 02:48:54.999231+00', '2025-02-03 02:48:54.999231+00'),
	('09b84319-4d2d-4567-9ab6-58ab73fdcac1', 'aec8cca1-13aa-4a42-980a-eec2081ffe2b', '3464d856-44ae-44ac-a9ca-1d44bbfad589', true, '2025-02-03 02:48:54.999231+00', '2025-02-03 02:48:54.999231+00');


--
-- Data for Name: staff_levels_junction; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."staff_levels_junction" ("id", "staff_id", "level_id", "is_primary", "created_at", "updated_at") VALUES
	('ebc6b275-4580-47e8-a0dc-fc9c999138c2', '7104e3de-3569-4ecf-b293-1a3b58ccf430', '648a96dc-18fe-429a-85e8-4cfd44723d2f', true, '2025-02-03 02:48:54.986177+00', '2025-02-03 02:48:54.986177+00'),
	('676b5b66-8c4c-46f7-a856-74e4b3e9ef0c', 'a422cfeb-2c59-4d61-a556-80864c2c1ac5', '648a96dc-18fe-429a-85e8-4cfd44723d2f', true, '2025-02-03 02:48:54.986177+00', '2025-02-03 02:48:54.986177+00'),
	('1cab0cde-9e0a-468d-af64-cc5a1acaf700', 'ab2e9680-47e3-4e5d-98c9-fd29b652ee61', '648a96dc-18fe-429a-85e8-4cfd44723d2f', true, '2025-02-03 02:48:54.986177+00', '2025-02-03 02:48:54.986177+00'),
	('55828c74-9211-438b-826d-9b77e79f655b', '333f1da0-1407-4b57-b756-55f67562eabe', 'e856be5d-ae8d-4dcc-9e33-f2cb24ee950d', true, '2025-02-03 02:48:54.986177+00', '2025-02-03 02:48:54.986177+00'),
	('bbf95389-6d84-4dd6-8aeb-1825aa483de7', '4d92a4e1-cfc3-484a-92f6-7ca062772d4e', '648a96dc-18fe-429a-85e8-4cfd44723d2f', true, '2025-02-03 02:48:54.986177+00', '2025-02-03 02:48:54.986177+00'),
	('e4737bfa-6797-4c33-ac43-2265e580693d', 'b73a5465-7b8c-4515-9df4-d2cbceb37368', 'b64835fc-cc41-4dfe-ac4e-2a0427afdb72', true, '2025-02-03 02:48:54.993505+00', '2025-02-03 02:48:54.993505+00'),
	('63ee8ecc-4975-4e94-aedf-13d5b598ec77', '328c86c7-3422-4048-9863-8b5106d0b088', '898b6a03-20e4-41cd-8ce6-a478aaf5c574', true, '2025-02-03 02:48:54.993505+00', '2025-02-03 02:48:54.993505+00'),
	('1d0f43d0-f8cd-419c-a74f-8138c4e29d00', 'cbcfb369-ce5a-44df-8c65-c51ee52a4d30', '648a96dc-18fe-429a-85e8-4cfd44723d2f', true, '2025-02-03 02:48:54.993505+00', '2025-02-03 02:48:54.993505+00'),
	('d3c428df-516c-4e97-bac1-63150596129f', '41d049a6-d094-4ae5-81ef-6d867fa96cf3', '898b6a03-20e4-41cd-8ce6-a478aaf5c574', true, '2025-02-03 02:48:54.993505+00', '2025-02-03 02:48:54.993505+00'),
	('8a908aa1-6205-47d6-b553-31be3cd9e7ef', '0bdb8f3f-ae86-4630-bc48-e828d9ba179e', '648a96dc-18fe-429a-85e8-4cfd44723d2f', true, '2025-02-03 02:48:54.993505+00', '2025-02-03 02:48:54.993505+00'),
	('72e7c6bb-9f05-4dcd-9ee3-27566af215ce', 'b27ebf3f-32b4-44a9-8b80-3078c28f5f4a', '648a96dc-18fe-429a-85e8-4cfd44723d2f', true, '2025-02-03 02:48:54.999231+00', '2025-02-03 02:48:54.999231+00'),
	('e2e4c3dc-2237-450f-8a9d-08636439dd55', 'c68fb6fc-eeaf-4d6a-8610-c0441f1afdd4', '898b6a03-20e4-41cd-8ce6-a478aaf5c574', true, '2025-02-03 02:48:54.999231+00', '2025-02-03 02:48:54.999231+00'),
	('9aea6ca4-7466-472f-b7cc-036285acd8fb', 'd8daf0a1-c4e0-40e3-9777-ae8ce1b909d9', '648a96dc-18fe-429a-85e8-4cfd44723d2f', true, '2025-02-03 02:48:54.999231+00', '2025-02-03 02:48:54.999231+00'),
	('270d2d35-4d35-4838-8a0e-7642e5414eb6', '10a9e90e-12df-4236-b9ef-ac0c8d7f28c0', '648a96dc-18fe-429a-85e8-4cfd44723d2f', true, '2025-02-03 02:48:54.999231+00', '2025-02-03 02:48:54.999231+00'),
	('c519149c-3647-4d1e-a4c4-42ff2bf5ff17', 'b4185cf1-ca0d-408e-a8eb-353fcb42ab65', '648a96dc-18fe-429a-85e8-4cfd44723d2f', true, '2025-02-03 02:48:54.999231+00', '2025-02-03 02:48:54.999231+00'),
	('7b458019-c471-4bc7-8da5-4dabdb7e883b', 'a4582de1-5d17-4526-ac78-69d76390dab0', '648a96dc-18fe-429a-85e8-4cfd44723d2f', true, '2025-02-03 02:48:54.999231+00', '2025-02-03 02:48:54.999231+00'),
	('6590bfec-f287-459f-950c-a5c93f1b8a10', '5477fced-418d-488f-a1f8-ca243c01cc53', '648a96dc-18fe-429a-85e8-4cfd44723d2f', true, '2025-02-03 02:48:54.999231+00', '2025-02-03 02:48:54.999231+00'),
	('884f06d4-3fbb-4390-8169-202f267e1737', 'c7d284db-cd13-4c33-995c-4b5f35b23858', '898b6a03-20e4-41cd-8ce6-a478aaf5c574', true, '2025-02-03 02:48:54.999231+00', '2025-02-03 02:48:54.999231+00'),
	('a79c94eb-d2c3-4d94-8489-c27f78dd55db', 'e6b1b224-c940-42e5-bc71-856b38c20e34', '648a96dc-18fe-429a-85e8-4cfd44723d2f', true, '2025-02-03 02:48:54.999231+00', '2025-02-03 02:48:54.999231+00'),
	('e8baec85-dddb-467e-afe3-b38b4816353c', '92ab14a1-15ee-439c-b991-6ac990a97eb1', '898b6a03-20e4-41cd-8ce6-a478aaf5c574', true, '2025-02-03 02:48:54.999231+00', '2025-02-03 02:48:54.999231+00'),
	('4c1349de-3b68-4515-9a73-ad259aeab60a', '59d76036-b107-4608-a7e5-22ab57c6fae3', '648a96dc-18fe-429a-85e8-4cfd44723d2f', true, '2025-02-03 02:48:54.999231+00', '2025-02-03 02:48:54.999231+00'),
	('687b9295-e9c8-4dcf-a5ae-d0e8dd2a48ac', 'cfd94f9b-5a11-4b01-b236-72080870e2ad', '648a96dc-18fe-429a-85e8-4cfd44723d2f', true, '2025-02-03 02:48:54.999231+00', '2025-02-03 02:48:54.999231+00'),
	('6c8c958e-8130-4c9a-aa9d-a5564ed6bbba', 'aec8cca1-13aa-4a42-980a-eec2081ffe2b', '648a96dc-18fe-429a-85e8-4cfd44723d2f', true, '2025-02-03 02:48:54.999231+00', '2025-02-03 02:48:54.999231+00');


--
-- PostgreSQL database dump complete
--

RESET ALL;
