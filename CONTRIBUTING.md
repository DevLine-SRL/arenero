# Cómo contribuir — Arenero

Equipo grande sobre un mismo sprint. Estas reglas existen para que nadie
pierda una tarde resolviendo conflictos de merge.

Las reglas de código están en `AGENTS.md` y en `docs/convenciones/`. Este
documento cubre el flujo de trabajo.

## Ramas

Una rama por tarea, partiendo de `main` actualizado:

```bash
git checkout main
git pull
git checkout -b feat/36-register-client
```

Nombre: `<tipo>/<numero-de-tarea>-<slug-en-ingles>`.

Tipos: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`.

No se trabaja directo sobre `main`.

## Commits

Conventional Commits, en inglés, siguiendo el historial existente:

```
feat(sellers): add account filter
feat(db): add create seller edge function
```

Formato: `<tipo>(<ámbito>): <qué hace, en imperativo>`

- Ámbitos en uso: `auth`, `sellers`, `clients`, `products`, `sales`, `db`,
  `router`, `shared`, `core`.
- Asunto en minúsculas, sin punto final, máximo 50 caracteres.
- Cuerpo solo cuando el "por qué" no es obvio. Explica la razón, no el
  cambio: el diff ya dice qué cambió.
- Un commit hace una cosa. Si necesitas "y" en el asunto, son dos commits.

## Cómo se parte un feature entre dos personas

El caso típico: una historia de usuario con cinco tareas repartidas entre dos
personas, todas sobre `lib/features/<x>/`. Sin acuerdo previo ambos crean el
mismo modelo, el mismo datasource y el mismo repositorio, y el merge es un
desastre.

Procedimiento:

**1. Contratos primero, en un PR pequeño y solo.** Quien tome la primera
tarea abre un PR que contiene únicamente:

```
domain/entities/<x>.dart
domain/repositories/<x>_repository.dart
data/models/<x>_model.dart
data/datasources/<x>_remote_datasource.dart
```

La interfaz del repositorio y la del datasource declaran **todos** los
métodos que el feature necesitará, incluidos los de las tareas de la otra
persona. Los contratos son un acuerdo, no un avance de trabajo.

**2. Ese PR se mergea antes de que nadie escriba interfaz de usuario.**

**3. A partir de ahí, archivos disjuntos.** Cada quien crea sus casos de uso,
sus providers y sus widgets, con nombres que incluyen la operación
(`create_client_form_provider.dart`, `edit_client_dialog.dart`). Nadie edita
los archivos del otro.

### Reparto vigente: módulo de clientes

Historia #22 "Gestión de clientes".

| Archivo | Responsable |
|---|---|
| `domain/entities/client.dart` | Jhunior — contratos |
| `domain/repositories/clients_repository.dart` | Jhunior — contratos |
| `data/models/client_model.dart` | Jhunior — contratos |
| `data/datasources/clients_remote_datasource.dart` | Jhunior — contratos |
| `data/repositories/clients_repository_impl.dart` | Jhunior — contratos |
| `domain/usecases/create_client_usecase.dart` | Jhunior — #36 |
| `domain/usecases/search_clients_usecase.dart` | Jhunior — #37 |
| `presentation/**/create_client_*` | Jhunior — #36, #40 |
| `presentation/**/clients_search_*` | Jhunior — #37 |
| `domain/usecases/update_client_usecase.dart` | Alejandro — #38 |
| `domain/usecases/set_client_active_usecase.dart` | Alejandro — #39 |
| `presentation/**/edit_client_*` | Alejandro — #38 |
| `presentation/**/deactivate_client_*` | Alejandro — #39 |

`presentation/pages/clients_page.dart` y
`presentation/providers/clients_providers.dart` los tocan ambos. Cambios de
una o dos líneas cada vez; avisa en el grupo antes de tocarlos.

## Archivos compartidos

Los toca todo el equipo. Cambios mínimos y aviso previo:

| Archivo | Qué se le agrega |
|---|---|
| `lib/core/router/route_paths.dart` | Una constante de ruta y una de nombre |
| `lib/core/router/route_definitions.dart` | Una línea con el branch del feature |
| `lib/core/layouts/sidebar.dart` | Un destino de menú |
| `lib/core/layouts/bottom_nav_bar.dart` | Un ítem de navegación |
| `pubspec.yaml` | Dependencias — consúltalo con el equipo antes |

La convención de rutas (cada feature declara su branch en
`presentation/routes.dart`) existe justamente para que
`route_definitions.dart` sea una línea por módulo.

## Migraciones en paralelo

Los archivos llevan timestamp y son independientes: dos personas pueden crear
migraciones a la vez sin conflicto de texto. Lo que hay que coordinar es el
orden de aplicación. Si tu migración depende de una tabla que crea otra
persona, espera a que la suya esté en `main`.

Nunca edites una migración que ya está en `main`.

## Antes de abrir un PR

```bash
dart format lib test
dart run build_runner build --delete-conflicting-outputs   # si tocaste providers
flutter analyze
flutter test
```

Los cuatro tienen que pasar. Los `.g.dart` regenerados se commitean.

Además:

- Rebase sobre `main` actualizado antes de pedir revisión.
- Descripción del PR: qué tarea de Taiga cierra y cómo probarlo.
- Si tocaste `supabase/`, di explícitamente que hay que correr
  `npm run supabase:deploy` después del merge.

## Después de hacer pull

Si el pull trae cambios en `supabase/`:

```bash
npm run supabase:deploy
```

Si trae cambios en `pubspec.yaml`:

```bash
flutter pub get
```
