# Análisis de Especificaciones Pre-Implementación (Actualizado)

> **Ámbito:** Análisis de discrepancias y lagunas en el corpus de documentación y planificación tras la incorporación de los ADRs 0026–0029 y la alineación de documentos.
> **Fecha:** 2026-05-29

---

## 1. Evaluación General

Con las últimas actualizaciones, el corpus documental (14 documentos principales + 29 ADRs) se encuentra en un estado sumamente robusto y cohesionado. Se han resuelto las principales inconsistencias operativas previas:
* Se ha indexado correctamente la totalidad de los ADRs en `docs/adr/README.md`.
* Los conteos de ADRs (29) y características diferidas (21) en `README.md` son coherentes con `TODO.md` y el log de `MEMORY.md`.
* El roadmap (`ROADMAP.md`) y la estrategia de pruebas (`TESTING_STRATEGY.md`) reflejan fielmente el diseño de descarte de peticiones concurrentes y el comportamiento offline.

No obstante, un análisis riguroso de cara al inicio de la fase de codificación (Phase 1) revela un número reducido de aspectos técnicos y de configuración nativa que aún requieren definición contractual o aclaración técnica para evitar fricciones durante el desarrollo TDD.

---

## 2. Puntos Críticos y Brechas Identificadas

### 2.1. Tránsito de Tráfico en Texto Plano (HTTP) en Android
* **Problema:** Gran parte de las emisoras de radio comunitarias de la API de Radio Browser todavía emiten mediante URLs con protocolo `http://` en lugar de `https://`. Por defecto, a partir de Android 9 (API 28), el sistema operativo bloquea todo el tráfico en texto plano.
* **Estado Actual:** `ARCHITECTURE.md` §"Native Platform Configuration" (Android) exige permisos de `INTERNET` y bloqueo de orientación, pero no menciona la configuración de tráfico HTTP. En cambio, en iOS sí se define correctamente `NSAllowsArbitraryLoads` y `NSAppTransportSecurity`.
* **Impacto:** Si no se define contractualmente, las emisoras con streaming HTTP fallarán silenciosamente en Android.
* **Recomendación:** Agregar una regla obligatoria en la sección de Android de `ARCHITECTURE.md` para incluir `android:usesCleartextTraffic="true"` en la etiqueta `<application>` de `AndroidManifest.xml`.

### 2.2. Estrategia de Paginación: Fin de Lista y Deduplicación en `StationsBloc`
* **Problema:** En el scroll infinito de emisoras (paginado de 30 en 30), existen dos escenarios típicos de carrera:
  1. **Fin de lista:** Qué ocurre cuando la API devuelve una página vacía o con menos de 30 elementos.
  2. **Deduplicación:** Si la popularidad o los clics de una emisora cambian entre peticiones de página, una emisora podría aparecer en la página `N` y nuevamente en la página `N+1`.
* **Estado Actual:** Las especificaciones indican un tope de `STATIONS_MAX_LIMIT=100`, pero no detallan cómo debe reaccionar el BLoC y el repositorio ante el fin de resultados o datos duplicados.
* **Recomendación:** Definir contractualmente que:
  * El repositorio o el BLoC debe deduplicar emisoras usando como clave única su `stationuuid`.
  * `StationsBloc` debe transicionar o mantener un flag `hasReachedMax` para evitar peticiones redundantes una vez que la API devuelva menos elementos del límite por página.

### 2.3. Resolución de Nombres de Países Localizados vía `intl`
* **Problema:** `API_SPEC.md` §6.3 establece que el asistente `country_name_resolver` debe usar el paquete `intl` para resolver nombres de países legibles a partir del código ISO retornado por `/countrycodes`. Sin embargo, el paquete `intl` estándar de Dart no provee traducciones ni mapeos integrados de códigos de país a nombres localizados (como sí lo hace con fechas o monedas).
* **Estado Actual:** Hay una discrepancia de diseño. Para cumplir con el contrato, el desarrollador se vería obligado a incluir un mapeo estático de países o una dependencia externa no registrada en el ADR-0018.
* **Recomendación:** Clarificar en el asistente si se utilizará un mapa estático local para los países requeridos o si se debe enmendar el ADR-0018 para dar cabida a una dependencia de geolocalización/países (por ejemplo, `flutter_country_names` o similar).

---

## 3. Estado del Scaffold Flutter y Alineación de Fase 1

Actualmente, el repositorio cuenta con el código por defecto de una plantilla de Flutter (`hello world` / app contador) que presenta las siguientes disconformidades con respecto al diseño aprobado:
1. **Identificadores:** El nombre del paquete Dart en `pubspec.yaml` es `labhouse_davidruiz_radio_app` en lugar de `radio_app` (violando ADR-0003).
2. **Plataformas en Scope:** Existen las carpetas `web`, `macos`, `linux` y `windows`, lo que contradice el límite estricto de Android e iOS (ADR-0001).
3. **Restricción de UI:** `lib/main.dart` contiene lógica visual de widgets de Material, themes y layouts, lo que entra en conflicto con el bloqueo estricto de generación de UI antes de recibir las especificaciones visuales.
4. **Análisis Estático:** El archivo `analysis_options.yaml` apunta a `flutter_lints` y no a la suite estricta de `very_good_analysis` requerida.

---

## 4. Conclusión

El estado actual del diseño documental es óptimo y está listo en un **95%** para iniciar la implementación de pruebas y codificación. Las brechas restantes son menores y fáciles de solventar mediante una rápida enmienda o adición de reglas de configuración:
1. Añadir el soporte de texto plano (`usesCleartextTraffic`) para Android.
2. Definir la regla de deduplicación y fin de lista en la paginación.
3. Clarificar la estrategia de resolución de nombres de países.

Una vez aprobada esta alineación, la Fase 1 RED podrá iniciarse con absoluta precisión sobre los fallos reales del scaffold actual.
