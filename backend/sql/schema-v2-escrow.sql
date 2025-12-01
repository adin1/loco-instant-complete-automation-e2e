-- ============================================
-- LOCO INSTANT - ESCROW & DISPUTE SYSTEM
-- Schema Extension v2.0
-- ============================================

-- Drop existing constraints if updating
ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_status_check;

-- Extend order statuses to support full workflow
ALTER TABLE orders ADD CONSTRAINT orders_status_check 
  CHECK (status IN (
    'draft',           -- Comandă în curs de creare
    'pending',         -- Așteaptă plată/provider
    'payment_pending', -- Așteaptă procesarea plății
    'funds_held',      -- Fonduri blocate în escrow
    'assigned',        -- Provider asignat
    'provider_en_route', -- Provider în drum
    'in_progress',     -- Lucrare în curs
    'work_completed',  -- Marcat finalizat de provider
    'confirmed',       -- Confirmat de client
    'disputed',        -- În dispută
    'completed',       -- Finalizat, bani eliberați
    'cancelled',       -- Anulat
    'refunded'         -- Rambursat
  ));

-- ============================================
-- PAYMENTS & ESCROW
-- ============================================
CREATE TABLE IF NOT EXISTS payments (
  id BIGSERIAL PRIMARY KEY,
  tenant_id BIGINT REFERENCES tenants(id) NOT NULL,
  order_id BIGINT REFERENCES orders(id) NOT NULL,
  customer_id BIGINT REFERENCES users(id) NOT NULL,
  provider_id BIGINT REFERENCES providers(id),
  
  -- Amount details
  total_amount NUMERIC(10,2) NOT NULL,
  advance_amount NUMERIC(10,2) DEFAULT 0, -- Avans (30-50%)
  remaining_amount NUMERIC(10,2) DEFAULT 0, -- Rest de plată
  platform_fee NUMERIC(10,2) DEFAULT 0, -- Comision platformă
  currency TEXT DEFAULT 'RON',
  
  -- Payment processor
  stripe_payment_intent_id TEXT,
  stripe_charge_id TEXT,
  stripe_transfer_id TEXT,
  
  -- Status
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN (
    'pending',          -- Inițiată
    'authorized',       -- Pre-autorizat (card blocat)
    'advance_paid',     -- Avans plătit
    'fully_paid',       -- Plătit integral
    'held',             -- În escrow (blocat)
    'released',         -- Eliberat către provider
    'refunded',         -- Rambursat către client
    'disputed',         -- În dispută
    'failed'            -- Eșuat
  )),
  
  -- Timing
  authorized_at TIMESTAMPTZ,
  advance_paid_at TIMESTAMPTZ,
  held_at TIMESTAMPTZ,
  released_at TIMESTAMPTZ,
  refunded_at TIMESTAMPTZ,
  auto_release_at TIMESTAMPTZ, -- Când se eliberează automat
  
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
  tenant_id BIGINT REFERENCES tenants(id) NOT NULL,
  order_id BIGINT REFERENCES orders(id) ON DELETE CASCADE NOT NULL,
  uploaded_by BIGINT REFERENCES users(id) NOT NULL,
  
  -- Type
  evidence_type TEXT NOT NULL CHECK (evidence_type IN (
    'before_work',      -- Înainte de intervenție
    'during_work',      -- În timpul lucrării
    'after_work',       -- După finalizare
    'test_proof',       -- Dovadă testare (video lumina se aprinde)
    'problem_report',   -- Raport problemă de la client
    'dispute_evidence'  -- Dovezi dispută
  )),
  
  -- Media
  media_type TEXT NOT NULL CHECK (media_type IN ('image', 'video')),
  file_url TEXT NOT NULL,
  thumbnail_url TEXT,
  file_size_bytes BIGINT,
  duration_seconds INT, -- Pentru video
  
  -- Metadata
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
  tenant_id BIGINT REFERENCES tenants(id) NOT NULL,
  order_id BIGINT REFERENCES orders(id) NOT NULL,
  payment_id BIGINT REFERENCES payments(id),
  
  -- Who filed
  filed_by BIGINT REFERENCES users(id) NOT NULL,
  filed_by_role TEXT NOT NULL CHECK (filed_by_role IN ('customer', 'provider')),
  
  -- Dispute details
  category TEXT NOT NULL CHECK (category IN (
    'work_not_completed',    -- Lucrarea nu e finalizată
    'poor_quality',          -- Calitate slabă
    'different_from_agreed', -- Diferit de ce s-a agreat
    'damage_caused',         -- Daune provocate
    'no_show',              -- Provider nu s-a prezentat
    'overcharged',          -- Suprataxat
    'payment_issue',        -- Problemă plată
    'communication',        -- Problemă comunicare
    'other'                 -- Altele
  )),
  
  -- Description
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  what_not_working TEXT, -- Ce exact nu funcționează
  technical_details TEXT, -- Detalii tehnice (priză, circuit, etc)
  
  -- Resolution
  status TEXT NOT NULL DEFAULT 'open' CHECK (status IN (
    'open',              -- Deschis
    'under_review',      -- În analiză
    'awaiting_response', -- Așteaptă răspuns
    'scheduled_revisit', -- Programată revenire
    'resolved_refund',   -- Rezolvat - ramburs
    'resolved_partial',  -- Rezolvat - ramburs parțial
    'resolved_redo',     -- Rezolvat - refacere lucrare
    'rejected',          -- Respins (nefondat)
    'closed'             -- Închis
  )),
  
  resolution_notes TEXT,
  resolved_by BIGINT REFERENCES users(id),
  resolution_amount NUMERIC(10,2), -- Sumă rambursată dacă e cazul
  
  -- Revisit scheduling
  revisit_scheduled_at TIMESTAMPTZ,
  revisit_cost NUMERIC(10,2) DEFAULT 0, -- 0 = gratis, >0 = cu cost
  revisit_notes TEXT,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  resolved_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_disputes_order ON disputes(order_id);
CREATE INDEX IF NOT EXISTS idx_disputes_status ON disputes(status);

-- ============================================
-- CHAT MESSAGES (Persistent)
-- ============================================
CREATE TABLE IF NOT EXISTS chat_messages (
  id BIGSERIAL PRIMARY KEY,
  tenant_id BIGINT REFERENCES tenants(id) NOT NULL,
  order_id BIGINT REFERENCES orders(id) ON DELETE CASCADE NOT NULL,
  
  sender_id BIGINT REFERENCES users(id) NOT NULL,
  sender_role TEXT NOT NULL CHECK (sender_role IN ('customer', 'provider', 'system')),
  
  -- Content
  message_type TEXT NOT NULL DEFAULT 'text' CHECK (message_type IN (
    'text',
    'image',
    'video',
    'audio',
    'file',
    'location',
    'system',      -- Mesaj automat sistem
    'price_quote', -- Ofertă preț
    'status_update' -- Update status
  )),
  content TEXT NOT NULL,
  media_url TEXT,
  metadata JSONB, -- Extra data (locație, preț oferit, etc)
  
  -- Status
  is_read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMPTZ,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
) PARTITION BY LIST (tenant_id);

CREATE INDEX IF NOT EXISTS idx_chat_order ON chat_messages(order_id);
CREATE INDEX IF NOT EXISTS idx_chat_sender ON chat_messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_chat_unread ON chat_messages(order_id) WHERE is_read = FALSE;

-- ============================================
-- USER RATINGS & BLOCKS
-- ============================================
CREATE TABLE IF NOT EXISTS user_ratings (
  id BIGSERIAL PRIMARY KEY,
  tenant_id BIGINT REFERENCES tenants(id) NOT NULL,
  order_id BIGINT REFERENCES orders(id) NOT NULL,
  
  -- Who rates who
  rater_id BIGINT REFERENCES users(id) NOT NULL,
  rated_id BIGINT REFERENCES users(id) NOT NULL,
  rater_role TEXT NOT NULL CHECK (rater_role IN ('customer', 'provider')),
  
  -- Rating
  overall_rating INT NOT NULL CHECK (overall_rating BETWEEN 1 AND 5),
  quality_rating INT CHECK (quality_rating BETWEEN 1 AND 5),
  punctuality_rating INT CHECK (punctuality_rating BETWEEN 1 AND 5),
  communication_rating INT CHECK (communication_rating BETWEEN 1 AND 5),
  
  -- Review
  review_text TEXT,
  is_public BOOLEAN DEFAULT TRUE,
  
  -- Provider response
  response_text TEXT,
  response_at TIMESTAMPTZ,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ratings_rated ON user_ratings(rated_id);
CREATE INDEX IF NOT EXISTS idx_ratings_order ON user_ratings(order_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_ratings_unique ON user_ratings(order_id, rater_id);

-- Block list
CREATE TABLE IF NOT EXISTS user_blocks (
  id BIGSERIAL PRIMARY KEY,
  tenant_id BIGINT REFERENCES tenants(id) NOT NULL,
  
  blocker_id BIGINT REFERENCES users(id) NOT NULL,
  blocked_id BIGINT REFERENCES users(id) NOT NULL,
  blocker_role TEXT NOT NULL CHECK (blocker_role IN ('customer', 'provider')),
  
  reason TEXT NOT NULL CHECK (reason IN (
    'abusive',       -- Comportament abuziv
    'non_payment',   -- Refuz plată
    'fraud',         -- Fraudă
    'poor_quality',  -- Calitate slabă (pentru clienți blocking provideri)
    'harassment',    -- Hărțuire
    'other'          -- Altele
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
  tenant_id BIGINT REFERENCES tenants(id) NOT NULL,
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
  tenant_id BIGINT REFERENCES tenants(id) NOT NULL,
  user_id BIGINT REFERENCES users(id) NOT NULL,
  
  -- Type
  notification_type TEXT NOT NULL CHECK (notification_type IN (
    'order_created',
    'order_assigned',
    'provider_en_route',
    'work_started',
    'work_completed',
    'confirm_reminder',    -- "Confirmă sau raportează problemă"
    'auto_release_warning', -- "Plata se va elibera în X ore"
    'payment_released',
    'dispute_opened',
    'dispute_resolved',
    'new_message',
    'new_review',
    'promotion'
  )),
  
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  data JSONB, -- Extra data (order_id, etc)
  
  -- Status
  is_read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMPTZ,
  
  -- Push notification
  push_sent BOOLEAN DEFAULT FALSE,
  push_sent_at TIMESTAMPTZ,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_unread ON notifications(user_id) WHERE is_read = FALSE;

-- ============================================
-- SCHEDULED TASKS (for auto-release)
-- ============================================
CREATE TABLE IF NOT EXISTS scheduled_tasks (
  id BIGSERIAL PRIMARY KEY,
  tenant_id BIGINT REFERENCES tenants(id) NOT NULL,
  
  task_type TEXT NOT NULL CHECK (task_type IN (
    'auto_release_payment',
    'send_reminder',
    'expire_dispute',
    'cleanup'
  )),
  
  reference_type TEXT NOT NULL, -- 'order', 'payment', 'dispute'
  reference_id BIGINT NOT NULL,
  
  scheduled_for TIMESTAMPTZ NOT NULL,
  executed_at TIMESTAMPTZ,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'executed', 'cancelled', 'failed')),
  
  payload JSONB,
  result JSONB,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_tasks_pending ON scheduled_tasks(scheduled_for) 
  WHERE status = 'pending';

-- ============================================
-- TRIGGERS
-- ============================================

-- Update payments.updated_at
DROP TRIGGER IF EXISTS trg_payments_updated_at ON payments;
CREATE TRIGGER trg_payments_updated_at 
  BEFORE UPDATE ON payments 
  FOR EACH ROW EXECUTE PROCEDURE set_updated_at();

-- Update disputes.updated_at  
DROP TRIGGER IF EXISTS trg_disputes_updated_at ON disputes;
CREATE TRIGGER trg_disputes_updated_at 
  BEFORE UPDATE ON disputes 
  FOR EACH ROW EXECUTE PROCEDURE set_updated_at();

-- ============================================
-- VIEWS
-- ============================================

-- Order with payment status
CREATE OR REPLACE VIEW order_with_payment AS
SELECT 
  o.*,
  p.status as payment_status,
  p.total_amount,
  p.advance_amount,
  p.remaining_amount,
  p.held_at,
  p.auto_release_at,
  EXTRACT(EPOCH FROM (p.auto_release_at - NOW())) / 3600 as hours_until_release
FROM orders o
LEFT JOIN payments p ON p.order_id = o.id;

-- Provider statistics
CREATE OR REPLACE VIEW provider_stats AS
SELECT 
  pr.id as provider_id,
  pr.display_name,
  pr.rating_avg,
  pr.rating_count,
  COUNT(DISTINCT o.id) FILTER (WHERE o.status = 'completed') as completed_orders,
  COUNT(DISTINCT d.id) FILTER (WHERE d.status NOT IN ('rejected', 'closed')) as active_disputes,
  AVG(ur.overall_rating) as avg_rating
FROM providers pr
LEFT JOIN orders o ON o.provider_id = pr.id
LEFT JOIN disputes d ON d.order_id = o.id
LEFT JOIN user_ratings ur ON ur.rated_id = pr.user_id
GROUP BY pr.id;

-- ============================================
-- SAMPLE DATA FOR TESTING
-- ============================================
-- (Uncomment if needed for development)

/*
-- Insert sample service
INSERT INTO services (tenant_id, slug, name) VALUES 
(1, 'electrician', 'Electrician'),
(1, 'plumber', 'Instalator'),
(1, 'cleaning', 'Curățenie')
ON CONFLICT DO NOTHING;
*/

