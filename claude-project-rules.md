# 📜 Dalili — Project Rules & Flutter Guidelines

## 🛠 Development Environment

- **Always use FVM**: Never run global flutter commands.
- **SDK**: `fvm use 3.41.9` — no exceptions.
- **Commands**: `fvm flutter pub get` | `fvm flutter run` | `fvm dart format .`
- **VS Code**: Set `.fvm/flutter_sdk` as Flutter SDK path in workspace settings.

---

## 🏛 Architecture (Clean Architecture)

- Layer order: `presentation` → `domain` → `data`
- **Domain**: Pure Dart only — zero external imports.
- **Single Responsibility**: Every class has exactly one job.
- **DI**: `GetIt` (`sl`) for all resolution. Never instantiate Cubits or Repos manually.
- **Repositories**: Throw `Failure` subclasses on error — no `Either`, no `dartz`.

---

## 🌍 Localization

- Use `flutter_localizations` + `intl` package with `.arb` files.
- Two locales: `ar` (Arabic, RTL) and `en` (English, LTR).
- **Never hardcode strings** in widget files — always use `S.current.keyName`.
- Expose all keys through a static `AppLocalizations` wrapper class:
  ```dart
  // Usage everywhere:
  AppLocalizations.searchHint         // NOT AppLocalizations.of(context).searchHint
  AppLocalizations.bookNotFound
  ```
- `AppLocalizations` internally holds a static `AppLocalizations _current` instance
  updated whenever locale changes via `AppSettingsCubit`.
- ARB files live at: `lib/l10n/intl_ar.arb` and `lib/l10n/intl_en.arb`
- Generated files go to: `lib/generated/`
- `lang` param sent with every Dio request via base interceptor — reads from
  `sl<AppSettingsCubit>().state.locale.languageCode`
- `isbn` is a plain string field on `Book` — display only when not empty

---

## 🎨 Theme

- **No hardcoded colors or styles anywhere in widget files.**
- All colors via `Theme.of(context).colorScheme` or `context.appColors` extension.
- All text styles via `Theme.of(context).textTheme` or `context.appTextStyles` extension.
- Define a `AppThemeExtension` that implements `ThemeExtension<AppThemeExtension>`.
- `ThemeData` is built once in `AppTheme` class and registered in `MaterialApp`.
- Light theme only for now — dark theme slot ready but not implemented.
- **Two fonts** (add to `pubspec.yaml` under `flutter.fonts`):
  - `Tajawal` — headlines (`headline-xl`, `headline-lg`, `headline-md`)
  - `Almarai` — body and labels (`body-lg`, `body-md`, `label-md`, `caption`)
- Font files at `assets/fonts/` — declared in pubspec but not embedded yet (placeholder).
- **Color tokens from DESIGN.md** mapped to `ColorScheme` + `AppThemeExtension`:

```
primary:                #041627
secondary:              #0058bc
secondary-container:    #0070eb
surface:                #f8f9ff
surface-container-low:  #eff4ff
surface-container:      #e5eeff
surface-container-high: #dce9ff
on-surface:             #0b1c30
on-surface-variant:     #44474c
outline:                #74777d
outline-variant:        #c4c6cd
error:                  #ba1a1a
```

- Border radius tokens:
  - `sm`: 4px | `md`: 12px | `lg`: 16px | `xl`: 24px | `full`: 9999px

- Spacing tokens (expose via `AppSpacing` static class):
  - `containerMargin`: 20 | `gutter`: 16 | `stackSm`: 8 | `stackMd`: 16 | `stackLg`: 24

---

## 📦 Packages

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0

  # State Management
  flutter_bloc: ^9.1.1
  hydrated_bloc: ^11.0.0
  equatable: ^2.0.8

  # DI
  get_it: ^9.2.1

  # Networking
  dio: ^5.8.0+1

  # Env
  flutter_dotenv: ^5.2.1

  # Scanner
  mobile_scanner: ^7.0.0

  # Image
  cached_network_image: ^3.4.1

  # URL
  url_launcher: ^6.3.1

  # Sensors (AR compass)
  sensors_plus: ^6.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  intl_utils: ^2.8.7
```

---

## 🧠 State Management (HydratedCubit)

- **All cubits extend `HydratedCubit`** — never plain `Cubit`.
- Single state class per cubit with status enum + `copyWith`.
- Never use abstract subclasses for states.
- `fromJson` always resets `status` to `initial` — never restore loading/error.
- `toJson` only persists data fields — never status or error messages.
- Emit always via `state.copyWith(...)` — never construct new state from scratch.

### Cubit inventory

| Cubit | Singleton/Factory | Persists |
|---|---|---|
| `AppSettingsCubit` | Singleton | `locale`, `themeMode`, `hasSeenOnboarding` |
| `DepartmentCubit` | Factory | `departments`, `booksByDepartment` |
| `SearchCubit` | Factory | `query`, `results`, `filter` |
| `ScannerCubit` | Factory | nothing |
| `BookDetailCubit` | Factory | `book`, `articles` |
| `FavoritesCubit` | Singleton | `favorites` (full `Book` list) |

---

## 🚀 Performance

- `const` constructors everywhere possible.
- No logic inside `build()` — all in Cubit.
- Controllers: init in `initState`, dispose in `dispose`.
- `cached_network_image` always — never `Image.network` directly.
- `IndexedStack` for bottom nav tabs — preserves state across tab switches.
- Departments list: `ListView.builder` — never `Column` with mapped children.
- Pagination: `NotificationListener<ScrollEndNotification>` for infinite scroll.

---

## ⚠️ Error Handling

- 4 UI states always: `initial`, `loading`, `success`/`empty`, `error`.
- Data layer: catch exceptions → wrap in `Failure` → rethrow.
- Presentation: Cubit catches `Failure` → emits error state.
- UI: shows Arabic/English message from `AppLocalizations` — never raw exceptions.
- Scanner not found → dedicated view (not SnackBar).
- Cover missing → `CoverPlaceholder` widget.
- Articles empty → `[]` never null.

---

## 📝 Code Style

- Files/folders: `snake_case` | Classes: `PascalCase` | Variables/methods: `camelCase`
- Imports: always `package:dalili/...` — never relative.
- `fvm dart format .` before every commit.
- `@override` always annotated.
- Public APIs always type-annotated.
- `AppLogger` only — never `print()`.

---

## 🗂 Linting

```yaml
analyzer:
  errors:
    always_use_package_imports: error
linter:
  rules:
    - prefer_final_fields
    - prefer_final_locals
    - prefer_const_constructors
    - prefer_expression_function_bodies
    - type_annotate_public_apis
    - always_use_package_imports
    - sort_constructors_first
    - annotate_overrides
    - avoid_print
```