# devportal-external

The **external** developer portal (Flutter Web) — third-party developers browse
the API catalog, register apps, get keys, try APIs live, and see their usage.
Phase-1 **clickable mock**: real UI on in-memory fixtures, no live backend yet.

Cinematic dark theme · **Bloc/Cubit + clean architecture** · `go_router`.

## Run it

```bash
flutter pub get
flutter run -d chrome
```

The shared design system + data layer comes from
[`devportal_shared`](../devportal-flutter-shared) (local `path:` dependency).

### Data source

Selected at build time; only `mock` is wired today (live lands in Phase 4):

```bash
flutter run -d chrome --dart-define=DATA_SOURCE=mock
```

## The happy path (all clickable on mock data)

`Home (hero + carousels)` → `Catalog (search/filter)` → `Product detail`
(Overview · Documentation · **Try it** console) → `Sign in` (stubbed SSO /
ForgeRock) → `My apps` → `Register app` (auto-approve public, queue restricted)
→ `App detail` (reveal/copy keys, products, **usage analytics**).

Demo sign-in needs no credentials — click **Continue with SSO**.

## Structure

```
lib/
  main.dart · app.dart            Composition root + MaterialApp.router
  di/        app_dependencies.dart   Picks mock vs live data source
  routing/   app_router.dart, app_shell.dart, go_router_refresh.dart
  auth/      AuthCubit (ForgeRock OIDC stub) + sign-in
  features/
    catalog/ cubits + pages (home, catalog, product detail) + try-it console
    apps/    cubits + pages (dashboard, register, app detail) + credential field
  utils/ · widgets/               Formatting + ContentWrap
```

Each route owns a Cubit; pages read repositories from the interfaces in
`devportal_shared`. Swapping to the live backend touches only the data layer.

## Verify

```bash
flutter analyze   # clean
flutter test      # smoke test renders home from mock data
flutter build web # compiles
```
