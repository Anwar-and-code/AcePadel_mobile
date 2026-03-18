-- ============================================================================
-- DATA EXPORT — PadelHouse (vslisxnahktqaifdurcu) → AcePadel (qxauriiupckwouucmgkr)
-- Exported: 2026-03-18
-- EXCLUDES: profiles, profile_permissions, reservations, reservation_payments,
--           notification_logs, fcm_tokens, reclamations, otp_codes, abonnements,
--           client_packages, client_package_sessions (toutes liées aux users)
-- ============================================================================

-- ────────────────────────────────────────────────────────────────────────────
-- 1. TERRAINS (4 rows)
-- ────────────────────────────────────────────────────────────────────────────
INSERT INTO public.terrains (id, code, is_active, created_at) VALUES
  (1, '1', true, '2026-01-12 00:24:59.739406+00'),
  (2, '2', true, '2026-01-12 00:24:59.739406+00'),
  (3, '3', true, '2026-01-12 00:24:59.739406+00'),
  (4, '4', true, '2026-01-12 00:24:59.739406+00')
ON CONFLICT (id) DO NOTHING;

SELECT setval('terrains_id_seq', (SELECT COALESCE(MAX(id), 0) FROM public.terrains));

-- ────────────────────────────────────────────────────────────────────────────
-- 2. TIME_SLOTS (13 rows)
-- ────────────────────────────────────────────────────────────────────────────
INSERT INTO public.time_slots (id, start_time, end_time, price, is_active, created_at) VALUES
  (1,  '08:00:00', '09:00:00', 20000, true, '2026-01-18 12:01:32.178636+00'),
  (2,  '09:00:00', '10:00:00', 20000, true, '2026-01-18 12:01:32.178636+00'),
  (3,  '10:00:00', '11:00:00', 20000, true, '2026-01-18 12:01:32.178636+00'),
  (4,  '11:00:00', '12:00:00', 20000, true, '2026-01-18 12:01:32.178636+00'),
  (5,  '12:00:00', '13:00:00', 20000, true, '2026-01-18 12:01:32.178636+00'),
  (6,  '13:00:00', '14:00:00', 20000, true, '2026-01-18 12:01:32.178636+00'),
  (7,  '14:00:00', '15:00:00', 20000, true, '2026-01-18 12:01:32.178636+00'),
  (8,  '15:00:00', '16:00:00', 20000, true, '2026-01-18 12:01:32.178636+00'),
  (9,  '16:00:00', '17:30:00', 30000, true, '2026-01-18 12:01:32.178636+00'),
  (10, '17:30:00', '19:00:00', 30000, true, '2026-01-18 12:01:32.178636+00'),
  (11, '19:00:00', '20:30:00', 30000, true, '2026-01-18 12:01:32.178636+00'),
  (12, '20:30:00', '22:00:00', 30000, true, '2026-01-18 12:01:32.178636+00'),
  (13, '22:00:00', '23:30:00', 30000, true, '2026-01-18 12:01:32.178636+00')
ON CONFLICT (id) DO NOTHING;

SELECT setval('time_slots_id_seq', (SELECT COALESCE(MAX(id), 0) FROM public.time_slots));

-- ────────────────────────────────────────────────────────────────────────────
-- 3. EXPENSE_TYPES (9 rows)
-- ────────────────────────────────────────────────────────────────────────────
INSERT INTO public.expense_types (id, name, description, is_active, created_at) VALUES
  (1, 'Électricité', 'Factures d''électricité', true, '2026-01-18 16:05:29.97936+00'),
  (2, 'Eau', 'Factures d''eau', true, '2026-01-18 16:05:29.97936+00'),
  (3, 'Maintenance', 'Réparations et entretien des terrains', true, '2026-01-18 16:05:29.97936+00'),
  (4, 'Équipement', 'Achat de raquettes, balles, filets', true, '2026-01-18 16:05:29.97936+00'),
  (5, 'Salaires', 'Paiement des employés', true, '2026-01-18 16:05:29.97936+00'),
  (6, 'Loyer', 'Loyer du local', true, '2026-01-18 16:05:29.97936+00'),
  (7, 'Marketing', 'Publicité et promotion', true, '2026-01-18 16:05:29.97936+00'),
  (8, 'Fournitures', 'Fournitures de bureau et consommables', true, '2026-01-18 16:05:29.97936+00'),
  (9, 'Autres', 'Autres dépenses', true, '2026-01-18 16:05:29.97936+00')
ON CONFLICT (id) DO NOTHING;

SELECT setval('expense_types_id_seq', (SELECT COALESCE(MAX(id), 0) FROM public.expense_types));

-- ────────────────────────────────────────────────────────────────────────────
-- 4. PAYMENT_METHODS (4 rows)
-- ────────────────────────────────────────────────────────────────────────────
INSERT INTO public.payment_methods (id, name, is_active, display_order, created_at, updated_at) VALUES
  (1, 'Espèce',      true, 1, '2026-02-05 11:15:23.040495+00', '2026-02-05 11:15:23.040495+00'),
  (2, 'Wave',         true, 2, '2026-02-05 11:15:23.040495+00', '2026-02-05 11:15:23.040495+00'),
  (3, 'Orange Money', true, 3, '2026-02-05 11:15:23.040495+00', '2026-02-05 11:15:23.040495+00'),
  (4, 'Carte',        true, 4, '2026-02-05 11:15:23.040495+00', '2026-02-05 11:15:23.040495+00')
ON CONFLICT (id) DO NOTHING;

SELECT setval('payment_methods_id_seq', (SELECT COALESCE(MAX(id), 0) FROM public.payment_methods));

-- ────────────────────────────────────────────────────────────────────────────
-- 5. COACHES (3 rows)
-- ────────────────────────────────────────────────────────────────────────────
INSERT INTO public.coaches (id, first_name, last_name, phone, image_url, bio, is_active,
  price_1h_solo, price_1h30_solo, price_1h_duo, price_1h30_duo, price_1h_trio, price_1h30_trio,
  created_at, updated_at) VALUES
  ('d33cb0fe-21a9-45ba-b350-6970e1bbe86c', 'Mamadou', 'Diallo', '+221 77 123 45 67',
   'https://images.unsplash.com/photo-1568602471122-7832951cc4c5?w=400',
   'Coach certifié avec 5 ans d''expérience. Spécialiste du padel tactique.',
   true, 15000, 20000, 12000, 17000, 10000, 14000,
   '2026-01-29 21:13:24.89788+00', '2026-01-29 21:13:24.89788+00'),
  ('ab9d732c-917f-4526-8d16-36d03d25497c', 'Fatou', 'Ndiaye', '+221 78 234 56 78',
   'https://images.unsplash.com/photo-1594381898411-846e7d193883?w=400',
   'Ancienne joueuse professionnelle. Experte en technique et préparation physique.',
   true, 18000, 25000, 14000, 20000, 12000, 16000,
   '2026-01-29 21:13:24.89788+00', '2026-01-29 21:13:24.89788+00'),
  ('e48d2390-e19f-4407-8286-cae8155dea77', 'Ibrahima', 'Sow', '+221 76 345 67 89',
   'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
   'Coach débutants et intermédiaires. Pédagogie adaptée à tous les niveaux.',
   true, 12000, 17000, 10000, 14000, 8000, 11000,
   '2026-01-29 21:13:24.89788+00', '2026-01-29 21:13:24.89788+00')
ON CONFLICT (id) DO NOTHING;

-- ────────────────────────────────────────────────────────────────────────────
-- 6. EMPLOYEE_PROFILES (4 rows)
-- ────────────────────────────────────────────────────────────────────────────
INSERT INTO public.employee_profiles (id, name, display_name, description, base_route, hierarchy_level, is_system, created_at) VALUES
  ('00000000-0000-0000-0000-000000000001', 'admin',        'Administrateur', 'Accès total au système',                       '/',              1, true, '2026-02-25 03:31:58.342885+00'),
  ('00000000-0000-0000-0000-000000000002', 'gerant',       'Gérant',         'Gestion complète de l''établissement',          '/',              2, true, '2026-02-25 03:31:58.342885+00'),
  ('00000000-0000-0000-0000-000000000003', 'superviseur',  'Superviseur',    'Supervision des opérations quotidiennes',       '/reservations',  3, true, '2026-02-25 03:31:58.342885+00'),
  ('00000000-0000-0000-0000-000000000004', 'caissiere',    'Caissière',      'Gestion de la caisse et des réservations',      '/caisse',        4, true, '2026-02-25 03:31:58.342885+00')
ON CONFLICT (id) DO NOTHING;

-- ────────────────────────────────────────────────────────────────────────────
-- 7. EMPLOYEES (2 rows) — dépend de employee_profiles
-- ────────────────────────────────────────────────────────────────────────────
INSERT INTO public.employees (id, username, password_hash, full_name, role, is_active, last_login_at, created_at, updated_at, profile_id) VALUES
  ('ea5d6511-11cc-4be7-adab-01bdec1e3433', 'admin', '$2a$06$mLxzCMvmajVEw5XKyxkPaewiyhQ7CST.mhZ5Y9TZ8Is3lShU09a72',
   'Administrateur', 'admin', true, '2026-02-23 23:04:17.587348+00',
   '2026-01-18 14:00:35.760979+00', '2026-01-18 14:00:35.760979+00',
   '00000000-0000-0000-0000-000000000001'),
  ('f9882963-b700-4d4e-8f02-1e376a5718f8', 'wehbe', '$2a$06$6ZiJPnEW/15miwarpdfQRungMERU1neYPs7C.8g6eXnt0y8kWA4Oq',
   'Mohamed WEHBE', 'gerant', true, null,
   '2026-01-18 16:07:05.713847+00', '2026-01-18 16:07:05.713847+00',
   '00000000-0000-0000-0000-000000000002')
ON CONFLICT (id) DO NOTHING;

-- ────────────────────────────────────────────────────────────────────────────
-- 8. CLIENTS (20 rows) — données de test/opérationnelles
-- ────────────────────────────────────────────────────────────────────────────
INSERT INTO public.clients (id, full_name, phone, created_at, updated_at) VALUES
  ('f11bcc06-e17b-4337-8dd6-5e8a2b00c205', 'cxvxcvxcv',   '0758870532', '2026-01-25 23:54:38.942778+00', '2026-01-25 23:54:38.942778+00'),
  ('916fa6cc-1cb9-49bc-93aa-a49bcc3a2e32', 'xcxcv',        '0544444444', '2026-01-26 00:08:35.483635+00', '2026-01-26 00:08:35.483635+00'),
  ('93d27580-315f-452f-af41-196532d6ea92', 'asasdasd',     '0758778547', '2026-01-26 00:10:57.426076+00', '2026-01-26 00:10:57.426076+00'),
  ('efa3f969-ff0d-4852-b775-e072e7a45a09', 'drrewrwer',    '0158870532', '2026-01-26 00:18:21.543479+00', '2026-01-26 00:18:21.543479+00'),
  ('2687b7bd-369b-447b-b1a3-aaf67d43fc92', 'dfsdfs',       '0758756984', '2026-01-26 00:24:36.431676+00', '2026-01-26 00:24:36.431676+00'),
  ('5e8ea677-ed5c-4e25-b836-0322de2508f1', 'asdasdasd',    '0758000000', '2026-01-26 00:34:41.300058+00', '2026-01-26 00:34:41.300058+00'),
  ('0e383f70-573c-4e35-a385-22e9b620cf5a', 'test',         '0709090909', '2026-01-30 08:45:22.444805+00', '2026-01-30 08:45:22.444805+00'),
  ('d9337dd7-7adf-40b8-a7f5-0c1da7ce1cd8', 'uhuhuh',       '0777777777', '2026-02-03 11:48:38.125551+00', '2026-02-03 11:48:38.125551+00'),
  ('5bb36ff2-d82a-4b57-af91-a2ad92417dd3', 'test',         '0701010101', '2026-02-05 11:40:40.785951+00', '2026-02-05 11:40:40.785951+00'),
  ('0377aa60-ca02-4157-b65a-28a70916b036', 'Anwar SAFA',   '0702222220', '2026-02-22 16:53:29.963402+00', '2026-02-22 16:53:29.963402+00'),
  ('a177b76a-8eb2-4107-84be-08bd5d2e7eae', 'test',         '0102030404', '2026-02-22 17:04:58.232585+00', '2026-02-22 17:04:58.232585+00'),
  ('96829884-2ca1-440f-a933-482c7d04669b', 'test',         '0745787845', '2026-02-23 20:52:58.128614+00', '2026-02-23 20:52:58.128614+00'),
  ('b3707a1a-8115-4f52-891b-9b0603153d54', 'sdfsd',        '0758875222', '2026-02-23 22:32:23.704917+00', '2026-02-23 22:32:23.704917+00'),
  ('b8f27b08-caaf-4cdc-ae6b-5128ae912ca0', 'ssds',         '0705050505', '2026-02-25 01:28:03.794938+00', '2026-02-25 01:28:03.794938+00'),
  ('cc988767-4ff8-4f36-bc93-5b4dd33ce95f', 'dffdg',        '0775887522', '2026-02-25 01:38:48.529857+00', '2026-02-25 01:38:48.529857+00'),
  ('3a9ff31a-2da4-4165-b5dd-ca708a5ee007', 'dfgdfgdf',     '0758787878', '2026-02-25 01:43:56.357791+00', '2026-02-25 01:43:56.357791+00'),
  ('415a0c46-fdc0-4dc0-b378-f568a26886de', 'ssdsd',        '0154444444', '2026-02-25 02:10:02.90287+00',  '2026-02-25 02:10:02.90287+00'),
  ('4456d602-73a0-40c4-8461-e468526f3871', 'dededed',      '0102658888', '2026-02-25 02:56:05.867349+00', '2026-02-25 02:56:05.867349+00'),
  ('815974e3-41e2-4873-8862-ac7f90d7bb80', 'rrrr',         '0745111111', '2026-02-25 13:11:42.519222+00', '2026-02-25 13:11:42.519222+00'),
  ('487768dc-568e-4e4f-bdfc-6cd90aff8e78', 'aaaaaa',       '0758870555', '2026-02-25 13:13:08.100401+00', '2026-02-25 13:13:08.100401+00')
ON CONFLICT (id) DO NOTHING;

-- ────────────────────────────────────────────────────────────────────────────
-- 9. APP_SETTINGS (1 row) — manual_reservation_user_id mis à NULL (référence profiles)
-- ────────────────────────────────────────────────────────────────────────────
INSERT INTO public.app_settings (
  id, business_name, business_phone, business_email, business_address,
  opening_time, closing_time, min_advance_booking, max_advance_booking,
  cancellation_deadline, currency, notifications_enabled, email_notifications,
  sms_notifications, manual_reservation_user_id, created_at, updated_at,
  security_code, default_tax_rate, otp_security_code
) VALUES (
  1, 'AcePadel', '07 99 99 88 88', 'info@acepadel.ci',
  'Treichville, Zone 3, Rue Cava',
  '08:00:00', '23:00:00', 1, 14, 24, 'FCFA',
  true, true, false,
  NULL, -- manual_reservation_user_id: lié à profiles, mis à NULL
  '2026-01-26 00:08:42.778063+00', '2026-01-26 00:08:42.778063+00',
  '0451373', '0.00', '045137'
) ON CONFLICT (id) DO NOTHING;

SELECT setval('app_settings_id_seq', (SELECT COALESCE(MAX(id), 0) FROM public.app_settings));

-- ────────────────────────────────────────────────────────────────────────────
-- 10. POS_CATEGORIES (4 rows)
-- ────────────────────────────────────────────────────────────────────────────
INSERT INTO public.pos_categories (id, name, icon, display_order, is_active, created_at) VALUES
  (1, 'Boissons chaudes',  'coffee',     1, true, '2026-02-22 03:22:05.517565+00'),
  (2, 'Boissons froides',  'cup-soda',   2, true, '2026-02-22 03:22:05.517565+00'),
  (3, 'Snacks',            'cookie',     3, true, '2026-02-22 03:22:05.517565+00'),
  (4, 'Accessoires Padel', 'circle-dot', 4, true, '2026-02-22 03:22:05.517565+00')
ON CONFLICT (id) DO NOTHING;

SELECT setval('pos_categories_id_seq', (SELECT COALESCE(MAX(id), 0) FROM public.pos_categories));

-- ────────────────────────────────────────────────────────────────────────────
-- 11. POS_PRODUCTS (22 rows) — dépend de pos_categories
-- ────────────────────────────────────────────────────────────────────────────
INSERT INTO public.pos_products (id, category_id, name, price, stock_quantity, is_active, created_at, updated_at, product_type, purchase_price, selling_price_ht, tax_rate, price_ttc) VALUES
  (1,  1, 'Café expresso',       500,  null, true, '2026-02-22 03:22:05.517565+00', '2026-02-22 03:22:05.517565+00', 'service', 0, 500,  '0.00', 500),
  (2,  1, 'Café crème',          750,  null, true, '2026-02-22 03:22:05.517565+00', '2026-02-22 03:22:05.517565+00', 'service', 0, 750,  '0.00', 750),
  (3,  1, 'Thé',                 500,  null, true, '2026-02-22 03:22:05.517565+00', '2026-02-22 03:22:05.517565+00', 'service', 0, 500,  '0.00', 500),
  (4,  1, 'Chocolat chaud',      750,  null, true, '2026-02-22 03:22:05.517565+00', '2026-02-22 03:22:05.517565+00', 'service', 0, 750,  '0.00', 750),
  (5,  1, 'Cappuccino',          1000, null, true, '2026-02-22 03:22:05.517565+00', '2026-02-22 03:22:05.517565+00', 'service', 0, 1000, '0.00', 1000),
  (6,  2, 'Eau minérale 50cl',   500,  null, true, '2026-02-22 03:22:05.517565+00', '2026-02-22 03:22:05.517565+00', 'service', 0, 500,  '0.00', 500),
  (7,  2, 'Eau minérale 1.5L',   1000, null, true, '2026-02-22 03:22:05.517565+00', '2026-02-22 03:22:05.517565+00', 'service', 0, 1000, '0.00', 1000),
  (8,  2, 'Coca-Cola',           750,  null, true, '2026-02-22 03:22:05.517565+00', '2026-02-22 03:22:05.517565+00', 'service', 0, 750,  '0.00', 750),
  (9,  2, 'Fanta',               750,  null, true, '2026-02-22 03:22:05.517565+00', '2026-02-22 03:22:05.517565+00', 'service', 0, 750,  '0.00', 750),
  (10, 2, 'Sprite',              750,  null, true, '2026-02-22 03:22:05.517565+00', '2026-02-22 03:22:05.517565+00', 'service', 0, 750,  '0.00', 750),
  (11, 2, 'Jus d''orange',       1000, null, true, '2026-02-22 03:22:05.517565+00', '2026-02-22 03:22:05.517565+00', 'service', 0, 1000, '0.00', 1000),
  (12, 2, 'Red Bull',            1500, null, true, '2026-02-22 03:22:05.517565+00', '2026-02-22 03:22:05.517565+00', 'service', 0, 1500, '0.00', 1500),
  (13, 3, 'Croissant',           500,  null, true, '2026-02-22 03:22:05.517565+00', '2026-02-22 03:22:05.517565+00', 'service', 0, 500,  '0.00', 500),
  (14, 3, 'Sandwich',            1500, null, true, '2026-02-22 03:22:05.517565+00', '2026-02-22 03:22:05.517565+00', 'service', 0, 1500, '0.00', 1500),
  (15, 3, 'Barre énergétique',   750,  null, true, '2026-02-22 03:22:05.517565+00', '2026-02-22 03:22:05.517565+00', 'service', 0, 750,  '0.00', 750),
  (16, 3, 'Chips',               500,  null, true, '2026-02-22 03:22:05.517565+00', '2026-02-22 03:22:05.517565+00', 'service', 0, 500,  '0.00', 500),
  (17, 3, 'Biscuits',            500,  null, true, '2026-02-22 03:22:05.517565+00', '2026-02-22 03:22:05.517565+00', 'service', 0, 500,  '0.00', 500),
  (18, 4, 'Boîte de balles (x3)',5000, 0,    true, '2026-02-22 03:22:05.517565+00', '2026-02-22 18:04:34.642+00',    'bien',    0, 5000, '0.00', 5000),
  (19, 4, 'Grip',                2000, null, true, '2026-02-22 03:22:05.517565+00', '2026-02-22 03:22:05.517565+00', 'bien',    0, 2000, '0.00', 2000),
  (20, 4, 'Surgrip',             1500, null, true, '2026-02-22 03:22:05.517565+00', '2026-02-22 03:22:05.517565+00', 'bien',    0, 1500, '0.00', 1500),
  (21, 4, 'Bandeau',             2500, -10,  true, '2026-02-22 03:22:05.517565+00', '2026-02-25 02:26:49.02+00',     'bien',    500, 2500, '0.00', 2500),
  (22, 4, 'Poignet éponge',      1500, null, true, '2026-02-22 03:22:05.517565+00', '2026-02-22 03:22:05.517565+00', 'bien',    0, 1500, '0.00', 1500)
ON CONFLICT (id) DO NOTHING;

SELECT setval('pos_products_id_seq', (SELECT COALESCE(MAX(id), 0) FROM public.pos_products));

-- ────────────────────────────────────────────────────────────────────────────
-- 12. POS_TABLES (2 rows)
-- ────────────────────────────────────────────────────────────────────────────
INSERT INTO public.pos_tables (id, name, capacity, position_x, position_y, shape, is_active, created_at) VALUES
  (1, '1', 2, 0, 0, 'round', true, '2026-02-22 18:03:41.505648+00'),
  (2, '2', 2, 0, 0, 'round', true, '2026-02-22 18:03:48.268178+00')
ON CONFLICT (id) DO NOTHING;

SELECT setval('pos_tables_id_seq', (SELECT COALESCE(MAX(id), 0) FROM public.pos_tables));

-- ────────────────────────────────────────────────────────────────────────────
-- 13. POS_CASH_REGISTER_SESSIONS (4 rows)
-- ────────────────────────────────────────────────────────────────────────────
INSERT INTO public.pos_cash_register_sessions (id, opened_by, closed_by, opening_amount, closing_amount, expected_amount, notes, opened_at, closed_at) VALUES
  (1, 'Administrateur', 'Administrateur', 50000, 50000,  50000,  null, '2026-02-22 03:37:14.513556+00', '2026-02-23 20:52:10.914+00'),
  (2, 'Administrateur', 'Administrateur', 50000, 224250, 224250, null, '2026-02-23 20:53:06.601255+00', '2026-02-25 04:46:41.61+00'),
  (3, 'Administrateur', 'Administrateur', 50000, 50000,  50000,  null, '2026-02-25 13:06:13.676926+00', '2026-03-07 02:00:31.871+00'),
  (4, 'Administrateur', null,             50000, null,    null,   null, '2026-03-07 02:20:25.817406+00', null)
ON CONFLICT (id) DO NOTHING;

SELECT setval('pos_cash_register_sessions_id_seq', (SELECT COALESCE(MAX(id), 0) FROM public.pos_cash_register_sessions));

-- ────────────────────────────────────────────────────────────────────────────
-- 14. EVENTS (6 rows) — URLs de storage mises à jour vers le nouveau projet
-- NOTE: Les images stockées dans event-images du ancien bucket ne sont PAS copiées.
--       Seules les URLs externes (unsplash) fonctionneront. Les images locales
--       devront être re-uploadées ou copiées manuellement.
-- ────────────────────────────────────────────────────────────────────────────
INSERT INTO public.events (id, title, subtitle, description, long_description, category, status,
  start_date, end_date, location, cover_image_url, is_featured, display_order, tags, price_info,
  is_free, created_by, created_at, updated_at, contact_phone) VALUES
  ('186236a4-043d-4223-b47f-477f110193cf', 'Nader Kojok', 'Enfoire', 'eded', 'eded',
   'TOURNOI', 'PUBLISHED', '2026-03-08 02:10:00+00', '2026-03-08 02:10:00+00',
   'AcePadel Club',
   'https://qxauriiupckwouucmgkr.supabase.co/storage/v1/object/public/event-images/1772849758796-6nbm2p8do86.jpg',
   false, 1, null, null, true, null,
   '2026-03-07 02:16:05.850633+00', '2026-03-07 02:17:08.604611+00', '+22507 99 99 88 88'),

  ('2fcaa588-cef7-4b6a-8735-e2b020bf163c', 'Tournoi Padel Master', 'Le plus grand tournoi de la saiso',
   'Venez assister au plus grand tournoi de padel de la saison ! Des matchs spectaculaires entre les meilleurs joueurs de la région.',
   'Le Tournoi Padel Masters est l''événement phare de notre club. Retrouvez les meilleurs joueurs de la région qui s''affronteront dans des matchs intenses et spectaculaires.\\n\\nAu programme :\\n- Matchs de qualification le matin\\n- Quarts de finale et demi-finales l''après-midi\\n- Grande finale en soirée\\n- Animations et restauration sur place\\n\\nVenez encourager vos joueurs favoris et profiter d''une ambiance unique !',
   'TOURNOI', 'PUBLISHED', '2026-03-15 09:00:00+00', '2026-03-15 18:00:00+00',
   'AcePadel Club - Courts 1 à 4',
   'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=800&q=80',
   false, 1, '{"compétition","spectacle","gratuit"}', 'Entrée libre', true, null,
   '2026-02-23 23:05:17.252981+00', '2026-03-07 02:09:34.674719+00', '+2250799998888'),

  ('56bb52d5-b07f-4a00-8233-a158b83283ea', 'Championnat Inter-Entreprises', 'Compétition entre entreprises',
   'Les entreprises de la région s''affrontent dans un tournoi de padel convivial. Venez supporter votre équipe !',
   'Le Championnat Inter-Entreprises est un événement unique qui réunit les entreprises locales autour du padel.\\n\\nFormat :\\n- Équipes de 4 joueurs par entreprise\\n- Phase de poules le matin\\n- Phases finales l''après-midi\\n- Remise des prix et cocktail\\n\\nUn événement parfait pour le team building et la compétition amicale !',
   'COMPETITION', 'PUBLISHED', '2026-04-05 08:00:00+00', '2026-04-05 17:00:00+00',
   'AcePadel Club - Tous les courts',
   'https://images.unsplash.com/photo-1526232761682-d26e03ac148e?w=400&q=80',
   false, 4, '{"entreprise","team-building","compétition"}', 'Sur invitation', true, null,
   '2026-02-23 23:05:17.252981+00', '2026-02-23 23:05:17.252981+00', '+2250799998888'),

  ('6293f439-a204-433f-a036-e1f5b8c987e9', 'tesy', 'yrdy', 'rtrt', 'rtrt',
   'SOCIAL', 'PUBLISHED', '2026-03-12 20:11:00+00', '2026-03-20 20:12:00+00',
   'AcePadel Club', null, false, 0, null, null, true, null,
   '2026-03-16 20:12:09.228129+00', '2026-03-16 20:12:29.817067+00', '+22507 99 99 88 88'),

  ('b26c1da6-a79c-4921-a9b7-83a64739fd61', 'Stage Perfectionnement Été', 'Améliorez votre jeu',
   'Stage intensif de 3 jours pour les joueurs intermédiaires souhaitant passer au niveau supérieur.',
   'Notre stage de perfectionnement est conçu pour les joueurs ayant déjà une base solide et souhaitant progresser.\\n\\nContenu du stage :\\n- Technique de frappe avancée\\n- Jeu de position\\n- Tactiques en double\\n- Analyse vidéo de vos matchs\\n- Matchs dirigés\\n\\nEncadré par nos coachs certifiés, ce stage vous fera franchir un cap dans votre pratique du padel.',
   'FORMATION', 'PUBLISHED', '2026-07-01 09:00:00+00', '2026-07-03 17:00:00+00',
   'AcePadel Club',
   'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&q=80',
   false, 5, '{"stage","intermédiaire","perfectionnement"}', '150€ / 3 jours', false, null,
   '2026-02-23 23:05:17.252981+00', '2026-02-23 23:05:17.252981+00', '+2250799998888'),

  ('dcf86836-29e4-471c-9b3d-08d473136570', 'Soirée Afterwork Padel', 'Détente entre collègues',
   'Après le travail, venez vous détendre autour de matchs de padel amicaux. Ambiance décontractée, musique et rafraîchissements.',
   'Chaque vendredi soir, le AcePadel Club se transforme en lieu de rencontre pour les amateurs de padel.\\n\\nAu programme :\\n- Matchs amicaux en rotation\\n- Musique d''ambiance\\n- Rafraîchissements offerts\\n- Networking entre passionnés\\n\\nUne soirée idéale pour décompresser et rencontrer de nouveaux partenaires de jeu !',
   'SOCIAL', 'PUBLISHED', '2026-03-22 18:00:00+00', '2026-03-22 21:00:00+00',
   'AcePadel Club',
   'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?w=400&q=80',
   true, 3, '{"afterwork","social","networking"}', 'Consommation sur place', true, null,
   '2026-02-23 23:05:17.252981+00', '2026-03-07 02:08:49.509389+00', '+2250799998888')
ON CONFLICT (id) DO NOTHING;

-- ────────────────────────────────────────────────────────────────────────────
-- 15. EVENT_IMAGES (6 rows) — dépend de events
-- ────────────────────────────────────────────────────────────────────────────
INSERT INTO public.event_images (id, event_id, image_url, caption, display_order, created_at) VALUES
  ('1859c1d9-acce-459c-9795-557d4a4d6be6', '186236a4-043d-4223-b47f-477f110193cf',
   'https://qxauriiupckwouucmgkr.supabase.co/storage/v1/object/public/event-images/1772849810566-x393ikz8uw.jpg',
   null, 0, '2026-03-07 02:16:52.708978+00'),
  ('e41cd412-b9a9-4641-8850-e2e2982d70b0', '2fcaa588-cef7-4b6a-8735-e2b020bf163c',
   'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=600&q=80',
   'Court principal du tournoi', 1, '2026-02-23 23:05:33.484023+00'),
  ('2c8c72fb-0c38-4067-b780-73bed823d3fa', '2fcaa588-cef7-4b6a-8735-e2b020bf163c',
   'https://images.unsplash.com/photo-1526232761682-d26e03ac148e?w=600&q=80',
   'Ambiance des matchs', 2, '2026-02-23 23:05:33.484023+00'),
  ('99a6524e-d8f3-4982-8087-67cfbd7362b3', '2fcaa588-cef7-4b6a-8735-e2b020bf163c',
   'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?w=600&q=80',
   'Remise des prix', 3, '2026-02-23 23:05:33.484023+00'),
  ('a9bad0b0-2746-4d43-8720-b3165de7c037', 'dcf86836-29e4-471c-9b3d-08d473136570',
   'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?w=600&q=80',
   'Ambiance afterwork', 1, '2026-02-23 23:05:33.484023+00'),
  ('bb1a160b-4813-4455-927b-f054412b4a12', 'dcf86836-29e4-471c-9b3d-08d473136570',
   'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=600&q=80',
   'Matchs amicaux', 2, '2026-02-23 23:05:33.484023+00')
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- FIN DE L'EXPORT DATA
-- ============================================================================
-- Tables exportées (15) :
--   terrains (4), time_slots (13), expense_types (9), payment_methods (4),
--   coaches (3), employee_profiles (4), employees (2), clients (20),
--   app_settings (1), pos_categories (4), pos_products (22), pos_tables (2),
--   pos_cash_register_sessions (4), events (6), event_images (6)
--
-- Tables NON exportées (liées aux profiles/users) :
--   profiles, profile_permissions, reservations, reservation_payments,
--   notification_logs, fcm_tokens, reclamations, otp_codes, abonnements,
--   client_packages, client_package_sessions
--
-- NOTE: 2 images dans event-images référencent le storage du nouveau projet
--   mais les fichiers n'existent peut-être pas encore. Il faudra les copier
--   manuellement ou les re-uploader depuis le dashboard.
--
-- NOTE: app_settings.business_name changé de "Padel House" → "AcePadel"
--       app_settings.business_email changé de "info@padelhouse.ci" → "info@acepadel.ci"
--       app_settings.manual_reservation_user_id mis à NULL
--       locations des events changées de "PadelHouse Club" → "AcePadel Club"
-- ============================================================================
