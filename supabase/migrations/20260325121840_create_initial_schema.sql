-- ============================================
-- Table: forms
-- A collection event (merch drop, membership drive, event tickets)
-- ============================================

CREATE TABLE forms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    description TEXT,
    is_published BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================
-- Table: form_fields
-- Line items available on a form
-- ============================================

CREATE TABLE form_fields (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    form_id UUID NOT NULL REFERENCES forms(id) ON DELETE CASCADE,
    label TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('fixed', 'quantity', 'bundle')),
    base_price NUMERIC(10, 2) NOT NULL,
    description TEXT,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================
-- Table: field_variants
-- Variant options for a field (e.g. shirt sizes/colors)
-- ============================================

CREATE TABLE field_variants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    field_id UUID NOT NULL REFERENCES form_fields(id) ON DELETE CASCADE,
    label TEXT NOT NULL,
    price_override NUMERIC(10,2),
    sort_order INTEGER NOT NULL DEFAULT 0
);


-- ============================================
-- Table: submissions
-- One per buyer per form fill
-- ============================================
CREATE TABLE submissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  form_id UUID NOT NULL REFERENCES forms(id),
  receipt_id TEXT NOT NULL UNIQUE,
  buyer_name TEXT NOT NULL,
  buyer_email TEXT NOT NULL,
  student_number TEXT,
  contact_number TEXT,
  mode_of_payment TEXT NOT NULL DEFAULT 'GCash',
  payment_account TEXT,
  notes TEXT,
  screenshot_path TEXT,
  computed_total NUMERIC(10,2) NOT NULL,
  amount_paid NUMERIC(10,2),
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'verified')),
  is_received BOOLEAN DEFAULT FALSE,
  verified_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================
-- Table: submission_entries
-- Line items on a submission
-- ============================================
CREATE TABLE submission_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  submission_id UUID NOT NULL REFERENCES submissions(id) ON DELETE CASCADE,
  field_id UUID NOT NULL REFERENCES form_fields(id),
  variant_id UUID REFERENCES field_variants(id),
  quantity INTEGER NOT NULL DEFAULT 1,
  unit_price NUMERIC(10,2) NOT NULL,
  subtotal NUMERIC(10,2) NOT NULL
);

-- ============================================
-- Row-Level Security
-- ============================================

-- Enable RLS on all tables
ALTER TABLE forms ENABLE ROW LEVEL SECURITY;
ALTER TABLE form_fields ENABLE ROW LEVEL SECURITY;
ALTER TABLE field_variants ENABLE ROW LEVEL SECURITY;
ALTER TABLE submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE submission_entries ENABLE ROW LEVEL SECURITY;

-- Forms: anyone can read published forms, admin can do anything
CREATE POLICY "Public can view published forms"
  ON forms FOR SELECT
  USING (is_published = true);

CREATE POLICY "Admin full access to forms"
  ON forms FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);


-- Form fields: anyone can read (needd to render the form), admin can do everything
CREATE POLICY "Public can view form fields"
  ON form_fields FOR SELECT
  USING (true);

CREATE POLICY "Admin full access to form fields"
  ON form_fields FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

  -- Submissions: anyone can insert (buyers submit), admin can read and update
CREATE POLICY "Public can create submissions"
  ON submissions FOR INSERT
  TO anon
  WITH CHECK (true);

CREATE POLICY "Admin full access to submissions"
  ON submissions FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Submission entries: anyone can insert (created with submission), admin can read
CREATE POLICY "Public can create submission entries"
  ON submission_entries FOR INSERT
  TO anon
  WITH CHECK (true);

CREATE POLICY "Admin full access to submission entries"
  ON submission_entries FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);