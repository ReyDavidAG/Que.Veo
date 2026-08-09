# TMDB_features.md

Auditoría de la API gratuita de [The Movie Database](https://developer.themoviedb.org) aplicada a
cinemapedia. Esta es la lista de funcionalidades que se podrían implementar con el tier gratuito
(API key + Bearer v4 token, sin auth de usuario).

El tier gratuito cubre: películas, gente, géneros, búsqueda, discover, watch providers, vídeos,
imágenes, trending. **No** requiere cuenta de usuario para los endpoints públicos.

---

## Lo que cinemapedia ya usa

| Endpoint | Dónde | Función |
|---|---|---|
| `/movie/now_playing` | `MoviedbDatasource` | HomeView → "En cines" |
| `/movie/popular` | `MoviedbDatasource` | HomeView → "Top 10 hoy" |
| `/movie/upcoming` | `MoviedbDatasource` | HomeView → "Próximamente" |
| `/movie/top_rated` | `MoviedbDatasource` | HomeView → "Mejor valoradas" |
| `/movie/{id}` | `MoviedbDatasource` | MovieScreen detail |
| `/movie/{id}/similar` | `MoviedbDatasource` | MovieScreen → "Películas Similares" |
| `/movie/{id}/credits` | `ActorMoviedbDatasource` | MovieScreen → cast |
| `/movie/{id}/videos` | `MovieVideosMoviedbDatasource` | MovieScreen → trailers YouTube |
| `/movie/{id}/watch/providers` | `WatchProvidersMoviedbDatasource` | MovieScreen → "Dónde ver" |
| `/search/movie` | `MoviedbDatasource` | Search delegate |
| `/discover/movie` | `MoviedbDatasource` | MoviesByGenreScreen |
| `/genre/movie/list` | `GenreMovieDBDataSource` | CategoriesView |
| `/person/{id}` | `ActorDetailsMoviedbDatasouce` | ActorScreen |
| `/person/{id}/movie_credits` | `ActorDetailsMoviedbDatasouce` | ActorScreen → filmografía |

**14 endpoints. 0 del tier de Account.** auth = ninguno.

---

## Lo que la API ofrece pero NO usamos (tier gratuito, sin auth)

### Capa 1 — Esenciales para una app de cine decente

| # | Endpoint | Qué aporta | Esfuerzo | Valor |
|---|---|---|---|---|
| 1 | `/trending/movie/{day\|week}` | Lista "Lo que es tendencia ahora" — mejor curaduría que `popular` | 0.5 día | Alto |
| 2 | `/movie/{id}/reviews` | Reseñas de usuarios (paginadas) — abre la pestaña "Críticas" | 1 día | Alto |
| 3 | `/movie/{id}/images` | Galería completa de posters, backdrops y logos — lightbox modal | 1 día | Alto |
| 4 | `/movie/{id}/recommendations` | "Porque te gustó X" — distinta de `similar`, usa signals de popularity | 0.5 día | Alto |
| 5 | `/movie/{id}/keywords` | Tags temáticos ("time travel", "heist", "post-apocalyptic") | 0.5 día | Medio |
| 6 | `/configuration` | URL base de imágenes, tamaños disponibles, lista de países | 0.5 día | Alto (foundational) |
| 7 | `/movie/{id}/release_dates` | Fechas de estreno por país + certificación (PG-13, R, etc.) | 0.5 día | Medio |
| 8 | `/person/{id}/images` | Galería de fotos del actor (eventos, premieres, behind-the-scenes) | 0.5 día | Bajo |

### Capa 2 — Calidad de vida

| # | Endpoint | Qué aporta | Esfuerzo | Valor |
|---|---|---|---|---|
| 9 | `/search/person` | Buscar actores además de películas (la search actual solo cubre películas) | 0.5 día | Medio |
| 10 | `/search/collection` | Buscar sagas/franquicias | 0.5 día | Medio |
| 11 | `/collection/{id}` | Detalle de saga (todas las películas de Marvel, Star Wars, etc.) + parts | 1 día | Alto |
| 12 | `/movie/{id}/translations` | Sinopsis en otros idiomas (relevante si quieres multi-idioma de verdad) | 1 día | Bajo |
| 13 | `/movie/{id}/external_ids` | IMDB + Facebook + Twitter + Instagram de la película | 0.5 día | Bajo |
| 14 | `/movie/{id}/videos` (ya usado) → **filtro por `site=YouTube` + tipos (Trailer, Teaser, Behind the Scenes, Featurette)** | Ya lo usas, pero solo el primero. Filtrar por tipo da "Trailers", "Detrás de cámaras", etc. | 0.5 día | Medio |
| 15 | `/configuration/languages` | Lista de idiomas para un picker | 0.5 día | Bajo |
| 16 | `/configuration/countries` | Lista de países para un picker (override del locale del dispositivo) | 0.5 día | Bajo |

### Capa 3 — Lujo

| # | Endpoint | Qué aporta | Esfuerzo | Valor |
|---|---|---|---|---|
| 17 | `/movie/{id}/changes` | Histórico de ediciones (poco interesante) | — | Ninguno |
| 18 | `/movie/{id}/lists` | Listas de usuarios donde aparece la película | 0.5 día | Bajo |
| 19 | `/search/keyword` | Buscar keywords (overlaps con autocompletar) | — | Ninguno |
| 20 | `/search/company` | Buscar productoras | — | Ninguno |
| 21 | `/search/multi` | Búsqueda unificada (película + persona + colección en una sola query) | 0.5 día | Medio |

### No aplica para cinemapedia (TV / Account / Auth)

| Endpoint | Razón para no usar |
|---|---|
| Todos los `/tv/*` | cinemapedia es de películas. Pasar a TV es un cambio de scope completo. |
| Todos los `/account/*` | Requieren auth de usuario. cinemapedia es local-first, sin login. Migrar a Supabase/Auth traería costos. |
| `/authentication/*` | No tenemos login. |

---

## Funcionalidades de producto (lo que el usuario final vería)

Estas son las features que se podrían implementar combinando los endpoints. Las marco con prioridad.

### Tier Esencial (debe hacerse si o si)

| Feature | Endpoints | Por qué |
|---|---|---|
| **Trending "Hoy" en Home** | `/trending/movie/day` | Reemplaza el "Top 10 hoy" con algo que cambia diariamente. Mucho más pegadizo que un top_rated estático. |
| **Tab "Reseñas" en MovieScreen** | `/movie/{id}/reviews` | Las personas quieren saber qué dice la crítica. Sin esto, MovieScreen se siente incompleto. |
| **Galería de imágenes** | `/movie/{id}/images` | Lightbox con posters y backdrops. Una imagen vale más que mil palabras. |
| **Sección "Porque te gustó X"** | `/movie/{id}/recommendations` | Una sección más en MovieScreen debajo de Similares. Conecta películas. |
| **Keywords como chips** | `/movie/{id}/keywords` | Debajo de géneros. Cada keyword clickeable → búsqueda por keyword. |
| **Calificación por país + año de estreno** | `/movie/{id}/release_dates` | Muestra "PG-13 (USA), 12 (ES), +16 años de edad" según el país. Para Latinoamérica es muy útil. |
| **`/configuration` como fuente única de imágenes** | `/configuration` | Hoy hay un hardcode `https://image.tmdb.org/t/p/w500`. El endpoint lo expone formalmente. |

### Tier Lujo (nice to have, no urgente)

| Feature | Endpoints | Por qué |
|---|---|---|
| **Sagas / Colecciones** | `/collection/{id}` + `/search/collection` | Nueva pantalla "Saga" que muestra todas las películas de una franquicia. Muy cool para Marvel, Star Wars, etc. |
| **Búsqueda de actores** | `/search/person` | Hoy la search solo busca películas. Si escribes "Tom Holland" no lo encuentra. |
| **Búsqueda multi-tipo** | `/search/multi` | Un solo input para películas, personas y colecciones. |
| **Pais de watch provider override** | `/configuration/countries` + UI | Hoy la app detecta el país del dispositivo. Un picker para forzar otro país sería útil cuando viajas. |
| **Filtros de trailer** | `/movie/{id}/videos` (con filtro) | Tabs "Trailer | Detrás de cámaras | Featurette" en lugar de solo el primer video. |
| **Galería de fotos del actor** | `/person/{id}/images` | Carrusel abajo de la bio. Premium feel. |
| **Links externos** | `/movie/{id}/external_ids` | Botones a IMDB, TMDB page oficial, etc. |

### Tier a ignorar (no aporta)

- `/movie/{id}/changes` (edit history) — sin valor para el usuario.
- `/search/keyword`, `/search/company` — niche extremo.
- `/movie/{id}/lists` — sin auth de usuario, solo muestra listas públicas de extraños.
- Traducciones multi-idioma — solo si decides invertir en i18n real.

---

## Recomendaciones de mi parte (5 picks)

Si tuviera que elegir las 5 que más mueven la aguja por día de trabajo:

### 1. Trending "Hoy" en HomeView (0.5 día)
Reemplaza la sección "Top 10 hoy" actual (que es estática de `popular`). El usuario siente que la app "está viva". Un solo endpoint, un cambio de provider.

### 2. `/configuration` como fuente de verdad de imágenes (0.5 día)
Hoy `MovieMapper` hardcodea `https://image.tmdb.org/t/p/w500`. Centralizar el base URL en una constante del app (cacheada en disco) deja a la app lista para cambiar de tamaño sin buscar y reemplazar.

### 3. Tab "Reseñas" en MovieScreen (1 día)
Las reseñas son el segundo bloque de información más pedido en una app de cine. El endpoint ya está documentado, la paginación es estándar, el rendering es lista de cards. Mejora grande de UX.

### 4. Galería de imágenes modal (1 día)
Tocar el poster de la película abre un lightbox con todas las imágenes (posters alternativos, backdrops HD, logos). Una sola pantalla nueva + un endpoint.

### 5. Colecciones / Sagas (1 día)
Nueva pantalla "Saga" accesible desde MovieScreen cuando la película tiene `belongs_to_collection`. Muestra todas las películas de la saga ordenadas. Para Marvel/Star Wars/Harry Potter es un diferenciador enorme.

**Total: ~4 días de trabajo. Producto pasa de "demo" a "app real".**

---

## Estructura de implementación sugerida

```
infrastructure/
  datasources/
    moviedb_datasource.dart           # + trendingNow(), getReviews(), getImages(), getRecommendations(), getKeywords()
    configuration_datasource.dart     # NEW — imagen base URL, sizes, países, idiomas
    collections_datasource.dart       # NEW — sagas
    person_search_datasource.dart     # NEW — search/multi + search/person
domain/
  entities/
    movie_review.dart                 # NEW — author, content, rating, created_at
    movie_image.dart                  # NEW — file_path, aspect_ratio, width/height, vote
    collection.dart                   # NEW — id, name, overview, parts[]
    movie_keyword.dart                # NEW — id, name
  datasources/
    configuration_datasource.dart     # abstract
    collections_datasource.dart       # abstract
    reviews_datasource.dart           # abstract
    keywords_datasource.dart          # abstract
```

---

## Preguntas para vos antes de implementar

1. **Trending en lugar de Top 10 estático**: ¿mantenemos ambos (Top 10 de la semana + trending diario) o reemplazamos?
2. **Reseñas**: ¿sólo TMDB (1 idioma) o dejamos al usuario elegir idioma del review?
3. **Galería de imágenes**: ¿lightbox fullscreen con zoom, o grid simple con tap-to-fullscreen?
4. **Colecciones**: ¿qué pasa cuando una saga tiene muchas películas? ¿grid horizontal como en HomeView?
5. **Búsqueda de personas**: ¿se mezcla con películas en la misma search, o se separa en tabs?

Marcá con ✅ lo que querés que implemente y con ❌ lo que descartás. Las que dejes sin marcar las dejo en backlog.

## Fuentes

- [TMDB API — getting started](https://developer.themoviedb.org/reference/intro/getting-started)
- [TMDB API — movie/popular reference](https://developer.themoviedb.org/reference/movie-popular-list)
- [TMDB API — llms.txt index](https://developer.themoviedb.org/llms.txt)
