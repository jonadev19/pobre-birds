# Repository Guidelines

## Project Structure & Module Organization
- `lib/main.dart` wires Flame + Forge2D, registers components, and is the starting point for new scenes or overlays.
- `lib/components/` hosts discrete gameplay pieces (player, enemies, ground, parallax background). Keep shared mixins/utilities in `body_component_with_user_data.dart`.
- Platform shells (`android`, `ios`, `macos`, `linux`, `web`, `windows`) only hold runner configs; touch them only when changing native plugins.
- All art, audio, and fonts live under `assets/` and are declared in `pubspec.yaml`; drop derived sprites inside `assets/images/` and keep source files in `assets/raw/` (create if missing) for clarity.
- Temporary scripts belong in `bin/` or `paypal_server/` if they serve backend callbacks.

## Build, Test, and Development Commands
- `flutter pub get` synchronizes dependencies; run after editing `pubspec.yaml`.
- `flutter run -d macos` (or any device ID) launches the game locally with hot reload.
- `flutter build web --release` produces the distributable bundle under `build/web/`.
- `flutter analyze` runs static analysis with `flutter_lints`.
- `flutter test` executes widget/unit suites; add `--coverage` to refresh `coverage/lcov.info`.

## Coding Style & Naming Conventions
- Use `dart format .` before committing; the project sticks to default 2-space indentation and 80-column soft wrap.
- Components, systems, and files use snake_case; classes use PascalCase; Flame layers stay in UpperCamelCase suffixes like `*Component`.
- Keep constructor parameters ordered as `{world, assets, config}` for predictable DI, mirroring existing components.

## Testing Guidelines
- Prefer small `test/*.dart` files that mirror the component under test (e.g., `player_test.dart`), using `flutter_test` plus Flame’s test harness.
- For physics-heavy pieces, pair integration checks in `test/forge2d/` with golden tests stored in `test/golden/`.
- Strive for coverage on new logic and document tricky setups with inline comments and TODOs referencing issues.

## Commit & Pull Request Guidelines
- Follow the imperative summary style seen in the log: `component: describe change`.
- Reference tickets with `Closes #id` in the body and list any follow-up tasks.
- PRs must describe gameplay impact, include before/after screenshots or recordings when visuals change, and paste the verification commands used.
