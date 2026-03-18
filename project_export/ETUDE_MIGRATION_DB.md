# Étude de Migration - Base de Données PadelHouse

**Projet source:** PadelHouse (`vslisxnahktqaifdurcu`)  
**Région:** eu-central-1  
**PostgreSQL:** 17.6.1  
**Date d'étude:** 2026-03-18

---

## 1. Vue d'ensemble

| Élément | Quantité |
|---------|----------|
| Tables publiques | 38 |
| Fonctions SQL | 20 |
| Triggers | 12 |
| RLS Policies | 68 |
| Enums custom | 4 |
| Extensions installées | 8 |
| Storage Buckets | 4 |
| Edge Functions | 6 |

---

## 2. Types Enum Custom

| Enum | Valeurs |
|------|---------|
| `user_role` | JOUEUR, GERANT, EMPLOYE |
| `reservation_status` | PENDING, CONFIRMED, CANCELED, EXPIRED, PAID |
| `event_status` | DRAFT, PUBLISHED, CANCELLED, COMPLETED |
| `event_category` | TOURNOI, FORMATION, SOCIAL, ANIMATION, COMPETITION, AUTRE |

---

## 3. Inventaire des Tables (38 tables public)

### 3.1 Tables de CONFIGURATION (structure + données à conserver)

| Table | Rows | Description | Action |
|-------|------|-------------|--------|
| `terrains` | 0 | Terrains de padel | ✅ Exporter structure |
| `time_slots` | 0 | Créneaux horaires | ✅ Exporter structure |
| `packages` | 1 | Forfaits disponibles | ✅ Exporter structure + données |
| `package_time_slots` | 0 | Créneaux par forfait | ✅ Exporter structure |
| `coaches` | 0 | Coachs | ✅ Exporter structure |
| `permissions` | 6 | Permissions système | ✅ Exporter structure + données |
| `employee_profiles` | 0 | Profils/rôles employés | ✅ Exporter structure |
| `employees` | 0 | Employés | ✅ Exporter structure |
| `payment_methods` | 0 | Méthodes de paiement | ✅ Exporter structure |
| `expense_types` | 0 | Types de dépenses | ✅ Exporter structure |
| `app_settings` | 0 | Paramètres app | ✅ Exporter structure |

### 3.2 Tables POS (structure uniquement - pas de données)

| Table | Rows | Description | Action |
|-------|------|-------------|--------|
| `pos_categories` | 0 | Catégories produits | ✅ Structure seule |
| `pos_products` | 0 | Produits POS | ✅ Structure seule |
| `pos_tables` | 0 | Tables restaurant | ✅ Structure seule |
| `pos_orders` | 0 | Commandes | ✅ Structure seule |
| `pos_order_items` | 0 | Items commandes | ✅ Structure seule |
| `pos_order_payments` | 0 | Paiements commandes | ✅ Structure seule |
| `pos_purchases` | 0 | Achats fournisseurs | ✅ Structure seule |
| `pos_purchase_orders` | 0 | Bons de commande | ✅ Structure seule |
| `pos_purchase_order_items` | 0 | Items bons commande | ✅ Structure seule |
| `pos_stock_movements` | 0 | Mouvements stock | ✅ Structure seule |
| `pos_cash_register_sessions` | 1 | Sessions caisse | ✅ Structure seule (vider données) |
| `pos_expenses` | 0 | Dépenses POS | ✅ Structure seule |
| `expenses` | 0 | Dépenses générales | ✅ Structure seule |

### 3.3 Tables liées aux UTILISATEURS (❌ VIDER les données)

| Table | Rows | Raison d'exclusion | Action |
|-------|------|---------------------|--------|
| `profiles` | 4 | FK → auth.users, données personnelles | ❌ Structure seule, vider données |
| `profile_permissions` | 71 | FK → profiles, liaisons user-specific | ❌ Structure seule, vider données |
| `fcm_tokens` | 14 | Tokens push user-specific | ❌ Structure seule, vider données |
| `otp_codes` | 0 | Codes OTP temporaires | ❌ Structure seule |
| `clients` | 0 | Clients (lié aux users) | ❌ Structure seule |
| `notification_logs` | 40 | Logs notifications envoyées | ❌ Structure seule, vider données |
| `reclamations` | 3 | FK → auth.users | ❌ Structure seule, vider données |

### 3.4 Tables TRANSACTIONNELLES (❌ VIDER les données)

| Table | Rows | Raison d'exclusion | Action |
|-------|------|---------------------|--------|
| `reservations` | 29 | FK → auth.users, données historiques | ❌ Structure seule, vider données |
| `reservation_payments` | 0 | FK → reservations | ❌ Structure seule |
| `client_packages` | 1 | FK → profiles | ❌ Structure seule, vider données |
| `client_package_sessions` | 0 | FK → client_packages | ❌ Structure seule |
| `abonnements` | 0 | FK → profiles | ❌ Structure seule |
| `events` | 2 | FK → auth.users (created_by) | ❌ Structure seule, vider données |
| `event_images` | 1 | FK → events | ❌ Structure seule, vider données |

---

## 4. Fonctions SQL (20)

### 4.1 Fonctions utilitaires (à conserver telles quelles)
- `is_gerant()` — Vérifie si l'user courant est GERANT
- `employee_has_permission()` — Vérifie permission d'un employé
- `hash_employee_password()` — Trigger: hash bcrypt des mots de passe
- `update_updated_at_column()` — Trigger: met à jour updated_at
- `update_coaches_updated_at()` — Trigger: updated_at coaches
- `update_events_updated_at()` — Trigger: updated_at events
- `update_user_gamification_updated_at()` — Trigger: updated_at gamification
- `update_client_package_sessions_count()` — Trigger: compteur sessions

### 4.2 Fonctions métier (à conserver)
- `get_available_slots(p_date)` — Créneaux disponibles par date
- `calculate_reservation_points()` — Calcul points fidélité
- `add_reservation_points()` — Ajout points après réservation
- `get_user_points()` — Points de l'utilisateur courant
- `verify_employee_login()` — Authentification employés
- `verify_employee_password()` — Vérification mdp (v1)
- `verify_employee_password_v2()` — Vérification mdp (v2)

### 4.3 Fonctions OTP (à conserver)
- `send_otp()` — Génère et stocke un OTP
- `verify_otp()` — Vérifie un code OTP

### 4.4 Fonctions notification ⚠️ CONTIENNENT URL HARDCODÉE
- `notify_event_published()` — ⚠️ URL hardcodée: `vslisxnahktqaifdurcu.supabase.co`
- `notify_reservation_confirmed()` — ⚠️ URL hardcodée: `vslisxnahktqaifdurcu.supabase.co`
- `get_service_role_key()` — Dépend de `vault.decrypted_secrets`

> **ACTION REQUISE:** Après import, remplacer `vslisxnahktqaifdurcu` par le nouveau project_id dans les 2 fonctions de notification.

---

## 5. Triggers (12)

| Trigger | Table | Event | Fonction |
|---------|-------|-------|----------|
| `reservations_updated_at` | reservations | BEFORE UPDATE | `update_updated_at_column()` |
| `trg_notify_reservation_confirmed` | reservations | AFTER INSERT/UPDATE | `notify_reservation_confirmed()` |
| `events_updated_at` | events | BEFORE UPDATE | `update_events_updated_at()` |
| `trg_notify_event_published` | events | AFTER INSERT/UPDATE | `notify_event_published()` |
| `coaches_updated_at_trigger` | coaches | BEFORE UPDATE | `update_coaches_updated_at()` |
| `trg_hash_employee_password` | employees | BEFORE INSERT/UPDATE | `hash_employee_password()` |
| `trg_update_package_sessions_count` | client_package_sessions | AFTER INSERT/UPDATE/DELETE | `update_client_package_sessions_count()` |

---

## 6. Extensions Installées

| Extension | Schema | Usage |
|-----------|--------|-------|
| `pgcrypto` | extensions | Hash bcrypt employés |
| `pg_net` | extensions | Appels HTTP (notifications) |
| `uuid-ossp` | extensions | Génération UUID |
| `pg_graphql` | graphql | API GraphQL Supabase |
| `pg_stat_statements` | extensions | Monitoring requêtes |
| `supabase_vault` | vault | Stockage secrets (service_role_key) |
| `pg_cron` | pg_catalog | Jobs planifiés |
| `plpgsql` | pg_catalog | Langage procédural |

> **Extensions critiques à activer sur le nouveau projet:** `pgcrypto`, `pg_net`, `uuid-ossp`

---

## 7. Storage Buckets

| Bucket | Action | Raison |
|--------|--------|--------|
| `avatars` | ❌ Recréer vide | Photos profil user-specific |
| `reclamations` | ❌ Recréer vide | Photos réclamations user-specific |
| `event-images` | ❌ Recréer vide | Images événements (historiques) |
| `app-assets` | ✅ Recréer + copier fichiers | Assets statiques de l'app |

---

## 8. Edge Functions (6)

| Fonction | JWT | Action |
|----------|-----|--------|
| `send-otp-email` | ❌ Non | ✅ Redéployer |
| `send-push-notification` | ✅ Oui | ✅ Redéployer |
| `reservation-reminder` | ❌ Non | ✅ Redéployer |
| `send-email-notification` | ❌ Non | ✅ Redéployer |
| `seed-app-images` | ✅ Oui | ✅ Redéployer |
| `bypass-otp` | ❌ Non | ✅ Redéployer |

> Les Edge Functions ne sont PAS incluses dans l'export SQL. Elles doivent être redéployées séparément.

---

## 9. RLS Policies (68 policies)

Toutes les policies sont incluses dans le script d'export. Points d'attention :
- Policies sur `profiles`, `events`, `terrains` utilisent `is_gerant()` → fonction doit exister avant
- Policies storage référencent `profiles.role` → la table profiles doit exister

---

## 10. Checklist Post-Import

1. [ ] Activer extensions: `pgcrypto`, `pg_net`, `uuid-ossp`
2. [ ] Exécuter le script SQL d'export
3. [ ] Remplacer l'ancien project_id dans les fonctions `notify_*`
4. [ ] Configurer le secret `service_role_key` dans Vault
5. [ ] Recréer les 4 storage buckets
6. [ ] Redéployer les 6 Edge Functions
7. [ ] Mettre à jour `.env` avec les nouvelles URL/clés Supabase
8. [ ] Configurer le SMTP email dans le dashboard
9. [ ] Configurer Google OAuth / Microsoft OAuth
10. [ ] Configurer pg_cron jobs si nécessaire
11. [ ] Tester les flux: inscription, réservation, notifications
