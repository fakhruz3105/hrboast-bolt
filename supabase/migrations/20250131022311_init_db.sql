create type "public"."approval_status" as enum ('pending', 'approved', 'rejected');

create type "public"."evaluation_status" as enum ('pending', 'completed');

create type "public"."evaluation_type" as enum ('quarter', 'half-year', 'yearly');

create type "public"."exit_interview_status" as enum ('pending', 'approved', 'rejected');

create type "public"."kpi_status" as enum ('Pending', 'Achieved', 'Not Achieved');

create type "public"."letter_status" as enum ('draft', 'submitted', 'pending', 'signed');

create type "public"."letter_type" as enum ('warning', 'evaluation', 'interview', 'notice', 'show_cause');

create type "public"."memo_type" as enum ('custom', 'bonus', 'salary_increment', 'rewards');

create type "public"."show_cause_type" as enum ('lateness', 'harassment', 'leave_without_approval', 'offensive_behavior', 'insubordination', 'misconduct');

create type "public"."staff_status" as enum ('permanent', 'probation', 'resigned');

create type "public"."warning_level" as enum ('first', 'second', 'final');

create table "public"."benefit_claims" (
    "id" uuid not null default gen_random_uuid(),
    "benefit_id" uuid,
    "staff_id" uuid,
    "amount" numeric(10,2) not null,
    "status" text not null default 'pending'::text,
    "claim_date" date not null default CURRENT_DATE,
    "receipt_url" text,
    "notes" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."benefit_claims" enable row level security;

create table "public"."benefit_eligibility" (
    "id" uuid not null default gen_random_uuid(),
    "benefit_id" uuid,
    "level_id" uuid,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."benefit_eligibility" enable row level security;

create table "public"."benefits" (
    "id" uuid not null default gen_random_uuid(),
    "company_id" uuid not null,
    "name" text not null,
    "description" text,
    "amount" numeric(10,2) not null,
    "status" boolean default true,
    "frequency" text not null,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."benefits" enable row level security;

create table "public"."companies" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "email" text not null,
    "phone" text,
    "address" text,
    "subscription_status" text not null default 'trial'::text,
    "trial_ends_at" timestamp with time zone,
    "is_active" boolean default false,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "password_hash" text,
    "schema_name" text,
    "ssm" text,
    "logo_url" text
);


alter table "public"."companies" enable row level security;

create table "public"."company_events" (
    "id" uuid not null default gen_random_uuid(),
    "company_id" uuid,
    "title" text not null,
    "description" text,
    "quarter" text not null,
    "start_date" date not null,
    "end_date" date not null,
    "status" text not null default 'upcoming'::text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."company_events" enable row level security;

create table "public"."department_default_levels" (
    "id" uuid not null default gen_random_uuid(),
    "department_id" uuid,
    "level_id" uuid,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."department_default_levels" enable row level security;

create table "public"."departments" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "description" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."departments" enable row level security;

create table "public"."employee_form_requests" (
    "id" uuid not null default gen_random_uuid(),
    "staff_name" text not null,
    "email" text not null,
    "phone_number" text not null,
    "department_id" uuid,
    "level_id" uuid,
    "form_link" text not null,
    "status" text not null default 'pending'::text,
    "created_at" timestamp with time zone default now(),
    "expires_at" timestamp with time zone not null,
    "company_id" uuid
);


alter table "public"."employee_form_requests" enable row level security;

create table "public"."employee_form_responses" (
    "id" uuid not null default gen_random_uuid(),
    "request_id" uuid,
    "personal_info" jsonb not null,
    "education_history" jsonb not null,
    "employment_history" jsonb not null,
    "emergency_contacts" jsonb not null,
    "submitted_at" timestamp with time zone default now()
);


alter table "public"."employee_form_responses" enable row level security;

create table "public"."evaluation_departments" (
    "evaluation_id" uuid not null,
    "department_id" uuid not null,
    "created_at" timestamp with time zone default now()
);


alter table "public"."evaluation_departments" enable row level security;

create table "public"."evaluation_form_departments" (
    "evaluation_id" uuid not null,
    "department_id" uuid not null,
    "created_at" timestamp with time zone default now()
);


alter table "public"."evaluation_form_departments" enable row level security;

create table "public"."evaluation_form_levels" (
    "evaluation_id" uuid not null,
    "level_id" uuid not null,
    "created_at" timestamp with time zone default now()
);


alter table "public"."evaluation_form_levels" enable row level security;

create table "public"."evaluation_forms" (
    "id" uuid not null default gen_random_uuid(),
    "title" text not null,
    "type" evaluation_type not null,
    "questions" jsonb not null default '[]'::jsonb,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "company_id" uuid
);


alter table "public"."evaluation_forms" enable row level security;

create table "public"."evaluation_responses" (
    "id" uuid not null default gen_random_uuid(),
    "evaluation_id" uuid,
    "staff_id" uuid,
    "manager_id" uuid,
    "self_ratings" jsonb not null default '{}'::jsonb,
    "self_comments" jsonb not null default '{}'::jsonb,
    "manager_ratings" jsonb not null default '{}'::jsonb,
    "manager_comments" jsonb not null default '{}'::jsonb,
    "percentage_score" numeric(5,2),
    "status" evaluation_status not null default 'pending'::evaluation_status,
    "submitted_at" timestamp with time zone,
    "completed_at" timestamp with time zone,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."evaluation_responses" enable row level security;

create table "public"."exit_interviews" (
    "id" uuid not null default gen_random_uuid(),
    "staff_id" uuid,
    "reason" text not null,
    "detailed_reason" text not null,
    "last_working_date" date not null,
    "suggestions" text,
    "handover_notes" text not null,
    "exit_checklist" jsonb not null default '{"clearedDues": false, "returnedLaptop": false, "completedHandover": false, "returnedAccessCard": false}'::jsonb,
    "hr_approval" approval_status not null default 'pending'::approval_status,
    "admin_approval" approval_status not null default 'pending'::approval_status,
    "status" exit_interview_status not null default 'pending'::exit_interview_status,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."exit_interviews" enable row level security;

create table "public"."hr_letters" (
    "id" uuid not null default gen_random_uuid(),
    "staff_id" uuid,
    "title" text not null,
    "type" letter_type not null,
    "content" jsonb not null default '{}'::jsonb,
    "document_url" text,
    "issued_date" timestamp with time zone not null default now(),
    "status" letter_status not null default 'submitted'::letter_status,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."hr_letters" enable row level security;

create table "public"."inventory_items" (
    "id" uuid not null default gen_random_uuid(),
    "staff_id" uuid,
    "item_type" text not null,
    "item_name" text not null,
    "brand" text not null,
    "model" text not null,
    "serial_number" text not null,
    "purchase_date" date,
    "condition" text not null,
    "price" numeric(10,2) not null,
    "notes" text,
    "image_url" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."inventory_items" enable row level security;

create table "public"."kpi_feedback" (
    "id" uuid not null default gen_random_uuid(),
    "kpi_id" uuid,
    "message" text not null,
    "is_admin" boolean not null default false,
    "created_by" uuid,
    "created_at" timestamp with time zone default now()
);


alter table "public"."kpi_feedback" enable row level security;

create table "public"."kpi_updates" (
    "id" uuid not null default gen_random_uuid(),
    "kpi_id" uuid,
    "value" numeric not null,
    "notes" text,
    "updated_by" uuid,
    "created_at" timestamp with time zone default now()
);


alter table "public"."kpi_updates" enable row level security;

create table "public"."kpis" (
    "id" uuid not null default gen_random_uuid(),
    "title" text not null,
    "description" text not null,
    "start_date" date not null,
    "end_date" date not null,
    "department_id" uuid,
    "staff_id" uuid,
    "status" kpi_status not null default 'Pending'::kpi_status,
    "admin_comment" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "company_id" uuid,
    "period" text not null default 'Q1'::text
);


alter table "public"."kpis" enable row level security;

create table "public"."memos" (
    "id" uuid not null default gen_random_uuid(),
    "title" text not null,
    "type" memo_type not null,
    "content" text not null,
    "department_id" uuid,
    "staff_id" uuid,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "company_id" uuid
);


alter table "public"."memos" enable row level security;

create table "public"."role_mappings" (
    "id" uuid not null default gen_random_uuid(),
    "staff_level_id" uuid,
    "role" text not null,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."role_mappings" enable row level security;

create table "public"."schema_backups" (
    "id" uuid not null default gen_random_uuid(),
    "company_id" uuid,
    "backup_date" timestamp with time zone default now(),
    "backup_type" text not null,
    "backup_data" jsonb not null,
    "created_by" uuid,
    "restored_at" timestamp with time zone,
    "restored_by" uuid
);


alter table "public"."schema_backups" enable row level security;

create table "public"."show_cause_letters" (
    "id" uuid not null default gen_random_uuid(),
    "staff_id" uuid,
    "type" show_cause_type not null,
    "title" text,
    "incident_date" date not null,
    "description" text not null,
    "issued_date" timestamp with time zone not null default now(),
    "response" text,
    "response_date" timestamp with time zone,
    "status" text not null default 'pending'::text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."show_cause_letters" enable row level security;

create table "public"."staff" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "phone_number" text not null,
    "email" text not null,
    "join_date" date not null default CURRENT_DATE,
    "status" staff_status not null default 'probation'::staff_status,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "role_id" uuid not null,
    "is_active" boolean default false,
    "company_id" uuid,
    "password" character varying not null default 'kertas12'::character varying
);


alter table "public"."staff" enable row level security;

create table "public"."staff_departments" (
    "id" uuid not null default gen_random_uuid(),
    "staff_id" uuid,
    "department_id" uuid,
    "is_primary" boolean default false,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."staff_departments" enable row level security;

create table "public"."staff_levels" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "description" text not null,
    "rank" integer not null,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."staff_levels" enable row level security;

create table "public"."staff_levels_junction" (
    "id" uuid not null default gen_random_uuid(),
    "staff_id" uuid,
    "level_id" uuid,
    "is_primary" boolean default false,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."staff_levels_junction" enable row level security;

CREATE UNIQUE INDEX benefit_claims_pkey ON public.benefit_claims USING btree (id);

CREATE UNIQUE INDEX benefit_eligibility_benefit_id_level_id_key ON public.benefit_eligibility USING btree (benefit_id, level_id);

CREATE UNIQUE INDEX benefit_eligibility_pkey ON public.benefit_eligibility USING btree (id);

CREATE UNIQUE INDEX benefits_pkey ON public.benefits USING btree (id);

CREATE UNIQUE INDEX companies_email_key ON public.companies USING btree (email);

CREATE UNIQUE INDEX companies_pkey ON public.companies USING btree (id);

CREATE UNIQUE INDEX companies_schema_name_key ON public.companies USING btree (schema_name);

CREATE UNIQUE INDEX company_events_pkey ON public.company_events USING btree (id);

CREATE UNIQUE INDEX department_default_levels_department_id_key ON public.department_default_levels USING btree (department_id);

CREATE UNIQUE INDEX department_default_levels_pkey ON public.department_default_levels USING btree (id);

CREATE UNIQUE INDEX departments_name_key ON public.departments USING btree (name);

CREATE UNIQUE INDEX departments_pkey ON public.departments USING btree (id);

CREATE UNIQUE INDEX employee_form_requests_email_key ON public.employee_form_requests USING btree (email);

CREATE UNIQUE INDEX employee_form_requests_pkey ON public.employee_form_requests USING btree (id);

CREATE UNIQUE INDEX employee_form_responses_pkey ON public.employee_form_responses USING btree (id);

CREATE UNIQUE INDEX employee_form_responses_request_id_key ON public.employee_form_responses USING btree (request_id);

CREATE UNIQUE INDEX evaluation_departments_pkey ON public.evaluation_departments USING btree (evaluation_id, department_id);

CREATE UNIQUE INDEX evaluation_form_departments_pkey ON public.evaluation_form_departments USING btree (evaluation_id, department_id);

CREATE UNIQUE INDEX evaluation_form_levels_pkey ON public.evaluation_form_levels USING btree (evaluation_id, level_id);

CREATE UNIQUE INDEX evaluation_forms_pkey ON public.evaluation_forms USING btree (id);

CREATE UNIQUE INDEX evaluation_responses_pkey ON public.evaluation_responses USING btree (id);

CREATE UNIQUE INDEX exit_interviews_pkey ON public.exit_interviews USING btree (id);

CREATE UNIQUE INDEX hr_letters_pkey ON public.hr_letters USING btree (id);

CREATE INDEX idx_benefits_company ON public.benefits USING btree (company_id);

CREATE INDEX idx_benefits_status ON public.benefits USING btree (status);

CREATE INDEX idx_companies_schema_name ON public.companies USING btree (schema_name);

CREATE INDEX idx_companies_status ON public.companies USING btree (subscription_status, is_active);

CREATE INDEX idx_company_events_company ON public.company_events USING btree (company_id);

CREATE INDEX idx_company_events_dates ON public.company_events USING btree (start_date, end_date);

CREATE INDEX idx_company_events_quarter ON public.company_events USING btree (quarter);

CREATE INDEX idx_company_events_status ON public.company_events USING btree (status);

CREATE INDEX idx_dept_default_levels_department ON public.department_default_levels USING btree (department_id);

CREATE INDEX idx_dept_default_levels_level ON public.department_default_levels USING btree (level_id);

CREATE INDEX idx_employee_form_requests_company ON public.employee_form_requests USING btree (company_id);

CREATE INDEX idx_employee_form_requests_department ON public.employee_form_requests USING btree (department_id);

CREATE INDEX idx_employee_form_requests_level ON public.employee_form_requests USING btree (level_id);

CREATE INDEX idx_employee_form_requests_status ON public.employee_form_requests USING btree (status);

CREATE INDEX idx_employee_form_responses_request ON public.employee_form_responses USING btree (request_id);

CREATE INDEX idx_eval_form_depts_dept ON public.evaluation_form_departments USING btree (department_id);

CREATE INDEX idx_eval_form_depts_eval ON public.evaluation_form_departments USING btree (evaluation_id);

CREATE INDEX idx_eval_form_levels_eval ON public.evaluation_form_levels USING btree (evaluation_id);

CREATE INDEX idx_eval_form_levels_level ON public.evaluation_form_levels USING btree (level_id);

CREATE INDEX idx_evaluation_departments_department ON public.evaluation_departments USING btree (department_id);

CREATE INDEX idx_evaluation_departments_evaluation ON public.evaluation_departments USING btree (evaluation_id);

CREATE INDEX idx_evaluation_forms_company ON public.evaluation_forms USING btree (company_id);

CREATE INDEX idx_evaluation_forms_type ON public.evaluation_forms USING btree (type);

CREATE INDEX idx_evaluation_responses_evaluation ON public.evaluation_responses USING btree (evaluation_id);

CREATE INDEX idx_evaluation_responses_manager ON public.evaluation_responses USING btree (manager_id);

CREATE INDEX idx_evaluation_responses_staff ON public.evaluation_responses USING btree (staff_id);

CREATE INDEX idx_evaluation_responses_status ON public.evaluation_responses USING btree (status);

CREATE INDEX idx_exit_interviews_admin_approval ON public.exit_interviews USING btree (admin_approval);

CREATE INDEX idx_exit_interviews_hr_approval ON public.exit_interviews USING btree (hr_approval);

CREATE INDEX idx_exit_interviews_staff_id ON public.exit_interviews USING btree (staff_id);

CREATE INDEX idx_exit_interviews_status ON public.exit_interviews USING btree (status);

CREATE INDEX idx_hr_letters_issued_date ON public.hr_letters USING btree (issued_date);

CREATE INDEX idx_hr_letters_staff ON public.hr_letters USING btree (staff_id);

CREATE INDEX idx_hr_letters_status ON public.hr_letters USING btree (status);

CREATE INDEX idx_hr_letters_type ON public.hr_letters USING btree (type);

CREATE INDEX idx_inventory_items_condition ON public.inventory_items USING btree (condition);

CREATE INDEX idx_inventory_items_staff ON public.inventory_items USING btree (staff_id);

CREATE INDEX idx_inventory_items_type ON public.inventory_items USING btree (item_type);

CREATE INDEX idx_kpi_feedback_created_by ON public.kpi_feedback USING btree (created_by);

CREATE INDEX idx_kpi_feedback_kpi ON public.kpi_feedback USING btree (kpi_id);

CREATE INDEX idx_kpi_updates_kpi ON public.kpi_updates USING btree (kpi_id);

CREATE INDEX idx_kpis_company ON public.kpis USING btree (company_id);

CREATE INDEX idx_kpis_department ON public.kpis USING btree (department_id);

CREATE INDEX idx_kpis_staff ON public.kpis USING btree (staff_id);

CREATE INDEX idx_kpis_status ON public.kpis USING btree (status);

CREATE INDEX idx_memos_all_fields ON public.memos USING btree (department_id, staff_id, created_at);

CREATE INDEX idx_memos_company ON public.memos USING btree (company_id);

CREATE INDEX idx_memos_created_at ON public.memos USING btree (created_at);

CREATE INDEX idx_memos_department ON public.memos USING btree (department_id);

CREATE INDEX idx_memos_staff ON public.memos USING btree (staff_id);

CREATE INDEX idx_memos_type ON public.memos USING btree (type);

CREATE INDEX idx_role_mappings_role ON public.role_mappings USING btree (role);

CREATE INDEX idx_role_mappings_staff_level ON public.role_mappings USING btree (staff_level_id);

CREATE INDEX idx_schema_backups_company ON public.schema_backups USING btree (company_id);

CREATE INDEX idx_schema_backups_date ON public.schema_backups USING btree (backup_date);

CREATE INDEX idx_schema_backups_type ON public.schema_backups USING btree (backup_type);

CREATE INDEX idx_show_cause_letters_incident_date ON public.show_cause_letters USING btree (incident_date);

CREATE INDEX idx_show_cause_letters_staff ON public.show_cause_letters USING btree (staff_id);

CREATE INDEX idx_show_cause_letters_status ON public.show_cause_letters USING btree (status);

CREATE INDEX idx_show_cause_letters_type ON public.show_cause_letters USING btree (type);

CREATE INDEX idx_staff_company ON public.staff USING btree (company_id);

CREATE INDEX idx_staff_departments_department ON public.staff_departments USING btree (department_id);

CREATE INDEX idx_staff_departments_primary ON public.staff_departments USING btree (is_primary);

CREATE INDEX idx_staff_departments_staff ON public.staff_departments USING btree (staff_id);

CREATE INDEX idx_staff_is_active ON public.staff USING btree (is_active);

CREATE INDEX idx_staff_levels_junction_level ON public.staff_levels_junction USING btree (level_id);

CREATE INDEX idx_staff_levels_junction_primary ON public.staff_levels_junction USING btree (is_primary);

CREATE INDEX idx_staff_levels_junction_staff ON public.staff_levels_junction USING btree (staff_id);

CREATE INDEX idx_staff_role_id ON public.staff USING btree (role_id);

CREATE UNIQUE INDEX inventory_items_pkey ON public.inventory_items USING btree (id);

CREATE UNIQUE INDEX kpi_feedback_pkey ON public.kpi_feedback USING btree (id);

CREATE UNIQUE INDEX kpi_updates_pkey ON public.kpi_updates USING btree (id);

CREATE UNIQUE INDEX kpis_pkey ON public.kpis USING btree (id);

CREATE UNIQUE INDEX memos_pkey ON public.memos USING btree (id);

CREATE UNIQUE INDEX role_mappings_pkey ON public.role_mappings USING btree (id);

CREATE UNIQUE INDEX role_mappings_staff_level_id_key ON public.role_mappings USING btree (staff_level_id);

CREATE UNIQUE INDEX schema_backups_pkey ON public.schema_backups USING btree (id);

CREATE UNIQUE INDEX show_cause_letters_pkey ON public.show_cause_letters USING btree (id);

CREATE UNIQUE INDEX staff_departments_pkey ON public.staff_departments USING btree (id);

CREATE UNIQUE INDEX staff_departments_staff_id_department_id_key ON public.staff_departments USING btree (staff_id, department_id);

CREATE INDEX staff_email_idx ON public.staff USING btree (email);

CREATE UNIQUE INDEX staff_email_key ON public.staff USING btree (email);

CREATE UNIQUE INDEX staff_levels_junction_pkey ON public.staff_levels_junction USING btree (id);

CREATE UNIQUE INDEX staff_levels_junction_staff_id_level_id_key ON public.staff_levels_junction USING btree (staff_id, level_id);

CREATE UNIQUE INDEX staff_levels_name_key ON public.staff_levels USING btree (name);

CREATE UNIQUE INDEX staff_levels_pkey ON public.staff_levels USING btree (id);

CREATE UNIQUE INDEX staff_levels_rank_key ON public.staff_levels USING btree (rank);

CREATE UNIQUE INDEX staff_pkey ON public.staff USING btree (id);

CREATE INDEX staff_status_idx ON public.staff USING btree (status);

alter table "public"."benefit_claims" add constraint "benefit_claims_pkey" PRIMARY KEY using index "benefit_claims_pkey";

alter table "public"."benefit_eligibility" add constraint "benefit_eligibility_pkey" PRIMARY KEY using index "benefit_eligibility_pkey";

alter table "public"."benefits" add constraint "benefits_pkey" PRIMARY KEY using index "benefits_pkey";

alter table "public"."companies" add constraint "companies_pkey" PRIMARY KEY using index "companies_pkey";

alter table "public"."company_events" add constraint "company_events_pkey" PRIMARY KEY using index "company_events_pkey";

alter table "public"."department_default_levels" add constraint "department_default_levels_pkey" PRIMARY KEY using index "department_default_levels_pkey";

alter table "public"."departments" add constraint "departments_pkey" PRIMARY KEY using index "departments_pkey";

alter table "public"."employee_form_requests" add constraint "employee_form_requests_pkey" PRIMARY KEY using index "employee_form_requests_pkey";

alter table "public"."employee_form_responses" add constraint "employee_form_responses_pkey" PRIMARY KEY using index "employee_form_responses_pkey";

alter table "public"."evaluation_departments" add constraint "evaluation_departments_pkey" PRIMARY KEY using index "evaluation_departments_pkey";

alter table "public"."evaluation_form_departments" add constraint "evaluation_form_departments_pkey" PRIMARY KEY using index "evaluation_form_departments_pkey";

alter table "public"."evaluation_form_levels" add constraint "evaluation_form_levels_pkey" PRIMARY KEY using index "evaluation_form_levels_pkey";

alter table "public"."evaluation_forms" add constraint "evaluation_forms_pkey" PRIMARY KEY using index "evaluation_forms_pkey";

alter table "public"."evaluation_responses" add constraint "evaluation_responses_pkey" PRIMARY KEY using index "evaluation_responses_pkey";

alter table "public"."exit_interviews" add constraint "exit_interviews_pkey" PRIMARY KEY using index "exit_interviews_pkey";

alter table "public"."hr_letters" add constraint "hr_letters_pkey" PRIMARY KEY using index "hr_letters_pkey";

alter table "public"."inventory_items" add constraint "inventory_items_pkey" PRIMARY KEY using index "inventory_items_pkey";

alter table "public"."kpi_feedback" add constraint "kpi_feedback_pkey" PRIMARY KEY using index "kpi_feedback_pkey";

alter table "public"."kpi_updates" add constraint "kpi_updates_pkey" PRIMARY KEY using index "kpi_updates_pkey";

alter table "public"."kpis" add constraint "kpis_pkey" PRIMARY KEY using index "kpis_pkey";

alter table "public"."memos" add constraint "memos_pkey" PRIMARY KEY using index "memos_pkey";

alter table "public"."role_mappings" add constraint "role_mappings_pkey" PRIMARY KEY using index "role_mappings_pkey";

alter table "public"."schema_backups" add constraint "schema_backups_pkey" PRIMARY KEY using index "schema_backups_pkey";

alter table "public"."show_cause_letters" add constraint "show_cause_letters_pkey" PRIMARY KEY using index "show_cause_letters_pkey";

alter table "public"."staff" add constraint "staff_pkey" PRIMARY KEY using index "staff_pkey";

alter table "public"."staff_departments" add constraint "staff_departments_pkey" PRIMARY KEY using index "staff_departments_pkey";

alter table "public"."staff_levels" add constraint "staff_levels_pkey" PRIMARY KEY using index "staff_levels_pkey";

alter table "public"."staff_levels_junction" add constraint "staff_levels_junction_pkey" PRIMARY KEY using index "staff_levels_junction_pkey";

alter table "public"."benefit_claims" add constraint "benefit_claims_benefit_id_fkey" FOREIGN KEY (benefit_id) REFERENCES benefits(id) ON DELETE CASCADE not valid;

alter table "public"."benefit_claims" validate constraint "benefit_claims_benefit_id_fkey";

alter table "public"."benefit_claims" add constraint "benefit_claims_staff_id_fkey" FOREIGN KEY (staff_id) REFERENCES staff(id) ON DELETE CASCADE not valid;

alter table "public"."benefit_claims" validate constraint "benefit_claims_staff_id_fkey";

alter table "public"."benefit_eligibility" add constraint "benefit_eligibility_benefit_id_fkey" FOREIGN KEY (benefit_id) REFERENCES benefits(id) ON DELETE CASCADE not valid;

alter table "public"."benefit_eligibility" validate constraint "benefit_eligibility_benefit_id_fkey";

alter table "public"."benefit_eligibility" add constraint "benefit_eligibility_benefit_id_level_id_key" UNIQUE using index "benefit_eligibility_benefit_id_level_id_key";

alter table "public"."benefit_eligibility" add constraint "benefit_eligibility_level_id_fkey" FOREIGN KEY (level_id) REFERENCES staff_levels(id) ON DELETE CASCADE not valid;

alter table "public"."benefit_eligibility" validate constraint "benefit_eligibility_level_id_fkey";

alter table "public"."benefits" add constraint "benefits_company_id_fkey" FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE not valid;

alter table "public"."benefits" validate constraint "benefits_company_id_fkey";

alter table "public"."companies" add constraint "companies_email_key" UNIQUE using index "companies_email_key";

alter table "public"."companies" add constraint "companies_schema_name_key" UNIQUE using index "companies_schema_name_key";

alter table "public"."company_events" add constraint "company_events_company_id_fkey" FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE not valid;

alter table "public"."company_events" validate constraint "company_events_company_id_fkey";

alter table "public"."company_events" add constraint "company_events_quarter_check" CHECK ((quarter = ANY (ARRAY['Q1'::text, 'Q2'::text, 'Q3'::text, 'Q4'::text]))) not valid;

alter table "public"."company_events" validate constraint "company_events_quarter_check";

alter table "public"."company_events" add constraint "company_events_status_check" CHECK ((status = ANY (ARRAY['upcoming'::text, 'ongoing'::text, 'completed'::text]))) not valid;

alter table "public"."company_events" validate constraint "company_events_status_check";

alter table "public"."company_events" add constraint "valid_dates" CHECK ((start_date <= end_date)) not valid;

alter table "public"."company_events" validate constraint "valid_dates";

alter table "public"."department_default_levels" add constraint "department_default_levels_department_id_fkey" FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE CASCADE not valid;

alter table "public"."department_default_levels" validate constraint "department_default_levels_department_id_fkey";

alter table "public"."department_default_levels" add constraint "department_default_levels_department_id_key" UNIQUE using index "department_default_levels_department_id_key";

alter table "public"."department_default_levels" add constraint "department_default_levels_level_id_fkey" FOREIGN KEY (level_id) REFERENCES staff_levels(id) ON DELETE CASCADE not valid;

alter table "public"."department_default_levels" validate constraint "department_default_levels_level_id_fkey";

alter table "public"."departments" add constraint "departments_name_key" UNIQUE using index "departments_name_key";

alter table "public"."employee_form_requests" add constraint "employee_form_requests_company_id_fkey" FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE not valid;

alter table "public"."employee_form_requests" validate constraint "employee_form_requests_company_id_fkey";

alter table "public"."employee_form_requests" add constraint "employee_form_requests_department_id_fkey" FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE RESTRICT not valid;

alter table "public"."employee_form_requests" validate constraint "employee_form_requests_department_id_fkey";

alter table "public"."employee_form_requests" add constraint "employee_form_requests_email_key" UNIQUE using index "employee_form_requests_email_key";

alter table "public"."employee_form_requests" add constraint "employee_form_requests_level_id_fkey" FOREIGN KEY (level_id) REFERENCES staff_levels(id) ON DELETE RESTRICT not valid;

alter table "public"."employee_form_requests" validate constraint "employee_form_requests_level_id_fkey";

alter table "public"."employee_form_responses" add constraint "employee_form_responses_request_id_fkey" FOREIGN KEY (request_id) REFERENCES employee_form_requests(id) ON DELETE CASCADE not valid;

alter table "public"."employee_form_responses" validate constraint "employee_form_responses_request_id_fkey";

alter table "public"."employee_form_responses" add constraint "employee_form_responses_request_id_key" UNIQUE using index "employee_form_responses_request_id_key";

alter table "public"."evaluation_departments" add constraint "evaluation_departments_department_id_fkey" FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE CASCADE not valid;

alter table "public"."evaluation_departments" validate constraint "evaluation_departments_department_id_fkey";

alter table "public"."evaluation_form_departments" add constraint "evaluation_form_departments_department_id_fkey" FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE CASCADE not valid;

alter table "public"."evaluation_form_departments" validate constraint "evaluation_form_departments_department_id_fkey";

alter table "public"."evaluation_form_departments" add constraint "evaluation_form_departments_evaluation_id_fkey" FOREIGN KEY (evaluation_id) REFERENCES evaluation_forms(id) ON DELETE CASCADE not valid;

alter table "public"."evaluation_form_departments" validate constraint "evaluation_form_departments_evaluation_id_fkey";

alter table "public"."evaluation_form_levels" add constraint "evaluation_form_levels_evaluation_id_fkey" FOREIGN KEY (evaluation_id) REFERENCES evaluation_forms(id) ON DELETE CASCADE not valid;

alter table "public"."evaluation_form_levels" validate constraint "evaluation_form_levels_evaluation_id_fkey";

alter table "public"."evaluation_form_levels" add constraint "evaluation_form_levels_level_id_fkey" FOREIGN KEY (level_id) REFERENCES staff_levels(id) ON DELETE CASCADE not valid;

alter table "public"."evaluation_form_levels" validate constraint "evaluation_form_levels_level_id_fkey";

alter table "public"."evaluation_forms" add constraint "evaluation_forms_company_id_fkey" FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE not valid;

alter table "public"."evaluation_forms" validate constraint "evaluation_forms_company_id_fkey";

alter table "public"."evaluation_forms" add constraint "valid_questions" CHECK ((jsonb_typeof(questions) = 'array'::text)) not valid;

alter table "public"."evaluation_forms" validate constraint "valid_questions";

alter table "public"."evaluation_responses" add constraint "evaluation_responses_evaluation_id_fkey" FOREIGN KEY (evaluation_id) REFERENCES evaluation_forms(id) ON DELETE CASCADE not valid;

alter table "public"."evaluation_responses" validate constraint "evaluation_responses_evaluation_id_fkey";

alter table "public"."evaluation_responses" add constraint "evaluation_responses_manager_id_fkey" FOREIGN KEY (manager_id) REFERENCES staff(id) ON DELETE CASCADE not valid;

alter table "public"."evaluation_responses" validate constraint "evaluation_responses_manager_id_fkey";

alter table "public"."evaluation_responses" add constraint "evaluation_responses_percentage_score_check" CHECK (((percentage_score >= (0)::numeric) AND (percentage_score <= (100)::numeric))) not valid;

alter table "public"."evaluation_responses" validate constraint "evaluation_responses_percentage_score_check";

alter table "public"."evaluation_responses" add constraint "evaluation_responses_staff_id_fkey" FOREIGN KEY (staff_id) REFERENCES staff(id) ON DELETE CASCADE not valid;

alter table "public"."evaluation_responses" validate constraint "evaluation_responses_staff_id_fkey";

alter table "public"."evaluation_responses" add constraint "valid_manager_comments" CHECK ((jsonb_typeof(manager_comments) = 'object'::text)) not valid;

alter table "public"."evaluation_responses" validate constraint "valid_manager_comments";

alter table "public"."evaluation_responses" add constraint "valid_manager_ratings" CHECK ((jsonb_typeof(manager_ratings) = 'object'::text)) not valid;

alter table "public"."evaluation_responses" validate constraint "valid_manager_ratings";

alter table "public"."evaluation_responses" add constraint "valid_ratings" CHECK ((jsonb_typeof(self_ratings) = 'object'::text)) not valid;

alter table "public"."evaluation_responses" validate constraint "valid_ratings";

alter table "public"."evaluation_responses" add constraint "valid_self_comments" CHECK ((jsonb_typeof(self_comments) = 'object'::text)) not valid;

alter table "public"."evaluation_responses" validate constraint "valid_self_comments";

alter table "public"."exit_interviews" add constraint "exit_interviews_staff_id_fkey" FOREIGN KEY (staff_id) REFERENCES staff(id) ON DELETE CASCADE not valid;

alter table "public"."exit_interviews" validate constraint "exit_interviews_staff_id_fkey";

alter table "public"."exit_interviews" add constraint "valid_last_working_date" CHECK ((last_working_date >= CURRENT_DATE)) not valid;

alter table "public"."exit_interviews" validate constraint "valid_last_working_date";

alter table "public"."hr_letters" add constraint "hr_letters_staff_id_fkey" FOREIGN KEY (staff_id) REFERENCES staff(id) ON DELETE CASCADE not valid;

alter table "public"."hr_letters" validate constraint "hr_letters_staff_id_fkey";

alter table "public"."hr_letters" add constraint "valid_content" CHECK (
CASE
    WHEN ((type = 'interview'::letter_type) AND (content ? 'type'::text)) THEN ((content ->> 'type'::text) = ANY (ARRAY['exit'::text, 'employee'::text]))
    ELSE true
END) not valid;

alter table "public"."hr_letters" validate constraint "valid_content";

alter table "public"."inventory_items" add constraint "inventory_items_condition_check" CHECK ((condition = ANY (ARRAY['New'::text, 'Used'::text, 'Refurbished'::text]))) not valid;

alter table "public"."inventory_items" validate constraint "inventory_items_condition_check";

alter table "public"."inventory_items" add constraint "inventory_items_item_type_check" CHECK ((item_type = ANY (ARRAY['Laptop'::text, 'Phone'::text, 'Tablet'::text, 'Others'::text]))) not valid;

alter table "public"."inventory_items" validate constraint "inventory_items_item_type_check";

alter table "public"."inventory_items" add constraint "inventory_items_price_check" CHECK ((price >= (0)::numeric)) not valid;

alter table "public"."inventory_items" validate constraint "inventory_items_price_check";

alter table "public"."inventory_items" add constraint "inventory_items_staff_id_fkey" FOREIGN KEY (staff_id) REFERENCES staff(id) ON DELETE CASCADE not valid;

alter table "public"."inventory_items" validate constraint "inventory_items_staff_id_fkey";

alter table "public"."kpi_feedback" add constraint "kpi_feedback_created_by_fkey" FOREIGN KEY (created_by) REFERENCES staff(id) ON DELETE SET NULL not valid;

alter table "public"."kpi_feedback" validate constraint "kpi_feedback_created_by_fkey";

alter table "public"."kpi_feedback" add constraint "kpi_feedback_kpi_id_fkey" FOREIGN KEY (kpi_id) REFERENCES kpis(id) ON DELETE CASCADE not valid;

alter table "public"."kpi_feedback" validate constraint "kpi_feedback_kpi_id_fkey";

alter table "public"."kpi_updates" add constraint "kpi_updates_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES staff(id) ON DELETE SET NULL not valid;

alter table "public"."kpi_updates" validate constraint "kpi_updates_updated_by_fkey";

alter table "public"."kpis" add constraint "kpis_company_id_fkey" FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE not valid;

alter table "public"."kpis" validate constraint "kpis_company_id_fkey";

alter table "public"."kpis" add constraint "kpis_department_id_fkey" FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE CASCADE not valid;

alter table "public"."kpis" validate constraint "kpis_department_id_fkey";

alter table "public"."kpis" add constraint "kpis_period_check" CHECK ((period = ANY (ARRAY['Q1'::text, 'Q2'::text, 'Q3'::text, 'Q4'::text, 'yearly'::text]))) not valid;

alter table "public"."kpis" validate constraint "kpis_period_check";

alter table "public"."kpis" add constraint "kpis_staff_id_fkey" FOREIGN KEY (staff_id) REFERENCES staff(id) ON DELETE CASCADE not valid;

alter table "public"."kpis" validate constraint "kpis_staff_id_fkey";

alter table "public"."kpis" add constraint "valid_assignment" CHECK ((((department_id IS NULL) AND (staff_id IS NOT NULL)) OR ((department_id IS NOT NULL) AND (staff_id IS NULL)))) not valid;

alter table "public"."kpis" validate constraint "valid_assignment";

alter table "public"."kpis" add constraint "valid_dates" CHECK ((start_date <= end_date)) not valid;

alter table "public"."kpis" validate constraint "valid_dates";

alter table "public"."memos" add constraint "memos_company_id_fkey" FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE not valid;

alter table "public"."memos" validate constraint "memos_company_id_fkey";

alter table "public"."memos" add constraint "memos_department_id_fkey" FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL not valid;

alter table "public"."memos" validate constraint "memos_department_id_fkey";

alter table "public"."memos" add constraint "memos_staff_id_fkey" FOREIGN KEY (staff_id) REFERENCES staff(id) ON DELETE SET NULL not valid;

alter table "public"."memos" validate constraint "memos_staff_id_fkey";

alter table "public"."memos" add constraint "valid_recipient" CHECK ((((department_id IS NULL) AND (staff_id IS NULL)) OR ((department_id IS NOT NULL) AND (staff_id IS NULL)) OR ((department_id IS NULL) AND (staff_id IS NOT NULL)))) not valid;

alter table "public"."memos" validate constraint "valid_recipient";

alter table "public"."role_mappings" add constraint "role_mappings_role_check" CHECK ((role = ANY (ARRAY['admin'::text, 'hr'::text, 'staff'::text, 'super_admin'::text]))) not valid;

alter table "public"."role_mappings" validate constraint "role_mappings_role_check";

alter table "public"."role_mappings" add constraint "role_mappings_staff_level_id_fkey" FOREIGN KEY (staff_level_id) REFERENCES staff_levels(id) ON DELETE CASCADE not valid;

alter table "public"."role_mappings" validate constraint "role_mappings_staff_level_id_fkey";

alter table "public"."role_mappings" add constraint "role_mappings_staff_level_id_key" UNIQUE using index "role_mappings_staff_level_id_key";

alter table "public"."schema_backups" add constraint "schema_backups_company_id_fkey" FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE not valid;

alter table "public"."schema_backups" validate constraint "schema_backups_company_id_fkey";

alter table "public"."schema_backups" add constraint "schema_backups_created_by_fkey" FOREIGN KEY (created_by) REFERENCES staff(id) ON DELETE SET NULL not valid;

alter table "public"."schema_backups" validate constraint "schema_backups_created_by_fkey";

alter table "public"."schema_backups" add constraint "schema_backups_restored_by_fkey" FOREIGN KEY (restored_by) REFERENCES staff(id) ON DELETE SET NULL not valid;

alter table "public"."schema_backups" validate constraint "schema_backups_restored_by_fkey";

alter table "public"."show_cause_letters" add constraint "show_cause_letters_staff_id_fkey" FOREIGN KEY (staff_id) REFERENCES staff(id) ON DELETE CASCADE not valid;

alter table "public"."show_cause_letters" validate constraint "show_cause_letters_staff_id_fkey";

alter table "public"."show_cause_letters" add constraint "show_cause_letters_status_check" CHECK ((status = ANY (ARRAY['pending'::text, 'responded'::text]))) not valid;

alter table "public"."show_cause_letters" validate constraint "show_cause_letters_status_check";

alter table "public"."show_cause_letters" add constraint "valid_incident_date" CHECK ((incident_date <= CURRENT_DATE)) not valid;

alter table "public"."show_cause_letters" validate constraint "valid_incident_date";

alter table "public"."show_cause_letters" add constraint "valid_response" CHECK ((((status = 'responded'::text) AND (response IS NOT NULL) AND (response_date IS NOT NULL)) OR ((status = 'pending'::text) AND (response IS NULL) AND (response_date IS NULL)))) not valid;

alter table "public"."show_cause_letters" validate constraint "valid_response";

alter table "public"."staff" add constraint "staff_company_id_fkey" FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE not valid;

alter table "public"."staff" validate constraint "staff_company_id_fkey";

alter table "public"."staff" add constraint "staff_email_key" UNIQUE using index "staff_email_key";

alter table "public"."staff" add constraint "staff_role_id_fkey" FOREIGN KEY (role_id) REFERENCES role_mappings(id) not valid;

alter table "public"."staff" validate constraint "staff_role_id_fkey";

alter table "public"."staff_departments" add constraint "staff_departments_department_id_fkey" FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE CASCADE not valid;

alter table "public"."staff_departments" validate constraint "staff_departments_department_id_fkey";

alter table "public"."staff_departments" add constraint "staff_departments_staff_id_department_id_key" UNIQUE using index "staff_departments_staff_id_department_id_key";

alter table "public"."staff_departments" add constraint "staff_departments_staff_id_fkey" FOREIGN KEY (staff_id) REFERENCES staff(id) ON DELETE CASCADE not valid;

alter table "public"."staff_departments" validate constraint "staff_departments_staff_id_fkey";

alter table "public"."staff_levels" add constraint "staff_levels_name_key" UNIQUE using index "staff_levels_name_key";

alter table "public"."staff_levels" add constraint "staff_levels_rank_key" UNIQUE using index "staff_levels_rank_key";

alter table "public"."staff_levels_junction" add constraint "staff_levels_junction_level_id_fkey" FOREIGN KEY (level_id) REFERENCES staff_levels(id) ON DELETE CASCADE not valid;

alter table "public"."staff_levels_junction" validate constraint "staff_levels_junction_level_id_fkey";

alter table "public"."staff_levels_junction" add constraint "staff_levels_junction_staff_id_fkey" FOREIGN KEY (staff_id) REFERENCES staff(id) ON DELETE CASCADE not valid;

alter table "public"."staff_levels_junction" validate constraint "staff_levels_junction_staff_id_fkey";

alter table "public"."staff_levels_junction" add constraint "staff_levels_junction_staff_id_level_id_key" UNIQUE using index "staff_levels_junction_staff_id_level_id_key";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.activate_company(p_company_id uuid)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
  UPDATE companies
  SET 
    is_active = true,
    subscription_status = 'active',
    updated_at = now()
  WHERE id = p_company_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.assign_exit_interview(p_staff_id uuid, p_title text DEFAULT 'Exit Interview Form'::text)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_letter_id uuid;
BEGIN
  INSERT INTO hr_letters (
    staff_id,
    title,
    type,
    content,
    status,
    issued_date
  ) VALUES (
    p_staff_id,
    p_title,
    'interview',
    jsonb_build_object(
      'type', 'exit',
      'status', 'pending'
    ),
    'pending',
    now()
  ) RETURNING id INTO v_letter_id;

  RETURN v_letter_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.backup_company_data(p_company_id uuid, p_backup_type text, p_user_id uuid)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_schema_name text;
  v_backup_id uuid;
  v_backup_data jsonb;
BEGIN
  -- Get schema name
  SELECT schema_name INTO v_schema_name
  FROM companies
  WHERE id = p_company_id;

  IF v_schema_name IS NULL THEN
    RAISE EXCEPTION 'Company schema not found';
  END IF;

  -- Collect all data from company schema
  EXECUTE format('
    WITH schema_data AS (
      SELECT 
        jsonb_build_object(
          ''staff'', (
            SELECT jsonb_agg(row_to_json(s))
            FROM %1$I.staff s
          ),
          ''staff_departments'', (
            SELECT jsonb_agg(row_to_json(sd))
            FROM %1$I.staff_departments sd
          ),
          ''staff_levels_junction'', (
            SELECT jsonb_agg(row_to_json(sl))
            FROM %1$I.staff_levels_junction sl
          ),
          ''benefits'', (
            SELECT jsonb_agg(row_to_json(b))
            FROM %1$I.benefits b
          ),
          ''benefit_eligibility'', (
            SELECT jsonb_agg(row_to_json(be))
            FROM %1$I.benefit_eligibility be
          ),
          ''benefit_claims'', (
            SELECT jsonb_agg(row_to_json(bc))
            FROM %1$I.benefit_claims bc
          ),
          ''evaluation_forms'', (
            SELECT jsonb_agg(row_to_json(ef))
            FROM %1$I.evaluation_forms ef
          ),
          ''evaluation_responses'', (
            SELECT jsonb_agg(row_to_json(er))
            FROM %1$I.evaluation_responses er
          ),
          ''warning_letters'', (
            SELECT jsonb_agg(row_to_json(wl))
            FROM %1$I.warning_letters wl
          ),
          ''hr_letters'', (
            SELECT jsonb_agg(row_to_json(hl))
            FROM %1$I.hr_letters hl
          ),
          ''memos'', (
            SELECT jsonb_agg(row_to_json(m))
            FROM %1$I.memos m
          )
        ) as data
    )
    SELECT data INTO %L FROM schema_data',
    v_schema_name
  ) INTO v_backup_data;

  -- Create backup record
  INSERT INTO schema_backups (
    company_id,
    backup_type,
    backup_data,
    created_by
  ) VALUES (
    p_company_id,
    p_backup_type,
    v_backup_data,
    p_user_id
  ) RETURNING id INTO v_backup_id;

  RETURN v_backup_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.calculate_evaluation_percentage(manager_ratings jsonb, max_rating integer DEFAULT 5)
 RETURNS numeric
 LANGUAGE plpgsql
AS $function$
DECLARE
  total_score numeric;
  max_possible_score numeric;
  num_ratings integer;
BEGIN
  SELECT sum((value#>>'{}'::text[])::numeric)
  INTO total_score
  FROM jsonb_each(manager_ratings);

  SELECT count(*)
  INTO num_ratings
  FROM jsonb_each(manager_ratings);

  max_possible_score := num_ratings * max_rating;
  RETURN ROUND((total_score / max_possible_score * 100)::numeric, 2);
END;
$function$
;

CREATE OR REPLACE FUNCTION public.can_claim_benefit(staff_uid uuid, benefit_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
DECLARE
  is_eligible boolean;
BEGIN
  SELECT EXISTS (
    SELECT 1 
    FROM benefit_eligibility be
    JOIN staff s ON s.level_id = be.level_id
    WHERE s.id = staff_uid 
    AND be.benefit_id = benefit_id
  ) INTO is_eligible;
  
  RETURN is_eligible;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.check_benefit_eligibility(p_staff_id uuid, p_benefit_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM staff s
    JOIN benefit_eligibility be ON s.level_id = be.level_id
    WHERE s.id = p_staff_id
    AND be.benefit_id = p_benefit_id
  );
END;
$function$
;

CREATE OR REPLACE FUNCTION public.cleanup_company_data(p_company_id uuid)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_schema_name text;
BEGIN
  -- Get schema name
  SELECT schema_name INTO v_schema_name
  FROM companies
  WHERE id = p_company_id;

  IF v_schema_name IS NULL THEN
    RAISE EXCEPTION 'Company schema not found';
  END IF;

  -- Delete orphaned records
  EXECUTE format('
    -- Delete benefit claims without valid benefits
    DELETE FROM %I.benefit_claims bc
    WHERE NOT EXISTS (
      SELECT 1 FROM %I.benefits b WHERE b.id = bc.benefit_id
    );

    -- Delete benefit eligibility without valid benefits
    DELETE FROM %I.benefit_eligibility be
    WHERE NOT EXISTS (
      SELECT 1 FROM %I.benefits b WHERE b.id = be.benefit_id
    );

    -- Delete evaluation responses without valid forms
    DELETE FROM %I.evaluation_responses er
    WHERE NOT EXISTS (
      SELECT 1 FROM %I.evaluation_forms ef WHERE ef.id = er.evaluation_id
    );

    -- Delete staff departments without valid staff
    DELETE FROM %I.staff_departments sd
    WHERE NOT EXISTS (
      SELECT 1 FROM %I.staff s WHERE s.id = sd.staff_id
    );

    -- Delete staff levels without valid staff
    DELETE FROM %I.staff_levels_junction sl
    WHERE NOT EXISTS (
      SELECT 1 FROM %I.staff s WHERE s.id = sl.staff_id
    );',
    v_schema_name, v_schema_name,
    v_schema_name, v_schema_name,
    v_schema_name, v_schema_name,
    v_schema_name, v_schema_name,
    v_schema_name, v_schema_name
  );
END;
$function$
;

CREATE OR REPLACE FUNCTION public.cleanup_company_data(p_company_id uuid, p_cleanup_type text)
 RETURNS TABLE(cleanup_type text, items_removed integer, details text)
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_count integer;
BEGIN
  CASE p_cleanup_type
    -- Clean up inactive staff
    WHEN 'inactive_staff' THEN
      WITH deleted AS (
        DELETE FROM staff
        WHERE company_id = p_company_id
        AND is_active = false
        RETURNING id
      )
      SELECT count(*) INTO v_count FROM deleted;
      
      RETURN QUERY SELECT 
        'inactive_staff'::text,
        v_count,
        'Removed ' || v_count || ' inactive staff members'::text;

    -- Clean up expired benefits
    WHEN 'expired_benefits' THEN
      WITH deleted AS (
        DELETE FROM benefits
        WHERE company_id = p_company_id
        AND status = false
        RETURNING id
      )
      SELECT count(*) INTO v_count FROM deleted;
      
      RETURN QUERY SELECT 
        'expired_benefits'::text,
        v_count,
        'Removed ' || v_count || ' expired benefits'::text;

    -- Clean up old evaluations
    WHEN 'old_evaluations' THEN
      WITH deleted AS (
        DELETE FROM evaluation_responses er
        USING staff s
        WHERE s.company_id = p_company_id
        AND er.staff_id = s.id
        AND er.status = 'completed'
        AND er.completed_at < now() - interval '1 year'
        RETURNING er.id
      )
      SELECT count(*) INTO v_count FROM deleted;
      
      RETURN QUERY SELECT 
        'old_evaluations'::text,
        v_count,
        'Removed ' || v_count || ' evaluations older than 1 year'::text;

    -- Clean up old warning letters
    WHEN 'old_warnings' THEN
      WITH deleted AS (
        DELETE FROM warning_letters wl
        USING staff s
        WHERE s.company_id = p_company_id
        AND wl.staff_id = s.id
        AND wl.issued_date < now() - interval '2 years'
        RETURNING wl.id
      )
      SELECT count(*) INTO v_count FROM deleted;
      
      RETURN QUERY SELECT 
        'old_warnings'::text,
        v_count,
        'Removed ' || v_count || ' warning letters older than 2 years'::text;

    -- Clean up old memos
    WHEN 'old_memos' THEN
      WITH deleted AS (
        DELETE FROM memos m
        WHERE m.staff_id IN (
          SELECT id FROM staff WHERE company_id = p_company_id
        )
        AND m.created_at < now() - interval '1 year'
        RETURNING id
      )
      SELECT count(*) INTO v_count FROM deleted;
      
      RETURN QUERY SELECT 
        'old_memos'::text,
        v_count,
        'Removed ' || v_count || ' memos older than 1 year'::text;

    -- Clean up all data
    WHEN 'all' THEN
      -- Recursively call for each type
      RETURN QUERY SELECT * FROM cleanup_company_data(p_company_id, 'inactive_staff');
      RETURN QUERY SELECT * FROM cleanup_company_data(p_company_id, 'expired_benefits');
      RETURN QUERY SELECT * FROM cleanup_company_data(p_company_id, 'old_evaluations');
      RETURN QUERY SELECT * FROM cleanup_company_data(p_company_id, 'old_warnings');
      RETURN QUERY SELECT * FROM cleanup_company_data(p_company_id, 'old_memos');

    ELSE
      RAISE EXCEPTION 'Invalid cleanup type: %', p_cleanup_type;
  END CASE;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.cleanup_old_backups(p_company_id uuid, p_days_to_keep integer DEFAULT 30)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_deleted_count integer;
BEGIN
  WITH deleted AS (
    DELETE FROM schema_backups
    WHERE company_id = p_company_id
    AND backup_date < now() - (p_days_to_keep || ' days')::interval
    AND restored_at IS NOT NULL
    RETURNING id
  )
  SELECT count(*) INTO v_deleted_count FROM deleted;

  RETURN v_deleted_count;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.create_company(p_name text, p_email text, p_phone text, p_address text)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_company_id uuid;
BEGIN
  -- Create company with default password
  INSERT INTO companies (
    name,
    email,
    phone,
    address,
    trial_ends_at,
    is_active,
    password_hash
  ) VALUES (
    p_name,
    p_email,
    p_phone,
    p_address,
    now() + interval '14 days',
    true,
    'default123' -- Default password that should be changed on first login
  ) RETURNING id INTO v_company_id;

  RETURN v_company_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.create_company_schema(p_company_id uuid, p_schema_name text)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
  -- Create new schema
  EXECUTE format('CREATE SCHEMA IF NOT EXISTS %I', p_schema_name);

  -- Create show cause letters table in schema
  EXECUTE format('
    CREATE TABLE IF NOT EXISTS %I.show_cause_letters (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      staff_id uuid REFERENCES %I.staff(id) ON DELETE CASCADE,
      type show_cause_type NOT NULL,
      title text,
      incident_date date NOT NULL,
      description text NOT NULL,
      issued_date timestamptz NOT NULL DEFAULT now(),
      response text,
      response_date timestamptz,
      status text NOT NULL DEFAULT ''pending'' CHECK (status IN (''pending'', ''responded'')),
      created_at timestamptz DEFAULT now(),
      updated_at timestamptz DEFAULT now(),
      CONSTRAINT valid_incident_date CHECK (incident_date <= CURRENT_DATE),
      CONSTRAINT valid_response CHECK (
        (status = ''responded'' AND response IS NOT NULL AND response_date IS NOT NULL) OR
        (status = ''pending'' AND response IS NULL AND response_date IS NULL)
      )
    )',
    p_schema_name,
    p_schema_name
  );

  -- Create other tables...
  -- [Previous table creation code remains the same]

  -- Grant usage on schema to authenticated users
  EXECUTE format('GRANT USAGE ON SCHEMA %I TO authenticated', p_schema_name);
  
  -- Grant access to all tables in schema
  EXECUTE format('GRANT ALL ON ALL TABLES IN SCHEMA %I TO authenticated', p_schema_name);
END;
$function$
;

CREATE OR REPLACE FUNCTION public.create_hr_letter_for_warning()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  INSERT INTO hr_letters (
    staff_id,
    title,
    type,
    content,
    issued_date,
    status
  ) VALUES (
    NEW.staff_id,
    'Warning Letter - ' || UPPER(NEW.warning_level),
    'warning',
    jsonb_build_object(
      'warning_letter_id', NEW.id,
      'warning_level', NEW.warning_level,
      'incident_date', NEW.incident_date,
      'description', NEW.description,
      'improvement_plan', NEW.improvement_plan,
      'consequences', NEW.consequences
    ),
    NEW.issued_date,
    CASE 
      WHEN NEW.signed_document_url IS NOT NULL THEN 'signed'::letter_status
      ELSE 'pending'::letter_status
    END
  );
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.create_show_cause_letter(p_staff_id uuid, p_type show_cause_type, p_title text, p_incident_date date, p_description text)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_letter_id uuid;
BEGIN
  -- Create HR letter record
  INSERT INTO hr_letters (
    staff_id,
    title,
    type,
    content,
    status
  ) VALUES (
    p_staff_id,
    CASE 
      WHEN p_type = 'misconduct' THEN p_title
      ELSE initcap(replace(p_type::text, '_', ' '))
    END,
    'show_cause',
    jsonb_build_object(
      'type', p_type,
      'title', p_title,
      'incident_date', p_incident_date,
      'description', p_description,
      'status', 'pending'
    ),
    'pending'
  ) RETURNING id INTO v_letter_id;

  RETURN v_letter_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.create_warning_letter(p_staff_id uuid, p_warning_level text, p_incident_date date, p_description text, p_improvement_plan text, p_consequences text, p_issued_date date)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_letter_id uuid;
  v_company_id uuid;
  v_staff_name text;
BEGIN
  -- Get company_id and staff name
  SELECT company_id, name INTO v_company_id, v_staff_name
  FROM staff
  WHERE id = p_staff_id;

  IF v_company_id IS NULL THEN
    RAISE EXCEPTION 'Staff member not found or has no company assigned';
  END IF;

  -- Create HR letter for warning
  INSERT INTO hr_letters (
    staff_id,
    title,
    type,
    content,
    status,
    issued_date
  ) VALUES (
    p_staff_id,
    initcap(p_warning_level) || ' Warning Letter - ' || v_staff_name,
    'warning',
    jsonb_build_object(
      'warning_level', p_warning_level,
      'incident_date', p_incident_date,
      'description', p_description,
      'improvement_plan', p_improvement_plan,
      'consequences', p_consequences,
      'status', 'pending'
    ),
    'pending',
    p_issued_date
  ) RETURNING id INTO v_letter_id;

  RETURN v_letter_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.delete_department(p_department_id uuid)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
  -- First check if there are any employee form requests
  IF EXISTS (
    SELECT 1 FROM employee_form_requests 
    WHERE department_id = p_department_id
  ) THEN
    -- Set department_id to NULL for any employee form requests
    UPDATE employee_form_requests
    SET department_id = NULL
    WHERE department_id = p_department_id;
  END IF;

  -- Remove all staff associations with this department
  DELETE FROM staff_departments 
  WHERE department_id = p_department_id;

  -- Delete the department
  DELETE FROM departments WHERE id = p_department_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.delete_department_rpc(p_department_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  PERFORM delete_department(p_department_id);
END;
$function$
;

CREATE OR REPLACE FUNCTION public.delete_staff(p_staff_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
BEGIN
  -- Delete the staff member and all related records will be deleted via cascade
  DELETE FROM staff WHERE id = p_staff_id;
  RETURN true;
EXCEPTION
  WHEN foreign_key_violation THEN
    RAISE EXCEPTION 'Cannot delete staff member due to existing dependencies';
  WHEN OTHERS THEN
    RAISE EXCEPTION 'Failed to delete staff member: %', SQLERRM;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.ensure_single_primary_department()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  IF NEW.is_primary THEN
    UPDATE staff_departments
    SET is_primary = false
    WHERE staff_id = NEW.staff_id
    AND id != NEW.id;
  END IF;
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.ensure_single_primary_level()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  IF NEW.is_primary THEN
    UPDATE staff_levels_junction
    SET is_primary = false
    WHERE staff_id = NEW.staff_id
    AND id != NEW.id;
  END IF;
  RETURN NEW;
END;
$function$
;

create or replace view "public"."evaluation_forms_with_departments" as  SELECT ef.id,
    ef.title,
    ef.type,
    ef.questions,
    ef.created_at,
    ef.updated_at,
    array_agg(DISTINCT d.name) AS department_names,
    array_agg(DISTINCT d.id) AS department_ids
   FROM ((evaluation_forms ef
     LEFT JOIN evaluation_form_departments efd ON ((ef.id = efd.evaluation_id)))
     LEFT JOIN departments d ON ((efd.department_id = d.id)))
  GROUP BY ef.id;


create or replace view "public"."evaluation_forms_with_details" as  SELECT ef.id,
    ef.title,
    ef.type,
    ef.questions,
    ef.created_at,
    ef.updated_at,
    array_agg(DISTINCT d.name) AS department_names,
    array_agg(DISTINCT d.id) AS department_ids,
    array_agg(DISTINCT sl.name) AS level_names,
    array_agg(DISTINCT sl.id) AS level_ids
   FROM ((((evaluation_forms ef
     LEFT JOIN evaluation_form_departments efd ON ((ef.id = efd.evaluation_id)))
     LEFT JOIN departments d ON ((efd.department_id = d.id)))
     LEFT JOIN evaluation_form_levels efl ON ((ef.id = efl.evaluation_id)))
     LEFT JOIN staff_levels sl ON ((efl.level_id = sl.id)))
  GROUP BY ef.id;


CREATE OR REPLACE FUNCTION public.generate_schema_name(company_id uuid)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN 'company_' || replace(company_id::text, '-', '_');
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_all_companies()
 RETURNS TABLE(id uuid, name text, email text, phone text, address text, subscription_status text, trial_ends_at timestamp with time zone, is_active boolean, staff_count bigint, created_at timestamp with time zone)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  SELECT 
    c.id,
    c.name,
    c.email,
    c.phone,
    c.address,
    c.subscription_status,
    c.trial_ends_at,
    c.is_active,
    COUNT(s.id) as staff_count,
    c.created_at
  FROM companies c
  LEFT JOIN staff s ON s.company_id = c.id
  GROUP BY c.id
  ORDER BY c.created_at DESC;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_company_benefits(p_company_id uuid)
 RETURNS TABLE(id uuid, name text, description text, amount numeric, status boolean, frequency text, created_at timestamp with time zone, updated_at timestamp with time zone, eligible_levels uuid[])
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_schema_name text;
BEGIN
  -- Get schema name
  SELECT schema_name INTO v_schema_name
  FROM companies
  WHERE id = p_company_id;

  IF v_schema_name IS NULL THEN
    RAISE EXCEPTION 'Company schema not found';
  END IF;

  -- Return benefits
  RETURN QUERY EXECUTE format('
    SELECT 
      b.id,
      b.name,
      b.description,
      b.amount,
      b.status,
      b.frequency,
      b.created_at,
      b.updated_at,
      array_agg(DISTINCT be.level_id) FILTER (WHERE be.level_id IS NOT NULL) as eligible_levels
    FROM %I.benefits b
    LEFT JOIN %I.benefit_eligibility be ON b.id = be.benefit_id
    GROUP BY b.id
    ORDER BY b.created_at DESC',
    v_schema_name, v_schema_name
  );
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_company_data_summary(p_company_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_summary jsonb;
BEGIN
  SELECT jsonb_build_object(
    'company_info', (
      SELECT jsonb_build_object(
        'name', c.name,
        'email', c.email,
        'subscription_status', c.subscription_status,
        'is_active', c.is_active,
        'created_at', c.created_at
      )
      FROM companies c
      WHERE c.id = p_company_id
    ),
    'statistics', (
      SELECT jsonb_agg(
        jsonb_build_object(
          'category', category,
          'total_count', total_count,
          'active_count', active_count,
          'inactive_count', inactive_count,
          'last_updated', last_updated
        )
      )
      FROM get_company_statistics(p_company_id)
    ),
    'data_integrity', (
      SELECT jsonb_agg(
        jsonb_build_object(
          'issue_type', issue_type,
          'issue_count', issue_count,
          'details', details
        )
      )
      FROM validate_company_integrity(p_company_id)
    )
  ) INTO v_summary;

  RETURN v_summary;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_company_details(p_company_id uuid)
 RETURNS TABLE(id uuid, name text, email text, phone text, address text, subscription_status text, trial_ends_at timestamp with time zone, is_active boolean, staff_count bigint, created_at timestamp with time zone, updated_at timestamp with time zone)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  SELECT 
    c.id,
    c.name,
    c.email,
    c.phone,
    c.address,
    c.subscription_status,
    c.trial_ends_at,
    c.is_active,
    COUNT(s.id) as staff_count,
    c.created_at,
    c.updated_at
  FROM companies c
  LEFT JOIN staff s ON s.company_id = c.id
  WHERE c.id = p_company_id
  GROUP BY c.id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_company_employee_form_requests(p_company_id uuid)
 RETURNS TABLE(id uuid, staff_name text, email text, phone_number text, department_name text, level_name text, status text, form_link text, created_at timestamp with time zone, expires_at timestamp with time zone)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  SELECT 
    efr.id,
    efr.staff_name,
    efr.email,
    efr.phone_number,
    d.name as department_name,
    sl.name as level_name,
    efr.status,
    efr.form_link,
    efr.created_at,
    efr.expires_at
  FROM employee_form_requests efr
  LEFT JOIN departments d ON efr.department_id = d.id
  LEFT JOIN staff_levels sl ON efr.level_id = sl.id
  WHERE efr.company_id = p_company_id
  ORDER BY efr.created_at DESC;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_company_evaluations(p_company_id uuid)
 RETURNS TABLE(id uuid, title text, type text, questions jsonb, created_at timestamp with time zone, updated_at timestamp with time zone, assigned_staff uuid[])
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_schema_name text;
BEGIN
  -- Get schema name
  SELECT schema_name INTO v_schema_name
  FROM companies
  WHERE id = p_company_id;

  IF v_schema_name IS NULL THEN
    RAISE EXCEPTION 'Company schema not found';
  END IF;

  -- Return evaluations
  RETURN QUERY EXECUTE format('
    SELECT 
      ef.id,
      ef.title,
      ef.type::text,
      ef.questions,
      ef.created_at,
      ef.updated_at,
      array_agg(DISTINCT er.staff_id) FILTER (WHERE er.staff_id IS NOT NULL) as assigned_staff
    FROM %I.evaluation_forms ef
    LEFT JOIN %I.evaluation_responses er ON ef.id = er.evaluation_id
    GROUP BY ef.id
    ORDER BY ef.created_at DESC',
    v_schema_name, v_schema_name
  );
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_company_exit_interviews(p_company_id uuid)
 RETURNS TABLE(id uuid, staff_id uuid, title text, content jsonb, status text, issued_date timestamp with time zone, staff_name text, department_name text, response text, response_date timestamp with time zone)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  SELECT 
    l.id,
    l.staff_id,
    l.title,
    l.content,
    l.status::text,
    l.issued_date,
    s.name as staff_name,
    d.name as department_name,
    l.content->>'response' as response,
    (l.content->>'response_date')::timestamptz as response_date
  FROM hr_letters l
  JOIN staff s ON l.staff_id = s.id
  LEFT JOIN staff_departments sd ON s.id = sd.staff_id AND sd.is_primary = true
  LEFT JOIN departments d ON sd.department_id = d.id
  WHERE l.type = 'show_cause'
  AND s.company_id = p_company_id
  ORDER BY l.created_at DESC;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_company_info(p_company_id uuid)
 RETURNS TABLE(id uuid, name text, email text, phone text, address text, subscription_status text, trial_ends_at timestamp with time zone, is_active boolean, staff_count bigint, created_at timestamp with time zone)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  SELECT 
    c.id,
    c.name,
    c.email,
    c.phone,
    c.address,
    c.subscription_status,
    c.trial_ends_at,
    c.is_active,
    COUNT(s.id) as staff_count,
    c.created_at
  FROM companies c
  LEFT JOIN staff s ON s.company_id = c.id
  WHERE c.id = p_company_id
  GROUP BY c.id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_company_kpis()
 RETURNS TABLE(id uuid, title text, description text, start_date date, end_date date, department_name text, staff_name text, status text, admin_comment text, created_at timestamp with time zone, updated_at timestamp with time zone, feedback jsonb)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  SELECT 
    k.id,
    k.title,
    k.description,
    k.start_date,
    k.end_date,
    d.name as department_name,
    s.name as staff_name,
    k.status::text,
    k.admin_comment,
    k.created_at,
    k.updated_at,
    COALESCE(
      jsonb_agg(
        jsonb_build_object(
          'id', f.id,
          'message', f.message,
          'created_at', f.created_at,
          'created_by', f.created_by,
          'is_admin', f.is_admin
        )
      ) FILTER (WHERE f.id IS NOT NULL),
      '[]'::jsonb
    ) as feedback
  FROM kpis k
  LEFT JOIN departments d ON k.department_id = d.id
  LEFT JOIN staff s ON k.staff_id = s.id
  LEFT JOIN kpi_feedback f ON k.id = f.kpi_id
  GROUP BY k.id, d.name, s.name
  ORDER BY k.created_at DESC;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_company_kpis_with_feedback(p_company_id uuid)
 RETURNS TABLE(id uuid, title text, description text, period text, start_date date, end_date date, department_name text, staff_name text, status text, admin_comment text, created_at timestamp with time zone, updated_at timestamp with time zone, feedback jsonb)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  SELECT 
    k.id,
    k.title,
    k.description,
    k.period,
    k.start_date,
    k.end_date,
    d.name as department_name,
    s.name as staff_name,
    k.status::text,
    k.admin_comment,
    k.created_at,
    k.updated_at,
    COALESCE(
      jsonb_agg(
        jsonb_build_object(
          'id', f.id,
          'message', f.message,
          'created_at', f.created_at,
          'created_by', f.created_by,
          'is_admin', f.is_admin
        )
      ) FILTER (WHERE f.id IS NOT NULL),
      '[]'::jsonb
    ) as feedback
  FROM kpis k
  LEFT JOIN departments d ON k.department_id = d.id
  LEFT JOIN staff s ON k.staff_id = s.id
  LEFT JOIN kpi_feedback f ON k.id = f.kpi_id
  WHERE k.company_id = p_company_id
  GROUP BY k.id, d.name, s.name
  ORDER BY k.created_at DESC;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_company_schema(p_user_id uuid)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_schema_name text;
BEGIN
  -- Get schema name from companies table
  SELECT c.schema_name INTO v_schema_name
  FROM companies c
  JOIN staff s ON s.company_id = c.id
  WHERE s.id = p_user_id;
  
  RETURN v_schema_name;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_company_schema_name(p_company_id uuid)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN (
    SELECT schema_name 
    FROM companies 
    WHERE id = p_company_id
  );
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_company_staff(p_company_id uuid)
 RETURNS TABLE(id uuid, name text, email text, department_name text, level_name text, status text, is_active boolean)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  SELECT 
    s.id,
    s.name,
    s.email,
    d.name as department_name,
    sl.name as level_name,
    s.status::text,
    s.is_active
  FROM staff s
  LEFT JOIN staff_departments sd ON s.id = sd.staff_id AND sd.is_primary = true
  LEFT JOIN departments d ON sd.department_id = d.id
  LEFT JOIN staff_levels_junction slj ON s.id = slj.staff_id AND slj.is_primary = true
  LEFT JOIN staff_levels sl ON slj.level_id = sl.id
  WHERE s.company_id = p_company_id
  ORDER BY s.name;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_company_staff_details(p_company_id uuid)
 RETURNS TABLE(id uuid, name text, email text, phone_number text, department_name text, level_name text, status text, is_active boolean, join_date date)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  SELECT 
    s.id,
    s.name,
    s.email,
    s.phone_number,
    d.name as department_name,
    sl.name as level_name,
    s.status::text,
    s.is_active,
    s.join_date
  FROM staff s
  LEFT JOIN staff_departments sd ON s.id = sd.staff_id AND sd.is_primary = true
  LEFT JOIN departments d ON sd.department_id = d.id
  LEFT JOIN staff_levels_junction slj ON s.id = slj.staff_id AND slj.is_primary = true
  LEFT JOIN staff_levels sl ON slj.level_id = sl.id
  WHERE s.company_id = p_company_id
  ORDER BY s.name;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_company_staff_details(p_company_id uuid, p_staff_id uuid)
 RETURNS TABLE(id uuid, name text, email text, phone_number text, join_date date, status text, is_active boolean, role_id uuid, departments jsonb, levels jsonb)
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_schema_name text;
BEGIN
  -- Get schema name
  SELECT schema_name INTO v_schema_name
  FROM companies
  WHERE id = p_company_id;

  IF v_schema_name IS NULL THEN
    RAISE EXCEPTION 'Company schema not found';
  END IF;

  -- Return staff details
  RETURN QUERY EXECUTE format('
    SELECT 
      s.id,
      s.name,
      s.email,
      s.phone_number,
      s.join_date,
      s.status::text,
      s.is_active,
      s.role_id,
      COALESCE(
        jsonb_agg(DISTINCT jsonb_build_object(
          ''department_id'', sd.department_id,
          ''is_primary'', sd.is_primary
        )) FILTER (WHERE sd.id IS NOT NULL),
        ''[]''::jsonb
      ) as departments,
      COALESCE(
        jsonb_agg(DISTINCT jsonb_build_object(
          ''level_id'', sl.level_id,
          ''is_primary'', sl.is_primary
        )) FILTER (WHERE sl.id IS NOT NULL),
        ''[]''::jsonb
      ) as levels
    FROM %I.staff s
    LEFT JOIN %I.staff_departments sd ON s.id = sd.staff_id
    LEFT JOIN %I.staff_levels_junction sl ON s.id = sl.staff_id
    WHERE s.id = %L
    GROUP BY s.id',
    v_schema_name, v_schema_name, v_schema_name, p_staff_id
  );
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_company_statistics(p_company_id uuid)
 RETURNS TABLE(category text, total_count bigint, active_count bigint, inactive_count bigint, last_updated timestamp with time zone)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  
  -- Staff statistics
  SELECT 
    'staff'::text as category,
    count(*) as total_count,
    count(*) FILTER (WHERE is_active = true) as active_count,
    count(*) FILTER (WHERE is_active = false) as inactive_count,
    max(updated_at) as last_updated
  FROM staff
  WHERE company_id = p_company_id
  
  UNION ALL
  
  -- Benefits statistics
  SELECT 
    'benefits'::text,
    count(*),
    count(*) FILTER (WHERE status = true),
    count(*) FILTER (WHERE status = false),
    max(updated_at)
  FROM benefits
  WHERE company_id = p_company_id
  
  UNION ALL
  
  -- Evaluations statistics
  SELECT 
    'evaluations'::text,
    count(*),
    count(*) FILTER (WHERE er.status = 'completed'),
    count(*) FILTER (WHERE er.status = 'pending'),
    max(er.updated_at)
  FROM evaluation_responses er
  JOIN staff s ON er.staff_id = s.id
  WHERE s.company_id = p_company_id
  
  UNION ALL
  
  -- Warning letters statistics
  SELECT 
    'warning_letters'::text,
    count(*),
    count(*) FILTER (WHERE wl.show_cause_response IS NOT NULL),
    count(*) FILTER (WHERE wl.show_cause_response IS NULL),
    max(wl.updated_at)
  FROM warning_letters wl
  JOIN staff s ON wl.staff_id = s.id
  WHERE s.company_id = p_company_id
  
  UNION ALL
  
  -- Memos statistics
  SELECT 
    'memos'::text,
    count(*),
    count(*),
    0,
    max(m.updated_at)
  FROM memos m
  WHERE m.staff_id IN (SELECT id FROM staff WHERE company_id = p_company_id)
  OR m.department_id IN (
    SELECT DISTINCT department_id 
    FROM staff_departments sd
    JOIN staff s ON sd.staff_id = s.id
    WHERE s.company_id = p_company_id
  );
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_company_table_data(p_table_name text, p_company_id uuid)
 RETURNS SETOF json
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY EXECUTE format(
    'SELECT row_to_json(t) FROM (SELECT * FROM %I WHERE company_id = %L) t',
    p_table_name,
    p_company_id
  );
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_company_warning_letters(p_company_id uuid)
 RETURNS TABLE(id uuid, staff_id uuid, warning_level text, incident_date date, description text, improvement_plan text, consequences text, issued_date date, show_cause_response text, response_submitted_at timestamp with time zone, staff_name text, department_name text)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  SELECT 
    l.id,
    l.staff_id,
    l.content->>'warning_level',
    (l.content->>'incident_date')::date,
    l.content->>'description',
    l.content->>'improvement_plan',
    l.content->>'consequences',
    l.issued_date,
    l.content->>'response',
    (l.content->>'response_date')::timestamptz,
    s.name as staff_name,
    d.name as department_name
  FROM hr_letters l
  JOIN staff s ON l.staff_id = s.id
  LEFT JOIN staff_departments sd ON s.id = sd.staff_id AND sd.is_primary = true
  LEFT JOIN departments d ON sd.department_id = d.id
  WHERE l.type = 'warning'
  AND s.company_id = p_company_id
  ORDER BY l.issued_date DESC;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_department_evaluations(dept_id uuid)
 RETURNS TABLE(evaluation_id uuid, title text, type text, created_at timestamp with time zone)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  SELECT ef.id, ef.title, ef.type::text, ef.created_at
  FROM evaluation_forms ef
  JOIN evaluation_form_departments efd ON ef.id = efd.evaluation_id
  WHERE efd.department_id = dept_id
  ORDER BY ef.created_at DESC;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_evaluation_departments(evaluation_id uuid)
 RETURNS TABLE(department_id uuid, department_name text)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  SELECT d.id, d.name
  FROM departments d
  JOIN evaluation_form_departments efd ON d.id = efd.department_id
  WHERE efd.evaluation_id = $1;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_evaluation_details(p_evaluation_id uuid)
 RETURNS TABLE(evaluation_id uuid, staff_name text, department_name text, manager_name text, status text, percentage_score numeric)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  SELECT 
    er.id as evaluation_id,
    s.name as staff_name,
    d.name as department_name,
    m.name as manager_name,
    er.status::text,
    er.percentage_score
  FROM evaluation_responses er
  JOIN staff s ON er.staff_id = s.id
  LEFT JOIN staff_departments sd ON s.id = sd.staff_id AND sd.is_primary = true
  LEFT JOIN departments d ON sd.department_id = d.id
  LEFT JOIN staff m ON er.manager_id = m.id
  WHERE er.id = p_evaluation_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_evaluation_form_departments(evaluation_id uuid)
 RETURNS TABLE(department_id uuid, department_name text)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  SELECT d.id, d.name
  FROM departments d
  JOIN evaluation_form_departments efd ON d.id = efd.department_id
  WHERE efd.evaluation_id = $1;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_evaluation_levels(evaluation_id uuid)
 RETURNS TABLE(level_id uuid, level_name text, level_rank integer)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  SELECT sl.id, sl.name, sl.rank
  FROM staff_levels sl
  JOIN evaluation_form_levels efl ON sl.id = efl.level_id
  WHERE efl.evaluation_id = $1
  ORDER BY sl.rank;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_evaluation_response_details(p_response_id uuid)
 RETURNS TABLE(id uuid, staff_name text, department_name text, manager_name text, status text, percentage_score numeric, submitted_at timestamp with time zone, completed_at timestamp with time zone)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  SELECT 
    er.id,
    s.name as staff_name,
    pd.name as department_name,
    m.name as manager_name,
    er.status::text,
    er.percentage_score,
    er.submitted_at,
    er.completed_at
  FROM evaluation_responses er
  LEFT JOIN staff s ON er.staff_id = s.id
  LEFT JOIN staff m ON er.manager_id = m.id
  LEFT JOIN LATERAL (
    SELECT d.name
    FROM staff_departments sd
    JOIN departments d ON d.id = sd.department_id
    WHERE sd.staff_id = s.id AND sd.is_primary = true
    LIMIT 1
  ) pd ON true
  WHERE er.id = p_response_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_exit_interview_details(p_letter_id uuid)
 RETURNS TABLE(letter_id uuid, staff_name text, department_name text, content jsonb, status text, issued_date timestamp with time zone)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  SELECT 
    l.id as letter_id,
    s.name as staff_name,
    d.name as department_name,
    l.content,
    l.status::text,
    l.issued_date
  FROM hr_letters l
  JOIN staff s ON l.staff_id = s.id
  LEFT JOIN staff_departments sd ON s.id = sd.staff_id AND sd.is_primary = true
  LEFT JOIN departments d ON sd.department_id = d.id
  WHERE l.id = p_letter_id
  AND l.type = 'interview'
  AND l.content->>'type' = 'exit';
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_hr_letter_details(p_letter_id uuid)
 RETURNS TABLE(id uuid, title text, type text, content jsonb, status text, staff_name text, department_name text, issued_date timestamp with time zone)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  SELECT 
    l.id,
    l.title,
    l.type::text,
    l.content,
    l.status::text,
    s.name as staff_name,
    pd.name as department_name,
    l.issued_date
  FROM hr_letters l
  LEFT JOIN staff s ON l.staff_id = s.id
  LEFT JOIN LATERAL (
    SELECT d.name
    FROM staff_departments sd
    JOIN departments d ON d.id = sd.department_id
    WHERE sd.staff_id = s.id AND sd.is_primary = true
    LIMIT 1
  ) pd ON true
  WHERE l.id = p_letter_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_role_id_for_level(p_level_id uuid)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_role_id uuid;
BEGIN
  SELECT id INTO v_role_id
  FROM role_mappings
  WHERE staff_level_id = p_level_id;

  IF v_role_id IS NULL THEN
    -- If no role mapping exists, create a default 'staff' role mapping
    INSERT INTO role_mappings (staff_level_id, role)
    VALUES (p_level_id, 'staff')
    RETURNING id INTO v_role_id;
  END IF;

  RETURN v_role_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_staff_departments(p_staff_id uuid)
 RETURNS TABLE(department_id uuid, department_name text, is_primary boolean)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  SELECT 
    d.id as department_id,
    d.name as department_name,
    sd.is_primary
  FROM staff_departments sd
  JOIN departments d ON d.id = sd.department_id
  WHERE sd.staff_id = p_staff_id
  ORDER BY sd.is_primary DESC, d.name;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_staff_details(p_staff_id uuid)
 RETURNS TABLE(id uuid, name text, email text, phone_number text, join_date date, status text, primary_department_name text, other_department_names text[], primary_level_name text, other_level_names text[], role_name text)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  SELECT 
    s.id,
    s.name,
    s.email,
    s.phone_number,
    s.join_date,
    s.status::text,
    (
      SELECT d.name
      FROM staff_departments sd
      JOIN departments d ON d.id = sd.department_id
      WHERE sd.staff_id = s.id AND sd.is_primary = true
      LIMIT 1
    ) as primary_department_name,
    ARRAY(
      SELECT d.name
      FROM staff_departments sd
      JOIN departments d ON d.id = sd.department_id
      WHERE sd.staff_id = s.id AND sd.is_primary = false
      ORDER BY d.name
    ) as other_department_names,
    (
      SELECT sl.name
      FROM staff_levels_junction slj
      JOIN staff_levels sl ON sl.id = slj.level_id
      WHERE slj.staff_id = s.id AND slj.is_primary = true
      LIMIT 1
    ) as primary_level_name,
    ARRAY(
      SELECT sl.name
      FROM staff_levels_junction slj
      JOIN staff_levels sl ON sl.id = slj.level_id
      WHERE slj.staff_id = s.id AND slj.is_primary = false
      ORDER BY sl.name
    ) as other_level_names,
    rm.role as role_name
  FROM staff s
  LEFT JOIN role_mappings rm ON s.role_id = rm.id
  WHERE s.id = p_staff_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_staff_eligible_benefits(staff_uid uuid)
 RETURNS TABLE(id uuid, name text, description text, amount numeric, status boolean, frequency text, created_at timestamp with time zone, updated_at timestamp with time zone, is_eligible boolean)
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_company_id uuid;
  v_staff_status staff_status;
BEGIN
  -- Get staff's company_id and status
  SELECT s.company_id, s.status INTO v_company_id, v_staff_status
  FROM staff s
  WHERE s.id = staff_uid;

  IF v_company_id IS NULL THEN
    RAISE EXCEPTION 'Staff member not found or has no company assigned';
  END IF;

  RETURN QUERY
  SELECT 
    b.id,
    b.name,
    b.description,
    b.amount,
    b.status,
    b.frequency,
    b.created_at,
    b.updated_at,
    CASE 
      WHEN v_staff_status = 'probation' THEN false  -- Probation staff are not eligible
      ELSE EXISTS (
        SELECT 1 
        FROM benefit_eligibility be
        JOIN staff_levels_junction slj ON be.level_id = slj.level_id
        WHERE be.benefit_id = b.id 
        AND slj.staff_id = staff_uid
        AND slj.is_primary = true
      )
    END as is_eligible
  FROM benefits b
  WHERE b.company_id = v_company_id
  AND b.status = true
  ORDER BY b.created_at DESC;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_staff_evaluations(staff_uid uuid)
 RETURNS TABLE(id uuid, evaluation_id uuid, staff_id uuid, manager_id uuid, status text, percentage_score numeric, submitted_at timestamp with time zone, completed_at timestamp with time zone, evaluation_title text, evaluation_type text, department_name text, manager_name text)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  SELECT 
    er.id,
    er.evaluation_id,
    er.staff_id,
    er.manager_id,
    er.status::text,
    er.percentage_score,
    er.submitted_at,
    er.completed_at,
    ef.title as evaluation_title,
    ef.type::text as evaluation_type,
    d.name as department_name,
    m.name as manager_name
  FROM evaluation_responses er
  JOIN evaluation_forms ef ON er.evaluation_id = ef.id
  JOIN staff s ON er.staff_id = s.id
  JOIN departments d ON s.department_id = d.id
  JOIN staff m ON er.manager_id = m.id
  WHERE er.staff_id = staff_uid
  ORDER BY er.created_at DESC;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_staff_kpis(p_staff_id uuid)
 RETURNS TABLE(id uuid, title text, description text, start_date date, end_date date, status text, admin_comment text, created_at timestamp with time zone, updated_at timestamp with time zone, feedback jsonb)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  SELECT 
    k.id,
    k.title,
    k.description,
    k.start_date,
    k.end_date,
    k.status::text,
    k.admin_comment,
    k.created_at,
    k.updated_at,
    COALESCE(
      jsonb_agg(
        jsonb_build_object(
          'id', f.id,
          'message', f.message,
          'created_at', f.created_at,
          'created_by', f.created_by,
          'is_admin', f.is_admin
        )
      ) FILTER (WHERE f.id IS NOT NULL),
      '[]'::jsonb
    ) as feedback
  FROM kpis k
  LEFT JOIN kpi_feedback f ON k.id = f.kpi_id
  WHERE 
    k.staff_id = p_staff_id OR
    (k.department_id IN (
      SELECT department_id 
      FROM staff_departments 
      WHERE staff_id = p_staff_id
    ) AND k.staff_id IS NULL)
  GROUP BY k.id
  ORDER BY k.created_at DESC;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_staff_letters(p_staff_id uuid)
 RETURNS TABLE(letter_id uuid, title text, type text, content jsonb, status text, issued_date timestamp with time zone, department_name text)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  SELECT 
    l.id as letter_id,
    l.title,
    l.type::text,
    l.content,
    l.status::text,
    l.issued_date,
    d.name as department_name
  FROM hr_letters l
  LEFT JOIN staff_departments sd ON p_staff_id = sd.staff_id AND sd.is_primary = true
  LEFT JOIN departments d ON sd.department_id = d.id
  WHERE l.staff_id = p_staff_id
  ORDER BY l.issued_date DESC;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_staff_levels(p_staff_id uuid)
 RETURNS TABLE(level_id uuid, level_name text, level_rank integer, is_primary boolean)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  SELECT 
    sl.id as level_id,
    sl.name as level_name,
    sl.rank as level_rank,
    slj.is_primary
  FROM staff_levels_junction slj
  JOIN staff_levels sl ON sl.id = slj.level_id
  WHERE slj.staff_id = p_staff_id
  ORDER BY slj.is_primary DESC, sl.rank;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_staff_memo_details(p_staff_id uuid)
 RETURNS TABLE(id uuid, title text, type memo_type, content text, department_id uuid, staff_id uuid, created_at timestamp with time zone, updated_at timestamp with time zone, department_name text, staff_name text)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  SELECT 
    m.id,
    m.title,
    m.type,
    m.content,
    m.department_id,
    m.staff_id,
    m.created_at,
    m.updated_at,
    d.name as department_name,
    s.name as staff_name
  FROM memos m
  LEFT JOIN departments d ON m.department_id = d.id
  LEFT JOIN staff s ON m.staff_id = s.id
  WHERE 
    -- All staff memos
    (m.department_id IS NULL AND m.staff_id IS NULL) OR
    -- Department memos for staff's department
    m.department_id = (
      SELECT department_id 
      FROM staff 
      WHERE id = p_staff_id
    ) OR
    -- Personal memos
    m.staff_id = p_staff_id
  ORDER BY m.created_at DESC;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_staff_memo_list(p_staff_id uuid)
 RETURNS TABLE(id uuid, title text, type memo_type, content text, department_id uuid, staff_id uuid, created_at timestamp with time zone, updated_at timestamp with time zone, department_name text, staff_name text)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  SELECT 
    m.id,
    m.title,
    m.type,
    m.content,
    m.department_id,
    m.staff_id,
    m.created_at,
    m.updated_at,
    d.name as department_name,
    s2.name as staff_name
  FROM memos m
  LEFT JOIN departments d ON m.department_id = d.id
  LEFT JOIN staff s2 ON m.staff_id = s2.id
  JOIN staff s ON s.id = p_staff_id
  WHERE 
    -- All staff memos for this company
    (m.department_id IS NULL AND m.staff_id IS NULL AND m.company_id = s.company_id) OR
    -- Department memos for staff's departments
    m.department_id IN (
      SELECT sd.department_id 
      FROM staff_departments sd
      WHERE sd.staff_id = p_staff_id
    ) OR
    -- Personal memos
    m.staff_id = p_staff_id
  ORDER BY m.created_at DESC;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_staff_memos(p_staff_id uuid)
 RETURNS TABLE(id uuid, title text, type memo_type, content text, department_id uuid, staff_id uuid, created_at timestamp with time zone, updated_at timestamp with time zone, department_name text, staff_name text)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  SELECT 
    m.id,
    m.title,
    m.type,
    m.content,
    m.department_id,
    m.staff_id,
    m.created_at,
    m.updated_at,
    d.name as department_name,
    s.name as staff_name
  FROM memos m
  LEFT JOIN departments d ON m.department_id = d.id
  LEFT JOIN staff s ON m.staff_id = s.id
  WHERE 
    -- All staff memos
    (m.department_id IS NULL AND m.staff_id IS NULL) OR
    -- Department memos for staff's department
    m.department_id = (
      SELECT department_id 
      FROM staff 
      WHERE id = p_staff_id
    ) OR
    -- Personal memos
    m.staff_id = p_staff_id
  ORDER BY m.created_at DESC;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_staff_primary_department(p_staff_id uuid)
 RETURNS TABLE(department_id uuid, department_name text)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  SELECT 
    d.id as department_id,
    d.name as department_name
  FROM staff_departments sd
  JOIN departments d ON d.id = sd.department_id
  WHERE sd.staff_id = p_staff_id
  AND sd.is_primary = true;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_staff_primary_level(p_staff_id uuid)
 RETURNS TABLE(level_id uuid, level_name text, level_rank integer)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  SELECT 
    sl.id as level_id,
    sl.name as level_name,
    sl.rank as level_rank
  FROM staff_levels_junction slj
  JOIN staff_levels sl ON sl.id = slj.level_id
  WHERE slj.staff_id = p_staff_id
  AND slj.is_primary = true;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_user_company_id(user_id uuid)
 RETURNS uuid
 LANGUAGE sql
 STABLE
AS $function$
  SELECT company_id FROM staff WHERE id = user_id;
$function$
;

CREATE OR REPLACE FUNCTION public.get_warning_letter_details(p_letter_id uuid)
 RETURNS TABLE(letter_id uuid, staff_name text, department_name text, warning_level text, incident_date date, description text, improvement_plan text, consequences text, issued_date date, show_cause_response text, response_submitted_at timestamp with time zone)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  SELECT 
    wl.id as letter_id,
    s.name as staff_name,
    d.name as department_name,
    wl.warning_level::text,
    wl.incident_date,
    wl.description,
    wl.improvement_plan,
    wl.consequences,
    wl.issued_date,
    wl.show_cause_response,
    wl.response_submitted_at
  FROM warning_letters wl
  JOIN staff s ON wl.staff_id = s.id
  LEFT JOIN staff_departments sd ON s.id = sd.staff_id AND sd.is_primary = true
  LEFT JOIN departments d ON sd.department_id = d.id
  WHERE wl.id = p_letter_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.initialize_company_benefits(p_company_id uuid)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
  -- Insert default benefits
  INSERT INTO benefits (
    company_id,
    name,
    description,
    amount,
    status,
    frequency
  ) VALUES
    (p_company_id, 'Medical Insurance', 'Annual medical coverage including hospitalization and outpatient care', 5000.00, true, 'Annual coverage'),
    (p_company_id, 'Dental Coverage', 'Annual dental care coverage including routine checkups', 1000.00, true, 'Annual coverage'),
    (p_company_id, 'Professional Development', 'Annual allowance for courses and certifications', 2000.00, true, 'Annual coverage'),
    (p_company_id, 'Gym Membership', 'Monthly gym membership reimbursement', 100.00, true, 'Monthly'),
    (p_company_id, 'Work From Home Setup', 'One-time allowance for home office setup', 1500.00, true, 'Once per employment'),
    (p_company_id, 'Transportation', 'Monthly transportation allowance', 200.00, true, 'Monthly'),
    (p_company_id, 'Wellness Program', 'Annual wellness program including health screenings', 800.00, true, 'Annual coverage'),
    (p_company_id, 'Education Subsidy', 'Support for continuing education', 5000.00, true, 'Annual coverage'),
    (p_company_id, 'Parental Leave', 'Paid parental leave benefit', 3000.00, true, 'Per child'),
    (p_company_id, 'Marriage Allowance', 'One-time marriage celebration allowance', 1000.00, true, 'Once per employment');

  -- Assign benefits to all staff levels
  INSERT INTO benefit_eligibility (benefit_id, level_id)
  SELECT b.id, sl.id
  FROM benefits b
  CROSS JOIN staff_levels sl
  WHERE b.company_id = p_company_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.initialize_company_schema(p_company_id uuid)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_schema_name text;
BEGIN
  -- Generate schema name
  v_schema_name := generate_schema_name(p_company_id);
  
  -- Update company record with schema name
  UPDATE companies
  SET schema_name = v_schema_name
  WHERE id = p_company_id;

  -- Create schema
  EXECUTE format('CREATE SCHEMA IF NOT EXISTS %I', v_schema_name);

  -- Create tables in new schema
  EXECUTE format('
    -- Staff table
    CREATE TABLE IF NOT EXISTS %I.staff (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      name text NOT NULL,
      email text NOT NULL UNIQUE,
      phone_number text NOT NULL,
      join_date date NOT NULL DEFAULT CURRENT_DATE,
      status staff_status NOT NULL DEFAULT ''probation'',
      is_active boolean DEFAULT true,
      role_id uuid NOT NULL,
      created_at timestamptz DEFAULT now(),
      updated_at timestamptz DEFAULT now()
    );

    -- Staff departments table
    CREATE TABLE IF NOT EXISTS %I.staff_departments (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      staff_id uuid REFERENCES %I.staff(id) ON DELETE CASCADE,
      department_id uuid NOT NULL,
      is_primary boolean DEFAULT false,
      created_at timestamptz DEFAULT now(),
      updated_at timestamptz DEFAULT now(),
      UNIQUE(staff_id, department_id)
    );

    -- Staff levels junction table
    CREATE TABLE IF NOT EXISTS %I.staff_levels_junction (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      staff_id uuid REFERENCES %I.staff(id) ON DELETE CASCADE,
      level_id uuid NOT NULL,
      is_primary boolean DEFAULT false,
      created_at timestamptz DEFAULT now(),
      updated_at timestamptz DEFAULT now(),
      UNIQUE(staff_id, level_id)
    );

    -- Benefits table
    CREATE TABLE IF NOT EXISTS %I.benefits (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      name text NOT NULL,
      description text,
      amount numeric(10,2) NOT NULL,
      status boolean DEFAULT true,
      frequency text NOT NULL,
      created_at timestamptz DEFAULT now(),
      updated_at timestamptz DEFAULT now()
    );

    -- Benefit eligibility table
    CREATE TABLE IF NOT EXISTS %I.benefit_eligibility (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      benefit_id uuid REFERENCES %I.benefits(id) ON DELETE CASCADE,
      level_id uuid NOT NULL,
      created_at timestamptz DEFAULT now(),
      updated_at timestamptz DEFAULT now(),
      UNIQUE(benefit_id, level_id)
    );

    -- Benefit claims table
    CREATE TABLE IF NOT EXISTS %I.benefit_claims (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      benefit_id uuid REFERENCES %I.benefits(id) ON DELETE CASCADE,
      staff_id uuid REFERENCES %I.staff(id) ON DELETE CASCADE,
      amount numeric(10,2) NOT NULL,
      status text NOT NULL DEFAULT ''pending'',
      claim_date date NOT NULL DEFAULT CURRENT_DATE,
      receipt_url text,
      notes text,
      created_at timestamptz DEFAULT now(),
      updated_at timestamptz DEFAULT now()
    );

    -- Evaluation forms table
    CREATE TABLE IF NOT EXISTS %I.evaluation_forms (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      title text NOT NULL,
      type evaluation_type NOT NULL,
      questions jsonb NOT NULL DEFAULT ''[]'',
      created_at timestamptz DEFAULT now(),
      updated_at timestamptz DEFAULT now()
    );

    -- Evaluation responses table
    CREATE TABLE IF NOT EXISTS %I.evaluation_responses (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      evaluation_id uuid REFERENCES %I.evaluation_forms(id) ON DELETE CASCADE,
      staff_id uuid REFERENCES %I.staff(id) ON DELETE CASCADE,
      manager_id uuid REFERENCES %I.staff(id) ON DELETE CASCADE,
      self_ratings jsonb NOT NULL DEFAULT ''{}''::jsonb,
      self_comments jsonb NOT NULL DEFAULT ''{}''::jsonb,
      manager_ratings jsonb NOT NULL DEFAULT ''{}''::jsonb,
      manager_comments jsonb NOT NULL DEFAULT ''{}''::jsonb,
      percentage_score numeric(5,2),
      status evaluation_status NOT NULL DEFAULT ''pending'',
      submitted_at timestamptz,
      completed_at timestamptz,
      created_at timestamptz DEFAULT now(),
      updated_at timestamptz DEFAULT now()
    );

    -- Warning letters table
    CREATE TABLE IF NOT EXISTS %I.warning_letters (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      staff_id uuid REFERENCES %I.staff(id) ON DELETE CASCADE,
      warning_level warning_level NOT NULL,
      incident_date date NOT NULL,
      description text NOT NULL,
      improvement_plan text NOT NULL,
      consequences text NOT NULL,
      issued_date date NOT NULL,
      show_cause_response text,
      response_submitted_at timestamptz,
      created_at timestamptz DEFAULT now(),
      updated_at timestamptz DEFAULT now()
    );

    -- HR letters table
    CREATE TABLE IF NOT EXISTS %I.hr_letters (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      staff_id uuid REFERENCES %I.staff(id) ON DELETE CASCADE,
      title text NOT NULL,
      type letter_type NOT NULL,
      content jsonb NOT NULL DEFAULT ''{}''::jsonb,
      document_url text,
      issued_date timestamptz NOT NULL DEFAULT now(),
      status letter_status NOT NULL DEFAULT ''submitted'',
      created_at timestamptz DEFAULT now(),
      updated_at timestamptz DEFAULT now()
    );

    -- Memos table
    CREATE TABLE IF NOT EXISTS %I.memos (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      title text NOT NULL,
      type memo_type NOT NULL,
      content text NOT NULL,
      department_id uuid,
      staff_id uuid REFERENCES %I.staff(id) ON DELETE CASCADE,
      created_at timestamptz DEFAULT now(),
      updated_at timestamptz DEFAULT now()
    );',
    v_schema_name, -- staff
    v_schema_name, v_schema_name, -- staff_departments
    v_schema_name, v_schema_name, -- staff_levels_junction
    v_schema_name, -- benefits
    v_schema_name, v_schema_name, -- benefit_eligibility
    v_schema_name, v_schema_name, v_schema_name, -- benefit_claims
    v_schema_name, -- evaluation_forms
    v_schema_name, v_schema_name, v_schema_name, v_schema_name, -- evaluation_responses
    v_schema_name, v_schema_name, -- warning_letters
    v_schema_name, v_schema_name, -- hr_letters
    v_schema_name, v_schema_name -- memos
  );

  -- Grant usage on schema to authenticated users
  EXECUTE format('GRANT USAGE ON SCHEMA %I TO authenticated', v_schema_name);
  
  -- Grant access to all tables in schema
  EXECUTE format('GRANT ALL ON ALL TABLES IN SCHEMA %I TO authenticated', v_schema_name);
END;
$function$
;

CREATE OR REPLACE FUNCTION public.initialize_new_company(p_name text, p_email text, p_phone text, p_address text)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_company_id uuid;
BEGIN
  -- Create company record
  INSERT INTO companies (
    name,
    email,
    phone,
    address,
    trial_ends_at,
    is_active
  ) VALUES (
    p_name,
    p_email,
    p_phone,
    p_address,
    now() + interval '14 days',
    true
  ) RETURNING id INTO v_company_id;

  -- Initialize schema for new company
  PERFORM initialize_company_schema(v_company_id);

  RETURN v_company_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.insert_company_data(p_table_name text, p_user_id uuid, p_data json)
 RETURNS json
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_schema_name text;
  v_sql text;
  v_result json;
BEGIN
  -- Get schema name for user's company
  SELECT c.schema_name INTO v_schema_name
  FROM companies c
  JOIN staff s ON s.company_id = c.id
  WHERE s.id = p_user_id;

  IF v_schema_name IS NULL THEN
    RAISE EXCEPTION 'Company schema not found';
  END IF;

  -- Build and execute insert query
  v_sql := format('
    INSERT INTO %I.%I 
    SELECT * FROM json_populate_record(null::%I.%I, %L)
    RETURNING row_to_json(%I.*)',
    v_schema_name, p_table_name,
    v_schema_name, p_table_name,
    p_data,
    p_table_name
  );
  
  EXECUTE v_sql INTO v_result;
  RETURN v_result;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.list_company_backups(p_company_id uuid)
 RETURNS TABLE(backup_id uuid, backup_type text, backup_date timestamp with time zone, created_by_name text, restored_at timestamp with time zone, restored_by_name text, table_counts jsonb)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  SELECT 
    b.id as backup_id,
    b.backup_type,
    b.backup_date,
    c.name as created_by_name,
    b.restored_at,
    r.name as restored_by_name,
    jsonb_build_object(
      'staff', jsonb_array_length(b.backup_data->'staff'),
      'benefits', jsonb_array_length(b.backup_data->'benefits'),
      'evaluations', jsonb_array_length(b.backup_data->'evaluation_forms'),
      'warning_letters', jsonb_array_length(b.backup_data->'warning_letters'),
      'hr_letters', jsonb_array_length(b.backup_data->'hr_letters'),
      'memos', jsonb_array_length(b.backup_data->'memos')
    ) as table_counts
  FROM schema_backups b
  LEFT JOIN staff c ON b.created_by = c.id
  LEFT JOIN staff r ON b.restored_by = r.id
  WHERE b.company_id = p_company_id
  ORDER BY b.backup_date DESC;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.migrate_company_data(p_company_id uuid)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_schema_name text;
BEGIN
  -- Get schema name
  SELECT schema_name INTO v_schema_name
  FROM companies
  WHERE id = p_company_id;

  IF v_schema_name IS NULL THEN
    RAISE EXCEPTION 'Company schema not found';
  END IF;

  -- Migrate staff data
  EXECUTE format('
    INSERT INTO %I.staff (
      id, name, email, phone_number, join_date, status, is_active, role_id, created_at, updated_at
    )
    SELECT 
      id, name, email, phone_number, join_date, status, is_active, role_id, created_at, updated_at
    FROM public.staff
    WHERE company_id = %L
    ON CONFLICT (id) DO UPDATE SET
      name = EXCLUDED.name,
      email = EXCLUDED.email,
      phone_number = EXCLUDED.phone_number,
      join_date = EXCLUDED.join_date,
      status = EXCLUDED.status,
      is_active = EXCLUDED.is_active,
      role_id = EXCLUDED.role_id,
      updated_at = now()',
    v_schema_name, p_company_id
  );

  -- Migrate staff departments
  EXECUTE format('
    INSERT INTO %I.staff_departments (
      id, staff_id, department_id, is_primary, created_at, updated_at
    )
    SELECT 
      sd.id, sd.staff_id, sd.department_id, sd.is_primary, sd.created_at, sd.updated_at
    FROM public.staff_departments sd
    JOIN public.staff s ON sd.staff_id = s.id
    WHERE s.company_id = %L
    ON CONFLICT (staff_id, department_id) DO UPDATE SET
      is_primary = EXCLUDED.is_primary,
      updated_at = now()',
    v_schema_name, p_company_id
  );

  -- Migrate staff levels
  EXECUTE format('
    INSERT INTO %I.staff_levels_junction (
      id, staff_id, level_id, is_primary, created_at, updated_at
    )
    SELECT 
      slj.id, slj.staff_id, slj.level_id, slj.is_primary, slj.created_at, slj.updated_at
    FROM public.staff_levels_junction slj
    JOIN public.staff s ON slj.staff_id = s.id
    WHERE s.company_id = %L
    ON CONFLICT (staff_id, level_id) DO UPDATE SET
      is_primary = EXCLUDED.is_primary,
      updated_at = now()',
    v_schema_name, p_company_id
  );

  -- Migrate benefits
  EXECUTE format('
    INSERT INTO %I.benefits (
      id, name, description, amount, status, frequency, created_at, updated_at
    )
    SELECT 
      id, name, description, amount, status, frequency, created_at, updated_at
    FROM public.benefits
    WHERE company_id = %L
    ON CONFLICT (id) DO UPDATE SET
      name = EXCLUDED.name,
      description = EXCLUDED.description,
      amount = EXCLUDED.amount,
      status = EXCLUDED.status,
      frequency = EXCLUDED.frequency,
      updated_at = now()',
    v_schema_name, p_company_id
  );

  -- Migrate benefit eligibility
  EXECUTE format('
    INSERT INTO %I.benefit_eligibility (
      id, benefit_id, level_id, created_at, updated_at
    )
    SELECT 
      be.id, be.benefit_id, be.level_id, be.created_at, be.updated_at
    FROM public.benefit_eligibility be
    JOIN public.benefits b ON be.benefit_id = b.id
    WHERE b.company_id = %L
    ON CONFLICT (benefit_id, level_id) DO UPDATE SET
      updated_at = now()',
    v_schema_name, p_company_id
  );

  -- Migrate benefit claims
  EXECUTE format('
    INSERT INTO %I.benefit_claims (
      id, benefit_id, staff_id, amount, status, claim_date, receipt_url, notes, created_at, updated_at
    )
    SELECT 
      bc.id, bc.benefit_id, bc.staff_id, bc.amount, bc.status, bc.claim_date, bc.receipt_url, bc.notes, bc.created_at, bc.updated_at
    FROM public.benefit_claims bc
    JOIN public.staff s ON bc.staff_id = s.id
    WHERE s.company_id = %L
    ON CONFLICT (id) DO UPDATE SET
      amount = EXCLUDED.amount,
      status = EXCLUDED.status,
      receipt_url = EXCLUDED.receipt_url,
      notes = EXCLUDED.notes,
      updated_at = now()',
    v_schema_name, p_company_id
  );

  -- Migrate evaluation forms
  EXECUTE format('
    INSERT INTO %I.evaluation_forms (
      id, title, type, questions, created_at, updated_at
    )
    SELECT 
      ef.id, ef.title, ef.type, ef.questions, ef.created_at, ef.updated_at
    FROM public.evaluation_forms ef
    JOIN public.evaluation_responses er ON ef.id = er.evaluation_id
    JOIN public.staff s ON er.staff_id = s.id
    WHERE s.company_id = %L
    GROUP BY ef.id
    ON CONFLICT (id) DO UPDATE SET
      title = EXCLUDED.title,
      type = EXCLUDED.type,
      questions = EXCLUDED.questions,
      updated_at = now()',
    v_schema_name, p_company_id
  );

  -- Migrate evaluation responses
  EXECUTE format('
    INSERT INTO %I.evaluation_responses (
      id, evaluation_id, staff_id, manager_id, self_ratings, self_comments,
      manager_ratings, manager_comments, percentage_score, status,
      submitted_at, completed_at, created_at, updated_at
    )
    SELECT 
      er.id, er.evaluation_id, er.staff_id, er.manager_id, er.self_ratings,
      er.self_comments, er.manager_ratings, er.manager_comments, er.percentage_score,
      er.status, er.submitted_at, er.completed_at, er.created_at, er.updated_at
    FROM public.evaluation_responses er
    JOIN public.staff s ON er.staff_id = s.id
    WHERE s.company_id = %L
    ON CONFLICT (id) DO UPDATE SET
      self_ratings = EXCLUDED.self_ratings,
      self_comments = EXCLUDED.self_comments,
      manager_ratings = EXCLUDED.manager_ratings,
      manager_comments = EXCLUDED.manager_comments,
      percentage_score = EXCLUDED.percentage_score,
      status = EXCLUDED.status,
      submitted_at = EXCLUDED.submitted_at,
      completed_at = EXCLUDED.completed_at,
      updated_at = now()',
    v_schema_name, p_company_id
  );

  -- Migrate warning letters
  EXECUTE format('
    INSERT INTO %I.warning_letters (
      id, staff_id, warning_level, incident_date, description, improvement_plan,
      consequences, issued_date, show_cause_response, response_submitted_at,
      created_at, updated_at
    )
    SELECT 
      wl.id, wl.staff_id, wl.warning_level, wl.incident_date, wl.description,
      wl.improvement_plan, wl.consequences, wl.issued_date, wl.show_cause_response,
      wl.response_submitted_at, wl.created_at, wl.updated_at
    FROM public.warning_letters wl
    JOIN public.staff s ON wl.staff_id = s.id
    WHERE s.company_id = %L
    ON CONFLICT (id) DO UPDATE SET
      description = EXCLUDED.description,
      improvement_plan = EXCLUDED.improvement_plan,
      consequences = EXCLUDED.consequences,
      show_cause_response = EXCLUDED.show_cause_response,
      response_submitted_at = EXCLUDED.response_submitted_at,
      updated_at = now()',
    v_schema_name, p_company_id
  );

  -- Migrate HR letters
  EXECUTE format('
    INSERT INTO %I.hr_letters (
      id, staff_id, title, type, content, document_url, issued_date, status,
      created_at, updated_at
    )
    SELECT 
      hl.id, hl.staff_id, hl.title, hl.type, hl.content, hl.document_url,
      hl.issued_date, hl.status, hl.created_at, hl.updated_at
    FROM public.hr_letters hl
    JOIN public.staff s ON hl.staff_id = s.id
    WHERE s.company_id = %L
    ON CONFLICT (id) DO UPDATE SET
      title = EXCLUDED.title,
      content = EXCLUDED.content,
      document_url = EXCLUDED.document_url,
      status = EXCLUDED.status,
      updated_at = now()',
    v_schema_name, p_company_id
  );

  -- Migrate memos
  EXECUTE format('
    INSERT INTO %I.memos (
      id, title, type, content, department_id, staff_id, created_at, updated_at
    )
    SELECT 
      m.id, m.title, m.type, m.content, m.department_id, m.staff_id,
      m.created_at, m.updated_at
    FROM public.memos m
    LEFT JOIN public.staff s ON m.staff_id = s.id
    WHERE s.company_id = %L OR m.department_id IN (
      SELECT DISTINCT department_id 
      FROM public.staff_departments sd
      JOIN public.staff s2 ON sd.staff_id = s2.id
      WHERE s2.company_id = %L
    )
    ON CONFLICT (id) DO UPDATE SET
      title = EXCLUDED.title,
      content = EXCLUDED.content,
      updated_at = now()',
    v_schema_name, p_company_id, p_company_id
  );
END;
$function$
;

CREATE OR REPLACE FUNCTION public.migrate_data_to_company_schema(p_company_id uuid)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_schema_name text;
BEGIN
  -- Skip Muslimtravelbug
  IF EXISTS (
    SELECT 1 FROM companies 
    WHERE id = p_company_id 
    AND name = 'Muslimtravelbug Sdn Bhd'
  ) THEN
    RETURN;
  END IF;

  -- Get schema name
  SELECT schema_name INTO v_schema_name
  FROM companies
  WHERE id = p_company_id;

  IF v_schema_name IS NULL THEN
    -- Initialize schema if it doesn't exist
    PERFORM initialize_company_schema(p_company_id);
    SELECT schema_name INTO v_schema_name
    FROM companies
    WHERE id = p_company_id;
  END IF;

  -- Migrate staff data
  EXECUTE format('
    INSERT INTO %I.staff (
      id, name, email, phone_number, join_date, status, is_active, role_id
    )
    SELECT 
      id, name, email, phone_number, join_date, status, is_active, role_id
    FROM staff
    WHERE company_id = %L',
    v_schema_name, p_company_id
  );

  -- Migrate staff departments
  EXECUTE format('
    INSERT INTO %I.staff_departments (
      staff_id, department_id, is_primary
    )
    SELECT 
      sd.staff_id, sd.department_id, sd.is_primary
    FROM staff_departments sd
    JOIN staff s ON sd.staff_id = s.id
    WHERE s.company_id = %L',
    v_schema_name, p_company_id
  );

  -- Migrate staff levels
  EXECUTE format('
    INSERT INTO %I.staff_levels_junction (
      staff_id, level_id, is_primary
    )
    SELECT 
      slj.staff_id, slj.level_id, slj.is_primary
    FROM staff_levels_junction slj
    JOIN staff s ON slj.staff_id = s.id
    WHERE s.company_id = %L',
    v_schema_name, p_company_id
  );

  -- Migrate benefits
  EXECUTE format('
    INSERT INTO %I.benefits (
      id, name, description, amount, status, frequency
    )
    SELECT 
      id, name, description, amount, status, frequency
    FROM benefits
    WHERE company_id = %L',
    v_schema_name, p_company_id
  );

  -- Migrate benefit eligibility
  EXECUTE format('
    INSERT INTO %I.benefit_eligibility (
      benefit_id, level_id
    )
    SELECT 
      be.benefit_id, be.level_id
    FROM benefit_eligibility be
    JOIN benefits b ON be.benefit_id = b.id
    WHERE b.company_id = %L',
    v_schema_name, p_company_id
  );

  -- Migrate benefit claims
  EXECUTE format('
    INSERT INTO %I.benefit_claims (
      benefit_id, staff_id, amount, status, claim_date, receipt_url, notes
    )
    SELECT 
      bc.benefit_id, bc.staff_id, bc.amount, bc.status, bc.claim_date,
      bc.receipt_url, bc.notes
    FROM benefit_claims bc
    JOIN staff s ON bc.staff_id = s.id
    WHERE s.company_id = %L',
    v_schema_name, p_company_id
  );

  -- Migrate evaluation forms
  EXECUTE format('
    INSERT INTO %I.evaluation_forms (
      id, title, type, questions
    )
    SELECT 
      ef.id, ef.title, ef.type, ef.questions
    FROM evaluation_forms ef
    WHERE company_id = %L',
    v_schema_name, p_company_id
  );

  -- Migrate evaluation responses
  EXECUTE format('
    INSERT INTO %I.evaluation_responses (
      evaluation_id, staff_id, manager_id, self_ratings, self_comments,
      manager_ratings, manager_comments, percentage_score, status,
      submitted_at, completed_at
    )
    SELECT 
      er.evaluation_id, er.staff_id, er.manager_id, er.self_ratings,
      er.self_comments, er.manager_ratings, er.manager_comments,
      er.percentage_score, er.status, er.submitted_at, er.completed_at
    FROM evaluation_responses er
    JOIN staff s ON er.staff_id = s.id
    WHERE s.company_id = %L',
    v_schema_name, p_company_id
  );

  -- Migrate warning letters
  EXECUTE format('
    INSERT INTO %I.warning_letters (
      staff_id, warning_level, incident_date, description, improvement_plan,
      consequences, issued_date, show_cause_response, response_submitted_at
    )
    SELECT 
      wl.staff_id, wl.warning_level, wl.incident_date, wl.description,
      wl.improvement_plan, wl.consequences, wl.issued_date,
      wl.show_cause_response, wl.response_submitted_at
    FROM warning_letters wl
    JOIN staff s ON wl.staff_id = s.id
    WHERE s.company_id = %L',
    v_schema_name, p_company_id
  );

  -- Migrate HR letters
  EXECUTE format('
    INSERT INTO %I.hr_letters (
      staff_id, title, type, content, document_url, issued_date, status
    )
    SELECT 
      hl.staff_id, hl.title, hl.type, hl.content, hl.document_url,
      hl.issued_date, hl.status
    FROM hr_letters hl
    JOIN staff s ON hl.staff_id = s.id
    WHERE s.company_id = %L',
    v_schema_name, p_company_id
  );

  -- Migrate memos
  EXECUTE format('
    INSERT INTO %I.memos (
      title, type, content, department_id, staff_id
    )
    SELECT 
      m.title, m.type, m.content, m.department_id, m.staff_id
    FROM memos m
    JOIN staff s ON m.staff_id = s.id
    WHERE s.company_id = %L',
    v_schema_name, p_company_id
  );
END;
$function$
;

CREATE OR REPLACE FUNCTION public.restore_company_data(p_backup_id uuid, p_user_id uuid)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_schema_name text;
  v_company_id uuid;
  v_backup_data jsonb;
BEGIN
  -- Get backup details
  SELECT 
    b.company_id,
    b.backup_data,
    c.schema_name
  INTO v_company_id, v_backup_data, v_schema_name
  FROM schema_backups b
  JOIN companies c ON b.company_id = c.id
  WHERE b.id = p_backup_id;

  IF v_schema_name IS NULL THEN
    RAISE EXCEPTION 'Backup not found or company schema missing';
  END IF;

  -- Start transaction
  BEGIN
    -- Clear existing data
    EXECUTE format('TRUNCATE TABLE %I.memos CASCADE', v_schema_name);
    EXECUTE format('TRUNCATE TABLE %I.hr_letters CASCADE', v_schema_name);
    EXECUTE format('TRUNCATE TABLE %I.warning_letters CASCADE', v_schema_name);
    EXECUTE format('TRUNCATE TABLE %I.evaluation_responses CASCADE', v_schema_name);
    EXECUTE format('TRUNCATE TABLE %I.evaluation_forms CASCADE', v_schema_name);
    EXECUTE format('TRUNCATE TABLE %I.benefit_claims CASCADE', v_schema_name);
    EXECUTE format('TRUNCATE TABLE %I.benefit_eligibility CASCADE', v_schema_name);
    EXECUTE format('TRUNCATE TABLE %I.benefits CASCADE', v_schema_name);
    EXECUTE format('TRUNCATE TABLE %I.staff_levels_junction CASCADE', v_schema_name);
    EXECUTE format('TRUNCATE TABLE %I.staff_departments CASCADE', v_schema_name);
    EXECUTE format('TRUNCATE TABLE %I.staff CASCADE', v_schema_name);

    -- Restore data
    EXECUTE format('
      -- Restore staff
      INSERT INTO %1$I.staff 
      SELECT * FROM jsonb_populate_recordset(null::%1$I.staff, %2$L);
      
      -- Restore staff departments
      INSERT INTO %1$I.staff_departments 
      SELECT * FROM jsonb_populate_recordset(null::%1$I.staff_departments, %3$L);
      
      -- Restore staff levels
      INSERT INTO %1$I.staff_levels_junction 
      SELECT * FROM jsonb_populate_recordset(null::%1$I.staff_levels_junction, %4$L);
      
      -- Restore benefits
      INSERT INTO %1$I.benefits 
      SELECT * FROM jsonb_populate_recordset(null::%1$I.benefits, %5$L);
      
      -- Restore benefit eligibility
      INSERT INTO %1$I.benefit_eligibility 
      SELECT * FROM jsonb_populate_recordset(null::%1$I.benefit_eligibility, %6$L);
      
      -- Restore benefit claims
      INSERT INTO %1$I.benefit_claims 
      SELECT * FROM jsonb_populate_recordset(null::%1$I.benefit_claims, %7$L);
      
      -- Restore evaluation forms
      INSERT INTO %1$I.evaluation_forms 
      SELECT * FROM jsonb_populate_recordset(null::%1$I.evaluation_forms, %8$L);
      
      -- Restore evaluation responses
      INSERT INTO %1$I.evaluation_responses 
      SELECT * FROM jsonb_populate_recordset(null::%1$I.evaluation_responses, %9$L);
      
      -- Restore warning letters
      INSERT INTO %1$I.warning_letters 
      SELECT * FROM jsonb_populate_recordset(null::%1$I.warning_letters, %10$L);
      
      -- Restore HR letters
      INSERT INTO %1$I.hr_letters 
      SELECT * FROM jsonb_populate_recordset(null::%1$I.hr_letters, %11$L);
      
      -- Restore memos
      INSERT INTO %1$I.memos 
      SELECT * FROM jsonb_populate_recordset(null::%1$I.memos, %12$L)',
      v_schema_name,
      v_backup_data->'staff',
      v_backup_data->'staff_departments',
      v_backup_data->'staff_levels_junction',
      v_backup_data->'benefits',
      v_backup_data->'benefit_eligibility',
      v_backup_data->'benefit_claims',
      v_backup_data->'evaluation_forms',
      v_backup_data->'evaluation_responses',
      v_backup_data->'warning_letters',
      v_backup_data->'hr_letters',
      v_backup_data->'memos'
    );

    -- Update backup record
    UPDATE schema_backups
    SET 
      restored_at = now(),
      restored_by = p_user_id
    WHERE id = p_backup_id;

    -- Commit transaction
    COMMIT;
  EXCEPTION WHEN OTHERS THEN
    -- Rollback transaction on error
    ROLLBACK;
    RAISE;
  END;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.submit_show_cause_response(p_letter_id uuid, p_response text)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
  UPDATE hr_letters
  SET 
    content = jsonb_set(
      jsonb_set(
        content,
        '{response}',
        to_jsonb(p_response)
      ),
      '{response_date}',
      to_jsonb(now())
    ),
    status = 'submitted'
  WHERE id = p_letter_id
  AND type = 'show_cause'
  AND status = 'pending';
END;
$function$
;

CREATE OR REPLACE FUNCTION public.submit_warning_letter_response(p_letter_id uuid, p_response text)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
  UPDATE hr_letters
  SET 
    content = jsonb_set(
      jsonb_set(
        content,
        '{response}',
        to_jsonb(p_response)
      ),
      '{response_date}',
      to_jsonb(now())
    ),
    status = 'submitted'
  WHERE id = p_letter_id
  AND type = 'warning'
  AND status = 'pending';
END;
$function$
;

CREATE OR REPLACE FUNCTION public.toggle_user_active_status(p_staff_id uuid)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
  UPDATE staff
  SET is_active = NOT is_active
  WHERE id = p_staff_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_company_admin_password(p_company_id uuid, p_password text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  -- Update company password
  UPDATE companies
  SET 
    password_hash = p_password,
    updated_at = now()
  WHERE id = p_company_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_company_details(p_company_id uuid, p_name text, p_ssm text, p_address text, p_phone text, p_logo_url text)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
  UPDATE companies
  SET 
    name = p_name,
    ssm = p_ssm,
    address = p_address,
    phone = p_phone,
    logo_url = p_logo_url,
    updated_at = now()
  WHERE id = p_company_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_evaluation_form_levels_timestamp()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  UPDATE evaluation_forms
  SET updated_at = now()
  WHERE id = NEW.evaluation_id;
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_evaluation_form_timestamp()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  UPDATE evaluation_forms
  SET updated_at = now()
  WHERE id = NEW.evaluation_id;
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_evaluation_form_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  UPDATE evaluation_forms
  SET updated_at = now()
  WHERE id = NEW.evaluation_id;
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_evaluation_percentage()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  IF NEW.manager_ratings IS NOT NULL AND NEW.manager_ratings != '{}'::jsonb THEN
    NEW.percentage_score := calculate_evaluation_percentage(NEW.manager_ratings);
  END IF;
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_evaluation_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  UPDATE evaluation_forms
  SET updated_at = now()
  WHERE id = NEW.evaluation_id;
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_event_status()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  -- Update status based on dates
  IF NEW.start_date > CURRENT_DATE THEN
    NEW.status := 'upcoming';
  ELSIF NEW.end_date < CURRENT_DATE THEN
    NEW.status := 'completed';
  ELSE
    NEW.status := 'ongoing';
  END IF;
  
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_expired_interviews()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  IF NEW.status = 'pending' AND NEW.expires_at < NOW() THEN
    NEW.status = 'expired';
  END IF;
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_hr_letter_status()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  IF NEW.signed_document_url IS NOT NULL AND OLD.signed_document_url IS NULL THEN
    UPDATE hr_letters
    SET 
      status = 'signed',
      document_url = NEW.signed_document_url
    WHERE 
      type = 'warning' 
      AND content->>'warning_letter_id' = NEW.id::text;
  END IF;
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_hr_letters_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_interview_status()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  UPDATE staff_interviews
  SET status = 'completed'
  WHERE id = NEW.interview_id;
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_role_mapping(p_staff_level_id uuid, p_role text)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
  -- Insert or update role mapping
  INSERT INTO role_mappings (staff_level_id, role)
  VALUES (p_staff_level_id, p_role)
  ON CONFLICT (staff_level_id) 
  DO UPDATE SET role = EXCLUDED.role;

  -- Update staff roles based on their primary level
  UPDATE staff s
  SET role_id = rm.id
  FROM staff_levels_junction slj
  JOIN role_mappings rm ON rm.staff_level_id = slj.level_id
  WHERE slj.staff_id = s.id
  AND slj.is_primary = true
  AND slj.level_id = p_staff_level_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_staff_departments_timestamp()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_staff_interview_forms_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_staff_levels_junction_timestamp()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_staff_password(p_email text, p_password text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  -- Verify staff exists
  IF NOT EXISTS (
    SELECT 1 FROM staff WHERE email = p_email
  ) THEN
    RAISE EXCEPTION 'Staff member not found';
  END IF;

  -- Update the staff password
  UPDATE staff
  SET 
    password_hash = p_password,
    updated_at = now()
  WHERE email = p_email;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_staff_role_from_level()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_role_id uuid;
BEGIN
  IF NEW.is_primary THEN
    -- Get role_id for the new primary level
    SELECT get_role_id_for_level(NEW.level_id) INTO v_role_id;

    -- Update staff role_id
    UPDATE staff
    SET role_id = v_role_id
    WHERE id = NEW.staff_id;
  END IF;
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_staff_role_from_levels()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  -- Get the role_id from role_mappings based on the primary level
  UPDATE staff s
  SET role_id = rm.id
  FROM staff_levels_junction slj
  JOIN role_mappings rm ON rm.staff_level_id = slj.level_id
  WHERE s.id = slj.staff_id
  AND slj.is_primary = true
  AND slj.staff_id = NEW.staff_id;
  
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.validate_benefit_claim()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  -- Check if staff member is eligible for this benefit
  IF NOT EXISTS (
    SELECT 1
    FROM benefit_eligibility be
    JOIN staff_levels_junction slj ON be.level_id = slj.level_id
    WHERE be.benefit_id = NEW.benefit_id
    AND slj.staff_id = NEW.staff_id
    AND slj.is_primary = true
  ) THEN
    RAISE EXCEPTION 'Staff member is not eligible for this benefit';
  END IF;

  -- Check frequency limits
  IF NOT validate_benefit_claim_frequency(NEW.staff_id, NEW.benefit_id, NEW.claim_date::date) THEN
    RAISE EXCEPTION 'Claim frequency limit exceeded for this benefit';
  END IF;

  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.validate_benefit_claim_frequency(p_benefit_id uuid, p_staff_id uuid, p_claim_date date)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_benefit benefits%ROWTYPE;
  v_last_claim benefit_claims%ROWTYPE;
  v_year_start date;
  v_claim_count integer;
BEGIN
  -- Get benefit details
  SELECT * INTO v_benefit FROM benefits WHERE id = p_benefit_id;
  
  -- Get last claim for this benefit and staff
  SELECT * INTO v_last_claim 
  FROM benefit_claims 
  WHERE benefit_id = p_benefit_id 
  AND staff_id = p_staff_id
  ORDER BY claim_date DESC 
  LIMIT 1;
  
  -- Calculate year start for the claim date
  v_year_start := date_trunc('year', p_claim_date)::date;
  
  CASE v_benefit.frequency
    WHEN 'yearly' THEN
      -- Check if already claimed this year
      RETURN NOT EXISTS (
        SELECT 1 FROM benefit_claims
        WHERE benefit_id = p_benefit_id
        AND staff_id = p_staff_id
        AND date_trunc('year', claim_date) = date_trunc('year', p_claim_date)
      );
      
    WHEN 'monthly' THEN
      -- Check if already claimed this month
      RETURN NOT EXISTS (
        SELECT 1 FROM benefit_claims
        WHERE benefit_id = p_benefit_id
        AND staff_id = p_staff_id
        AND date_trunc('month', claim_date) = date_trunc('month', p_claim_date)
      );
      
    WHEN 'custom_months' THEN
      -- Check if enough months have passed since last claim
      RETURN v_last_claim IS NULL OR 
        (p_claim_date - v_last_claim.claim_date) >= (v_benefit.frequency_months * 30);
        
    WHEN 'custom_times_per_year' THEN
      -- Count claims in current year
      SELECT count(*) INTO v_claim_count
      FROM benefit_claims
      WHERE benefit_id = p_benefit_id
      AND staff_id = p_staff_id
      AND date_trunc('year', claim_date) = date_trunc('year', p_claim_date);
      
      -- Check if under the allowed number of claims per period
      RETURN v_claim_count < v_benefit.frequency_times;
      
    ELSE
      RETURN false;
  END CASE;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.validate_benefit_data(p_company_id uuid)
 RETURNS TABLE(benefit_id uuid, validation_type text, validation_message text)
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_schema_name text;
BEGIN
  -- Get schema name
  SELECT schema_name INTO v_schema_name
  FROM companies
  WHERE id = p_company_id;

  IF v_schema_name IS NULL THEN
    RAISE EXCEPTION 'Company schema not found';
  END IF;

  RETURN QUERY EXECUTE format('
    -- Check for benefits without any eligible levels
    SELECT 
      b.id,
      ''no_eligible_levels''::text,
      ''Benefit has no eligible levels assigned''::text
    FROM %I.benefits b
    WHERE NOT EXISTS (
      SELECT 1 FROM %I.benefit_eligibility be 
      WHERE be.benefit_id = b.id
    )
    
    UNION ALL
    
    -- Check for benefits with invalid amounts
    SELECT 
      b.id,
      ''invalid_amount''::text,
      ''Benefit amount must be greater than 0''::text
    FROM %I.benefits b
    WHERE b.amount <= 0
    
    UNION ALL
    
    -- Check for benefits with empty frequency
    SELECT 
      b.id,
      ''missing_frequency''::text,
      ''Benefit frequency is required''::text
    FROM %I.benefits b
    WHERE b.frequency IS NULL OR b.frequency = ''''
    
    UNION ALL
    
    -- Check for orphaned benefit claims
    SELECT 
      bc.benefit_id,
      ''orphaned_claim''::text,
      ''Benefit claim exists for inactive benefit''::text
    FROM %I.benefit_claims bc
    JOIN %I.benefits b ON bc.benefit_id = b.id
    WHERE b.status = false',
    v_schema_name, v_schema_name,
    v_schema_name,
    v_schema_name,
    v_schema_name, v_schema_name
  );
END;
$function$
;

CREATE OR REPLACE FUNCTION public.validate_company_data(p_company_id uuid)
 RETURNS TABLE(entity_id uuid, entity_type text, validation_type text, validation_message text)
 LANGUAGE plpgsql
AS $function$
BEGIN
  -- Staff validations
  RETURN QUERY
  SELECT 
    staff_id as entity_id,
    'staff'::text as entity_type,
    validation_type,
    validation_message
  FROM validate_staff_data(p_company_id);

  -- Benefit validations
  RETURN QUERY
  SELECT 
    benefit_id as entity_id,
    'benefit'::text as entity_type,
    validation_type,
    validation_message
  FROM validate_benefit_data(p_company_id);

  -- Evaluation validations
  RETURN QUERY
  SELECT 
    evaluation_id as entity_id,
    'evaluation'::text as entity_type,
    validation_type,
    validation_message
  FROM validate_evaluation_data(p_company_id);

  -- Warning letter validations
  RETURN QUERY
  SELECT 
    letter_id as entity_id,
    'warning_letter'::text as entity_type,
    validation_type,
    validation_message
  FROM validate_warning_letter_data(p_company_id);
END;
$function$
;

CREATE OR REPLACE FUNCTION public.validate_company_integrity(p_company_id uuid)
 RETURNS TABLE(issue_type text, issue_count integer, details text)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  
  -- Check for staff without departments
  SELECT 
    'staff_without_department'::text,
    count(*)::integer,
    'Staff members without any department assignment'::text
  FROM staff s
  WHERE s.company_id = p_company_id
  AND NOT EXISTS (
    SELECT 1 FROM staff_departments sd WHERE sd.staff_id = s.id
  )
  HAVING count(*) > 0
  
  UNION ALL
  
  -- Check for staff without levels
  SELECT 
    'staff_without_level'::text,
    count(*)::integer,
    'Staff members without any level assignment'::text
  FROM staff s
  WHERE s.company_id = p_company_id
  AND NOT EXISTS (
    SELECT 1 FROM staff_levels_junction sl WHERE sl.staff_id = s.id
  )
  HAVING count(*) > 0
  
  UNION ALL
  
  -- Check for benefits without eligibility
  SELECT 
    'benefits_without_eligibility'::text,
    count(*)::integer,
    'Benefits without any level eligibility'::text
  FROM benefits b
  WHERE b.company_id = p_company_id
  AND NOT EXISTS (
    SELECT 1 FROM benefit_eligibility be WHERE be.benefit_id = b.id
  )
  HAVING count(*) > 0
  
  UNION ALL
  
  -- Check for orphaned evaluation responses
  SELECT 
    'orphaned_evaluations'::text,
    count(*)::integer,
    'Evaluation responses without valid evaluation forms'::text
  FROM evaluation_responses er
  JOIN staff s ON er.staff_id = s.id
  WHERE s.company_id = p_company_id
  AND NOT EXISTS (
    SELECT 1 FROM evaluation_forms ef WHERE ef.id = er.evaluation_id
  )
  HAVING count(*) > 0
  
  UNION ALL
  
  -- Check for orphaned warning letters
  SELECT 
    'orphaned_warnings'::text,
    count(*)::integer,
    'Warning letters for inactive staff'::text
  FROM warning_letters wl
  JOIN staff s ON wl.staff_id = s.id
  WHERE s.company_id = p_company_id
  AND s.is_active = false
  HAVING count(*) > 0;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.validate_evaluation_data(p_company_id uuid)
 RETURNS TABLE(evaluation_id uuid, validation_type text, validation_message text)
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_schema_name text;
BEGIN
  -- Get schema name
  SELECT schema_name INTO v_schema_name
  FROM companies
  WHERE id = p_company_id;

  IF v_schema_name IS NULL THEN
    RAISE EXCEPTION 'Company schema not found';
  END IF;

  RETURN QUERY EXECUTE format('
    -- Check for evaluations without questions
    SELECT 
      ef.id,
      ''no_questions''::text,
      ''Evaluation form has no questions''::text
    FROM %I.evaluation_forms ef
    WHERE ef.questions IS NULL OR ef.questions::text = ''[]''
    
    UNION ALL
    
    -- Check for evaluations with invalid question structure
    SELECT 
      ef.id,
      ''invalid_questions''::text,
      ''Evaluation questions must have id, category, and question fields''::text
    FROM %I.evaluation_forms ef,
    jsonb_array_elements(ef.questions) q
    WHERE NOT (
      q ? ''id'' AND 
      q ? ''category'' AND 
      q ? ''question''
    )
    
    UNION ALL
    
    -- Check for completed evaluations without scores
    SELECT 
      er.evaluation_id,
      ''missing_score''::text,
      ''Completed evaluation has no percentage score''::text
    FROM %I.evaluation_responses er
    WHERE er.status = ''completed''
    AND er.percentage_score IS NULL
    
    UNION ALL
    
    -- Check for evaluations with invalid manager assignments
    SELECT 
      er.evaluation_id,
      ''invalid_manager''::text,
      ''Evaluation assigned to invalid manager''::text
    FROM %I.evaluation_responses er
    WHERE NOT EXISTS (
      SELECT 1 FROM %I.staff s WHERE s.id = er.manager_id
    )',
    v_schema_name,
    v_schema_name,
    v_schema_name,
    v_schema_name, v_schema_name
  );
END;
$function$
;

CREATE OR REPLACE FUNCTION public.validate_staff_data(p_company_id uuid)
 RETURNS TABLE(staff_id uuid, validation_type text, validation_message text)
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_schema_name text;
BEGIN
  -- Get schema name
  SELECT schema_name INTO v_schema_name
  FROM companies
  WHERE id = p_company_id;

  IF v_schema_name IS NULL THEN
    RAISE EXCEPTION 'Company schema not found';
  END IF;

  RETURN QUERY EXECUTE format('
    -- Check for staff without primary department
    SELECT 
      s.id,
      ''missing_primary_department''::text,
      ''Staff member has no primary department''::text
    FROM %I.staff s
    WHERE NOT EXISTS (
      SELECT 1 FROM %I.staff_departments sd 
      WHERE sd.staff_id = s.id AND sd.is_primary = true
    )
    
    UNION ALL
    
    -- Check for staff without primary level
    SELECT 
      s.id,
      ''missing_primary_level''::text,
      ''Staff member has no primary level''::text
    FROM %I.staff s
    WHERE NOT EXISTS (
      SELECT 1 FROM %I.staff_levels_junction sl 
      WHERE sl.staff_id = s.id AND sl.is_primary = true
    )
    
    UNION ALL
    
    -- Check for staff with multiple primary departments
    SELECT 
      s.id,
      ''multiple_primary_departments''::text,
      ''Staff member has multiple primary departments''::text
    FROM %I.staff s
    JOIN %I.staff_departments sd ON s.id = sd.staff_id
    WHERE sd.is_primary = true
    GROUP BY s.id
    HAVING COUNT(*) > 1
    
    UNION ALL
    
    -- Check for staff with multiple primary levels
    SELECT 
      s.id,
      ''multiple_primary_levels''::text,
      ''Staff member has multiple primary levels''::text
    FROM %I.staff s
    JOIN %I.staff_levels_junction sl ON s.id = sl.staff_id
    WHERE sl.is_primary = true
    GROUP BY s.id
    HAVING COUNT(*) > 1
    
    UNION ALL
    
    -- Check for staff with invalid role_id
    SELECT 
      s.id,
      ''invalid_role''::text,
      ''Staff member has invalid role_id''::text
    FROM %I.staff s
    WHERE NOT EXISTS (
      SELECT 1 FROM role_mappings rm WHERE rm.id = s.role_id
    )',
    v_schema_name, v_schema_name,
    v_schema_name, v_schema_name,
    v_schema_name, v_schema_name,
    v_schema_name, v_schema_name,
    v_schema_name
  );
END;
$function$
;

CREATE OR REPLACE FUNCTION public.validate_staff_status_change()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  -- Allow changing from resigned to permanent for admin user
  IF OLD.email = 'admin@example.com' THEN
    RETURN NEW;
  END IF;

  -- For other users, prevent changing from resigned
  IF OLD.status = 'resigned' AND NEW.status != 'resigned' THEN
    RAISE EXCEPTION 'Cannot change status from resigned to %', NEW.status;
  END IF;

  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.validate_warning_letter_data(p_company_id uuid)
 RETURNS TABLE(letter_id uuid, validation_type text, validation_message text)
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_schema_name text;
BEGIN
  -- Get schema name
  SELECT schema_name INTO v_schema_name
  FROM companies
  WHERE id = p_company_id;

  IF v_schema_name IS NULL THEN
    RAISE EXCEPTION 'Company schema not found';
  END IF;

  RETURN QUERY EXECUTE format('
    -- Check for warning letters with future incident dates
    SELECT 
      wl.id,
      ''future_incident_date''::text,
      ''Incident date cannot be in the future''::text
    FROM %I.warning_letters wl
    WHERE wl.incident_date > CURRENT_DATE
    
    UNION ALL
    
    -- Check for warning letters with issue date before incident date
    SELECT 
      wl.id,
      ''invalid_issue_date''::text,
      ''Issue date must be after incident date''::text
    FROM %I.warning_letters wl
    WHERE wl.issued_date < wl.incident_date
    
    UNION ALL
    
    -- Check for warning letters with empty required fields
    SELECT 
      wl.id,
      ''missing_required_fields''::text,
      ''Warning letter has empty required fields''::text
    FROM %I.warning_letters wl
    WHERE wl.description = '''' 
    OR wl.improvement_plan = '''' 
    OR wl.consequences = ''''
    
    UNION ALL
    
    -- Check for warning letters with invalid staff assignments
    SELECT 
      wl.id,
      ''invalid_staff''::text,
      ''Warning letter assigned to invalid staff member''::text
    FROM %I.warning_letters wl
    WHERE NOT EXISTS (
      SELECT 1 FROM %I.staff s WHERE s.id = wl.staff_id
    )',
    v_schema_name,
    v_schema_name,
    v_schema_name,
    v_schema_name, v_schema_name
  );
END;
$function$
;

CREATE OR REPLACE FUNCTION public.verify_company_login(p_email text, p_password text)
 RETURNS TABLE(id uuid, name text, email text, is_valid boolean)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  RETURN QUERY
  SELECT 
    c.id,
    c.name,
    c.email,
    CASE 
      WHEN c.password_hash = p_password AND c.is_active = true THEN true
      ELSE false
    END as is_valid
  FROM companies c
  WHERE c.email = p_email;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.verify_company_schema(p_company_id uuid)
 RETURNS TABLE(table_name text, record_count bigint, last_updated timestamp with time zone)
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_schema_name text;
BEGIN
  -- Get schema name
  SELECT schema_name INTO v_schema_name
  FROM companies
  WHERE id = p_company_id;

  IF v_schema_name IS NULL THEN
    RAISE EXCEPTION 'Company schema not found';
  END IF;

  RETURN QUERY EXECUTE format('
    SELECT 
      table_name::text,
      (SELECT count(*) FROM %I.' || quote_ident(table_name) || ') as record_count,
      (SELECT max(updated_at) FROM %I.' || quote_ident(table_name) || ') as last_updated
    FROM information_schema.tables
    WHERE table_schema = %L
    AND table_type = ''BASE TABLE''',
    v_schema_name, v_schema_name, v_schema_name
  );
END;
$function$
;

grant delete on table "public"."benefit_claims" to "anon";

grant insert on table "public"."benefit_claims" to "anon";

grant references on table "public"."benefit_claims" to "anon";

grant select on table "public"."benefit_claims" to "anon";

grant trigger on table "public"."benefit_claims" to "anon";

grant truncate on table "public"."benefit_claims" to "anon";

grant update on table "public"."benefit_claims" to "anon";

grant delete on table "public"."benefit_claims" to "authenticated";

grant insert on table "public"."benefit_claims" to "authenticated";

grant references on table "public"."benefit_claims" to "authenticated";

grant select on table "public"."benefit_claims" to "authenticated";

grant trigger on table "public"."benefit_claims" to "authenticated";

grant truncate on table "public"."benefit_claims" to "authenticated";

grant update on table "public"."benefit_claims" to "authenticated";

grant delete on table "public"."benefit_claims" to "service_role";

grant insert on table "public"."benefit_claims" to "service_role";

grant references on table "public"."benefit_claims" to "service_role";

grant select on table "public"."benefit_claims" to "service_role";

grant trigger on table "public"."benefit_claims" to "service_role";

grant truncate on table "public"."benefit_claims" to "service_role";

grant update on table "public"."benefit_claims" to "service_role";

grant delete on table "public"."benefit_eligibility" to "anon";

grant insert on table "public"."benefit_eligibility" to "anon";

grant references on table "public"."benefit_eligibility" to "anon";

grant select on table "public"."benefit_eligibility" to "anon";

grant trigger on table "public"."benefit_eligibility" to "anon";

grant truncate on table "public"."benefit_eligibility" to "anon";

grant update on table "public"."benefit_eligibility" to "anon";

grant delete on table "public"."benefit_eligibility" to "authenticated";

grant insert on table "public"."benefit_eligibility" to "authenticated";

grant references on table "public"."benefit_eligibility" to "authenticated";

grant select on table "public"."benefit_eligibility" to "authenticated";

grant trigger on table "public"."benefit_eligibility" to "authenticated";

grant truncate on table "public"."benefit_eligibility" to "authenticated";

grant update on table "public"."benefit_eligibility" to "authenticated";

grant delete on table "public"."benefit_eligibility" to "service_role";

grant insert on table "public"."benefit_eligibility" to "service_role";

grant references on table "public"."benefit_eligibility" to "service_role";

grant select on table "public"."benefit_eligibility" to "service_role";

grant trigger on table "public"."benefit_eligibility" to "service_role";

grant truncate on table "public"."benefit_eligibility" to "service_role";

grant update on table "public"."benefit_eligibility" to "service_role";

grant delete on table "public"."benefits" to "anon";

grant insert on table "public"."benefits" to "anon";

grant references on table "public"."benefits" to "anon";

grant select on table "public"."benefits" to "anon";

grant trigger on table "public"."benefits" to "anon";

grant truncate on table "public"."benefits" to "anon";

grant update on table "public"."benefits" to "anon";

grant delete on table "public"."benefits" to "authenticated";

grant insert on table "public"."benefits" to "authenticated";

grant references on table "public"."benefits" to "authenticated";

grant select on table "public"."benefits" to "authenticated";

grant trigger on table "public"."benefits" to "authenticated";

grant truncate on table "public"."benefits" to "authenticated";

grant update on table "public"."benefits" to "authenticated";

grant delete on table "public"."benefits" to "service_role";

grant insert on table "public"."benefits" to "service_role";

grant references on table "public"."benefits" to "service_role";

grant select on table "public"."benefits" to "service_role";

grant trigger on table "public"."benefits" to "service_role";

grant truncate on table "public"."benefits" to "service_role";

grant update on table "public"."benefits" to "service_role";

grant delete on table "public"."companies" to "anon";

grant insert on table "public"."companies" to "anon";

grant references on table "public"."companies" to "anon";

grant select on table "public"."companies" to "anon";

grant trigger on table "public"."companies" to "anon";

grant truncate on table "public"."companies" to "anon";

grant update on table "public"."companies" to "anon";

grant delete on table "public"."companies" to "authenticated";

grant insert on table "public"."companies" to "authenticated";

grant references on table "public"."companies" to "authenticated";

grant select on table "public"."companies" to "authenticated";

grant trigger on table "public"."companies" to "authenticated";

grant truncate on table "public"."companies" to "authenticated";

grant update on table "public"."companies" to "authenticated";

grant delete on table "public"."companies" to "service_role";

grant insert on table "public"."companies" to "service_role";

grant references on table "public"."companies" to "service_role";

grant select on table "public"."companies" to "service_role";

grant trigger on table "public"."companies" to "service_role";

grant truncate on table "public"."companies" to "service_role";

grant update on table "public"."companies" to "service_role";

grant delete on table "public"."company_events" to "anon";

grant insert on table "public"."company_events" to "anon";

grant references on table "public"."company_events" to "anon";

grant select on table "public"."company_events" to "anon";

grant trigger on table "public"."company_events" to "anon";

grant truncate on table "public"."company_events" to "anon";

grant update on table "public"."company_events" to "anon";

grant delete on table "public"."company_events" to "authenticated";

grant insert on table "public"."company_events" to "authenticated";

grant references on table "public"."company_events" to "authenticated";

grant select on table "public"."company_events" to "authenticated";

grant trigger on table "public"."company_events" to "authenticated";

grant truncate on table "public"."company_events" to "authenticated";

grant update on table "public"."company_events" to "authenticated";

grant delete on table "public"."company_events" to "service_role";

grant insert on table "public"."company_events" to "service_role";

grant references on table "public"."company_events" to "service_role";

grant select on table "public"."company_events" to "service_role";

grant trigger on table "public"."company_events" to "service_role";

grant truncate on table "public"."company_events" to "service_role";

grant update on table "public"."company_events" to "service_role";

grant delete on table "public"."department_default_levels" to "anon";

grant insert on table "public"."department_default_levels" to "anon";

grant references on table "public"."department_default_levels" to "anon";

grant select on table "public"."department_default_levels" to "anon";

grant trigger on table "public"."department_default_levels" to "anon";

grant truncate on table "public"."department_default_levels" to "anon";

grant update on table "public"."department_default_levels" to "anon";

grant delete on table "public"."department_default_levels" to "authenticated";

grant insert on table "public"."department_default_levels" to "authenticated";

grant references on table "public"."department_default_levels" to "authenticated";

grant select on table "public"."department_default_levels" to "authenticated";

grant trigger on table "public"."department_default_levels" to "authenticated";

grant truncate on table "public"."department_default_levels" to "authenticated";

grant update on table "public"."department_default_levels" to "authenticated";

grant delete on table "public"."department_default_levels" to "service_role";

grant insert on table "public"."department_default_levels" to "service_role";

grant references on table "public"."department_default_levels" to "service_role";

grant select on table "public"."department_default_levels" to "service_role";

grant trigger on table "public"."department_default_levels" to "service_role";

grant truncate on table "public"."department_default_levels" to "service_role";

grant update on table "public"."department_default_levels" to "service_role";

grant delete on table "public"."departments" to "anon";

grant insert on table "public"."departments" to "anon";

grant references on table "public"."departments" to "anon";

grant select on table "public"."departments" to "anon";

grant trigger on table "public"."departments" to "anon";

grant truncate on table "public"."departments" to "anon";

grant update on table "public"."departments" to "anon";

grant delete on table "public"."departments" to "authenticated";

grant insert on table "public"."departments" to "authenticated";

grant references on table "public"."departments" to "authenticated";

grant select on table "public"."departments" to "authenticated";

grant trigger on table "public"."departments" to "authenticated";

grant truncate on table "public"."departments" to "authenticated";

grant update on table "public"."departments" to "authenticated";

grant delete on table "public"."departments" to "service_role";

grant insert on table "public"."departments" to "service_role";

grant references on table "public"."departments" to "service_role";

grant select on table "public"."departments" to "service_role";

grant trigger on table "public"."departments" to "service_role";

grant truncate on table "public"."departments" to "service_role";

grant update on table "public"."departments" to "service_role";

grant delete on table "public"."employee_form_requests" to "anon";

grant insert on table "public"."employee_form_requests" to "anon";

grant references on table "public"."employee_form_requests" to "anon";

grant select on table "public"."employee_form_requests" to "anon";

grant trigger on table "public"."employee_form_requests" to "anon";

grant truncate on table "public"."employee_form_requests" to "anon";

grant update on table "public"."employee_form_requests" to "anon";

grant delete on table "public"."employee_form_requests" to "authenticated";

grant insert on table "public"."employee_form_requests" to "authenticated";

grant references on table "public"."employee_form_requests" to "authenticated";

grant select on table "public"."employee_form_requests" to "authenticated";

grant trigger on table "public"."employee_form_requests" to "authenticated";

grant truncate on table "public"."employee_form_requests" to "authenticated";

grant update on table "public"."employee_form_requests" to "authenticated";

grant delete on table "public"."employee_form_requests" to "service_role";

grant insert on table "public"."employee_form_requests" to "service_role";

grant references on table "public"."employee_form_requests" to "service_role";

grant select on table "public"."employee_form_requests" to "service_role";

grant trigger on table "public"."employee_form_requests" to "service_role";

grant truncate on table "public"."employee_form_requests" to "service_role";

grant update on table "public"."employee_form_requests" to "service_role";

grant delete on table "public"."employee_form_responses" to "anon";

grant insert on table "public"."employee_form_responses" to "anon";

grant references on table "public"."employee_form_responses" to "anon";

grant select on table "public"."employee_form_responses" to "anon";

grant trigger on table "public"."employee_form_responses" to "anon";

grant truncate on table "public"."employee_form_responses" to "anon";

grant update on table "public"."employee_form_responses" to "anon";

grant delete on table "public"."employee_form_responses" to "authenticated";

grant insert on table "public"."employee_form_responses" to "authenticated";

grant references on table "public"."employee_form_responses" to "authenticated";

grant select on table "public"."employee_form_responses" to "authenticated";

grant trigger on table "public"."employee_form_responses" to "authenticated";

grant truncate on table "public"."employee_form_responses" to "authenticated";

grant update on table "public"."employee_form_responses" to "authenticated";

grant delete on table "public"."employee_form_responses" to "service_role";

grant insert on table "public"."employee_form_responses" to "service_role";

grant references on table "public"."employee_form_responses" to "service_role";

grant select on table "public"."employee_form_responses" to "service_role";

grant trigger on table "public"."employee_form_responses" to "service_role";

grant truncate on table "public"."employee_form_responses" to "service_role";

grant update on table "public"."employee_form_responses" to "service_role";

grant delete on table "public"."evaluation_departments" to "anon";

grant insert on table "public"."evaluation_departments" to "anon";

grant references on table "public"."evaluation_departments" to "anon";

grant select on table "public"."evaluation_departments" to "anon";

grant trigger on table "public"."evaluation_departments" to "anon";

grant truncate on table "public"."evaluation_departments" to "anon";

grant update on table "public"."evaluation_departments" to "anon";

grant delete on table "public"."evaluation_departments" to "authenticated";

grant insert on table "public"."evaluation_departments" to "authenticated";

grant references on table "public"."evaluation_departments" to "authenticated";

grant select on table "public"."evaluation_departments" to "authenticated";

grant trigger on table "public"."evaluation_departments" to "authenticated";

grant truncate on table "public"."evaluation_departments" to "authenticated";

grant update on table "public"."evaluation_departments" to "authenticated";

grant delete on table "public"."evaluation_departments" to "service_role";

grant insert on table "public"."evaluation_departments" to "service_role";

grant references on table "public"."evaluation_departments" to "service_role";

grant select on table "public"."evaluation_departments" to "service_role";

grant trigger on table "public"."evaluation_departments" to "service_role";

grant truncate on table "public"."evaluation_departments" to "service_role";

grant update on table "public"."evaluation_departments" to "service_role";

grant delete on table "public"."evaluation_form_departments" to "anon";

grant insert on table "public"."evaluation_form_departments" to "anon";

grant references on table "public"."evaluation_form_departments" to "anon";

grant select on table "public"."evaluation_form_departments" to "anon";

grant trigger on table "public"."evaluation_form_departments" to "anon";

grant truncate on table "public"."evaluation_form_departments" to "anon";

grant update on table "public"."evaluation_form_departments" to "anon";

grant delete on table "public"."evaluation_form_departments" to "authenticated";

grant insert on table "public"."evaluation_form_departments" to "authenticated";

grant references on table "public"."evaluation_form_departments" to "authenticated";

grant select on table "public"."evaluation_form_departments" to "authenticated";

grant trigger on table "public"."evaluation_form_departments" to "authenticated";

grant truncate on table "public"."evaluation_form_departments" to "authenticated";

grant update on table "public"."evaluation_form_departments" to "authenticated";

grant delete on table "public"."evaluation_form_departments" to "service_role";

grant insert on table "public"."evaluation_form_departments" to "service_role";

grant references on table "public"."evaluation_form_departments" to "service_role";

grant select on table "public"."evaluation_form_departments" to "service_role";

grant trigger on table "public"."evaluation_form_departments" to "service_role";

grant truncate on table "public"."evaluation_form_departments" to "service_role";

grant update on table "public"."evaluation_form_departments" to "service_role";

grant delete on table "public"."evaluation_form_levels" to "anon";

grant insert on table "public"."evaluation_form_levels" to "anon";

grant references on table "public"."evaluation_form_levels" to "anon";

grant select on table "public"."evaluation_form_levels" to "anon";

grant trigger on table "public"."evaluation_form_levels" to "anon";

grant truncate on table "public"."evaluation_form_levels" to "anon";

grant update on table "public"."evaluation_form_levels" to "anon";

grant delete on table "public"."evaluation_form_levels" to "authenticated";

grant insert on table "public"."evaluation_form_levels" to "authenticated";

grant references on table "public"."evaluation_form_levels" to "authenticated";

grant select on table "public"."evaluation_form_levels" to "authenticated";

grant trigger on table "public"."evaluation_form_levels" to "authenticated";

grant truncate on table "public"."evaluation_form_levels" to "authenticated";

grant update on table "public"."evaluation_form_levels" to "authenticated";

grant delete on table "public"."evaluation_form_levels" to "service_role";

grant insert on table "public"."evaluation_form_levels" to "service_role";

grant references on table "public"."evaluation_form_levels" to "service_role";

grant select on table "public"."evaluation_form_levels" to "service_role";

grant trigger on table "public"."evaluation_form_levels" to "service_role";

grant truncate on table "public"."evaluation_form_levels" to "service_role";

grant update on table "public"."evaluation_form_levels" to "service_role";

grant delete on table "public"."evaluation_forms" to "anon";

grant insert on table "public"."evaluation_forms" to "anon";

grant references on table "public"."evaluation_forms" to "anon";

grant select on table "public"."evaluation_forms" to "anon";

grant trigger on table "public"."evaluation_forms" to "anon";

grant truncate on table "public"."evaluation_forms" to "anon";

grant update on table "public"."evaluation_forms" to "anon";

grant delete on table "public"."evaluation_forms" to "authenticated";

grant insert on table "public"."evaluation_forms" to "authenticated";

grant references on table "public"."evaluation_forms" to "authenticated";

grant select on table "public"."evaluation_forms" to "authenticated";

grant trigger on table "public"."evaluation_forms" to "authenticated";

grant truncate on table "public"."evaluation_forms" to "authenticated";

grant update on table "public"."evaluation_forms" to "authenticated";

grant delete on table "public"."evaluation_forms" to "service_role";

grant insert on table "public"."evaluation_forms" to "service_role";

grant references on table "public"."evaluation_forms" to "service_role";

grant select on table "public"."evaluation_forms" to "service_role";

grant trigger on table "public"."evaluation_forms" to "service_role";

grant truncate on table "public"."evaluation_forms" to "service_role";

grant update on table "public"."evaluation_forms" to "service_role";

grant delete on table "public"."evaluation_responses" to "anon";

grant insert on table "public"."evaluation_responses" to "anon";

grant references on table "public"."evaluation_responses" to "anon";

grant select on table "public"."evaluation_responses" to "anon";

grant trigger on table "public"."evaluation_responses" to "anon";

grant truncate on table "public"."evaluation_responses" to "anon";

grant update on table "public"."evaluation_responses" to "anon";

grant delete on table "public"."evaluation_responses" to "authenticated";

grant insert on table "public"."evaluation_responses" to "authenticated";

grant references on table "public"."evaluation_responses" to "authenticated";

grant select on table "public"."evaluation_responses" to "authenticated";

grant trigger on table "public"."evaluation_responses" to "authenticated";

grant truncate on table "public"."evaluation_responses" to "authenticated";

grant update on table "public"."evaluation_responses" to "authenticated";

grant delete on table "public"."evaluation_responses" to "service_role";

grant insert on table "public"."evaluation_responses" to "service_role";

grant references on table "public"."evaluation_responses" to "service_role";

grant select on table "public"."evaluation_responses" to "service_role";

grant trigger on table "public"."evaluation_responses" to "service_role";

grant truncate on table "public"."evaluation_responses" to "service_role";

grant update on table "public"."evaluation_responses" to "service_role";

grant delete on table "public"."exit_interviews" to "anon";

grant insert on table "public"."exit_interviews" to "anon";

grant references on table "public"."exit_interviews" to "anon";

grant select on table "public"."exit_interviews" to "anon";

grant trigger on table "public"."exit_interviews" to "anon";

grant truncate on table "public"."exit_interviews" to "anon";

grant update on table "public"."exit_interviews" to "anon";

grant delete on table "public"."exit_interviews" to "authenticated";

grant insert on table "public"."exit_interviews" to "authenticated";

grant references on table "public"."exit_interviews" to "authenticated";

grant select on table "public"."exit_interviews" to "authenticated";

grant trigger on table "public"."exit_interviews" to "authenticated";

grant truncate on table "public"."exit_interviews" to "authenticated";

grant update on table "public"."exit_interviews" to "authenticated";

grant delete on table "public"."exit_interviews" to "service_role";

grant insert on table "public"."exit_interviews" to "service_role";

grant references on table "public"."exit_interviews" to "service_role";

grant select on table "public"."exit_interviews" to "service_role";

grant trigger on table "public"."exit_interviews" to "service_role";

grant truncate on table "public"."exit_interviews" to "service_role";

grant update on table "public"."exit_interviews" to "service_role";

grant delete on table "public"."hr_letters" to "anon";

grant insert on table "public"."hr_letters" to "anon";

grant references on table "public"."hr_letters" to "anon";

grant select on table "public"."hr_letters" to "anon";

grant trigger on table "public"."hr_letters" to "anon";

grant truncate on table "public"."hr_letters" to "anon";

grant update on table "public"."hr_letters" to "anon";

grant delete on table "public"."hr_letters" to "authenticated";

grant insert on table "public"."hr_letters" to "authenticated";

grant references on table "public"."hr_letters" to "authenticated";

grant select on table "public"."hr_letters" to "authenticated";

grant trigger on table "public"."hr_letters" to "authenticated";

grant truncate on table "public"."hr_letters" to "authenticated";

grant update on table "public"."hr_letters" to "authenticated";

grant delete on table "public"."hr_letters" to "service_role";

grant insert on table "public"."hr_letters" to "service_role";

grant references on table "public"."hr_letters" to "service_role";

grant select on table "public"."hr_letters" to "service_role";

grant trigger on table "public"."hr_letters" to "service_role";

grant truncate on table "public"."hr_letters" to "service_role";

grant update on table "public"."hr_letters" to "service_role";

grant delete on table "public"."inventory_items" to "anon";

grant insert on table "public"."inventory_items" to "anon";

grant references on table "public"."inventory_items" to "anon";

grant select on table "public"."inventory_items" to "anon";

grant trigger on table "public"."inventory_items" to "anon";

grant truncate on table "public"."inventory_items" to "anon";

grant update on table "public"."inventory_items" to "anon";

grant delete on table "public"."inventory_items" to "authenticated";

grant insert on table "public"."inventory_items" to "authenticated";

grant references on table "public"."inventory_items" to "authenticated";

grant select on table "public"."inventory_items" to "authenticated";

grant trigger on table "public"."inventory_items" to "authenticated";

grant truncate on table "public"."inventory_items" to "authenticated";

grant update on table "public"."inventory_items" to "authenticated";

grant delete on table "public"."inventory_items" to "service_role";

grant insert on table "public"."inventory_items" to "service_role";

grant references on table "public"."inventory_items" to "service_role";

grant select on table "public"."inventory_items" to "service_role";

grant trigger on table "public"."inventory_items" to "service_role";

grant truncate on table "public"."inventory_items" to "service_role";

grant update on table "public"."inventory_items" to "service_role";

grant delete on table "public"."kpi_feedback" to "anon";

grant insert on table "public"."kpi_feedback" to "anon";

grant references on table "public"."kpi_feedback" to "anon";

grant select on table "public"."kpi_feedback" to "anon";

grant trigger on table "public"."kpi_feedback" to "anon";

grant truncate on table "public"."kpi_feedback" to "anon";

grant update on table "public"."kpi_feedback" to "anon";

grant delete on table "public"."kpi_feedback" to "authenticated";

grant insert on table "public"."kpi_feedback" to "authenticated";

grant references on table "public"."kpi_feedback" to "authenticated";

grant select on table "public"."kpi_feedback" to "authenticated";

grant trigger on table "public"."kpi_feedback" to "authenticated";

grant truncate on table "public"."kpi_feedback" to "authenticated";

grant update on table "public"."kpi_feedback" to "authenticated";

grant delete on table "public"."kpi_feedback" to "service_role";

grant insert on table "public"."kpi_feedback" to "service_role";

grant references on table "public"."kpi_feedback" to "service_role";

grant select on table "public"."kpi_feedback" to "service_role";

grant trigger on table "public"."kpi_feedback" to "service_role";

grant truncate on table "public"."kpi_feedback" to "service_role";

grant update on table "public"."kpi_feedback" to "service_role";

grant delete on table "public"."kpi_updates" to "anon";

grant insert on table "public"."kpi_updates" to "anon";

grant references on table "public"."kpi_updates" to "anon";

grant select on table "public"."kpi_updates" to "anon";

grant trigger on table "public"."kpi_updates" to "anon";

grant truncate on table "public"."kpi_updates" to "anon";

grant update on table "public"."kpi_updates" to "anon";

grant delete on table "public"."kpi_updates" to "authenticated";

grant insert on table "public"."kpi_updates" to "authenticated";

grant references on table "public"."kpi_updates" to "authenticated";

grant select on table "public"."kpi_updates" to "authenticated";

grant trigger on table "public"."kpi_updates" to "authenticated";

grant truncate on table "public"."kpi_updates" to "authenticated";

grant update on table "public"."kpi_updates" to "authenticated";

grant delete on table "public"."kpi_updates" to "service_role";

grant insert on table "public"."kpi_updates" to "service_role";

grant references on table "public"."kpi_updates" to "service_role";

grant select on table "public"."kpi_updates" to "service_role";

grant trigger on table "public"."kpi_updates" to "service_role";

grant truncate on table "public"."kpi_updates" to "service_role";

grant update on table "public"."kpi_updates" to "service_role";

grant delete on table "public"."kpis" to "anon";

grant insert on table "public"."kpis" to "anon";

grant references on table "public"."kpis" to "anon";

grant select on table "public"."kpis" to "anon";

grant trigger on table "public"."kpis" to "anon";

grant truncate on table "public"."kpis" to "anon";

grant update on table "public"."kpis" to "anon";

grant delete on table "public"."kpis" to "authenticated";

grant insert on table "public"."kpis" to "authenticated";

grant references on table "public"."kpis" to "authenticated";

grant select on table "public"."kpis" to "authenticated";

grant trigger on table "public"."kpis" to "authenticated";

grant truncate on table "public"."kpis" to "authenticated";

grant update on table "public"."kpis" to "authenticated";

grant delete on table "public"."kpis" to "service_role";

grant insert on table "public"."kpis" to "service_role";

grant references on table "public"."kpis" to "service_role";

grant select on table "public"."kpis" to "service_role";

grant trigger on table "public"."kpis" to "service_role";

grant truncate on table "public"."kpis" to "service_role";

grant update on table "public"."kpis" to "service_role";

grant delete on table "public"."memos" to "anon";

grant insert on table "public"."memos" to "anon";

grant references on table "public"."memos" to "anon";

grant select on table "public"."memos" to "anon";

grant trigger on table "public"."memos" to "anon";

grant truncate on table "public"."memos" to "anon";

grant update on table "public"."memos" to "anon";

grant delete on table "public"."memos" to "authenticated";

grant insert on table "public"."memos" to "authenticated";

grant references on table "public"."memos" to "authenticated";

grant select on table "public"."memos" to "authenticated";

grant trigger on table "public"."memos" to "authenticated";

grant truncate on table "public"."memos" to "authenticated";

grant update on table "public"."memos" to "authenticated";

grant delete on table "public"."memos" to "service_role";

grant insert on table "public"."memos" to "service_role";

grant references on table "public"."memos" to "service_role";

grant select on table "public"."memos" to "service_role";

grant trigger on table "public"."memos" to "service_role";

grant truncate on table "public"."memos" to "service_role";

grant update on table "public"."memos" to "service_role";

grant delete on table "public"."role_mappings" to "anon";

grant insert on table "public"."role_mappings" to "anon";

grant references on table "public"."role_mappings" to "anon";

grant select on table "public"."role_mappings" to "anon";

grant trigger on table "public"."role_mappings" to "anon";

grant truncate on table "public"."role_mappings" to "anon";

grant update on table "public"."role_mappings" to "anon";

grant delete on table "public"."role_mappings" to "authenticated";

grant insert on table "public"."role_mappings" to "authenticated";

grant references on table "public"."role_mappings" to "authenticated";

grant select on table "public"."role_mappings" to "authenticated";

grant trigger on table "public"."role_mappings" to "authenticated";

grant truncate on table "public"."role_mappings" to "authenticated";

grant update on table "public"."role_mappings" to "authenticated";

grant delete on table "public"."role_mappings" to "service_role";

grant insert on table "public"."role_mappings" to "service_role";

grant references on table "public"."role_mappings" to "service_role";

grant select on table "public"."role_mappings" to "service_role";

grant trigger on table "public"."role_mappings" to "service_role";

grant truncate on table "public"."role_mappings" to "service_role";

grant update on table "public"."role_mappings" to "service_role";

grant delete on table "public"."schema_backups" to "anon";

grant insert on table "public"."schema_backups" to "anon";

grant references on table "public"."schema_backups" to "anon";

grant select on table "public"."schema_backups" to "anon";

grant trigger on table "public"."schema_backups" to "anon";

grant truncate on table "public"."schema_backups" to "anon";

grant update on table "public"."schema_backups" to "anon";

grant delete on table "public"."schema_backups" to "authenticated";

grant insert on table "public"."schema_backups" to "authenticated";

grant references on table "public"."schema_backups" to "authenticated";

grant select on table "public"."schema_backups" to "authenticated";

grant trigger on table "public"."schema_backups" to "authenticated";

grant truncate on table "public"."schema_backups" to "authenticated";

grant update on table "public"."schema_backups" to "authenticated";

grant delete on table "public"."schema_backups" to "service_role";

grant insert on table "public"."schema_backups" to "service_role";

grant references on table "public"."schema_backups" to "service_role";

grant select on table "public"."schema_backups" to "service_role";

grant trigger on table "public"."schema_backups" to "service_role";

grant truncate on table "public"."schema_backups" to "service_role";

grant update on table "public"."schema_backups" to "service_role";

grant delete on table "public"."show_cause_letters" to "anon";

grant insert on table "public"."show_cause_letters" to "anon";

grant references on table "public"."show_cause_letters" to "anon";

grant select on table "public"."show_cause_letters" to "anon";

grant trigger on table "public"."show_cause_letters" to "anon";

grant truncate on table "public"."show_cause_letters" to "anon";

grant update on table "public"."show_cause_letters" to "anon";

grant delete on table "public"."show_cause_letters" to "authenticated";

grant insert on table "public"."show_cause_letters" to "authenticated";

grant references on table "public"."show_cause_letters" to "authenticated";

grant select on table "public"."show_cause_letters" to "authenticated";

grant trigger on table "public"."show_cause_letters" to "authenticated";

grant truncate on table "public"."show_cause_letters" to "authenticated";

grant update on table "public"."show_cause_letters" to "authenticated";

grant delete on table "public"."show_cause_letters" to "service_role";

grant insert on table "public"."show_cause_letters" to "service_role";

grant references on table "public"."show_cause_letters" to "service_role";

grant select on table "public"."show_cause_letters" to "service_role";

grant trigger on table "public"."show_cause_letters" to "service_role";

grant truncate on table "public"."show_cause_letters" to "service_role";

grant update on table "public"."show_cause_letters" to "service_role";

grant delete on table "public"."staff" to "anon";

grant insert on table "public"."staff" to "anon";

grant references on table "public"."staff" to "anon";

grant select on table "public"."staff" to "anon";

grant trigger on table "public"."staff" to "anon";

grant truncate on table "public"."staff" to "anon";

grant update on table "public"."staff" to "anon";

grant delete on table "public"."staff" to "authenticated";

grant insert on table "public"."staff" to "authenticated";

grant references on table "public"."staff" to "authenticated";

grant select on table "public"."staff" to "authenticated";

grant trigger on table "public"."staff" to "authenticated";

grant truncate on table "public"."staff" to "authenticated";

grant update on table "public"."staff" to "authenticated";

grant delete on table "public"."staff" to "service_role";

grant insert on table "public"."staff" to "service_role";

grant references on table "public"."staff" to "service_role";

grant select on table "public"."staff" to "service_role";

grant trigger on table "public"."staff" to "service_role";

grant truncate on table "public"."staff" to "service_role";

grant update on table "public"."staff" to "service_role";

grant delete on table "public"."staff_departments" to "anon";

grant insert on table "public"."staff_departments" to "anon";

grant references on table "public"."staff_departments" to "anon";

grant select on table "public"."staff_departments" to "anon";

grant trigger on table "public"."staff_departments" to "anon";

grant truncate on table "public"."staff_departments" to "anon";

grant update on table "public"."staff_departments" to "anon";

grant delete on table "public"."staff_departments" to "authenticated";

grant insert on table "public"."staff_departments" to "authenticated";

grant references on table "public"."staff_departments" to "authenticated";

grant select on table "public"."staff_departments" to "authenticated";

grant trigger on table "public"."staff_departments" to "authenticated";

grant truncate on table "public"."staff_departments" to "authenticated";

grant update on table "public"."staff_departments" to "authenticated";

grant delete on table "public"."staff_departments" to "service_role";

grant insert on table "public"."staff_departments" to "service_role";

grant references on table "public"."staff_departments" to "service_role";

grant select on table "public"."staff_departments" to "service_role";

grant trigger on table "public"."staff_departments" to "service_role";

grant truncate on table "public"."staff_departments" to "service_role";

grant update on table "public"."staff_departments" to "service_role";

grant delete on table "public"."staff_levels" to "anon";

grant insert on table "public"."staff_levels" to "anon";

grant references on table "public"."staff_levels" to "anon";

grant select on table "public"."staff_levels" to "anon";

grant trigger on table "public"."staff_levels" to "anon";

grant truncate on table "public"."staff_levels" to "anon";

grant update on table "public"."staff_levels" to "anon";

grant delete on table "public"."staff_levels" to "authenticated";

grant insert on table "public"."staff_levels" to "authenticated";

grant references on table "public"."staff_levels" to "authenticated";

grant select on table "public"."staff_levels" to "authenticated";

grant trigger on table "public"."staff_levels" to "authenticated";

grant truncate on table "public"."staff_levels" to "authenticated";

grant update on table "public"."staff_levels" to "authenticated";

grant delete on table "public"."staff_levels" to "service_role";

grant insert on table "public"."staff_levels" to "service_role";

grant references on table "public"."staff_levels" to "service_role";

grant select on table "public"."staff_levels" to "service_role";

grant trigger on table "public"."staff_levels" to "service_role";

grant truncate on table "public"."staff_levels" to "service_role";

grant update on table "public"."staff_levels" to "service_role";

grant delete on table "public"."staff_levels_junction" to "anon";

grant insert on table "public"."staff_levels_junction" to "anon";

grant references on table "public"."staff_levels_junction" to "anon";

grant select on table "public"."staff_levels_junction" to "anon";

grant trigger on table "public"."staff_levels_junction" to "anon";

grant truncate on table "public"."staff_levels_junction" to "anon";

grant update on table "public"."staff_levels_junction" to "anon";

grant delete on table "public"."staff_levels_junction" to "authenticated";

grant insert on table "public"."staff_levels_junction" to "authenticated";

grant references on table "public"."staff_levels_junction" to "authenticated";

grant select on table "public"."staff_levels_junction" to "authenticated";

grant trigger on table "public"."staff_levels_junction" to "authenticated";

grant truncate on table "public"."staff_levels_junction" to "authenticated";

grant update on table "public"."staff_levels_junction" to "authenticated";

grant delete on table "public"."staff_levels_junction" to "service_role";

grant insert on table "public"."staff_levels_junction" to "service_role";

grant references on table "public"."staff_levels_junction" to "service_role";

grant select on table "public"."staff_levels_junction" to "service_role";

grant trigger on table "public"."staff_levels_junction" to "service_role";

grant truncate on table "public"."staff_levels_junction" to "service_role";

grant update on table "public"."staff_levels_junction" to "service_role";

create policy "benefit_claims_insert"
on "public"."benefit_claims"
as permissive
for insert
to public
with check (true);


create policy "benefit_claims_select"
on "public"."benefit_claims"
as permissive
for select
to public
using (true);


create policy "benefit_eligibility_delete"
on "public"."benefit_eligibility"
as permissive
for delete
to public
using (true);


create policy "benefit_eligibility_insert"
on "public"."benefit_eligibility"
as permissive
for insert
to public
with check (true);


create policy "benefit_eligibility_select"
on "public"."benefit_eligibility"
as permissive
for select
to public
using (true);


create policy "benefits_delete"
on "public"."benefits"
as permissive
for delete
to public
using (true);


create policy "benefits_delete_new"
on "public"."benefits"
as permissive
for delete
to public
using (true);


create policy "benefits_insert"
on "public"."benefits"
as permissive
for insert
to public
with check (true);


create policy "benefits_insert_new"
on "public"."benefits"
as permissive
for insert
to public
with check (true);


create policy "benefits_select"
on "public"."benefits"
as permissive
for select
to public
using (true);


create policy "benefits_select_new"
on "public"."benefits"
as permissive
for select
to public
using (true);


create policy "benefits_update"
on "public"."benefits"
as permissive
for update
to public
using (true);


create policy "benefits_update_new"
on "public"."benefits"
as permissive
for update
to public
using (true);


create policy "companies_insert"
on "public"."companies"
as permissive
for insert
to public
with check (true);


create policy "companies_insert_policy"
on "public"."companies"
as permissive
for insert
to public
with check (true);


create policy "companies_insert_policy_new"
on "public"."companies"
as permissive
for insert
to public
with check (true);


create policy "companies_select_policy"
on "public"."companies"
as permissive
for select
to public
using (((auth.role() = 'authenticated'::text) AND ((EXISTS ( SELECT 1
   FROM (staff s
     JOIN role_mappings rm ON ((s.role_id = rm.id)))
  WHERE ((s.id = auth.uid()) AND (rm.role = 'super_admin'::text)))) OR (EXISTS ( SELECT 1
   FROM staff s
  WHERE ((s.id = auth.uid()) AND (s.company_id = companies.id)))))));


create policy "companies_select_policy_new"
on "public"."companies"
as permissive
for select
to public
using (((auth.role() = 'authenticated'::text) AND ((EXISTS ( SELECT 1
   FROM (staff s
     JOIN role_mappings rm ON ((s.role_id = rm.id)))
  WHERE ((s.id = auth.uid()) AND (rm.role = 'super_admin'::text)))) OR (EXISTS ( SELECT 1
   FROM staff s
  WHERE ((s.id = auth.uid()) AND (s.company_id = companies.id)))))));


create policy "companies_update"
on "public"."companies"
as permissive
for update
to public
using (true);


create policy "companies_update_policy"
on "public"."companies"
as permissive
for update
to public
using (true);


create policy "companies_update_policy_new"
on "public"."companies"
as permissive
for update
to public
using (true);


create policy "companies_view"
on "public"."companies"
as permissive
for select
to public
using (true);


create policy "company_events_delete"
on "public"."company_events"
as permissive
for delete
to public
using (true);


create policy "company_events_insert"
on "public"."company_events"
as permissive
for insert
to public
with check (true);


create policy "company_events_select"
on "public"."company_events"
as permissive
for select
to public
using (true);


create policy "company_events_update"
on "public"."company_events"
as permissive
for update
to public
using (true);


create policy "department_default_levels_delete"
on "public"."department_default_levels"
as permissive
for delete
to public
using (true);


create policy "department_default_levels_insert"
on "public"."department_default_levels"
as permissive
for insert
to public
with check (true);


create policy "department_default_levels_select"
on "public"."department_default_levels"
as permissive
for select
to public
using (true);


create policy "department_default_levels_update"
on "public"."department_default_levels"
as permissive
for update
to public
using (true);


create policy "Enable all access for all users on departments"
on "public"."departments"
as permissive
for all
to public
using (true);


create policy "Enable read access for all users on departments"
on "public"."departments"
as permissive
for select
to public
using (true);


create policy "employee_form_requests_delete"
on "public"."employee_form_requests"
as permissive
for delete
to public
using (true);


create policy "employee_form_requests_insert"
on "public"."employee_form_requests"
as permissive
for insert
to public
with check (true);


create policy "employee_form_requests_select"
on "public"."employee_form_requests"
as permissive
for select
to public
using (true);


create policy "employee_form_requests_update"
on "public"."employee_form_requests"
as permissive
for update
to public
using (true);


create policy "employee_form_responses_insert"
on "public"."employee_form_responses"
as permissive
for insert
to public
with check (true);


create policy "employee_form_responses_select"
on "public"."employee_form_responses"
as permissive
for select
to public
using (true);


create policy "evaluation_departments_delete_policy"
on "public"."evaluation_departments"
as permissive
for delete
to public
using ((auth.role() = ANY (ARRAY['admin'::text, 'hr'::text])));


create policy "evaluation_departments_insert_policy"
on "public"."evaluation_departments"
as permissive
for insert
to public
with check ((auth.role() = ANY (ARRAY['admin'::text, 'hr'::text])));


create policy "evaluation_departments_select_policy"
on "public"."evaluation_departments"
as permissive
for select
to public
using (true);


create policy "evaluation_form_departments_delete"
on "public"."evaluation_form_departments"
as permissive
for delete
to public
using (true);


create policy "evaluation_form_departments_insert"
on "public"."evaluation_form_departments"
as permissive
for insert
to public
with check (true);


create policy "evaluation_form_departments_select"
on "public"."evaluation_form_departments"
as permissive
for select
to public
using (true);


create policy "evaluation_form_levels_delete"
on "public"."evaluation_form_levels"
as permissive
for delete
to public
using (true);


create policy "evaluation_form_levels_insert"
on "public"."evaluation_form_levels"
as permissive
for insert
to public
with check (true);


create policy "evaluation_form_levels_select"
on "public"."evaluation_form_levels"
as permissive
for select
to public
using (true);


create policy "evaluation_forms_delete"
on "public"."evaluation_forms"
as permissive
for delete
to public
using (true);


create policy "evaluation_forms_insert"
on "public"."evaluation_forms"
as permissive
for insert
to public
with check (true);


create policy "evaluation_forms_select"
on "public"."evaluation_forms"
as permissive
for select
to public
using (true);


create policy "evaluation_forms_select_new"
on "public"."evaluation_forms"
as permissive
for select
to public
using (true);


create policy "evaluation_responses_delete"
on "public"."evaluation_responses"
as permissive
for delete
to public
using (true);


create policy "evaluation_responses_delete_new"
on "public"."evaluation_responses"
as permissive
for delete
to public
using ((EXISTS ( SELECT 1
   FROM (staff s
     JOIN role_mappings rm ON ((s.role_id = rm.id)))
  WHERE ((s.id = auth.uid()) AND (rm.role = ANY (ARRAY['admin'::text, 'hr'::text]))))));


create policy "evaluation_responses_insert"
on "public"."evaluation_responses"
as permissive
for insert
to public
with check (true);


create policy "evaluation_responses_insert_new"
on "public"."evaluation_responses"
as permissive
for insert
to public
with check (true);


create policy "evaluation_responses_select"
on "public"."evaluation_responses"
as permissive
for select
to public
using (true);


create policy "evaluation_responses_select_new"
on "public"."evaluation_responses"
as permissive
for select
to public
using (true);


create policy "evaluation_responses_update"
on "public"."evaluation_responses"
as permissive
for update
to public
using (true);


create policy "evaluation_responses_update_new"
on "public"."evaluation_responses"
as permissive
for update
to public
using (((staff_id = auth.uid()) OR (manager_id = auth.uid()) OR (EXISTS ( SELECT 1
   FROM (staff s
     JOIN role_mappings rm ON ((s.role_id = rm.id)))
  WHERE ((s.id = auth.uid()) AND (rm.role = ANY (ARRAY['admin'::text, 'hr'::text])))))));


create policy "Enable insert access for all users"
on "public"."exit_interviews"
as permissive
for insert
to public
with check (true);


create policy "Enable read access for all users"
on "public"."exit_interviews"
as permissive
for select
to public
using (true);


create policy "Enable update access for all users"
on "public"."exit_interviews"
as permissive
for update
to public
using (true)
with check (true);


create policy "hr_letters_delete"
on "public"."hr_letters"
as permissive
for delete
to public
using (true);


create policy "hr_letters_insert"
on "public"."hr_letters"
as permissive
for insert
to public
with check (true);


create policy "hr_letters_select"
on "public"."hr_letters"
as permissive
for select
to public
using (true);


create policy "hr_letters_update"
on "public"."hr_letters"
as permissive
for update
to public
using (true);


create policy "inventory_items_delete_policy_v4"
on "public"."inventory_items"
as permissive
for delete
to public
using ((EXISTS ( SELECT 1
   FROM staff s
  WHERE ((s.id = inventory_items.staff_id) AND (s.company_id = ( SELECT staff.company_id
           FROM staff
          WHERE (staff.id = auth.uid())))))));


create policy "inventory_items_delete_policy_v6"
on "public"."inventory_items"
as permissive
for delete
to public
using (true);


create policy "inventory_items_insert_policy_v4"
on "public"."inventory_items"
as permissive
for insert
to public
with check ((EXISTS ( SELECT 1
   FROM staff s
  WHERE ((s.id = inventory_items.staff_id) AND (s.company_id = ( SELECT staff.company_id
           FROM staff
          WHERE (staff.id = auth.uid())))))));


create policy "inventory_items_insert_policy_v6"
on "public"."inventory_items"
as permissive
for insert
to public
with check (true);


create policy "inventory_items_select_policy_v4"
on "public"."inventory_items"
as permissive
for select
to public
using ((EXISTS ( SELECT 1
   FROM staff s
  WHERE ((s.id = inventory_items.staff_id) AND (s.company_id = ( SELECT staff.company_id
           FROM staff
          WHERE (staff.id = auth.uid())))))));


create policy "inventory_items_select_policy_v6"
on "public"."inventory_items"
as permissive
for select
to public
using (true);


create policy "inventory_items_update_policy_v4"
on "public"."inventory_items"
as permissive
for update
to public
using ((EXISTS ( SELECT 1
   FROM staff s
  WHERE ((s.id = inventory_items.staff_id) AND (s.company_id = ( SELECT staff.company_id
           FROM staff
          WHERE (staff.id = auth.uid())))))));


create policy "inventory_items_update_policy_v6"
on "public"."inventory_items"
as permissive
for update
to public
using (true);


create policy "kpi_feedback_insert_policy"
on "public"."kpi_feedback"
as permissive
for insert
to public
with check (true);


create policy "kpi_feedback_insert_policy_v2"
on "public"."kpi_feedback"
as permissive
for insert
to public
with check (true);


create policy "kpi_feedback_select_policy"
on "public"."kpi_feedback"
as permissive
for select
to public
using (true);


create policy "kpi_feedback_select_policy_v2"
on "public"."kpi_feedback"
as permissive
for select
to public
using (true);


create policy "kpi_updates_insert"
on "public"."kpi_updates"
as permissive
for insert
to public
with check (true);


create policy "kpi_updates_select"
on "public"."kpi_updates"
as permissive
for select
to public
using (true);


create policy "kpis_delete_policy_v2"
on "public"."kpis"
as permissive
for delete
to public
using (true);


create policy "kpis_insert_policy_v2"
on "public"."kpis"
as permissive
for insert
to public
with check (true);


create policy "kpis_select_policy_v2"
on "public"."kpis"
as permissive
for select
to public
using (true);


create policy "kpis_update_policy_v2"
on "public"."kpis"
as permissive
for update
to public
using (true);


create policy "memos_delete"
on "public"."memos"
as permissive
for delete
to public
using (true);


create policy "memos_insert"
on "public"."memos"
as permissive
for insert
to public
with check (true);


create policy "memos_select"
on "public"."memos"
as permissive
for select
to public
using (true);


create policy "Enable delete access for all users"
on "public"."role_mappings"
as permissive
for delete
to public
using (true);


create policy "Enable insert access for all users"
on "public"."role_mappings"
as permissive
for insert
to public
with check (true);


create policy "Enable read access for all users"
on "public"."role_mappings"
as permissive
for select
to public
using (true);


create policy "role_mappings_delete"
on "public"."role_mappings"
as permissive
for delete
to public
using (true);


create policy "role_mappings_insert"
on "public"."role_mappings"
as permissive
for insert
to public
with check (true);


create policy "role_mappings_select"
on "public"."role_mappings"
as permissive
for select
to public
using (true);


create policy "role_mappings_update"
on "public"."role_mappings"
as permissive
for update
to public
using (true);


create policy "schema_backups_insert"
on "public"."schema_backups"
as permissive
for insert
to public
with check (true);


create policy "schema_backups_select"
on "public"."schema_backups"
as permissive
for select
to public
using (true);


create policy "show_cause_letters_delete"
on "public"."show_cause_letters"
as permissive
for delete
to public
using (true);


create policy "show_cause_letters_insert"
on "public"."show_cause_letters"
as permissive
for insert
to public
with check (true);


create policy "show_cause_letters_select"
on "public"."show_cause_letters"
as permissive
for select
to public
using (true);


create policy "show_cause_letters_update"
on "public"."show_cause_letters"
as permissive
for update
to public
using (true);


create policy "Enable delete access for all users on staff"
on "public"."staff"
as permissive
for delete
to public
using (true);


create policy "Enable insert access for all users on staff"
on "public"."staff"
as permissive
for insert
to public
with check (true);


create policy "Enable read access for all users on staff"
on "public"."staff"
as permissive
for select
to public
using (true);


create policy "Enable update access for all users on staff"
on "public"."staff"
as permissive
for update
to public
using (true)
with check (true);


create policy "staff_delete"
on "public"."staff"
as permissive
for delete
to public
using (true);


create policy "staff_insert"
on "public"."staff"
as permissive
for insert
to public
with check (true);


create policy "staff_select"
on "public"."staff"
as permissive
for select
to public
using (true);


create policy "staff_select_new"
on "public"."staff"
as permissive
for select
to public
using (true);


create policy "staff_select_policy_new"
on "public"."staff"
as permissive
for select
to public
using (true);


create policy "staff_update"
on "public"."staff"
as permissive
for update
to public
using (true)
with check (true);


create policy "Enable read access for all users on staff_departments"
on "public"."staff_departments"
as permissive
for select
to public
using (true);


create policy "staff_departments_delete"
on "public"."staff_departments"
as permissive
for delete
to public
using (true);


create policy "staff_departments_insert"
on "public"."staff_departments"
as permissive
for insert
to public
with check (true);


create policy "staff_departments_select"
on "public"."staff_departments"
as permissive
for select
to public
using (true);


create policy "staff_departments_update"
on "public"."staff_departments"
as permissive
for update
to public
using (true);


create policy "Enable delete access for all users"
on "public"."staff_levels"
as permissive
for delete
to public
using (true);


create policy "Enable delete access for authenticated users"
on "public"."staff_levels"
as permissive
for delete
to authenticated
using (true);


create policy "Enable insert access for all users"
on "public"."staff_levels"
as permissive
for insert
to public
with check (true);


create policy "Enable insert access for authenticated users"
on "public"."staff_levels"
as permissive
for insert
to authenticated
with check (true);


create policy "Enable read access for all users"
on "public"."staff_levels"
as permissive
for select
to public
using (true);


create policy "Enable read access for authenticated users"
on "public"."staff_levels"
as permissive
for select
to authenticated
using (true);


create policy "Enable update access for all users"
on "public"."staff_levels"
as permissive
for update
to public
using (true)
with check (true);


create policy "Enable update access for authenticated users"
on "public"."staff_levels"
as permissive
for update
to authenticated
using (true)
with check (true);


create policy "Enable read access for all users on staff_levels_junction"
on "public"."staff_levels_junction"
as permissive
for select
to public
using (true);


create policy "staff_levels_junction_delete_new"
on "public"."staff_levels_junction"
as permissive
for delete
to public
using (true);


create policy "staff_levels_junction_insert_new"
on "public"."staff_levels_junction"
as permissive
for insert
to public
with check (true);


create policy "staff_levels_junction_select_new"
on "public"."staff_levels_junction"
as permissive
for select
to public
using (true);


create policy "staff_levels_junction_update_new"
on "public"."staff_levels_junction"
as permissive
for update
to public
using (true);


CREATE TRIGGER set_companies_timestamp BEFORE UPDATE ON public.companies FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_company_events_timestamp BEFORE UPDATE ON public.company_events FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_event_status_trigger BEFORE INSERT OR UPDATE ON public.company_events FOR EACH ROW EXECUTE FUNCTION update_event_status();

CREATE TRIGGER set_department_default_levels_timestamp BEFORE UPDATE ON public.department_default_levels FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_evaluation_timestamp AFTER INSERT OR DELETE ON public.evaluation_departments FOR EACH ROW EXECUTE FUNCTION update_evaluation_updated_at();

CREATE TRIGGER update_evaluation_form_timestamp AFTER INSERT OR DELETE ON public.evaluation_form_departments FOR EACH ROW EXECUTE FUNCTION update_evaluation_form_timestamp();

CREATE TRIGGER update_evaluation_form_levels_timestamp AFTER INSERT OR DELETE ON public.evaluation_form_levels FOR EACH ROW EXECUTE FUNCTION update_evaluation_form_levels_timestamp();

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.evaluation_forms FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.evaluation_responses FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.exit_interviews FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_hr_letters_timestamp BEFORE UPDATE ON public.hr_letters FOR EACH ROW EXECUTE FUNCTION update_hr_letters_updated_at();

CREATE TRIGGER set_hr_letters_updated_at BEFORE UPDATE ON public.hr_letters FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_inventory_items_timestamp BEFORE UPDATE ON public.inventory_items FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_kpi_feedback_timestamp BEFORE UPDATE ON public.kpi_feedback FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_kpis_timestamp BEFORE UPDATE ON public.kpis FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_memos_timestamp BEFORE UPDATE ON public.memos FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_show_cause_letters_timestamp BEFORE UPDATE ON public.show_cause_letters FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.staff FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER validate_status_change BEFORE UPDATE OF status ON public.staff FOR EACH ROW EXECUTE FUNCTION validate_staff_status_change();

CREATE TRIGGER ensure_single_primary_department_trigger BEFORE INSERT OR UPDATE ON public.staff_departments FOR EACH ROW EXECUTE FUNCTION ensure_single_primary_department();

CREATE TRIGGER set_staff_departments_timestamp BEFORE UPDATE ON public.staff_departments FOR EACH ROW EXECUTE FUNCTION update_staff_departments_timestamp();

CREATE TRIGGER ensure_single_primary_level_trigger BEFORE INSERT OR UPDATE ON public.staff_levels_junction FOR EACH ROW EXECUTE FUNCTION ensure_single_primary_level();

CREATE TRIGGER set_staff_levels_junction_timestamp BEFORE UPDATE ON public.staff_levels_junction FOR EACH ROW EXECUTE FUNCTION update_staff_levels_junction_timestamp();

CREATE TRIGGER update_staff_role_from_levels AFTER INSERT OR UPDATE ON public.staff_levels_junction FOR EACH ROW EXECUTE FUNCTION update_staff_role_from_levels();

CREATE TRIGGER update_staff_role_trigger AFTER INSERT OR UPDATE OF is_primary ON public.staff_levels_junction FOR EACH ROW WHEN ((new.is_primary = true)) EXECUTE FUNCTION update_staff_role_from_level();



