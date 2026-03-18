# Vault Secrets - Ancien Projet PadelHouse (vslisxnahktqaifdurcu)

## service_role_key (ANCIEN PROJET - NE PAS RÉUTILISER TEL QUEL)
Ce secret est lié à l'ancien projet. Pour le nouveau projet, récupérer la 
service_role_key depuis : Dashboard > Settings > API > service_role key

### Commande SQL pour insérer dans le Vault du NOUVEAU projet :
```sql
SELECT vault.create_secret(
  '<NOUVELLE_SERVICE_ROLE_KEY>',
  'service_role_key',
  'Service role key for edge function calls'
);
```

## Secrets Edge Functions à configurer :
- **RESEND_API_KEY** : Clé API Resend pour l'envoi d'emails (utilisée par send-otp-email et send-email-notification)
- **FIREBASE_SERVICE_ACCOUNT** : JSON du service account Firebase (utilisé par send-push-notification)

## Edge Functions - Configuration JWT :
| Function | verify_jwt |
|----------|-----------|
| send-otp-email | false |
| send-push-notification | true |
| reservation-reminder | false |
| send-email-notification | false |
| seed-app-images | true |
| bypass-otp | false |
