# Codex Analysis

## Estado General

La documentacion ha mejorado respecto a la revision anterior, sobre todo por
la incorporacion de los ADR `0020` a `0025`. Esos ADR cubren varias decisiones
funcionales que antes estaban poco definidas.

Sin embargo, los problemas principales del scaffold y de la alineacion entre
documentacion y estado real del repositorio siguen pendientes. El proyecto
Flutter existe ya, pero varios documentos todavia describen el repositorio como
si no estuviera scaffolded.

## Ya Cubierto

- Los ADR `0020` a `0025` existen y estan indexados en
  `docs/adr/README.md`.
- Se han definido mejor estas decisiones:
  - favoritos remotos desaparecidos: no borrado silencioso y
    `lastCheckOk = false`;
  - historial reciente: limite FIFO de 50 elementos;
  - controles de reproduccion en background: solo Play, Pause y Stop;
  - lista fija de mirrors HTTPS: DE, AT, NL y FR;
  - parsing de Icy metadata con el primer separador `" - "`;
  - transicion offline: `Buffering -> Error`.
- Estos cambios se han propagado parcialmente a:
  - `API_SPEC.md`;
  - `ROADMAP.md`;
  - `TECHNICAL_SPEC.md`;
  - `TESTING_STRATEGY.md`;
  - `VALIDATION_CHECKLIST.md`;
  - `TODO.md`.

## Sigue Pendiente

### Documentacion Operativa Desactualizada

- `README.md` sigue diciendo que el proyecto Flutter no esta scaffolded.
- `AGENTS.md` sigue diciendo que el repositorio contiene solo documentos.
- `MEMORY.md` mantiene como tarea actual presentar la estrategia Phase 1 RED,
  aunque el repo ya contiene un scaffold Flutter y nuevos ADR.
- `MEMORY.md` contiene una errata menor: `metatada` en la entrada de ADR-0024.

### Scaffold Flutter No Conforme

- `pubspec.yaml` usa `labhouse_davidruiz_radio_app`, pero ADR-0003 exige
  `radio_app`.
- Android sigue usando `com.example...` en:
  - `android/app/build.gradle.kts`;
  - `android/app/src/main/kotlin/.../MainActivity.kt`.
- Siguen existiendo plataformas fuera de scope:
  - `web/`;
  - `macos/`;
  - `linux/`;
  - `windows/`.
- Esas plataformas contradicen ADR-0001, que limita el target a Android e iOS.

### UI Demo Todavia Presente

- `lib/main.dart` contiene la app contador por defecto de Flutter.
- Esto incluye `MaterialApp`, `Scaffold`, `ThemeData`, layout y styling.
- Aunque venga de `flutter create`, choca con el bloqueo de UI antes de tener
  especificaciones visuales.

### Faltan Elementos Obligatorios De Fase 1

- `config/app.json`.
- `.github/workflows/ci.yml`.
- `lefthook.yml`.
- Estructura Clean Architecture bajo `lib/`.
- `core/network/dio_client.dart`.
- `core/constants/` con los mirrors definidos en ADR-0023.

### Dependencias Y Analisis Estatico

- `analysis_options.yaml` sigue usando `flutter_lints`, no
  `very_good_analysis`.
- `pubspec.yaml` sigue sin las 13 dependencias productivas y 7 dependencias dev
  definidas en ADR-0018.
- `flutter analyze` pasa, pero no demuestra cumplimiento con la politica real
  de `very_good_analysis`.

### Configuracion Nativa Incompleta

Android sigue pendiente de:

- permiso `INTERNET`;
- bloqueo portrait;
- `minSdk = 23`;
- `targetSdk = 34`;
- `compileSdk = 34`;
- `applicationId = com.labhouse.davidruizassessment.radioapp`;
- registro de `audio_service`.

iOS sigue pendiente de:

- `CFBundleIdentifier = com.labhouse.davidruizassessment.radioapp`;
- bloqueo portrait estricto;
- `NSAppTransportSecurity`;
- `NSAllowsArbitraryLoads`;
- background audio mode.

Actualmente `ios/Runner/Info.plist` sigue permitiendo landscape.

## Inconsistencias Nuevas Menores

- ADR-0022 dice que `TECHNICAL_SPEC.md` se actualizo para reflejar las
  restricciones de controles background, pero la fila de `RadioPlayerBloc` aun
  no lo menciona explicitamente.
- ADR-0025 dice que `ROADMAP.md` Phase 7 se actualizo con testing tasks, pero
  Phase 7 solo mantiene una referencia generica a playback failure; no lista
  explicitamente el caso offline `Buffering -> Error`.
- En ADR-0025 hay enlaces relativos como `docs/adr/0013...` dentro de
  `docs/adr/`, que probablemente resolverian mal desde ese archivo.

## Verificacion Ejecutada

- `flutter analyze`: pasa con la configuracion actual.
- `flutter test`: pasa, pero solo ejecuta el test demo del contador.

Estas verificaciones no prueban cumplimiento con la arquitectura acordada,
porque el proyecto todavia usa `flutter_lints`, dependencias por defecto y el
test demo generado por Flutter.

## Recomendacion

Antes de empezar a programar funcionalidad, conviene hacer una correccion de
estado y preparar de nuevo la Fase 1 RED:

1. Actualizar `MEMORY.md`, `README.md`, `AGENTS.md` y `ROADMAP.md` para reflejar
   que ya existe un scaffold Flutter no conforme.
2. Decidir si se regenera el proyecto con el comando canonico o si se repara el
   scaffold actual.
3. Reescribir la estrategia Phase 1 RED para comprobar incumplimientos reales
   del scaffold actual, no la ausencia de infraestructura.
4. Empezar Phase 1 RED solo despues de aprobacion explicita.
