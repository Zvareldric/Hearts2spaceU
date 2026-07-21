# Spec · Home Layout — Release 0.3.0 (Design System V1, Checkpoint 3)

> **Status:** 🟢 Disetujui — rev. 1 · **Dibuat:** 2026-07-21 · **Diperbarui:** 2026-07-21
> **Penanggung jawab:** Mohammad Rifqi Hidayat (Product Owner)
> **Epic:** Design System V1 · **Checkpoint:** 3 — Home Refresh
> **Branch:** `feature/schedule` (lanjutan Release 0.3.0)

Final Layout Specification untuk Home — ditulis **sebelum** kode. Setelah disetujui,
diimplementasikan bertahap dalam 4 sub-checkpoint, masing-masing mengikuti:
**Implement → Analyze → Visual Check → Commit → Push → Stop.**

---

## 0. Konteks

Mengeksekusi konsep Home dari **Design Proposal V1** (disetujui) yang sudah disetujui:
hero + greeting/branding + capability cards + "Up next". Semua nilai visual **wajib**
mengacu ke token [`docs/design-system-v1.md`](../design-system-v1.md) — **tanpa** angka
baru yang tidak tertelusur.

**Tidak berubah (arsitektur/logika):** `upcomingEventsProvider` (Sprint 2),
`memberRepositoryProvider`, Named Routes (`memberList`, `schedule`, `eventDetail`) —
Home murni **mengonsumsi** yang sudah ada.

## 1. Struktur Layout (top → bottom)

```
Scaffold
└─ body: SafeArea(bottom: false)
   └─ Center                                    ← responsive wrapper
      └─ ConstrainedBox(maxWidth: 600)
         └─ SingleChildScrollView
            └─ Column
               ├─ HeroSection                    ← full-bleed (edge-to-edge)
               └─ Padding(horizontal: 24)
                  └─ Column
                     ├─ SizedBox(height: 24)
                     ├─ Capability Cards Row      ← Members · Schedule
                     ├─ SizedBox(height: 32)
                     ├─ SectionHeader "UP NEXT"
                     ├─ SizedBox(height: 12)
                     ├─ Up Next Card (atau disembunyikan — lihat §5)
                     └─ SizedBox(height: 32)      ← ruang napas bawah
```

> **Keputusan:** Home **tidak lagi memakai `AppBar` standar.** Hero Section
> mengambil alih peran identitas (branding + greeting) di posisi paling atas.
> Halaman lain (Members, Schedule, Detail) **tetap** memakai `AppBar` bertema
> dari Checkpoint 1 — perubahan ini **khusus Home**.

## 2. Hero Section

| Properti | Nilai (token) |
|----------|---------------|
| Lebar | **full-bleed** — edge-to-edge, di luar `screenPadding` |
| Background | `LinearGradient(AppColors.heroGradient)`, `topLeft → bottomRight` |
| Radius | hanya sudut **bawah**, `AppRadius.xl` (28) — sudut atas persegi (menempel status bar) |
| Padding dalam | horizontal `AppSpacing.xl` (24) · top = *safe-area inset* + `AppSpacing.xl` (24) · bottom `AppSpacing.xxl` (32) |
| Tinggi | **intrinsik** (mengikuti konten) — bukan tinggi tetap |

**Konten (rata kiri, top → bottom):**

| Elemen | Style token | Contoh |
|--------|-------------|--------|
| Greeting | `bodyLarge`, warna `inkMuted` | "Good evening" *(time-aware: Morning &lt;12 · Afternoon &lt;18 · Evening lainnya)* |
| **Brand mark + Wordmark** | ikon dalam lingkaran + `displaySmall` warna `ink` | 🔵❤ **Hearts2spaceU** |
| Tagline | `bodyMedium`, warna `inkMuted` | "Your Hearts2Hearts companion" |

**Brand mark (revisi — elemen identitas visual):** lingkaran kecil 36×36, background `surface` (putih, kontras dari gradient), shadow `AppShadows.sm`, berisi `Icons.favorite_rounded` warna `primaryStrong` di tengah — placeholder logo sederhana (belum ada aset logo final; ikon hati merujuk "Hearts2Hearts", tanpa dependency baru). Diletakkan **sejajar** dengan wordmark dalam satu `Row` (mark → gap `AppSpacing.sm` (8) → teks wordmark), bukan di baris terpisah.

Jarak antar elemen: greeting→(mark+wordmark) `AppSpacing.xs` (4) · (mark+wordmark)→tagline `AppSpacing.sm` (8).

## 3. Capability Cards

- **Row** berisi 2× `CapabilityCard` (sudah ada dari Checkpoint 2, dipakai ulang **apa adanya**, tanpa modifikasi).
- Masing-masing `Expanded` (lebar setara); jarak antar-kartu `AppSpacing.md` (12) via `SizedBox(width: 12)`.
- Tinggi kartu **intrinsik** (konten pendek, secara alami setara — tidak perlu `IntrinsicHeight`, dievaluasi ulang bila visual pecah).

| Kartu | Icon | Title | Subtitle *(revisi — lebih natural)* | Aksi |
|-------|------|-------|----------|------|
| Members | `Icons.groups_rounded` | "Members" | "Meet Hearts2Hearts" | `pushNamed(AppRoutes.memberList)` |
| Schedule | `Icons.event_rounded` | "Schedule" | "Upcoming activities" | `pushNamed(AppRoutes.schedule)` |

## 4. Section Header ("Up next")

- Teks "UP NEXT" (uppercase), style `labelSmall` (sudah termasuk *tracking* +0.8 — peran *overline*), warna `inkMuted`.
- **Widget baru generik** `SectionHeader` di `app/widgets/layout/` (folder ini dibuat kosong di Checkpoint 2, baru terpakai sekarang) — menerima `String` polos, tanpa pengetahuan domain. Dipakai ulang oleh Schedule/Members Refresh bila relevan.

## 5. Up Next Card

Membaca `upcomingEventsProvider` (provider **sama persis** dengan Schedule, Sprint 2 — bukti reusabilitas lintas-halaman), mengambil **event pertama** (indeks 0, sudah terurut) bila ada.

| State provider | Perilaku Home *(revisi — konsisten, section selalu tampil)* |
|-----------------|----------------|
| `loading` | `LoadingView` versi ringkas (tanpa pesan) di slot kartu |
| `error` | **`ErrorView`** di slot kartu (pesan singkat + `Retry` → `ref.invalidate(upcomingEventsProvider)`) |
| `data`, kosong | **`EmptyView`** di slot kartu (pesan "No upcoming events yet.") |
| `data`, ada isi | Tampilkan **kartu ringkas** (bukan `EventCardRefresh` penuh — itu untuk daftar Schedule; di sini cukup teaser) |

Section header **"UP NEXT" selalu tampil**, apa pun state-nya — struktur Home tetap konsisten & dapat diprediksi (tidak ada bagian yang "menghilang").

**Kartu ringkas ("Up Next Card")** — widget baru **lokal ke `features/home/`** (bukan `app/widgets/`, karena spesifik menampilkan `Event`):
- Dibangun dari `AppCard` (generic building block, konsisten prinsip Checkpoint 2.5).
- Isi: ikon `Icons.event_rounded` dalam lingkaran ter-tint (kiri) · `event.title` (`titleMedium`) + `formatEventDateTime(event.startDateTime)` (`bodyMedium`, `inkMuted`) · chevron kanan.
- *Note lintas-feature:* memakai `formatEventDateTime` dari `features/schedule/presentation/` — konsisten dengan Home yang **sudah** bergantung ke `upcomingEventsProvider` milik Schedule; bukan kategori *coupling* baru.
- Tap → `pushNamed(AppRoutes.eventDetail, arguments: event.id)` (route yang sama dengan Schedule).

## 6. Coming Soon Section *(baru — revisi)*

Roadmap visual di **bagian paling bawah** Home: kapabilitas yang **belum tersedia**
(Collection, Gallery, Music, News), non-interaktif, berlabel **"Soon"**.

- `SectionHeader` "COMING SOON" (widget generik yang sama, §4).
- **2×2 grid** (dua `Row`, masing-masing 2× `Expanded`) — pola sama seperti Capability
  Cards (§3), jarak antar-kartu `AppSpacing.md` (12), antar-baris `AppSpacing.md` (12).
- Tiap kartu (widget baru generik `ComingSoonCard` di `app/widgets/cards/` — **tanpa**
  pengetahuan domain, hanya `icon`+`label`, aman di `app/widgets/`):
  - `AppCard` dengan **`onTap: null`** (non-interaktif, tanpa ripple) dan opacity
    diturunkan (~60%, lewat `Opacity`/warna `inkMuted`) → jelas terlihat *disabled*.
  - Ikon (muted, `inkMuted`) + label + badge pill **"Soon"** (widget generik baru
    `SoonBadge` di `app/widgets/badges/`, style senada `TypeBadge` tapi warna netral
    `surfaceTint`/`inkMuted`).

| Kartu | Icon |
|-------|------|
| Collection | `Icons.collections_bookmark_rounded` |
| Gallery | `Icons.photo_library_rounded` |
| Music | `Icons.music_note_rounded` |
| News | `Icons.newspaper_rounded` |

> Murni dekoratif/informatif — **tidak** ada route/provider/capability baru. Berfungsi
> sebagai peta jalan visual, sesuai `03_roadmap.md` (Early Growth/Future Expansion).

## 7. Out of Scope — Bottom Navigation *(catatan, bukan bagian layout ini)*

**Tidak ditambahkan pada Release 0.3.0.** Kapabilitas aktif masih sedikit (Members,
Schedule); Bottom Navigation sekarang berisiko banyak tab kosong/placeholder. **Home
tetap menjadi pusat navigasi** untuk saat ini. Evaluasi ulang saat kapabilitas aktif
mencapai **4–5 fitur nyata** — desain mengikuti kebutuhan produk, bukan sebaliknya.
*(Keputusan produk, dicatat di memori proyek — bukan Acceptance Criteria checkpoint ini.)*

## 8. Responsive Behavior

- **Target utama:** lebar ponsel (~360–430dp) — MVP mobile-first.
- **Lebar besar (tablet, ≥600dp):** konten dibatasi `ConstrainedBox(maxWidth: 600)` + `Center` — mencegah kartu/hero melar tak wajar (satu breakpoint, MVP-level, selaras `docs/09` "Breakpoint").
- **Vertikal:** `SingleChildScrollView` — konten pendek/perangkat kecil tidak overflow.
- **Safe area:** dihormati (`SafeArea` + padding-top Hero memakai inset asli).
- **Skala teks:** murni dari `TextTheme` (tidak ada ukuran font hardcoded di luar token) → pengaturan aksesibilitas OS tetap berfungsi otomatis (`docs/09` "Teks dapat diskalakan").
- **Content-first:** tinggi Hero & kartu mengikuti konten, bukan sebaliknya.

## 9. Sub-Checkpoint Breakdown

Dieksekusi berurutan — tiap sub-checkpoint: **Implement → Analyze → Visual Check → Commit → Push → Stop.**

| # | Sub-checkpoint | Isi | File utama |
|---|-----------------|-----|-------------|
| 3.1 | **Home Layout** | Skeleton: `SafeArea`+`ConstrainedBox`+`ScrollView`+`Column`, spacing/gap, wrapper responsif. Section diisi **placeholder** (`Container` warna netral) agar spacing/scroll teruji lebih dulu sebelum konten nyata. | `home_page.dart` (rewrite struktur) |
| 3.2 | **Hero Section** | Ganti placeholder Hero dengan `HeroSection` nyata (gradient, brand mark, greeting time-aware, wordmark, tagline). | `features/home/presentation/widgets/hero_section.dart` (baru) |
| 3.3 | **Capability Cards** | Ganti placeholder dengan Row `CapabilityCard` nyata + navigasi + copy baru (memakai ulang komponen Checkpoint 2 apa adanya). | `home_page.dart` (isi bagian ini) |
| 3.4 | **Up Next Section** | Ganti placeholder dengan `SectionHeader` + `UpNextCard` nyata, wiring `upcomingEventsProvider`, `LoadingView`/`EmptyView`/`ErrorView` konsisten. | `app/widgets/layout/section_header.dart` (baru) · `features/home/presentation/widgets/up_next_card.dart` (baru) |
| 3.5 | **Coming Soon Section** *(baru — revisi)* | `SectionHeader` "COMING SOON" + grid 2×2 `ComingSoonCard` (Collection/Gallery/Music/News), non-interaktif + `SoonBadge`. | `app/widgets/cards/coming_soon_card.dart` (baru) · `app/widgets/badges/soon_badge.dart` (baru) |

> 🔎 Catatan: 3.5 (Coming Soon) adalah penambahan saya di luar 4 sub-checkpoint awal yang Anda sebutkan — saya jadikan checkpoint terpisah (bukan digabung ke 3.4) karena ini blok visual berdiri sendiri. Beri tahu bila Anda ingin digabung/diurutkan ulang.

## 10. Acceptance Criteria

- [ ] Tidak ada `AppBar` standar di Home; identitas dibawa oleh Hero (dengan brand mark).
- [ ] Seluruh nilai visual (warna/radius/spacing/tipografi/shadow) berasal dari token — **tidak ada** angka baru di luar `docs/design-system-v1.md`.
- [ ] Capability Cards menavigasi ke `memberList`/`schedule` (route yang sudah ada, tidak diubah); copy = "Meet Hearts2Hearts" / "Upcoming activities".
- [ ] Up Next Card menavigasi ke `eventDetail` dengan `id` yang benar (route yang sudah ada).
- [ ] Section "Up next" **selalu tampil** dengan `LoadingView`/`EmptyView`/`ErrorView` yang konsisten sesuai state (§5) — tidak pernah disembunyikan.
- [ ] Section "Coming Soon" tampil non-interaktif dengan badge "Soon" untuk 4 kapabilitas (§6) — murni informatif, tanpa route/provider baru.
- [ ] Konten dibatasi `maxWidth: 600` pada layar lebar; scroll aman di layar pendek.
- [ ] **Home dapat dipahami dalam ±5 detik** — hierarki visual (Hero → 2 Capability Cards → Up Next) cukup jelas agar pengguna baru langsung paham "ini aplikasi apa & bisa apa" tanpa perlu membaca detail *(diverifikasi visual oleh Anda, bukan otomatis)*.
- [ ] **Hero tetap terasa menarik walau tidak ada event mendatang** — Hero (brand mark, greeting, wordmark, tagline) berdiri sendiri, tidak bergantung pada data Up Next untuk terasa "hidup" *(diverifikasi visual oleh Anda)*.
- [ ] `flutter analyze` bersih & **36/36 test lama tetap hijau** di setiap sub-checkpoint (Home tidak punya test khusus saat ini — tidak menyentuh test manapun).
- [ ] Tidak ada perubahan pada Domain/Data/Repository/Provider/Routes/Architecture.
- [ ] Tidak ada dependency baru. Tidak ada Bottom Navigation (§7 — ditunda).

## 11. Dokumen Terkait

| Hubungan | Dokumen |
|----------|---------|
| Token visual (sumber nilai) | [`design-system-v1.md`](../design-system-v1.md) |
| Sistem & prinsip desain | [`09_design_system.md`](../09_design_system.md) |
| Provider yang dipakai ulang | [`schedule.md`](schedule.md) |
