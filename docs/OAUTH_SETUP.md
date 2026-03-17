# Configuration OAuth - Google & Microsoft

Ce guide explique comment configurer l'authentification OAuth avec Google (Gmail) et Microsoft (Outlook) pour AcePadel.

## Prérequis

- **Google Sign-In** : Utilise le package `google_sign_in` pour une authentification native via **Google Play Services** (popup natif au lieu du navigateur)
- **Microsoft Sign-In** : Utilise le flow OAuth web via Supabase

---

## 1. Configuration Supabase Dashboard

### Étape 1: Accéder aux paramètres d'authentification

1. Connectez-vous à [Supabase Dashboard](https://supabase.com/dashboard)
2. Sélectionnez votre projet AcePadel
3. Allez dans **Authentication** → **Providers**

### Étape 2: Ajouter l'URL de redirection

1. Allez dans **Authentication** → **URL Configuration**
2. Dans **Redirect URLs**, ajoutez:
   ```
   io.acepadel.app://auth-callback
   ```

---

## 2. Configuration Google OAuth (Google Play Services)

L'authentification Google utilise le **Google Sign-In natif** via Google Play Services, offrant une meilleure expérience utilisateur (popup natif au lieu du navigateur).

### Étape 1: Créer un projet Google Cloud

1. Allez sur [Google Cloud Console](https://console.cloud.google.com/)
2. Créez un nouveau projet ou sélectionnez un existant
3. Activez l'API **Google Identity Services**

### Étape 2: Configurer l'écran de consentement OAuth

1. Allez dans **APIs & Services** → **OAuth consent screen**
2. Choisissez **External** (pour les utilisateurs externes)
3. Remplissez les informations:
   - **App name**: AcePadel
   - **User support email**: votre email
   - **Developer contact**: votre email
4. Ajoutez les scopes: `email`, `profile`, `openid`
5. Publiez l'application (passez en Production)

### Étape 3: Créer les identifiants OAuth

Vous devez créer **3 types de Client ID** :

#### A. Web Client ID (obligatoire pour Supabase)
1. **APIs & Services** → **Credentials** → **Create Credentials** → **OAuth client ID**
2. Type: **Web application**
3. Nom: `AcePadel Web`
4. **Authorized redirect URIs**: `https://<VOTRE_PROJECT_REF>.supabase.co/auth/v1/callback`
5. Copiez le **Client ID** → c'est votre `GOOGLE_WEB_CLIENT_ID`

#### B. Android Client ID
1. **Create Credentials** → **OAuth client ID**
2. Type: **Android**
3. Nom: `AcePadel Android`
4. **Package name**: `com.armasoft.acepadel`
5. **SHA-1 certificate fingerprint**: 
   ```bash
   # Debug (développement)
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   
   # Release (production)
   keytool -list -v -keystore <votre-keystore.jks> -alias <votre-alias>
   ```
6. Copiez le SHA-1 et collez-le

#### C. iOS Client ID (si vous ciblez iOS)
1. **Create Credentials** → **OAuth client ID**
2. Type: **iOS**
3. Nom: `AcePadel iOS`
4. **Bundle ID**: `io.acepadel.app`
5. Copiez le **Client ID** → c'est votre `GOOGLE_IOS_CLIENT_ID`

### Étape 4: Configurer les variables d'environnement

Ajoutez dans votre fichier `.env` :
```env
GOOGLE_WEB_CLIENT_ID=xxxxx.apps.googleusercontent.com
GOOGLE_IOS_CLIENT_ID=xxxxx.apps.googleusercontent.com
```

### Étape 5: Activer Google dans Supabase

1. Dans Supabase Dashboard → **Authentication** → **Providers**
2. Trouvez **Google** et activez-le
3. Collez le **Web Client ID** et **Client Secret** (du Web Client)
4. **Important**: Activez **Skip nonce check** (nécessaire pour iOS)
5. Sauvegardez

---

## 3. Configuration Microsoft OAuth (Azure AD)

### Étape 1: Enregistrer l'application dans Azure

1. Allez sur [Azure Portal](https://portal.azure.com/)
2. Recherchez **Azure Active Directory**
3. Allez dans **App registrations** → **New registration**
4. Remplissez:
   - **Name**: AcePadel
   - **Supported account types**: Accounts in any organizational directory and personal Microsoft accounts
   - **Redirect URI**: Web → `https://<VOTRE_PROJECT_REF>.supabase.co/auth/v1/callback`
5. Cliquez sur **Register**

### Étape 2: Configurer les identifiants

1. Copiez l'**Application (client) ID**
2. Allez dans **Certificates & secrets** → **New client secret**
3. Créez un secret et copiez sa **Value** (visible une seule fois!)

### Étape 3: Configurer les permissions API

1. Allez dans **API permissions**
2. Ajoutez les permissions Microsoft Graph:
   - `email`
   - `openid`
   - `profile`
   - `User.Read`
3. Cliquez sur **Grant admin consent** si nécessaire

### Étape 4: Activer Azure dans Supabase

1. Dans Supabase Dashboard → **Authentication** → **Providers**
2. Trouvez **Azure** et activez-le
3. Collez:
   - **Azure Tenant URL**: `https://login.microsoftonline.com/common` (pour tous les comptes)
   - **Client ID**: votre Application ID
   - **Client Secret**: votre secret
4. Sauvegardez

---

## 4. Configuration de l'application

### Deep Links (déjà configurés)

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:scheme="io.acepadel.app"
        android:host="auth-callback" />
</intent-filter>
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>io.acepadel.app</string>
        </array>
    </dict>
</array>
```

---

## 5. Test

1. Lancez l'application: `flutter run`
2. Sur l'écran de connexion, cliquez sur **Continuer avec Google** ou **Continuer avec Microsoft**
3. Le navigateur s'ouvre pour l'authentification
4. Après connexion, l'utilisateur est redirigé vers l'app

---

## Dépannage

### Erreur "redirect_uri_mismatch"
- Vérifiez que l'URL de callback dans Google/Azure correspond exactement à celle de Supabase

### L'app ne se rouvre pas après authentification
- Vérifiez la configuration des deep links dans AndroidManifest.xml et Info.plist
- Sur Android, assurez-vous que `android:launchMode="singleTop"` est présent

### Erreur "invalid_client"
- Vérifiez que le Client ID et Secret sont corrects dans Supabase
- Pour Azure, vérifiez que le secret n'a pas expiré

---

## Fichiers modifiés

- `lib/core/services/auth_service.dart` - Méthodes `signInWithGoogle()` et `signInWithMicrosoft()`
- `lib/features/auth/screens/email_screen.dart` - Boutons OAuth et listener d'authentification
- `android/app/src/main/AndroidManifest.xml` - Deep link Android
- `ios/Runner/Info.plist` - URL scheme iOS
