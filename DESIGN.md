# DESIGN.md

Locked design system for **cinemapedia**. Every screen, view, and widget reads from these tokens.
Code rules are in [CLAUDE.md](CLAUDE.md); the audit and roadmap are in
[Improve_design_functionaly.md](Improve_design_functionaly.md).

```
Hallmark · genre: atmospheric · scope: system (mobile app)
themes: Cinema (dark) + Cinema-light · anchor hue: navy 250 + accent coral 350
pre-emit critique: P4 H4 E4 S5 R3 V4
```

**Scope note.** Hallmark's macrostructure, nav, and footer archetypes are page constructs for the
web and are skipped on purpose. What carries over: the token discipline, the type and motion
budgets, and the anti-pattern list.

---

## 1. Context

| | |
|---|---|
| **Audience** | Spanish-speaking movie browser. Opens for 30 seconds between decisions. Wants quick answers, no friction |
| **Use case** | "What's playing, what's good, where can I watch it" — three taps from launch to detail |
| **Tone** | Cinematic, calm. Dark like a theater or bright like a daytime poster. Not playful, not corporate |
| **Genre** | atmospheric — restraint with weight |
| **Themes** | Dark (default) + Light. Both anchored on navy with coral accent. User picks via Settings |

These were inferred, not asked.

---

## 2. Colour

cinemapedia ships two themes. Both anchor on navy with the same coral accent — the brand stays
consistent across modes; only the surrounding surfaces flip.

### Surface elevation (per mode)

Four steps, lighter means higher. The same name resolves to different hex per brightness through
`context.colors` (see `lib/config/theme/theme_context.dart`).

| Token | Dark | Light | Use |
|---|---|---|---|
| `paper` | `#0E1427` | `#F5F5F7` | Screen background |
| `surface` | `#121A34` | `#FFFFFF` | Cards, sheets, input fill |
| `surfaceRaised` | `#16213E` | `#EBEBEF` | Pressed, nav chip background |
| `surfaceHighest` | `#1B1B2F` | `#E0E0E5` | Modal, sheet, full-bleed overlay |

### Foreground (per mode)

| Token | Dark | Light | Use |
|---|---|---|---|
| `text` | `#FFFFFF` | `#0E1427` | Primary text, icons |
| `textMuted` | white 70 % | navy 60 % | Secondary text |
| `textHint` | white 40 % | navy 40 % | Placeholders, disabled |
| `icon` | white | `#0E1427` | Default icons |
| `iconMuted` | white 60 % | navy 60 % | Secondary icons |
| `rule` | white 12 % | black 12 % | Dividers, hairline borders |
| `outlineVariant` | white 20 % | black 20 % | Heavier borders, focused states |

### Accent

Same coral on both grounds. Light mode uses a slightly darker variant for contrast on white.

| Token | Dark | Light | Use |
|---|---|---|---|
| `accent` | `#FF4D6D` | `#E63E5E` | Favourite toggle on, FAB, focused border |
| `accentInk` | `#FFFFFF` | `#FFFFFF` | Text or icon on `accent` |
| `rating` | `#FFC107` | `#F5A300` | Star badges only |
| `danger` | `#E53935` | `#E53935` | Destructive actions only |

### Hero gradient (per mode)

The full-bleed gradient behind HomeView, CategoriesView, FavoritesView, MoviesByGenreScreen,
FullScreenLoader. Each component reads `context.colors.heroGradient`.

| Dark | Light |
|---|---|
| black → `#0E1427` → `#121A34` | `#E8EAF0` → `#F5F5F7` → `#FFFFFF` |

### Accent discipline

The accent is a highlighter, not a colour block. Allowed on:
- The favourite heart icon when active
- The FAB (when one exists)
- The focused input border
- The active bottom-nav chip
- The onboarding dots indicator

**Not** allowed as a header band, a section background, or a page-width fill.

---

## 3. Typography

Two weights do all the work: **500** for UI controls (buttons, tabs, form labels) and **700** for
every heading. Body and small body are **400**. No weight below 400.

The platform default font is used. A custom display face (e.g. Geist) can be added later without
changing the scale.

### Scale

Major third (1.25) from a 13 px base. These are the `TextTheme` slots the code actually assigns.

| Slot | Size | Weight | Use |
|---|---|---|---|
| `displayLarge` | 28 | 700 | Reserved display |
| `displayMedium` | 24 | 700 | Hero stats |
| `headlineLarge` | 22 | 700 | Screen title |
| `headlineMedium` | 18 | 700 | Section title |
| `titleLarge` | 16 | 700 | AppBar title, card title |
| `titleMedium` | 14 | 700 | Sub-section title |
| `titleSmall` | 13 | 500 | List row title |
| `bodyLarge` | 14 | 400 | Body — floor for reading copy |
| `bodyMedium` | 13 | 400 | Default body |
| `bodySmall` | 12 | 400 | Metadata, helper text |
| `labelLarge` | 13 | 500 | Buttons, form labels |
| `labelMedium` | 12 | 500 | Tags, chips |
| `labelSmall` | 11 | 500 | Tracked uppercase micro-label |

**No more than five sizes on one screen.** More hierarchy comes from weight and colour, not
another size.

---

## 4. Space and shape

4 pt scale, named by step. Never type a raw number in a widget — use a token or role alias.

`xs3 2 · xs2 4 · xs 8 · sm 12 · md 16 · lg 24 · xl 32 · xl2 40 · xl3 48 · xl4 64`

Role aliases:

- `screenPadding = md` (16) — horizontal margin on screens
- `cardPadding = sm` (12) — interior padding of cards
- `sectionGap = xl` (32) — vertical space between sections
- `listGap = sm` (12) — space between list items

### Radii

Two shape languages only:

- `radiusCard = 12` — cards, sheets, buttons, FAB
- `radiusPill = 999` — chip selectors only

Inputs use `radiusInput = 8`.

**Depth is weight and scale, not shadow.** Cards are separated by their `surface` fill against
`paper`. The FAB carries `elevation: 1`; nothing else does.

---

## 5. Motion

Three durations, three curves. Hard budget of **two moving things per screen**.

| Token | Value | Use |
|---|---|---|
| `micro` | 120 ms | Press feedback, toggle, colour shift |
| `short` | 220 ms | List item entry, chip selection |
| `long` | 420 ms | Route transition, bottom sheet |
| `reduced` | 150 ms | Reduced-motion replacement |

| Curve | Cubic | Use |
|---|---|---|
| `easeOut` | `(0.16, 1, 0.3, 1)` | Anything entering |
| `easeIn` | `(0.7, 0, 0.84, 0)` | Anything leaving |
| `easeInOut` | `(0.65, 0, 0.35, 1)` | State toggles |

Animate `transform` and `opacity` only. Never a bounce, never an overshoot, never an infinite loop
that is not a real loading indicator. If a transition does not communicate information, remove it.

---

## 6. Component voice

### Bottom navigation

The bottom nav uses `surfaceRaised` background with `radiusCard = 12`. Selected item uses `text`,
unselected uses `iconMuted`. The chip floats above the safe area with horizontal margins of `sm`.

### Favourite heart

The favourite toggle uses `accent` when active, `iconMuted` when not. Tap triggers a 120 ms
scale pulse (`micro`) and a light haptic. (Implementation lands in phase 3.)

### Star rating

Always `rating` (amber). Never `accent`. Used for badges only — never as a fill.

### Buttons

Primary button: `accent` fill, `accentInk` label, `radiusCard`, height 48.

### Empty and error states

Phase 2 introduces the shared widgets. Until then, screens fall back to a centred `CircularProgressIndicator`
or `SizedBox.shrink()` — both are documented as known deviations.

---

## 7. Where the tokens live

| File | Holds |
|---|---|
| [app_colors.dart](lib/config/theme/app_colors.dart) | Palette, semantic colours, accent discipline |
| [app_typography.dart](lib/config/theme/app_typography.dart) | Type scale and `TextTheme` |
| [app_spacing.dart](lib/config/theme/app_spacing.dart) | Spacing scale, role aliases, radii |
| [app_motion.dart](lib/config/theme/app_motion.dart) | Durations and curves |
| [app_theme.dart](lib/config/theme/app_theme.dart) | Assembles `ThemeData` |

A widget that hardcodes a colour, a size, a radius, or a duration is a bug. Reference the token.

---

## 8. Banned in this project

- `Colors.white` or `Colors.black` outside the tokens file
- `Color(0xFF...)` literals anywhere outside `app_colors.dart`
- Hardcoded `Duration(milliseconds: …)` outside `app_motion.dart`
- Hardcoded `BorderRadius.circular(0)` or any radius literal outside `app_spacing.dart`
- Bounce or spring easing on UI state
- Colour as the only signal — always pair with an icon or a label
- Italic headings

---

## 9. Migration status

| Surface | Status |
|---|---|
| `AppColors` (light + dark palettes, gradients) | ✅ Done (theme work) |
| `AppTheme` (dual `ThemeData`) | ✅ Done |
| `themeModeProvider` + `theme_context.dart` | ✅ Done |
| `MaterialApp.themeMode` wired to provider | ✅ Done |
| `CustomAppbar`, `CustomBottomNavigation`, `OnboardingScreen`, `SettingsScreen`, `EmptyStateWidget`, `ErrorRetryWidget`, `SkeletonLoader`, `AnimatedHeartButton`, `DoubleTapToFavorite` | ✅ Migrated to `context.colors` |
| `HomeView`, `FavoritesView`, `CategoriesView`, `MoviesByGenreScreen`, `FullScreenLoader` hero gradients | ✅ Migrated |
| `MoviesSlideshow` content colours (text on poster, dots) | Pending |
| `MovieScreen`, `ActorScreen` detail layouts | Pending (deferred — many `Colors.white` calls inside image overlays that are intentionally always-white for image legibility) |
| `MovieHorizontalListview`, `TopTenMoviesListview`, `MovieMasonry` cards | Pending |

Deferred intentionally: `MovieScreen` and `ActorScreen` are image-heavy. White text on a darkened
poster overlay is correct in both themes — image legibility does not invert with the theme. Those
remaining `Colors.white` calls are intentional, not bugs.
