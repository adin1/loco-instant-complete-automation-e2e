-- ============================================================
-- SEED DEMO USERS pentru LOCO INSTANT
-- Rulează acest script după ce ai creat schema bazei de date
-- ============================================================

-- Parola pentru toți utilizatorii demo: "password123"
-- Hash bcrypt pentru "password123": $2b$10$rQZ8K.X9VjXHXHXHXHXHXuXHXHXHXHXHXHXHXHXHXHXHXHXHXHXHXH

-- Creează tenant-ul principal
INSERT INTO tenants (id, code, name, settings, created_at) 
VALUES (1, 'cluj', 'Cluj-Napoca', '{}', NOW())
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- CLIENȚI (Customers)
-- ============================================================

INSERT INTO users (id, tenant_id, email, password, name, phone, role, created_at, is_active) VALUES
(1, 1, 'client@test.ro', '$2b$10$EpRnTzVlqHNP0.fUbXUwSOyuiXe0JqSQB6I6X2mL1qsJvqyPVFNqy', 'Ion Popescu', '0721000001', 'customer', NOW(), true),
(2, 1, 'maria@test.ro', '$2b$10$EpRnTzVlqHNP0.fUbXUwSOyuiXe0JqSQB6I6X2mL1qsJvqyPVFNqy', 'Maria Ionescu', '0721000002', 'customer', NOW(), true),
(3, 1, 'alex@test.ro', '$2b$10$EpRnTzVlqHNP0.fUbXUwSOyuiXe0JqSQB6I6X2mL1qsJvqyPVFNqy', 'Alexandru Radu', '0721000003', 'customer', NOW(), true),
(4, 1, 'elena@test.ro', '$2b$10$EpRnTzVlqHNP0.fUbXUwSOyuiXe0JqSQB6I6X2mL1qsJvqyPVFNqy', 'Elena Munteanu', '0721000004', 'customer', NOW(), true),
(5, 1, 'adinatraica@gmail.com', '$2b$10$EpRnTzVlqHNP0.fUbXUwSOyuiXe0JqSQB6I6X2mL1qsJvqyPVFNqy', 'Adina Traica', '0721000005', 'customer', NOW(), true)
ON CONFLICT (email) DO UPDATE SET name = EXCLUDED.name, password = EXCLUDED.password;

-- ============================================================
-- PRESTATORI (Providers)
-- ============================================================

INSERT INTO users (id, tenant_id, email, password, name, phone, role, created_at, is_active) VALUES
-- Instalatori
(10, 1, 'instalator1@test.ro', '$2b$10$EpRnTzVlqHNP0.fUbXUwSOyuiXe0JqSQB6I6X2mL1qsJvqyPVFNqy', 'Vasile Mureșan', '0722000001', 'provider', NOW(), true),
(11, 1, 'instalator2@test.ro', '$2b$10$EpRnTzVlqHNP0.fUbXUwSOyuiXe0JqSQB6I6X2mL1qsJvqyPVFNqy', 'Florin Popa', '0722000002', 'provider', NOW(), true),
-- Electricieni
(12, 1, 'electrician1@test.ro', '$2b$10$EpRnTzVlqHNP0.fUbXUwSOyuiXe0JqSQB6I6X2mL1qsJvqyPVFNqy', 'Mihai Electricul', '0722000003', 'provider', NOW(), true),
(13, 1, 'electrician2@test.ro', '$2b$10$EpRnTzVlqHNP0.fUbXUwSOyuiXe0JqSQB6I6X2mL1qsJvqyPVFNqy', 'Dan Volt', '0722000004', 'provider', NOW(), true),
-- Curățenie
(14, 1, 'curatenie1@test.ro', '$2b$10$EpRnTzVlqHNP0.fUbXUwSOyuiXe0JqSQB6I6X2mL1qsJvqyPVFNqy', 'Maria Clean', '0722000005', 'provider', NOW(), true),
(15, 1, 'curatenie2@test.ro', '$2b$10$EpRnTzVlqHNP0.fUbXUwSOyuiXe0JqSQB6I6X2mL1qsJvqyPVFNqy', 'Ana Curățel', '0722000006', 'provider', NOW(), true),
-- Lăcătuși
(16, 1, 'lacatus1@test.ro', '$2b$10$EpRnTzVlqHNP0.fUbXUwSOyuiXe0JqSQB6I6X2mL1qsJvqyPVFNqy', 'Andrei Lăcătușul', '0722000007', 'provider', NOW(), true),
-- Transport
(17, 1, 'transport1@test.ro', '$2b$10$EpRnTzVlqHNP0.fUbXUwSOyuiXe0JqSQB6I6X2mL1qsJvqyPVFNqy', 'George Transport', '0722000008', 'provider', NOW(), true),
-- Zugrăveli
(18, 1, 'zugrav1@test.ro', '$2b$10$EpRnTzVlqHNP0.fUbXUwSOyuiXe0JqSQB6I6X2mL1qsJvqyPVFNqy', 'Dan Zugravu', '0722000009', 'provider', NOW(), true),
-- IT
(19, 1, 'it1@test.ro', '$2b$10$EpRnTzVlqHNP0.fUbXUwSOyuiXe0JqSQB6I6X2mL1qsJvqyPVFNqy', 'Radu TechFix', '0722000010', 'provider', NOW(), true),
-- Prestator test general
(20, 1, 'prestator@test.ro', '$2b$10$EpRnTzVlqHNP0.fUbXUwSOyuiXe0JqSQB6I6X2mL1qsJvqyPVFNqy', 'Prestator Demo', '0722000000', 'provider', NOW(), true)
ON CONFLICT (email) DO UPDATE SET name = EXCLUDED.name, password = EXCLUDED.password;

-- ============================================================
-- ADMIN
-- ============================================================

INSERT INTO users (id, tenant_id, email, password, name, phone, role, created_at, is_active) VALUES
(100, 1, 'admin@test.ro', '$2b$10$EpRnTzVlqHNP0.fUbXUwSOyuiXe0JqSQB6I6X2mL1qsJvqyPVFNqy', 'Admin LOCO', '0720000000', 'admin', NOW(), true)
ON CONFLICT (email) DO UPDATE SET name = EXCLUDED.name, password = EXCLUDED.password;

-- ============================================================
-- SERVICII pentru prestatori
-- ============================================================

INSERT INTO services (id, tenant_id, name, description, category, base_price, created_at) VALUES
(1, 1, 'Instalații sanitare', 'Reparații și instalații sanitare complete', 'Instalator', 80.00, NOW()),
(2, 1, 'Desfundare canalizare', 'Desfundare urgentă canalizări', 'Instalator', 100.00, NOW()),
(3, 1, 'Montaj centrale termice', 'Instalare și service centrale', 'Instalator', 300.00, NOW()),
(4, 1, 'Instalații electrice', 'Cablare și instalații complete', 'Electrician', 120.00, NOW()),
(5, 1, 'Reparații prize', 'Reparații prize și întrerupătoare', 'Electrician', 50.00, NOW()),
(6, 1, 'Tablouri electrice', 'Montaj și verificare tablouri', 'Electrician', 200.00, NOW()),
(7, 1, 'Curățenie generală', 'Curățenie completă apartament', 'Curățenie', 150.00, NOW()),
(8, 1, 'Curățenie după constructor', 'Curățenie specială post-renovare', 'Curățenie', 300.00, NOW()),
(9, 1, 'Deblocare ușă', 'Deblocare urgentă uși', 'Lăcătuș', 100.00, NOW()),
(10, 1, 'Mutări apartamente', 'Transport și mutări complete', 'Transport', 400.00, NOW()),
(11, 1, 'Zugrăvit interior', 'Zugrăveli interioare complete', 'Zugrăveli', 15.00, NOW()),
(12, 1, 'Reparații PC/Laptop', 'Diagnosticare și reparații', 'IT & Tech', 100.00, NOW())
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;

-- ============================================================
-- Asociere prestatori cu servicii
-- ============================================================

INSERT INTO provider_services (provider_id, service_id, price, is_active) VALUES
(10, 1, 80.00, true), (10, 2, 100.00, true), (10, 3, 300.00, true),
(11, 1, 90.00, true), (11, 2, 120.00, true),
(12, 4, 120.00, true), (12, 5, 50.00, true), (12, 6, 200.00, true),
(13, 4, 100.00, true), (13, 5, 45.00, true),
(14, 7, 150.00, true), (14, 8, 300.00, true),
(15, 7, 140.00, true), (15, 8, 280.00, true),
(16, 9, 100.00, true),
(17, 10, 400.00, true),
(18, 11, 15.00, true),
(19, 12, 100.00, true),
(20, 1, 85.00, true), (20, 4, 110.00, true), (20, 7, 145.00, true)
ON CONFLICT DO NOTHING;

-- Reset sequences
SELECT setval('users_id_seq', (SELECT MAX(id) FROM users));
SELECT setval('services_id_seq', (SELECT MAX(id) FROM services));

-- Verify
SELECT 'Utilizatori creați:' as info, count(*) as total FROM users;
SELECT role, count(*) as count FROM users GROUP BY role;

