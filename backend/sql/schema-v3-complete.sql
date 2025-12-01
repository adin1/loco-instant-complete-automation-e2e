-- ============================================
-- LOCO INSTANT - SCHEMA COMPLETĂ V3
-- Platformă Marketplace Servicii la Domiciliu
-- ============================================

-- Extensions
CREATE EXTENSION IF NOT EXISTS citext;

-- ============================================
-- 1. USERS (Utilizatori)
-- ============================================
CREATE TABLE IF NOT EXISTS users (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  email CITEXT UNIQUE NOT NULL,
  phone TEXT UNIQUE,
  password_hash TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('client', 'prestator', 'admin')),
  avatar_url TEXT,
  rating_avg NUMERIC(3,2) DEFAULT 0,
  rating_count INT DEFAULT 0,
  is_verified BOOLEAN DEFAULT FALSE,
  is_blocked BOOLEAN DEFAULT FALSE,
  blocked_reason TEXT,
  last_login_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- ============================================
-- 2. PRESTATORI_DETAILS (Detalii Prestatori)
-- ============================================
CREATE TABLE IF NOT EXISTS prestatori_details (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT REFERENCES users(id) UNIQUE NOT NULL,
  
  -- Competențe și servicii
  skills TEXT[] DEFAULT '{}',  -- ['electrician', 'instalator']
  description TEXT,
  bio TEXT,
  
  -- Tarife
  price_per_hour NUMERIC(10,2),
  min_order_price NUMERIC(10,2) DEFAULT 50,
  currency TEXT DEFAULT 'RON',
  
  -- Zonă de acoperire
  service_area TEXT,  -- 'București', 'Sector 1-6', etc.
  service_radius_km INT DEFAULT 20,
  location_lat NUMERIC(10,7),
  location_lng NUMERIC(10,7),
  
  -- Documente și verificări
  documents JSONB DEFAULT '{}',  -- {id_card: url, certificate: url}
  id_verified BOOLEAN DEFAULT FALSE,
  background_check BOOLEAN DEFAULT FALSE,
  
  -- Disponibilitate
  is_available BOOLEAN DEFAULT TRUE,
  working_hours JSONB DEFAULT '{}',  -- {mon: {start: "08:00", end: "18:00"}}
  
  -- Status
  status TEXT DEFAULT 'pending' CHECK (status IN (
    'pending',      -- Așteaptă aprobare
    'approved',     -- Aprobat
    'suspended',    -- Suspendat temporar
    'rejected'      -- Respins
  )),
  
  approved_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_prestatori_skills ON prestatori_details USING GIN (skills);
CREATE INDEX IF NOT EXISTS idx_prestatori_status ON prestatori_details(status);

-- ============================================
-- 3. SERVICES (Categorii Servicii)
-- ============================================
CREATE TABLE IF NOT EXISTS services (
  id BIGSERIAL PRIMARY KEY,
  slug TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  icon TEXT,
  parent_id BIGINT REFERENCES services(id),
  is_active BOOLEAN DEFAULT TRUE,
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================
-- 4. PRESTATOR_SERVICES (Servicii oferite de prestator)
-- ============================================
CREATE TABLE IF NOT EXISTS prestator_services (
  id BIGSERIAL PRIMARY KEY,
  prestator_id BIGINT REFERENCES prestatori_details(id) NOT NULL,
  service_id BIGINT REFERENCES services(id) NOT NULL,
  price NUMERIC(10,2),
  price_type TEXT DEFAULT 'fixed' CHECK (price_type IN ('fixed', 'hourly', 'quote')),
  description TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  UNIQUE(prestator_id, service_id)
);

-- ============================================
-- 5. JOBS (Comenzi/Lucrări)
-- Status-uri complete conform specificației
-- ============================================
CREATE TABLE IF NOT EXISTS jobs (
  id BIGSERIAL PRIMARY KEY,
  
  -- Părți implicate
  client_id BIGINT REFERENCES users(id) NOT NULL,
  prestator_id BIGINT REFERENCES users(id),
  
  -- Detalii lucrare
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  service_id BIGINT REFERENCES services(id),
  
  -- Locație
  address TEXT NOT NULL,
  address_details TEXT,  -- Etaj, apartament, etc.
  location_lat NUMERIC(10,7),
  location_lng NUMERIC(10,7),
  
  -- Programare
  scheduled_date DATE,
  scheduled_time_start TIME,
  scheduled_time_end TIME,
  is_flexible BOOLEAN DEFAULT FALSE,
  
  -- Prețuri
  price_estimate NUMERIC(10,2),
  price_final NUMERIC(10,2),
  currency TEXT DEFAULT 'RON',
  platform_fee NUMERIC(10,2) DEFAULT 0,
  
  -- Status complet
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN (
    'pending',                    -- În așteptare
    'funds_blocked',              -- Fonduri blocate
    'accepted',                   -- Acceptat de prestator
    'scheduled',                  -- Programat
    'on_the_way',                 -- Prestator în drum
    'in_progress',                -- În lucru
    'completed_by_prestator',     -- Finalizat de prestator
    'awaiting_client_confirmation', -- Așteaptă confirmare client
    'confirmed',                  -- Confirmat de client
    'auto_confirmed',             -- Confirmat automat (timeout)
    'disputed',                   -- În dispută
    'resolved',                   -- Dispută rezolvată
    'paid',                       -- Plătit către prestator
    'cancelled',                  -- Anulat
    'refunded'                    -- Rambursat
  )),
  
  -- Timestamps workflow
  accepted_at TIMESTAMPTZ,
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  confirmed_at TIMESTAMPTZ,
  confirmation_deadline TIMESTAMPTZ,  -- Deadline pentru confirmare client
  paid_at TIMESTAMPTZ,
  cancelled_at TIMESTAMPTZ,
  cancellation_reason TEXT,
  cancelled_by BIGINT REFERENCES users(id),
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_jobs_client ON jobs(client_id);
CREATE INDEX IF NOT EXISTS idx_jobs_prestator ON jobs(prestator_id);
CREATE INDEX IF NOT EXISTS idx_jobs_status ON jobs(status);
CREATE INDEX IF NOT EXISTS idx_jobs_date ON jobs(scheduled_date);

-- ============================================
-- 6. JOB_PHOTOS (Poze lucrare)
-- ============================================
CREATE TABLE IF NOT EXISTS job_photos (
  id BIGSERIAL PRIMARY KEY,
  job_id BIGINT REFERENCES jobs(id) ON DELETE CASCADE NOT NULL,
  uploaded_by BIGINT REFERENCES users(id) NOT NULL,
  
  type TEXT NOT NULL CHECK (type IN (
    'before',        -- Înainte de lucrare
    'during',        -- În timpul lucrării
    'after',         -- După lucrare
    'problem',       -- Raport problemă
    'dispute'        -- Dovadă dispută
  )),
  
  file_url TEXT NOT NULL,
  thumbnail_url TEXT,
  description TEXT,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_job_photos_job ON job_photos(job_id);
CREATE INDEX IF NOT EXISTS idx_job_photos_type ON job_photos(type);

-- ============================================
-- 7. PAYMENTS (Plăți)
-- ============================================
CREATE TABLE IF NOT EXISTS payments (
  id BIGSERIAL PRIMARY KEY,
  job_id BIGINT REFERENCES jobs(id) NOT NULL,
  client_id BIGINT REFERENCES users(id) NOT NULL,
  prestator_id BIGINT REFERENCES users(id),
  
  -- Sume
  amount NUMERIC(10,2) NOT NULL,
  platform_fee NUMERIC(10,2) DEFAULT 0,
  prestator_amount NUMERIC(10,2),  -- amount - platform_fee
  currency TEXT DEFAULT 'RON',
  
  -- Metodă plată
  method TEXT CHECK (method IN (
    'card',
    'apple_pay',
    'google_pay',
    'bank_transfer'
  )),
  
  -- Status
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN (
    'pending',       -- În așteptare
    'blocked',       -- Blocat (preautorizat)
    'captured',      -- Încasat
    'released',      -- Eliberat către prestator
    'refunded',      -- Rambursat
    'failed'         -- Eșuat
  )),
  
  -- Stripe/Procesator
  stripe_payment_intent_id TEXT,
  stripe_charge_id TEXT,
  stripe_transfer_id TEXT,
  transaction_id TEXT,
  
  -- Timestamps
  blocked_at TIMESTAMPTZ,
  captured_at TIMESTAMPTZ,
  released_at TIMESTAMPTZ,
  refunded_at TIMESTAMPTZ,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_payments_job ON payments(job_id);
CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status);

-- ============================================
-- 8. DISPUTES (Reclamații)
-- ============================================
CREATE TABLE IF NOT EXISTS disputes (
  id BIGSERIAL PRIMARY KEY,
  job_id BIGINT REFERENCES jobs(id) NOT NULL,
  client_id BIGINT REFERENCES users(id) NOT NULL,
  prestator_id BIGINT REFERENCES users(id) NOT NULL,
  
  -- Detalii reclamație
  category TEXT NOT NULL CHECK (category IN (
    'incomplete_work',      -- Lucrare incompletă
    'poor_quality',         -- Calitate slabă
    'different_from_agreed', -- Diferit de ce s-a agreat
    'damage',               -- Daune provocate
    'no_show',              -- Nu s-a prezentat
    'overcharge',           -- Suprataxare
    'communication',        -- Probleme comunicare
    'other'                 -- Altele
  )),
  
  description TEXT NOT NULL,
  what_not_working TEXT,
  
  -- Status
  status TEXT NOT NULL DEFAULT 'open' CHECK (status IN (
    'open',              -- Deschis
    'under_review',      -- În analiză
    'prestator_response', -- Așteaptă răspuns prestator
    'revisit_scheduled', -- Programată revizie
    'resolved_refund',   -- Rezolvat - ramburs
    'resolved_partial',  -- Rezolvat - ramburs parțial
    'resolved_redo',     -- Rezolvat - refacere
    'resolved_no_action', -- Rezolvat - fără acțiune (nefondat)
    'closed'             -- Închis
  )),
  
  -- Rezoluție
  resolution_notes TEXT,
  resolved_by BIGINT REFERENCES users(id),
  refund_amount NUMERIC(10,2),
  
  -- Revizie programată
  revisit_date DATE,
  revisit_cost NUMERIC(10,2) DEFAULT 0,
  revisit_notes TEXT,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  resolved_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_disputes_job ON disputes(job_id);
CREATE INDEX IF NOT EXISTS idx_disputes_status ON disputes(status);

-- ============================================
-- 9. MESSAGES (Chat intern)
-- ============================================
CREATE TABLE IF NOT EXISTS messages (
  id BIGSERIAL PRIMARY KEY,
  job_id BIGINT REFERENCES jobs(id) ON DELETE CASCADE NOT NULL,
  sender_id BIGINT REFERENCES users(id) NOT NULL,
  receiver_id BIGINT REFERENCES users(id) NOT NULL,
  
  message TEXT NOT NULL,
  message_type TEXT DEFAULT 'text' CHECK (message_type IN (
    'text', 'image', 'file', 'system', 'price_quote'
  )),
  
  is_read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMPTZ,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_messages_job ON messages(job_id);
CREATE INDEX IF NOT EXISTS idx_messages_sender ON messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_unread ON messages(job_id) WHERE is_read = FALSE;

-- ============================================
-- 10. REVIEWS (Recenzii)
-- ============================================
CREATE TABLE IF NOT EXISTS reviews (
  id BIGSERIAL PRIMARY KEY,
  job_id BIGINT REFERENCES jobs(id) NOT NULL,
  from_user_id BIGINT REFERENCES users(id) NOT NULL,
  to_user_id BIGINT REFERENCES users(id) NOT NULL,
  
  rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  
  -- Sub-ratinguri
  quality_rating INT CHECK (quality_rating BETWEEN 1 AND 5),
  punctuality_rating INT CHECK (punctuality_rating BETWEEN 1 AND 5),
  communication_rating INT CHECK (communication_rating BETWEEN 1 AND 5),
  
  comment TEXT,
  
  -- Răspuns
  response TEXT,
  response_at TIMESTAMPTZ,
  
  is_public BOOLEAN DEFAULT TRUE,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  UNIQUE(job_id, from_user_id)
);

CREATE INDEX IF NOT EXISTS idx_reviews_to_user ON reviews(to_user_id);
CREATE INDEX IF NOT EXISTS idx_reviews_job ON reviews(job_id);

-- ============================================
-- 11. WALLET (Portofel Prestator)
-- ============================================
CREATE TABLE IF NOT EXISTS wallet (
  id BIGSERIAL PRIMARY KEY,
  prestator_id BIGINT REFERENCES users(id) UNIQUE NOT NULL,
  
  balance NUMERIC(10,2) NOT NULL DEFAULT 0,
  pending_balance NUMERIC(10,2) NOT NULL DEFAULT 0,  -- În așteptare eliberare
  total_earned NUMERIC(10,2) NOT NULL DEFAULT 0,
  total_withdrawn NUMERIC(10,2) NOT NULL DEFAULT 0,
  
  currency TEXT DEFAULT 'RON',
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================
-- 12. WALLET_TRANSACTIONS (Tranzacții portofel)
-- ============================================
CREATE TABLE IF NOT EXISTS wallet_transactions (
  id BIGSERIAL PRIMARY KEY,
  wallet_id BIGINT REFERENCES wallet(id) NOT NULL,
  job_id BIGINT REFERENCES jobs(id),
  
  type TEXT NOT NULL CHECK (type IN (
    'credit',      -- Plată primită
    'debit',       -- Retragere
    'refund',      -- Ramburs
    'fee',         -- Comision platformă
    'adjustment'   -- Ajustare manuală
  )),
  
  amount NUMERIC(10,2) NOT NULL,
  balance_after NUMERIC(10,2) NOT NULL,
  
  description TEXT,
  reference_id TEXT,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_wallet_tx_wallet ON wallet_transactions(wallet_id);

-- ============================================
-- 13. WITHDRAWALS (Retrageri)
-- ============================================
CREATE TABLE IF NOT EXISTS withdrawals (
  id BIGSERIAL PRIMARY KEY,
  prestator_id BIGINT REFERENCES users(id) NOT NULL,
  wallet_id BIGINT REFERENCES wallet(id) NOT NULL,
  
  amount NUMERIC(10,2) NOT NULL,
  currency TEXT DEFAULT 'RON',
  
  -- Cont bancar
  bank_name TEXT NOT NULL,
  bank_account TEXT NOT NULL,  -- IBAN
  account_holder TEXT NOT NULL,
  
  -- Status
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN (
    'pending',     -- În așteptare
    'processing',  -- În procesare
    'completed',   -- Finalizat
    'failed',      -- Eșuat
    'cancelled'    -- Anulat
  )),
  
  -- Procesare
  processed_at TIMESTAMPTZ,
  processed_by BIGINT REFERENCES users(id),
  transaction_reference TEXT,
  failure_reason TEXT,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_withdrawals_prestator ON withdrawals(prestator_id);
CREATE INDEX IF NOT EXISTS idx_withdrawals_status ON withdrawals(status);

-- ============================================
-- 14. JOB_STATUS_HISTORY (Istoric status-uri)
-- ============================================
CREATE TABLE IF NOT EXISTS job_status_history (
  id BIGSERIAL PRIMARY KEY,
  job_id BIGINT REFERENCES jobs(id) ON DELETE CASCADE NOT NULL,
  
  old_status TEXT,
  new_status TEXT NOT NULL,
  changed_by BIGINT REFERENCES users(id),
  changed_by_role TEXT,
  
  notes TEXT,
  metadata JSONB,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_job_history_job ON job_status_history(job_id);

-- ============================================
-- 15. NOTIFICATIONS (Notificări)
-- ============================================
CREATE TABLE IF NOT EXISTS notifications (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT REFERENCES users(id) NOT NULL,
  
  type TEXT NOT NULL,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  data JSONB,
  
  is_read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMPTZ,
  
  push_sent BOOLEAN DEFAULT FALSE,
  push_sent_at TIMESTAMPTZ,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_unread ON notifications(user_id) WHERE is_read = FALSE;

-- ============================================
-- 16. USER_BLOCKS (Blocări utilizatori)
-- ============================================
CREATE TABLE IF NOT EXISTS user_blocks (
  id BIGSERIAL PRIMARY KEY,
  blocker_id BIGINT REFERENCES users(id) NOT NULL,
  blocked_id BIGINT REFERENCES users(id) NOT NULL,
  
  reason TEXT NOT NULL,
  notes TEXT,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  UNIQUE(blocker_id, blocked_id)
);

-- ============================================
-- 17. SCHEDULED_TASKS (Task-uri programate)
-- ============================================
CREATE TABLE IF NOT EXISTS scheduled_tasks (
  id BIGSERIAL PRIMARY KEY,
  
  task_type TEXT NOT NULL,
  reference_type TEXT NOT NULL,
  reference_id BIGINT NOT NULL,
  
  scheduled_for TIMESTAMPTZ NOT NULL,
  executed_at TIMESTAMPTZ,
  
  status TEXT DEFAULT 'pending' CHECK (status IN (
    'pending', 'executed', 'cancelled', 'failed'
  )),
  
  payload JSONB,
  result JSONB,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_tasks_pending ON scheduled_tasks(scheduled_for) 
  WHERE status = 'pending';

-- ============================================
-- TRIGGERS
-- ============================================

CREATE OR REPLACE FUNCTION set_updated_at() RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at := NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_user_rating() RETURNS TRIGGER AS $$
BEGIN
  UPDATE users SET 
    rating_avg = (
      SELECT COALESCE(AVG(rating), 0) FROM reviews WHERE to_user_id = NEW.to_user_id
    ),
    rating_count = (
      SELECT COUNT(*) FROM reviews WHERE to_user_id = NEW.to_user_id
    )
  WHERE id = NEW.to_user_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply triggers
DROP TRIGGER IF EXISTS trg_users_updated_at ON users;
CREATE TRIGGER trg_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE PROCEDURE set_updated_at();

DROP TRIGGER IF EXISTS trg_jobs_updated_at ON jobs;
CREATE TRIGGER trg_jobs_updated_at BEFORE UPDATE ON jobs FOR EACH ROW EXECUTE PROCEDURE set_updated_at();

DROP TRIGGER IF EXISTS trg_payments_updated_at ON payments;
CREATE TRIGGER trg_payments_updated_at BEFORE UPDATE ON payments FOR EACH ROW EXECUTE PROCEDURE set_updated_at();

DROP TRIGGER IF EXISTS trg_disputes_updated_at ON disputes;
CREATE TRIGGER trg_disputes_updated_at BEFORE UPDATE ON disputes FOR EACH ROW EXECUTE PROCEDURE set_updated_at();

DROP TRIGGER IF EXISTS trg_wallet_updated_at ON wallet;
CREATE TRIGGER trg_wallet_updated_at BEFORE UPDATE ON wallet FOR EACH ROW EXECUTE PROCEDURE set_updated_at();

DROP TRIGGER IF EXISTS trg_reviews_update_rating ON reviews;
CREATE TRIGGER trg_reviews_update_rating AFTER INSERT ON reviews FOR EACH ROW EXECUTE PROCEDURE update_user_rating();

-- ============================================
-- SEED DATA
-- ============================================

-- Servicii
INSERT INTO services (slug, name, icon, sort_order) VALUES 
  ('electrician', 'Electrician', '⚡', 1),
  ('instalator', 'Instalator', '🔧', 2),
  ('curatenie', 'Curățenie', '🧹', 3),
  ('zugrav', 'Zugrav', '🎨', 4),
  ('mecanic-auto', 'Mecanic Auto', '🚗', 5),
  ('tamplar', 'Tâmplar', '🪚', 6),
  ('gradinar', 'Grădinar', '🌱', 7),
  ('reparatii-electrocasnice', 'Reparații Electrocasnice', '🔌', 8)
ON CONFLICT (slug) DO NOTHING;

-- Utilizatori demo
INSERT INTO users (name, email, phone, password_hash, role) VALUES 
  ('Ion Popescu', 'client@test.com', '+40700000001', '$2b$10$dummyhash', 'client'),
  ('Maria Ionescu', 'prestator@test.com', '+40700000002', '$2b$10$dummyhash', 'prestator'),
  ('Admin Loco', 'admin@loco.ro', '+40700000000', '$2b$10$dummyhash', 'admin')
ON CONFLICT (email) DO NOTHING;

-- Detalii prestator
INSERT INTO prestatori_details (user_id, skills, description, price_per_hour, service_area, status)
SELECT id, ARRAY['electrician', 'instalator'], 
  'Prestator cu experiență de 10 ani în domeniu. Servicii profesioniste și prompte.',
  100, 'București', 'approved'
FROM users WHERE email = 'prestator@test.com'
ON CONFLICT (user_id) DO NOTHING;

-- Wallet pentru prestator
INSERT INTO wallet (prestator_id)
SELECT id FROM users WHERE email = 'prestator@test.com'
ON CONFLICT (prestator_id) DO NOTHING;

SELECT '✅ Schema V3 aplicată cu succes!' as status;

