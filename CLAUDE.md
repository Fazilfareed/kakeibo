# Kakeibo app — project notes

The source of truth is `Kakeibo_PRD_Architecture.md` (v1.2). When a skill's general advice conflicts with the PRD, follow the PRD.

## Installed skills (`.claude/skills/`)
- `ui-ux-pro-max` (nextlevelbuilder, MIT): design system, UX rules, `--stack flutter` guidance. Run it as `python .claude/skills/ui-ux-pro-max/scripts/search.py ...` from the project root. Save the design system with `--persist --output-dir .` into `design-system/kakeibo/MASTER.md`.
- Official Flutter team skills (flutter/agent-plugins, BSD-3): architecture, responsive layout, layout fixes, go_router routing, localization, widget/integration/unit tests, static analysis, runtime error fixes.

## Design system
`design-system/kakeibo/MASTER.md` defines every colour, type, spacing, motion and component token. Read it before building any screen, and run its section 13 checklist before calling a screen done. `design-system/kakeibo/preview.html` is a visual reference with light/dark mockups of the dashboard and quick-add sheet.

## PRD decisions that override skill defaults
- State management: **Riverpod** (not the `ChangeNotifier`/`provider` MVVM used in the Flutter architecture skill). Keep its layering idea: UI → domain → data.
- Folders: **feature-first** (`lib/features/<feature>/{data,domain,presentation}`), as in PRD §10.3.
- Mocks: **mocktail** (not mockito). Models: **freezed + json_serializable**. DB: **Drift**.
- Visual style: calm, Japanese-minimal, paper-like, light and dark (PRD §8). No glassmorphism, no landing-page patterns. This is an app, not a website.
- Offline only: no `http` package, no network permission, no deep-link domains.
- Money is always integer minor units (LKR cents). Currency is **LKR** and displays as `Rs` by default. Always format through `MoneyFormatter`, which applies the user's symbol format (FR-109). Never hard-code `Rs`, `₹` or any symbol in widgets.
- Icons: **Material Symbols Rounded** only (`package:material_symbols_icons/symbols.dart`, `Symbols.*_rounded`), with `fill: 1` for selected states. Never use emoji as icons. Don't use `phosphor_flutter`: it's abandoned and breaks on Flutter 3.47. The mood tag may show emoji *alongside* a text label.

## Build & run (Windows, this PC)
- Flutter SDK: `F:\dev\flutter` · JDK 17: `F:\dev\jdk-17` · Gradle cache: `F:\dev\gradle` (`GRADLE_USER_HOME`) · Android SDK: `%LOCALAPPDATA%\Android\Sdk` (platform 36, build-tools 36, NDK 28.2).
- Phone: Infinix X6812 (Android 11), device id `072952518G001312`. `flutter build apk --debug`, then `adb -s 072952518G001312 install -r build/app/outputs/flutter-apk/app-debug.apk`. Don't use `flutter install`: it uninstalls first, which wipes the app's data on the phone.
- `android/gradle.properties` is sized for this 8 GB RAM PC (Gradle 2.5 GB, Kotlin 1.5 GB) and turns off `kotlin.incremental`, because the project (F:) and pub cache (C:) are on different drives. Don't raise those limits.
- After changing Drift tables: `dart run build_runner build --delete-conflicting-outputs`.
- Widget tests must not use a real SQLite database (its I/O never completes in fake-async). Override `pillarsProvider`/`settingsProvider` with `Stream.value(...)`, as in `test/widget_test.dart`. Database logic is tested in `test/core/db/` with `NativeDatabase.memory()`.

## Git
- Commit as **Fazilfareed <fazilfrd9@gmail.com>** (personal account, set in this repo's local config). The PC's global git identity is a work account. Never use it or change it here. Push only to a remote on the personal GitHub account.
