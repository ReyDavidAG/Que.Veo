# Improve_design_functionaly.md

Auditoría de UX, diseño y funcionamiento de **cinemapedia**. Generada el 2026-08-08.
Este documento cataloga lo que falta, lo que está roto y lo que se puede mejorar — no es código, es
un mapa de ruta para las fases de implementación.

Las reglas de código del proyecto viven en [CLAUDE.md](CLAUDE.md); el sistema de diseño se
bloqueará en [DESIGN.md](DESIGN.md) cuando se implemente la fase 1.

---

## 1. Resumen ejecutivo

cinemapedia funciona: navega, carga películas, reproduce tráilers, persiste favoritos. Pero está
**a medio hacer** en cinco frentes:

| Frente | Estado | Prioridad |
|---|---|---|
| **Sistema de diseño** | No existe. Colores, espacios, animaciones hardcoded en cada widget | Crítica |
| **Estados de UI** | Solo `loading` y `data`. Faltan `empty` y `error` en casi todos los flujos | Crítica |
| **Favoritos** | Funciona, pero sin la pulpa que esperarías. Sin haptic, sin animación, sin doble-tap | Alta |
| **Utilidad para el usuario** | Descubrir, ver detalle, marcar favorito. Falta: compartir, ver dónde, continuar viendo, lista propia | Media |
| **Calidad de código** | Tiros vagos en nombres, hot-paths sin try/catch, repositorio de DB sin inyectar | Baja (regresión, no bloqueante) |

El usuario ya pidió 3 cosas explícitas:
- Favoritos **al estilo Instagram** (animación + haptic + doble-tap)
- **Auditoría** del diseño y la funcionalidad
- **Fases** para implementar las mejoras

---

## 2. Estado actual — mapa rápido

### Pantallas

| Pantalla | Carga | Vacío | Error | Animación | Notas |
|---|---|---|---|---|---|
| HomeView | ✅ FullScreenLoader | ❌ | ❌ | Fade slides | 4 secciones pre-cargan en `initState` |
| CategoriesView | ✅ CircularProgressIndicator | ❌ | ❌ | FadeInUp staggered | Grid de 2 columnas, género → MoviesByGenreScreen |
| FavoritesView | ✅ — | ❌ | ❌ | — | Lista masonry sin manera de quitar favorito |
| MoviesByGenreScreen | ✅ CircularProgressIndicator | ❌ Icono + texto | ❌ | FadeInUp staggered | Scroll infinito con blur background |
| MovieScreen | ✅ FullScreenLoader | ❌ | ❌ | FadeIn image | Vídeo YouTube inline, watch providers por país |
| ActorScreen | ✅ FullScreenLoader | ❌ | ❌ | FadeIn image | Bio scrollable, info chips |

### Providers (Riverpod)

| Provider | Lifecycle | Notas |
|---|---|---|
| `nowPlayingMoviesProvider`, `popularMoviesProvider`, etc. | App-scoped | `MoviesNotifier` con guard `isLoading` y delay 300ms |
| `similarMoviesProvider(id)`, `moviesByGenreProvider(id)` | App-scoped (family) | Mismo `MoviesNotifier` |
| `searchMoviesProvider`, `searchQueryProvider` | App-scoped | Sin historial de búsquedas |
| `favoriteMoviesProvider` | App-scoped | `Map<int, Movie>` |
| `isFavoriteInMemoryProvider(id)` | App-scoped | Lee del mapa en memoria |
| `isFavoriteMovieProvider(id)` | App-scoped | `FutureProvider.family` que pega a DB cada vez |
| `actorsProvider`, `actorDetailsProvider`, `actorMoviesProvider` | App-scoped | `Map<String, ...>` |
| `movieVideosProvider`, `watchProvidersProvider` | App-scoped | `Map<id, ...>` |
| `genreProvider` | App-scoped | Cachea si ya cargó |

### Capa de datos

- **Drift** para favoritos — tabla `FavoriteMovies` con 7 columnas
- **TMDB** vía `Dio` con `api_key` query + Bearer token
- Locale fijo `es-MX`
- Sin caché de red (cada `MovieScreen` reabre `dio.get`)
- Sin caché de imágenes consistente (`Image.network` vs `cached_network_image` mezclado)

---

## 3. Hallazgos detallados

### 3.1 Críticos — afectan funcionalidad

#### F-01 · Sin estados `empty` ni `error`

Cuatro pantallas devuelven `SizedBox.shrink()` cuando no hay datos y **ninguna** tiene retry. Los
errores de Dio se manifiestan como `FullScreenLoader` infinito.

```
lib/presentations/delegates/search_movies_delegate.dart:123   SizedBox.shrink en query vacía
lib/presentations/screens/movies/movie_screen.dart:521        SizedBox.shrink sin watch providers
lib/presentations/screens/movies/movie_screen.dart:548        SizedBox.shrink sin tabs
lib/presentations/widgets/movies/movies_slideshow.dart:23     SizedBox.shrink sin películas
```

Pantallas sin `error` widget:
`HomeView`, `MovieScreen`, `ActorScreen`, `CategoriesView`, `FavoritesView`, `MoviesByGenreScreen`.

#### F-02 · Favoritos sin la pulpa de Instagram

El toggle funciona, pero la interacción se siente plana:

- `IconButton` en el `SliverAppBar` — sin animación al cambiar
- Sin haptic feedback (`HapticFeedback.lightImpact()`)
- Sin doble-tap en el poster (gesto estrella de Instagram)
- Sin corazón flotante que sube (overlay IG-style)
- `MovieMasonry` no permite quitar favoritos de la lista
- `isFavoriteMovieProvider` golpea DB cada vez (ver F-08)

#### F-03 · Diseño no existe como sistema

`AppTheme.getTheme()` es `ColorScheme.fromSeed(Colors.blueAccent)` — el resto de la app ignora
`colorScheme` y dibuja su propio degradado (`Color(0xFF0E1427)`, `Color(0xFF121A34)`,
`Color(0xFF16213E)`) a mano en cada widget. Resultado:

- Imposible cambiar paleta sin buscar y reemplazar
- No hay modo claro (la app es dark-only por construcción)
- Tokens de tipografía no se usan (`Theme.of(context).textTheme.titleMedium` aparece sin coherencia)
- Sin escala de espacios (140, 220, 350, 200, 76, etc. en posiciones arbitrarias)
- Sin presupuesto de animación (todo es `Duration(milliseconds: ...)` literal)

#### F-04 · Sin caché de red ni imagen consistente

- `Image.network` en `movies_slideshow.dart`, `movie_horizontal_listview.dart`, `top_ten_movies_listview.dart`, `search_movies_delegate.dart`, `movie_screen.dart`
- `CachedNetworkImage` solo en `CategoriesView`, `MoviesByGenreScreen`
- Cada `MovieScreen.initState` dispara 5 requests nuevos (`dio.get`)

#### F-05 · Sin pull-to-refresh en ningún lado

Recargar el home requiere matar y reabrir la app. La lista de favoritos nunca se refresca.

### 3.2 Altos — utilidad para el usuario final

#### U-01 · No se puede compartir una película

`url_launcher` está en `pubspec.yaml` pero no se usa en ningún lado. Faltaría botón de compartir
(tráiler, ficha) en `MovieScreen`.

#### U-02 · No hay "dónde ver" unificado

`_NewWatchProvidersDisplay` lee del país actual del dispositivo. Bien. Pero:
- No hay acción de "abrir en proveedor" (`url_launcher`)
- Si no hay datos para el país, vuelve `SizedBox.shrink` (F-01)

#### U-03 · El Top 10 está duplicado conceptualmente

`topRatedMoviesProvider` ya carga `top_rated`. `TopTenMoviesListview` los muestra como ranking
metálico. Está bien, pero el subtítulo "Más vistas" sugiere `popular`, no `top_rated`. Confuso.

#### U-04 · Búsqueda sin memoria

Cada vez que abres la búsqueda, arrancas desde cero. No hay historial, ni sugerencias, ni "búsquedas
recientes".

#### U-05 · Reproductor de vídeo invasivo

`_FullScreenVideoPlayer` fuerza orientación landscape + immersive mode, pero no restaura la
orientación anterior al cerrarse correctamente en todos los casos. Edge case en `dispose`.

#### U-06 · Sin onboarding

Primera vez que abres la app: splash → loading → home. Sin pantalla de bienvenida, sin
explicación de qué es la app. Especialmente molesto si TMDB falla (queda en loading infinito).

#### U-07 · Sin settings / preferencias

No hay pantalla de:
- Tema (claro / oscuro / sistema)
- Idioma (es-MX hardcoded)
- Limpiar caché
- Versión / créditos

#### U-08 · Categorías sin "Todas las películas"

`CategoriesView` muestra 19 géneros. No hay forma de ver "Todas" sin entrar a un género específico.

### 3.3 Medios — pulido visual

#### V-01 · `MovieMasonry` tiene un hack

```dart
if (index == 1) {
  return Column(
    children: [
      const SizedBox(height: 30),
      MoviePosterLink(movie: widget.movies[index]),
    ],
  );
}
```

Añadir 30px al segundo item no es diseño — es una corrección visual improvisada. Si la app cambia
el ancho, el truco se rompe.

#### V-02 · `_MetalDigit` es CustomPainter sin necesidad

420 líneas de gradientes y blur apilados para pintar un número "1" sobre el poster. Con una
tipografía display adecuada se hace en 5 líneas y queda mejor.

#### V-03 · Hardcoded "Lunes 20" en HomeView

`MovieHorizontalListview(... subtitle: 'Lunes 20')` está clavado en código. Si abres la app un
martes, sigue diciendo "Lunes 20".

#### V-04 · Inconsistencia de borde redondeado

- `ClipRRect(borderRadius: BorderRadius.circular(0))` aparece en widgets donde el radio debería
  ser 12 o 16
- `OutlinedButton` con `borderRadius: BorderRadius.circular(0)` rompe el lenguaje visual del resto

#### V-05 · Sombras pesadas

`boxShadow` con `blurRadius: 18, offset: Offset(0, 10)` y opacidad 140 — el slide show y el Top 10
tienen sombras que no aportan y gastan GPU.

#### V-06 · `FullScreenLoader` con mensajes rotativos

```dart
final listMessages = <String>['Cargando...', 'Por favor, espere...', ...];
```

Spam de texto cambiando cada 2s distrae más que informa. Una sola línea o un esqueleto del
contenido es mejor.

### 3.4 Bajos — calidad de código (no rompe, pero molesta)

#### Q-01 · Carpeta mal escrita: `reporsitories/`

`lib/infrastructure/reporsitories/` (sin la `i` de *repositories*). Propagado a todos los imports
de 7 archivos. Renombrar + sed en una sola fase.

#### Q-02 · `local_storage_reposytory_provider.dart` (typo en filename)

Misma raíz, otro typo distinto. Renombrar junto con Q-01.

#### Q-03 · `widget_test.dart` no compila

`await tester.pumpWidget(const MainApp())` con expectativas de contador. La app no tiene contador.
`flutter analyze` falla. Borrar o reescribir antes de cualquier `flutter test`.

#### Q-04 · `AppDatabase()` instanciado inline

`LocalStorageFavoriteDBDatasource` hace `final db = AppDatabase()` en el field initializer.
Sin inyección → imposible de mockear en tests. Mover al constructor.

#### Q-05 · Casts dinámicos en `movies_slideshow.dart`

```dart
final dynamic rd = (m as dynamic).releaseDate;
```

`_yearFromMovie`, `_ratingText`, `_overview` usan `(m as dynamic)` porque la entidad `Movie` está
mal tipada (`releaseDate` es `DateTime` según la entidad, pero el código lo trata como string o
DateTime). Decidir el tipo y limpiar.

#### Q-06 · `flutter_riverpod` con `hide ProviderRef` en `movie_screen.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart' hide ProviderRef;
```

Workaround frágil porque la entidad `watch_providers.dart` también exporta una clase `ProviderRef`.
Renombrar la clase del modelo (a `ProviderRefData` o `TmdbProviderRef`).

#### Q-07 · `SearchMoviesDelegate` deja streams sin cerrar

```dart
StreamController<List<Movie>> debounceMovies = StreamController...();
StreamController<bool> isLoadingStream = StreamController...();
```

`cleanStreams()` cierra `debounceMovies` pero **no** `isLoadingStream`. Fuga de memoria menor
cada vez que abres la búsqueda.

#### Q-08 · `MoviesByGenreScreen` usa `setState` + `mounted`

```dart
ref.read(moviesByGenreProvider(widget.genreId).notifier).loadNextPage().then((_) {
  if (mounted) setState(() => isInitialLoadDone = true);
});
```

Funciona pero no es Riverpod idiomático. Mover el flag al provider.

---

## 4. Recomendaciones (por prioridad)

| # | Cambio | Esfuerzo | Impacto |
|---|---|---|---|
| 1 | **F-02 Favoritos Instagram-style** (heart animado + haptic + doble-tap) | 1-2 días | Alto |
| 2 | **F-01 Shared `EmptyState` + `ErrorRetry` widgets** | 0.5 día | Alto |
| 3 | **F-03 Sistema de diseño (tokens)** | 2-3 días | Alto |
| 4 | **F-04 Caché consistente con `cached_network_image`** | 1 día | Medio |
| 5 | **F-05 Pull-to-refresh en HomeView y FavoritesView** | 0.5 día | Medio |
| 6 | **U-01 Compartir película** | 0.5 día | Medio |
| 7 | **U-07 Settings screen (tema + idioma)** | 1 día | Medio |
| 8 | **U-04 Búsqueda con historial** | 1 día | Bajo |
| 9 | **U-02 Abrir watch provider con `url_launcher`** | 0.5 día | Bajo |
| 10 | **V-01..V-06 Pulido visual** (parche durante las fases) | continuo | Bajo |
| 11 | **Q-01..Q-08 Limpieza de código** (typos, inyección, tests) | 1 día | Bajo |

---

## 5. Plan de fases

Cada fase es una rama `feature/<nombre>`, merge `--no-ff` a `develop` al terminar. No se solapan.

| # | Fase | Estado |
|---|---|---|
| 0 | Housekeeping | ✅ Hecho en `feature/phase-0-housekeeping` (2026-08-08) |
| 1 | Sistema de diseño | Pendiente |
| 2 | Estados compartidos | Pendiente |
| 3 | Favoritos Instagram | Pendiente |
| 4 | Navegación y settings | Pendiente |
| 5 | Compartir y watch providers | Pendiente |
| 6 | Búsqueda con historial | Pendiente |
| 7 | Pulido y limpieza | Pendiente |

### Phase 0 — qué se hizo, qué se saltó

Hecho:
- Renombrado `lib/infrastructure/reporsitories/` → `repositories/` con `git mv`, 6 imports actualizados
- Renombrado `local_storage_reposytory_provider.dart` → `local_storage_repository_provider.dart`, 2 imports actualizados
- `LocalStorageFavoriteDBDatasource` ahora acepta `AppDatabase` por constructor (default `AppDatabase()`)
- `SearchMoviesDelegate.cleanStreams()` cierra `isLoadingStream` y cancela el timer pendiente

Saltado (a propósito):
- **`widget_test.dart`**: el usuario revirtió mi rewrite al test de contador roto. No lo toco.
- **`actors_respository_provider.dart` filename typo**: fuera del alcance explícito de phase 0, queda para phase 7.

### Fase 0 · Housekeeping

**Rama**: `feature/audit-housekeeping`

- Crear `DESIGN.md` con el sistema de tokens inicial (placeholder)
- Renombrar `reporsitories/` → `repositories/` (Q-01)
- Renombrar `local_storage_reposytory_provider.dart` → `local_storage_repository_provider.dart` (Q-02)
- Borrar o reescribir `widget_test.dart` (Q-03)
- Inyectar `AppDatabase` en `LocalStorageFavoriteDBDatasource` (Q-04)
- Cerrar `isLoadingStream` en `SearchMoviesDelegate.cleanStreams` (Q-07)

**Entrega**: `flutter analyze` limpio, `DESIGN.md` placeholder.

---

### Fase 1 · Sistema de diseño

**Rama**: `feature/design-system`

Inspirado en [venceAppExample/DESIGN.md](venceAppExample/DESIGN.md), adaptado a una app de cine.

- Crear `lib/config/theme/` con:
  - `app_colors.dart` — paleta dark (cinemapedia es dark-only) con anchor cinematográfico
  - `app_typography.dart` — escala 1.25, pesos Geist (o lo que se decida)
  - `app_spacing.dart` — escala 4pt, role aliases
  - `app_motion.dart` — 3 duraciones, 3 curvas, presupuesto 2 elementos en movimiento
- Reemplazar todos los `Color(0xFF...)` hardcoded por tokens
- Reemplazar todos los `Duration(milliseconds: ...)` sueltos por tokens
- Reemplazar todos los `borderRadius: BorderRadius.circular(0)` y radios sueltos por tokens

**Entrega**: `flutter analyze` limpio, app se ve igual pero el código lee de tokens.

**Riesgo**: grande. Tocar muchos archivos. Hacerlo por pantalla, no de golpe.

---

### Fase 2 · Estados compartidos (empty / error)

**Rama**: `feature/empty-and-error-states`

- Crear `lib/presentations/widgets/common/empty_state_widget.dart`
- Crear `lib/presentations/widgets/common/error_retry_widget.dart`
- Crear `lib/presentations/widgets/common/skeleton_loader.dart` (con `shimmer`)
- Reemplazar los 4 `SizedBox.shrink()` por `EmptyState` contextual
- Añadir `ErrorRetry` a las 6 pantallas que solo tienen `loading` o nada

**Entrega**: cada pantalla tiene los 4 estados (`loading`, `data`, `empty`, `error`).

---

### Fase 3 · Favoritos Instagram-style

**Rama**: `feature/favorites-instagram-style`

F-02 + U-03 + parte de U-04. La estrella de esta fase.

- Crear `lib/presentations/widgets/common/animated_heart_button.dart`
  - Tap → scale 0.7→1.2→1.0 con bounce (180ms)
  - `HapticFeedback.lightImpact()` al toggle
  - Color: `Colors.white` → `Colors.redAccent` con `AnimatedSwitcher`
- Crear `lib/presentations/widgets/common/double_tap_to_favorite.dart`
  - `GestureDetector` con `onDoubleTap`
  - Overlay con corazón flotante que sube y se desvanece (300ms, easeOut)
- Reemplazar el `IconButton` en `MovieScreen._CustomSliverAppBar` por `AnimatedHeartButton`
- Envolver el poster de `_MovieDetailsSection` con `DoubleTapToFavorite`
- Permitir quitar favorito desde `FavoritesView` (long-press → confirmar)
- Hacer `isFavoriteMovieProvider.autoDispose` y combinar con `isFavoriteInMemoryProvider` (un solo
  read, sin doble fetch)

**Entrega**: el favorito se siente IG-quality.

---

### Fase 4 · Navegación, onboarding y settings

**Rama**: `feature/nav-and-settings`

U-06 + U-07 + parte de U-08.

- Crear `lib/presentations/screens/onboarding/onboarding_screen.dart` (3 slides, `PageView`)
- Persistir `onboarding_done` en `shared_preferences`
- Branch en `app_router.dart`: si no está hecho → onboarding, sino → home
- Crear `lib/presentations/screens/settings/settings_screen.dart`
  - Tema: dark (único por ahora, pero conmutador visible para futuro)
  - Idioma: selector (cosmético, sin i18n real todavía)
  - Limpiar caché de Drift
  - Versión + créditos
- Añadir `IconButton` de settings en `CustomAppbar`

**Entrega**: primera vez → onboarding; siempre → home con settings accesibles.

---

### Fase 5 · Compartir y watch providers

**Rama**: `feature/share-and-providers`

U-01 + U-02.

- En `MovieScreen`, añadir `IconButton(Icons.share)` en `_CustomSliverAppBar.actions`
- Usar `Share.share('https://www.themoviedb.org/movie/${movie.id} - ${movie.title}')`
- En `_NewWatchProvidersDisplay`, cada chip de proveedor pasa a `InkWell` que llama
  `launchUrl(Uri.parse(provider.url))` con `mode: LaunchMode.externalApplication`

**Entrega**: compartir y abrir proveedor en proveedor real.

---

### Fase 6 · Búsqueda con historial

**Rama**: `feature/search-history`

U-04.

- Persistir últimas 5 búsquedas en `shared_preferences`
- Mostrarlas en `_IdleHint` (cuando el campo está vacío) como chips clickeables
- Limpiar historial desde settings

**Entrega**: la búsqueda se siente personal.

---

### Fase 7 · Pulido y limpieza

**Rama**: `feature/polish-and-cleanup`

V-01..V-06 + Q-05, Q-06, Q-08.

- Eliminar el hack de `index == 1` en `MovieMasonry` (cambiar layout a `Staggered` de verdad)
- Reemplazar `_MetalDigit` por tipografía display
- Quitar el `'Lunes 20'` hardcoded, calcular fecha actual
- Decidir tipo de `Movie.releaseDate` (DateTime) y limpiar los `(m as dynamic)`
- Renombrar `ProviderRef` del modelo watch_providers → algo sin colisión

**Entrega**: app limpia por dentro y por fuera.

---

## 6. Fuera de alcance (no en estas fases)

- **Cuenta de usuario / login** — la app es local-first, sin auth
- **Sincronización en la nube de favoritos** — Drift local es suficiente
- **Notificaciones push** — no es una app que notifique
- **Multi-idioma real** — la UI es es-MX hardcoded, el conmutador de settings es cosmético
- **Modo claro** — la marca es dark; si se pide, fase futura
- **Web/desktop** — el proyecto es iOS + Android
- **Compartir a redes sociales específicas** — share genérico de URL basta
- **Tests E2E / integración** — la base es `flutter analyze` limpio + smoke test manual
- **CI/CD** — fuera de alcance por ahora

---

## 7. Cómo contribuir a este documento

Cuando termines una fase:
1. Mueve las recomendaciones de "Pendiente" a "Hecho" (no aquí, en el PR)
2. Si descubres un hallazgo nuevo, añádelo a la sección 3 con severidad
3. Si una decisión cambia el alcance, edita la sección 6

Este documento vive en `develop` y se mergea con cada fase. No se va a `main` hasta el release.
