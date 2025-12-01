-- ============================================
-- LOCO INSTANT - FULL SCHEMA (No PostGIS)
-- ============================================

-- Extensions
CREATE EXTENSION IF NOT EXISTS citext;

-- ============================================
-- BASE TABLES
-- ============================================

CREATE TABLE IF NOT EXISTS tenants (
  id BIGSERIAL PRIMARY KEY,
  code TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  tz TEXT NOT NULL DEFAULT 'Europe/Bucharest',
  is_active BOOLEAN NOT NULL DEFAULT TRUE
);

-- Insert default tenant
INSERT INTO tenants (code, name) VALUES ('default', 'Loco Default') ON CONFLICT DO NOTHING;

CREATE TABLE IF NOT EXISTS users (
  id BIGSERIAL PRIMARY KEY,
  tenant_id BIGINT REFERENCES tenants(id) NOT NULL DEFAULT 1,
  role TEXT NOT NULL CHECK (role IN ('customer','provider','admin')),
  phone_e164 TEXT UNIQUE,
  email CITEXT UNIQUE,
  password_hash TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS providers (
  id BIGSERIAL PRIMARY KEY,
  tenant_id BIGINT REFERENCES tenants(id) NOT NULL DEFAULT 1,
  user_id BIGINT REFERENCES users(id) UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  rating_avg NUMERIC(3,2) DEFAULT 0,
  rating_count INT DEFAULT 0,
  is_verified BOOLEAN DEFAULT FALSE,
  is_available BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS services (
  id BIGSERIAL PRIMARY KEY,
  tenant_id BIGINT REFERENCES tenants(id) NOT NULL DEFAULT 1,
  slug TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS provider_services (
  provider_id BIGINT REFERENCES providers(id),
  service_id BIGINT REFERENCES services(id),
  base_price NUMERIC(10,2),
  currency TEXT DEFAULT 'RON',
  PRIMARY KEY (provider_id, service_id)
);

-- ============================================
-- ORDERS (simplified without geography)
-- ============================================

CREATE TABLE IF NOT EXISTS orders (
  id BIGSERIAL PRIMARY KEY,
  tenant_id BIGINT REFERENCES tenants(id) NOT NULL DEFAULT 1,
  customer_id BIGINT REFERENCES users(id) NOT NULL,
  provider_id BIGINT REFERENCES providers(id),
  service_id BIGINT REFERENCES services(id),
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN (
    'draft', 'pending', 'payment_pending', 'funds_held', 'assigned',
    'provider_en_route', 'in_progress', 'work_completed', 'confirmed',
    'disputed', 'completed', 'cancelled', 'refunded'
  )),
  price_estimate NUMERIC(10,2),
  currency TEXT DEFAULT 'RON',
  origin_lat NUMERIC(10,7),
  origin_lng NUMERIC(10,7),
  address TEXT,
  description TEXT,
  scheduled_for TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_orders_customer ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_provider ON orders(provider_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);

-- ============================================
-- PAYMENTS & ESCROW
-- ============================================

CREATE TABLE IF NOT EXISTS payments (
  id BIGSERIAL PRIMARY KEY,
  tenant_id BIGINT REFERENCES tenants(id) NOT NULL DEFAULT 1,
  order_id BIGINT REFERENCES orders(id) NOT NULL,
  customer_id BIGINT REFERENCES users(id) NOT NULL,
  provider_id BIGINT REFERENCES providers(id),
  
  total_amount NUMERIC(10,2) NOT NULL,
  advance_amount NUMERIC(10,2) DEFAULT 0,
  remaining_amount NUMERIC(10,2) DEFAULT 0,
  platform_fee NUMERIC(10,2) DEFAULT 0,
  currency TEXT DEFAULT 'RON',
  
  stripe_payment_intent_id TEXT,
  stripe_charge_id TEXT,
  stripe_transfer_id TEXT,
  
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN (
    'pending', 'authorized', 'advance_paid', 'fully_paid',
    'held', 'released', 'refunded', 'disputed', 'failed'
  )),
  
  authorized_at TIMESTAMPTZ,
  advance_paid_at TIMESTAMPTZ,
  held_at TIMESTAMPTZ,
  released_at TIMESTAMPTZ,
  refunded_at TIMESTAMPTZ,
  auto_release_at TIMESTAMPTZ,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_payments_order ON payments(order_id);
CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status);
CREATE INDEX IF NOT EXISTS idx_payments_auto_release ON payments(auto_release_at) WHERE status = 'held';

-- ============================================
-- EVIDENCE / DOVEZI FOTO-VIDEO
-- ============================================

CREATE TABLE IF NOT EXISTS order_evidence (
  id BIGSERIAL PRIMARY KEY,
  tenant_id BIGINT REFERENCES tenants(id) NOT NULL DEFAULT 1,
  order_id BIGINT REFERENCES orders(id) ON DELETE CASCADE NOT NULL,
  uploaded_by BIGINT REFERENCES users(id) NOT NULL,
  
  evidence_type TEXT NOT NULL CHECK (evidence_type IN (
    'before_work', 'during_work', 'after_work',
    'test_proof', 'problem_report', 'dispute_evidence'
  )),
  
  media_type TEXT NOT NULL CHECK (media_type IN ('image', 'video')),
  file_url TEXT NOT NULL,
  thumbnail_url TEXT,
  file_size_bytes BIGINT,
  duration_seconds INT,
  
  description TEXT,
  captured_at TIMESTAMPTZ DEFAULT NOW(),
  location_lat NUMERIC(10,7),
  location_lng NUMERIC(10,7),
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_evidence_order ON order_evidence(order_id);
CREATE INDEX IF NOT EXISTS idx_evidence_type ON order_evidence(evidence_type);

-- ============================================
-- DISPUTES / RECLAMAȚII
-- ============================================

CREATE TABLE IF NOT EXISTS disputes (
  id BIGSERIAL PRIMARY KEY,
  tenant_id BIGINT REFERENCES tenants(id) NOT NULL DEFAULT 1,
  order_id BIGINT REFERENCES orders(id) NOT NULL,
  payment_id BIGINT REFERENCES payments(id),
  
  filed_by BIGINT REFERENCES users(id) NOT NULL,
  filed_by_role TEXT NOT NULL CHECK (filed_by_role IN ('customer', 'provider')),
  
  category TEXT NOT NULL CHECK (category IN (
    'work_not_completed', 'poor_quality', 'different_from_agreed',
    'damage_caused', 'no_show', 'overcharged', 'payment_issue',
    'communication', 'other'
  )),
  
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  what_not_working TEXT,
  technical_details TEXT,
  
  status TEXT NOT NULL DEFAULT 'open' CHECK (status IN (
    'open', 'under_review', 'awaiting_response', 'scheduled_revisit',
    'resolved_refund', 'resolved_partial', 'resolved_redo', 'rejected', 'closed'
  )),
  
  resolution_notes TEXT,
  resolved_by BIGINT REFERENCES users(id),
  resolution_amount NUMERIC(10,2),
  
  revisit_scheduled_at TIMESTAMPTZ,
  revisit_cost NUMERIC(10,2) DEFAULT 0,
  revisit_notes TEXT,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  resolved_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_disputes_order ON disputes(order_id);
CREATE INDEX IF NOT EXISTS idx_disputes_status ON disputes(status);

-- ============================================
-- CHAT MESSAGES (Non-partitioned)
-- ============================================

CREATE TABLE IF NOT EXISTS chat_messages (
  id BIGSERIAL PRIMARY KEY,
  tenant_id BIGINT REFERENCES tenants(id) NOT NULL DEFAULT 1,
  order_id BIGINT REFERENCES orders(id) ON DELETE CASCADE NOT NULL,
  
  sender_id BIGINT NOT NULL, -- 0 for system
  sender_role TEXT NOT NULL CHECK (sender_role IN ('customer', 'provider', 'system')),
  
  message_type TEXT NOT NULL DEFAULT 'text' CHECK (message_type IN (
    'text', 'image', 'video', 'audio', 'file',
    'location', 'system', 'price_quote', 'status_update'
  )),
  content TEXT NOT NULL,
  media_url TEXT,
  metadata JSONB,
  
  is_read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMPTZ,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_chat_order ON chat_messages(order_id);
CREATE INDEX IF NOT EXISTS idx_chat_sender ON chat_messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_chat_unread ON chat_messages(order_id) WHERE is_read = FALSE;

-- ============================================
-- USER RATINGS & BLOCKS
-- ============================================

CREATE TABLE IF NOT EXISTS user_ratings (
  id BIGSERIAL PRIMARY KEY,
  tenant_id BIGINT REFERENCES tenants(id) NOT NULL DEFAULT 1,
  order_id BIGINT REFERENCES orders(id) NOT NULL,
  
  rater_id BIGINT REFERENCES users(id) NOT NULL,
  rated_id BIGINT REFERENCES users(id) NOT NULL,
  rater_role TEXT NOT NULL CHECK (rater_role IN ('customer', 'provider')),
  
  overall_rating INT NOT NULL CHECK (overall_rating BETWEEN 1 AND 5),
  quality_rating INT CHECK (quality_rating BETWEEN 1 AND 5),
  punctuality_rating INT CHECK (punctuality_rating BETWEEN 1 AND 5),
  communication_rating INT CHECK (communication_rating BETWEEN 1 AND 5),
  
  review_text TEXT,
  is_public BOOLEAN DEFAULT TRUE,
  
  response_text TEXT,
  response_at TIMESTAMPTZ,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ratings_rated ON user_ratings(rated_id);
CREATE INDEX IF NOT EXISTS idx_ratings_order ON user_ratings(order_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_ratings_unique ON user_ratings(order_id, rater_id);

CREATE TABLE IF NOT EXISTS user_blocks (
  id BIGSERIAL PRIMARY KEY,
  tenant_id BIGINT REFERENCES tenants(id) NOT NULL DEFAULT 1,
  
  blocker_id BIGINT REFERENCES users(id) NOT NULL,
  blocked_id BIGINT REFERENCES users(id) NOT NULL,
  blocker_role TEXT NOT NULL CHECK (blocker_role IN ('customer', 'provider')),
  
  reason TEXT NOT NULL CHECK (reason IN (
    'abusive', 'non_payment', 'fraud', 'poor_quality', 'harassment', 'other'
  )),
  
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_blocks_unique ON user_blocks(blocker_id, blocked_id);

-- ============================================
-- ORDER STATUS HISTORY / TIMELINE
-- ============================================

CREATE TABLE IF NOT EXISTS order_status_history (
  id BIGSERIAL PRIMARY KEY,
  tenant_id BIGINT REFERENCES tenants(id) NOT NULL DEFAULT 1,
  order_id BIGINT REFERENCES orders(id) ON DELETE CASCADE NOT NULL,
  
  old_status TEXT,
  new_status TEXT NOT NULL,
  changed_by BIGINT REFERENCES users(id),
  changed_by_role TEXT CHECK (changed_by_role IN ('customer', 'provider', 'admin', 'system')),
  
  notes TEXT,
  metadata JSONB,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_status_history_order ON order_status_history(order_id);

-- ============================================
-- NOTIFICATIONS
-- ============================================

CREATE TABLE IF NOT EXISTS notifications (
  id BIGSERIAL PRIMARY KEY,
  tenant_id BIGINT REFERENCES tenants(id) NOT NULL DEFAULT 1,
  user_id BIGINT REFERENCES users(id) NOT NULL,
  
  notification_type TEXT NOT NULL CHECK (notification_type IN (
    'order_created', 'order_assigned', 'provider_en_route', 'work_started',
    'work_completed', 'confirm_reminder', 'auto_release_warning',
    'payment_released', 'dispute_opened', 'dispute_resolved',
    'new_message', 'new_review', 'promotion'
  )),
  
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
-- SCHEDULED TASKS
-- ============================================

CREATE TABLE IF NOT EXISTS scheduled_tasks (
  id BIGSERIAL PRIMARY KEY,
  tenant_id BIGINT REFERENCES tenants(id) NOT NULL DEFAULT 1,
  
  task_type TEXT NOT NULL CHECK (task_type IN (
    'auto_release_payment', 'send_reminder', 'expire_dispute', 'cleanup'
  )),
  
  reference_type TEXT NOT NULL,
  reference_id BIGINT NOT NULL,
  
  scheduled_for TIMESTAMPTZ NOT NULL,
  executed_at TIMESTAMPTZ,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'executed', 'cancelled', 'failed')),
  
  payload JSONB,
  result JSONB,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_tasks_pending ON scheduled_tasks(scheduled_for) WHERE status = 'pending';

-- ============================================
-- TRIGGERS
-- ============================================

CREATE OR REPLACE FUNCTION set_updated_at() RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at := NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_orders_updated_at ON orders;
CREATE TRIGGER trg_orders_updated_at 
  BEFORE UPDATE ON orders 
  FOR EACH ROW EXECUTE PROCEDURE set_updated_at();

DROP TRIGGER IF EXISTS trg_payments_updated_at ON payments;
CREATE TRIGGER trg_payments_updated_at 
  BEFORE UPDATE ON payments 
  FOR EACH ROW EXECUTE PROCEDURE set_updated_at();

DROP TRIGGER IF EXISTS trg_disputes_updated_at ON disputes;
CREATE TRIGGER trg_disputes_updated_at 
  BEFORE UPDATE ON disputes 
  FOR EACH ROW EXECUTE PROCEDURE set_updated_at();

-- ============================================
-- SEED DATA
-- ============================================

-- Insert demo services
INSERT INTO services (slug, name) VALUES 
  ('electrician', 'Electrician'),
  ('plumber', 'Instalator'),
  ('cleaning', 'Curățenie'),
  ('mechanic', 'Mecanic Auto')
ON CONFLICT (slug) DO NOTHING;

-- Insert demo customer
INSERT INTO users (role, email, password_hash) VALUES 
  ('customer', 'client@test.com', '$2b$10$dummyhash'),
  ('provider', 'provider@test.com', '$2b$10$dummyhash'),
  ('admin', 'admin@test.com', '$2b$10$dummyhash')
ON CONFLICT (email) DO NOTHING;

-- Insert demo provider
INSERT INTO providers (user_id, display_name) 
SELECT id, 'Ion Popescu - Electrician' FROM users WHERE email = 'provider@test.com'
ON CONFLICT (user_id) DO NOTHING;

SELECT 'Schema applied successfully!' as status;

