-- ==============================================
-- LOCO INSTANT - DATABASE SECURITY CONFIGURATION
-- ==============================================

-- 1. Revoke public access
REVOKE ALL ON SCHEMA public FROM PUBLIC;

-- 2. Create application role with limited permissions
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'loco_app') THEN
        CREATE ROLE loco_app WITH LOGIN PASSWORD 'app_user_password_change_me';
    END IF;
END
$$;

-- 3. Grant necessary permissions to app role
GRANT USAGE ON SCHEMA public TO loco_app;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO loco_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO loco_app;

-- 4. Set default privileges for future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO loco_app;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT USAGE, SELECT ON SEQUENCES TO loco_app;

-- 5. Enable row-level security on sensitive tables
ALTER TABLE IF EXISTS users ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS payments ENABLE ROW LEVEL SECURITY;

-- 6. Create audit log table
CREATE TABLE IF NOT EXISTS audit_log (
    id BIGSERIAL PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL,
    record_id BIGINT,
    action VARCHAR(20) NOT NULL, -- INSERT, UPDATE, DELETE
    old_data JSONB,
    new_data JSONB,
    user_id BIGINT,
    ip_address INET,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. Create index for audit log
CREATE INDEX IF NOT EXISTS idx_audit_log_table_action ON audit_log(table_name, action);
CREATE INDEX IF NOT EXISTS idx_audit_log_created_at ON audit_log(created_at);

-- 8. Function to log changes
CREATE OR REPLACE FUNCTION audit_trigger_func()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        INSERT INTO audit_log (table_name, record_id, action, old_data)
        VALUES (TG_TABLE_NAME, OLD.id, TG_OP, row_to_json(OLD)::jsonb);
        RETURN OLD;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit_log (table_name, record_id, action, old_data, new_data)
        VALUES (TG_TABLE_NAME, NEW.id, TG_OP, row_to_json(OLD)::jsonb, row_to_json(NEW)::jsonb);
        RETURN NEW;
    ELSIF TG_OP = 'INSERT' THEN
        INSERT INTO audit_log (table_name, record_id, action, new_data)
        VALUES (TG_TABLE_NAME, NEW.id, TG_OP, row_to_json(NEW)::jsonb);
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- 9. Create audit triggers for critical tables
DROP TRIGGER IF EXISTS audit_users ON users;
CREATE TRIGGER audit_users
    AFTER INSERT OR UPDATE OR DELETE ON users
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();

DROP TRIGGER IF EXISTS audit_payments ON payments;
CREATE TRIGGER audit_payments
    AFTER INSERT OR UPDATE OR DELETE ON payments
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();

-- 10. Create session tracking table
CREATE TABLE IF NOT EXISTS user_sessions (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id),
    token_hash VARCHAR(256) NOT NULL,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ NOT NULL,
    revoked_at TIMESTAMPTZ,
    CONSTRAINT idx_active_sessions UNIQUE (user_id, token_hash)
);

CREATE INDEX IF NOT EXISTS idx_sessions_user ON user_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_expires ON user_sessions(expires_at);

-- 11. Create failed login attempts table (rate limiting)
CREATE TABLE IF NOT EXISTS failed_login_attempts (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255),
    ip_address INET,
    attempted_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_failed_login_email ON failed_login_attempts(email, attempted_at);
CREATE INDEX IF NOT EXISTS idx_failed_login_ip ON failed_login_attempts(ip_address, attempted_at);

-- 12. Create function to check rate limiting
CREATE OR REPLACE FUNCTION check_rate_limit(
    p_email VARCHAR,
    p_ip INET,
    p_max_attempts INT DEFAULT 5,
    p_window_minutes INT DEFAULT 15
)
RETURNS BOOLEAN AS $$
DECLARE
    attempt_count INT;
BEGIN
    SELECT COUNT(*) INTO attempt_count
    FROM failed_login_attempts
    WHERE (email = p_email OR ip_address = p_ip)
    AND attempted_at > NOW() - (p_window_minutes || ' minutes')::INTERVAL;
    
    RETURN attempt_count < p_max_attempts;
END;
$$ LANGUAGE plpgsql;

-- 13. Cleanup old audit logs (keep 90 days)
CREATE OR REPLACE FUNCTION cleanup_old_audit_logs()
RETURNS void AS $$
BEGIN
    DELETE FROM audit_log WHERE created_at < NOW() - INTERVAL '90 days';
    DELETE FROM failed_login_attempts WHERE attempted_at < NOW() - INTERVAL '7 days';
END;
$$ LANGUAGE plpgsql;

-- 14. Set password encryption
ALTER SYSTEM SET password_encryption = 'scram-sha-256';

-- 15. Connection logging
ALTER SYSTEM SET log_connections = on;
ALTER SYSTEM SET log_disconnections = on;

-- 16. Statement logging for debugging (disable in production for performance)
-- ALTER SYSTEM SET log_statement = 'all';

-- Reload configuration
SELECT pg_reload_conf();

COMMENT ON TABLE audit_log IS 'Audit trail for all critical database changes';
COMMENT ON TABLE user_sessions IS 'Active user sessions with token hashes';
COMMENT ON TABLE failed_login_attempts IS 'Failed login attempts for rate limiting';

