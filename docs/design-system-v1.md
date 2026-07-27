# Design System V1 — Foundation Reference

> **Status:** 🟢 Aktif · **Dibuat:** 2026-07-20 · **Diperbarui:** 2026-07-20
> **Penanggung jawab:** Mohammad Rifqi Hidayat (Product Owner)
> **Release:** 0.3.0 · **Epic:** Design System V1 · **Checkpoint:** 1 — Theme Foundation

Dokumen ini mencatat **nilai konkret** Design System V1 — warna, tipografi, radius,
spacing, shadow. [`docs/09_design_system.md`](09_design_system.md) mengunci **sistem**
(struktur & prinsip) dan sengaja menunda nilai visual ke "desain visual"; dokumen ini
**adalah** keputusan desain visual tersebut. Sumber kebenaran teknis tetap kode di
`app/hearts2spaceu/lib/app/theme/`; dokumen ini adalah rangkumannya agar token tidak
hanya hidup di kode.

---

## 1. Design Philosophy

> **"A calm companion, not a control panel."**

Hearts2spaceU harus terasa **modern, premium, elegant, soft, dreamy, minimal, clean,
calming** — bukan aplikasi CRUD atau template Flutter bawaan. Konten (grup & aktivitasnya)
adalah bintangnya; antarmuka menepi dengan anggun.

Inspirasi: Apple Human Interface, Samsung One UI, Linear, Notion, nuansa aplikasi K-Pop modern.

## 2. Color Palette

Baby blue (primary) + baby pink (secondary, khas Hearts2Hearts) di atas latar terang
yang lapang, dengan tinta navy untuk teks. Sumber: `lib/app/theme/app_colors.dart`.

### Light

| Token | Hex | Peran |
|-------|-----|-------|
| `primary` | `#8CC5F2` | aksen utama, fill lembut |
| `primaryStrong` | `#2F7CC0` | CTA solid + teks putih (AA-safe) |
| `onPrimary` | `#12233F` | teks di atas fill baby-blue lembut |
| `secondary` | `#F7C5D9` | aksen sekunder, badge |
| `secondaryStrong` | `#D96FA0` | teks/badge pink di atas terang (AA-safe) |
| `ink` | `#1E2A46` | teks utama (navy) |
| `inkMuted` | `#5B6478` | teks sekunder |
| `background` | `#F6FAFE` | latar dreamy (very light blue) |
| `surface` | `#FFFFFF` | kartu |
| `surfaceTint` | `#EAF3FC` | kartu ter-tint / section |
| `outline` | `#E4EAF2` | pembatas lembut |
| `success` / `warning` / `error` | `#57C4A3` / `#F0C15E` / `#E6807F` | semantik muted |

**Hero gradient:** `#EAF3FC → #FCEBF2` (blue → pink, sangat lembut).

**Type badge tints** (per `Event.type`): concert `#EAF3FC` · broadcast `#FCEBF2` ·
showcase `#EAF7F1` · fanmeeting `#F3EEFC`.

### Dark

Navy dalam yang desaturated (bukan hitam pekat) agar rasa *calm* tetap terjaga.

| Token | Hex |
|-------|-----|
| `darkBackground` | `#0F1626` |
| `darkSurface` | `#17203A` |
| `darkSurfaceTint` | `#1E2A46` |
| `darkOutline` | `#2B3652` |
| `darkInk` | `#EAF1FB` |
| `darkInkMuted` | `#AEB8CE` |
| `darkPrimary` | `#8CC5F2` |
| `darkOnPrimary` | `#0B1B2E` |
| `darkSecondary` | `#F0AAC7` |

**Kenapa `primaryStrong`/`secondaryStrong` terpisah dari `primary`/`secondary`?**
Warna brand pastel (baby blue/pink) terlalu terang untuk teks/CTA solid ber-kontras
AA. Varian "Strong" dipakai untuk teks & tombol; varian pastel untuk fill/tint lembut.

## 3. Typography

Skala bernama (Material 3 style), dibangun di atas **font sistem** (SF Pro di Apple,
Roboto di Android) — **zero font asset baru, zero dependency baru**. Sumber:
`lib/app/theme/app_typography.dart`.

| Peran | Size / Line | Weight | Tracking | Pemakaian |
|-------|-------------|--------|----------|-----------|
| `displaySmall` | 32 / 40 | 600 | −0.2 | greeting / hero |
| `headlineSmall` | 24 / 30 | 600 | −0.2 | judul halaman/detail |
| `titleMedium` | 18 / 24 | 600 | — | judul kartu |
| `bodyLarge` | 16 / 24 | 400 | — | teks utama |
| `bodyMedium` | 14 / 20 | 400 | — | subtitle |
| `labelMedium` | 13 / 16 | 500 | — | metadata |
| `labelSmall` | 11 / 14 | 600 | +0.8 | badge / overline |

> Hindari bold 700 — menjaga kesan *soft*, bukan tegas/berat.

## 4. Spacing

Skala base-4 dengan langkah bernama. Sumber: `lib/app/theme/app_spacing.dart`.

| Token | Nilai |
|-------|------:|
| `xs` | 4 |
| `sm` | 8 |
| `md` | 12 |
| `lg` | 16 |
| `xl` | 24 |
| `xxl` | 32 |
| `xxxl` | 48 |
| `screenPadding` | 24 (`xl`) |
| `cardPadding` | 16 (`lg`) |

Whitespace diperlakukan sebagai fitur (kesan *calm*, bukan padat), bukan sisa ruang.

## 5. Border Radius

Radius besar = kesan *soft & premium*. Sumber: `lib/app/theme/app_radius.dart`.

| Token | Nilai | Pemakaian |
|-------|------:|-----------|
| `xs` | 8 | elemen kecil |
| `sm` | 12 | chip/badge |
| `md` | 16 | elemen menengah |
| `lg` | 20 | **kartu** (default) |
| `xl` | 28 | sheet / hero |
| `pill` | 999 | tombol |

## 6. Shadows / Elevation

Rendah, difus, ter-tint navy — bukan shadow Material yang tajam. `ThemeData` mengunci
`elevation: 0` pada Card/AppBar; kedalaman datang dari shadow kustom ini di level
komponen (Checkpoint 2). Sumber: `lib/app/theme/app_shadows.dart`.

| Token | Offset | Blur | Warna |
|-------|-------:|-----:|-------|
| `sm` | y4 | 16 | `ink` @ 5% alpha |
| `md` | y8 | 28 | `ink` @ 7% alpha |
| `lg` | y16 | 40 | `ink` @ 9% alpha |

## 7. Iconography *(rencana Checkpoint 2+)*

Material Symbols **Rounded** (mis. `Icons.event_rounded`) — bawaan Flutter, tanpa
dependency baru; bentuk membulat selaras estetika *soft*. Ukuran `20 / 24 / 28`.

## 8. Motion *(rencana Checkpoint 7)*

Durasi `fast 150ms · base 250ms · slow 400ms`; easing `easeOutCubic` (masuk),
`easeInOut` (ubah state). Hanya widget animasi bawaan Flutter (`Hero`,
`AnimatedSwitcher`, `AnimatedContainer`, `FadeTransition`, `SlideTransition`,
`AnimatedScale`). Menghormati *reduced motion* (`MediaQuery.disableAnimations`).

## 9. ThemeData Wiring

`AppTheme.light` / `AppTheme.dark` (`lib/app/theme/app_theme.dart`) merakit token di
atas menjadi `ColorScheme`, `TextTheme`, dan style komponen dasar (`AppBarTheme`
large-title transparan, `CardThemeData` radius `lg` elevation 0, `ElevatedButtonThemeData`
pill, `ListTileThemeData`, `DividerThemeData`). Ini adalah satu-satunya titik wiring —
API publik (`AppTheme.light`/`.dark`) tidak berubah dari sebelumnya, sehingga `app.dart`
tidak perlu disentuh.

---

## Dokumen Terkait

| Hubungan | Dokumen |
|----------|---------|
| Sistem & prinsip desain (mengunci struktur, menunda nilai) | [`09_design_system.md`](09_design_system.md) |
| Struktur arsitektur (`lib/app/theme/`) | [`04_architecture.md`](04_architecture.md) |
| Item roadmap Design System V1 | [`10_backlog.md`](10_backlog.md) |

_Turunan dari: [`09_design_system.md`](09_design_system.md)_
