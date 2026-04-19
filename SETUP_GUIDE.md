# Section App — Complete Setup Guide

## 🗄️ Supabase Setup

### Step 1 — Create Project
1. Go to [supabase.com](https://supabase.com) → New Project
2. Name: `section-app` | Region: `eu-central-1` (closest to Egypt)

### Step 2 — Run SQL
1. Dashboard → **SQL Editor** → **New Query**
2. Paste the entire contents of `SUPABASE_SQL.sql`
3. Click **Run**

### Step 3 — Create Storage Buckets
Dashboard → **Storage** → **New Bucket** (make each **Public**):

| Bucket Name     | Use                    |
|-----------------|------------------------|
| `avatars`       | User profile photos    |
| `products`      | Product images         |
| `study-resources` | PDFs, notes, books  |
| `chat-files`    | Chat attachments       |
| `post-images`   | Community post images  |

### Step 4 — Enable Realtime
Dashboard → **Database** → **Replication** → Enable for:
- `chat_messages` (INSERT)
- `community_posts` (INSERT, UPDATE)
- `post_comments` (INSERT)

### Step 5 — Auth Settings
Dashboard → **Authentication** → **URL Configuration**:
- Site URL: your app's URL or `section://callback`
- Redirect URLs: add `section://callback`

---

## 🔥 Firebase Setup

### Step 1 — Create Project
1. [console.firebase.google.com](https://console.firebase.google.com)
2. Create project → name `section-app`

### Step 2 — Android App
- Package: `com.section.app`
- Download `google-services.json` → place in `android/app/`

### Step 3 — iOS App
- Bundle ID: `com.section.app`
- Download `GoogleService-Info.plist` → place in `ios/Runner/`

### Step 4 — Enable Services
- **Authentication** → Email/Password + Google Sign-In
- **Cloud Messaging** → note Server Key
- **Analytics** → Enable

### Step 5 — Android build.gradle
```gradle
// android/build.gradle
dependencies { classpath 'com.google.gms:google-services:4.4.0' }

// android/app/build.gradle
apply plugin: 'com.google.gms.google-services'
minSdkVersion 21
```

### Step 6 — Uncomment Firebase in Code
In `lib/main.dart`, uncomment:
```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// In main():
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
```

In `lib/core/services/notification_service.dart`, uncomment all `// TODO: Uncomment after Firebase` lines.

---

## 💳 Paymob Setup

Your credentials are already configured in `app_config.dart`.

### What to do:
1. Login at [accept.paymob.com](https://accept.paymob.com)
2. Go to **Developers → iFrames** → Create iFrame → copy the ID
3. Update `AppConfig.paymobIframeId` with your iFrame ID
4. Test with Visa test card: `4987654321098769`, CVV: `123`, Date: `12/25`

---

## 📱 Install Fonts

Download from Google Fonts and place in `assets/fonts/`:
- **Cairo**: [fonts.google.com/specimen/Cairo](https://fonts.google.com/specimen/Cairo)
  - `Cairo-Regular.ttf` (weight 400)
  - `Cairo-SemiBold.ttf` (weight 600)
  - `Cairo-Bold.ttf` (weight 700)
- **Lora**: [fonts.google.com/specimen/Lora](https://fonts.google.com/specimen/Lora)
  - `Lora-Regular.ttf` (weight 400)
  - `Lora-Bold.ttf` (weight 700)

---

## 🔐 Security Before GitHub

The `.gitignore` already excludes `app_config.dart`. Before pushing:
1. `lib/core/config/app_config.dart` → **excluded** ✅
2. `android/app/google-services.json` → **excluded** ✅
3. `ios/GoogleService-Info.plist` → **excluded** ✅

Use `app_config.example.dart` as the safe template.

---

## 🚀 Run the App

```bash
cd section_app
flutter pub get
flutter run
```

## App Flow
1. Splash (animated logo)
2. Language selection (Arabic default)
3. 4-slide onboarding with your Lottie animations
4. Login / Register
5. Profile setup (3 steps: avatar → faculty/year → university)
6. Main app with 5 tabs: Home, Store, Community, Study, AI

---

## 🔔 Notification Setup (Android)

Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```
