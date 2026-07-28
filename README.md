# Arenero

## Requisitos

- Flutter SDK 3.12+
- Supabase project

## Ejecutar

```bash
flutter run \
  --dart-define=SUPABASE_URL='https://<project>.supabase.co' \
  --dart-define=SUPABASE_PUBLISHABLE_KEY='sb_publishable_<key>'
```

## Build

```bash
flutter build apk \
  --dart-define=SUPABASE_URL='https://<project>.supabase.co' \
  --dart-define=SUPABASE_PUBLISHABLE_KEY='sb_publishable_<key>'
```

## Generar código (Riverpod)

```bash
dart run build_runner build
```
