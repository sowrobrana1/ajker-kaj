# Ajker Kaj

Bangla daily planner app (Flutter). Home dashboard with today's tasks and
progress, calendar, reminders and profile tabs, plus an add-task dialog.

The app code lives in `app_main.dart` (kept at the repo root so the build
workflow can scaffold a standard Flutter project around it). The workflow
`.github/workflows/build-apk.yml` runs `flutter create`, copies
`app_main.dart` to `lib/main.dart`, and builds a release APK.
