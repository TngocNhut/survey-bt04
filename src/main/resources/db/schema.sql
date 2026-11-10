-- Moi dong la mot lan gui khao sat; cung email duoc phep gui nhieu lan.
-- Chay lai an toan, khong xoa du lieu da luu.
CREATE TABLE IF NOT EXISTS public.w2_survey (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL CHECK (btrim(first_name) <> ''),
    last_name VARCHAR(100) NOT NULL CHECK (btrim(last_name) <> ''),
    email VARCHAR(254) NOT NULL CHECK (email ~ '^[^[:space:]@]+@[^[:space:]@]+[.][^[:space:]@]+$'),
    date_of_birth DATE NOT NULL CHECK (date_of_birth <= CURRENT_DATE),
    heard_from VARCHAR(30) NOT NULL
        CHECK (heard_from IN ('Search engine', 'Word of mouth', 'Social Media', 'Other')),
    wants_updates BOOLEAN NOT NULL DEFAULT FALSE,
    email_announcements BOOLEAN NOT NULL DEFAULT FALSE,
    contact_via VARCHAR(30) NOT NULL
        CHECK (contact_via IN ('Email or postal mail', 'Email only', 'Postal mail only')),
    submitted_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS w2_survey_email_idx ON public.w2_survey (email);

COMMENT ON TABLE public.w2_survey IS 'Snapshot day du cua moi lan gui survey, khong ghi de lan gui cu.';
COMMENT ON COLUMN public.w2_survey.id IS 'Ma tu tang cua lan gui survey.';
COMMENT ON COLUMN public.w2_survey.date_of_birth IS 'Ngay sinh, khong chua gio.';
COMMENT ON COLUMN public.w2_survey.submitted_at IS 'Thoi diem gui co mui gio; hien thi theo timezone cua phien truy van.';
