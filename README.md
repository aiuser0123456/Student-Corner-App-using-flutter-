# Student Corner — Flutter App

A Flutter mobile port of your **Student Corner** Next.js website. It connects to
the **same Firebase project** (Firestore `resources`/`users` collections) so
content stays in sync with your website.

## What's included

- Email/password authentication (sign up, log in, forgot password)
- Browse / search / filter resources by category, subject, class, stream
- Resource detail screen with markdown content + in-app PDF viewer
- Save/bookmark resources (stored on-device)
- AI Tools screen — works with **your own** Gemini, OpenAI, or OpenRouter API
  key, switchable in Settings, with direct links to each provider's key page
- Admin screen to list/delete resources (see **Important note on Admin** below)
- GitHub Actions CI workflow (analyze, test, build debug APK)

## What's NOT included / needs your attention

1. **Firebase config.** `lib/firebase_options.dart` is a placeholder. Run:
   ```
   dart pub global activate flutterfire_cli
   cd student_corner
   flutterfire configure
   ```
   Sign in with the same Google account/project your website uses. This also
   registers the Android/iOS app and downloads `google-services.json` for you.

2. **`google-services.json`** is excluded (it's project-specific and shouldn't
   be committed). `flutterfire configure` places it automatically. For CI, add
   its full contents as a GitHub Actions secret named `GOOGLE_SERVICES_JSON`
   (Settings → Secrets and variables → Actions).

3. **Admin writes use a different path than your website.** Your website's
   admin actions (`src/app/admin/actions.ts`) write to Firestore using the
   **Firebase Admin SDK from a server action**, authenticated by a service
   account — this bypasses client security rules entirely. Your deployed
   `firestore.rules` (copied into this project for reference) only allow a
   *client* to write `resources` if their auth token has a **custom claim**
   `isAdmin: true`. Nothing in your current codebase sets that claim on a
   user's Firebase Auth token (the `isAdmin` field on the `users` Firestore
   document is separate, and is read-only display info in this app).
   To make the Flutter admin screen actually write successfully, you'll need
   a Cloud Function (e.g. triggered on a Firestore `users` update) that calls
   `admin.auth().setCustomUserClaims(uid, { isAdmin: true })`. Until then, the
   in-app Admin screen will likely get permission-denied errors on add/edit —
   it's included as a working UI/Firestore-wiring scaffold, with this caveat
   surfaced directly in the screen.

4. **AI features were re-implemented**, not ported. Your website's AI flows
   (`src/ai/flows/*`) run server-side via Genkit. Flutter has no equivalent
   server runtime, so the app instead calls Gemini/OpenAI/OpenRouter directly
   from the device using the student's own API key (entered in AI Settings).
   Prompts and behavior are not feature-identical to your Genkit flows.

5. **iOS project is minimal.** Only `Info.plist` is included — a full Xcode
   project (`.pbxproj`, schemes, workspace) isn't something that can be
   reliably hand-written outside Xcode. Easiest path: after `flutterfire
   configure`, run `flutter create .` once inside `student_corner/` on a Mac
   with Xcode installed; it will regenerate the full `ios/` folder, and
   `flutterfire configure` will then wire in `GoogleService-Info.plist`.
   GitHub Actions' free Linux runners also can't build/sign iOS apps — that
   needs a `macos-latest` runner plus an Apple Developer signing setup.

6. **Google Sign-In was intentionally left out** per your request — only
   email/password is wired up.

## Running locally

```
cd student_corner
flutter pub get
flutterfire configure        # one-time, see above
flutter run
```

## GitHub Actions

`.github/workflows/flutter-ci.yml` runs on every push/PR to `main`:
- `flutter analyze`
- `flutter test`
- builds a debug APK and uploads it as a workflow artifact

Add the `GOOGLE_SERVICES_JSON` secret (see point 2 above) so the Android
build step succeeds.

## Project structure

```
student_corner/
├── lib/
│   ├── models/          # Resource, AppUser — mirror your TS types
│   ├── services/        # Firebase Auth/Firestore, AI providers, local storage
│   ├── providers/        # App state (Provider package)
│   ├── screens/          # auth, home, resources, saved, ai_tools, settings, admin
│   ├── widgets/          # ResourceCard, filter sheet
│   ├── theme/            # Colors/typography ported from your globals.css
│   ├── firebase_options.dart   # PLACEHOLDER — replace via flutterfire configure
│   ├── auth_gate.dart
│   ├── root_shell.dart   # bottom navigation
│   └── main.dart
├── android/
├── ios/                  # minimal — see note 5 above
├── test/
├── firestore.rules        # copied from your website, for reference
├── storage.rules
├── pubspec.yaml
└── .github/workflows/flutter-ci.yml
```
