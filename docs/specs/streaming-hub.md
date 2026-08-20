# Spec · Official Streaming Hub — Sprint 4

> **Status:** 🟢 Disetujui (tanpa revisi) · **Dibuat:** 2026-07-28
> **Penanggung jawab:** Mohammad Rifqi Hidayat (Product Owner)
> **Branch:** `feature/streaming-hub`

Specification untuk **kapabilitas MVP terakhir**. Ditulis **sebelum** kode
([`08`](../08_ai_guidelines.md)); persetujuan dokumen ini adalah gerbang sebelum audit
`pubspec` & implementasi.

---

## 0. Konteks & Traceability

- **Capability:** *Official Streaming Hub* — kapabilitas **MVP** ketiga & terakhir
  ([`03`](../03_roadmap.md)). **Menuntaskan MVP.**
- **Definisi tegas** ([`01`](../01_project_overview.md)): menghubungkan pengguna ke platform
  resmi lewat *deep link* — **bukan pemutar konten**. Hearts2spaceU tidak menyalurkan
  musik/video sendiri; ia mengantar pengguna ke layanan resmi.
- **Rantai traceability:**
  - **Why** → *Centralized Experience* + *Trusted Information* ([`02`](../02_product_vision.md)).
  - **When** → fase **MVP**; setelah ini gerbang MVP → Early Growth dapat dievaluasi.
  - **How** → **ADR-001** + **Data Source Boundary** ([`04`](../04_architecture.md)).
  - **Tech** → **`url_launcher`** ([`05`](../05_tech_stack.md), diratifikasi 2026-07-18 dengan
    traceability yang menyebut kapabilitas ini persis).
- **Yang BARU vs sprint sebelumnya:** aplikasi untuk pertama kalinya **keluar** ke aplikasi
  lain, dan untuk pertama kalinya menyentuh **konfigurasi native** (Android/iOS).

## 1. Tujuan Capability

Menyediakan **satu tempat berisi seluruh kanal resmi** Hearts2Hearts — musik, video, sosial,
komunitas — sehingga penggemar tidak perlu mencari-cari tautan yang benar dan tidak berisiko
membuka kanal palsu (*Trusted Information*).

Tujuan Sprint: **menuntaskan MVP** dan membuktikan aplikasi dapat berintegrasi dengan
ekosistem luar secara bertanggung jawab.

## 2. Ruang Lingkup Sprint 4

**Masuk (In Scope):**
- **Daftar platform resmi** dikelompokkan per kategori (Music · Video · Social · Community).
- **Tap → membuka** aplikasi/situs resmi platform tersebut.
- State **Loading / Empty / Error** (aset lokal, jadi error praktis langka).
- Entry dari Home (Capability Card keempat).
- **Mengaktifkan 3 tombol "(soon)" yang sudah ada**: `sourceUrl` (Update detail),
  `officialUrl` (Event detail), `officialProfileUrl` (Member detail).
- **Konfigurasi native** yang diperlukan `url_launcher`.

**Di luar (Out of Scope):**
- Halaman detail platform — tap langsung keluar aplikasi, tak ada layar antara.
- Pemutar musik/video di dalam aplikasi (**Non-Goal permanen**, [`01`](../01_project_overview.md)).
- Tautan per rilisan musik (menunggu kapabilitas *Music Releases*).
- Ikon/logo resmi tiap platform (butuh aset gambar & pertimbangan merek dagang) —
  memakai ikon Material generik dulu.
- *In-app browser* (WebView).

## 3. Use Cases

| ID | Sebagai | Saya ingin | Agar |
|----|---------|-----------|------|
| **UC-1** | penggemar | melihat daftar kanal resmi grup | tahu di mana saja bisa mengikuti mereka |
| **UC-2** | penggemar | menekan satu platform | langsung dibawa ke kanal resminya |
| **UC-3** | penggemar | menekan tautan sumber di halaman detail | membaca/memverifikasi dari sumber aslinya |

## 4. Data yang Dibutuhkan

**Sumber:** `assets/data/platforms.json` — **dibundel** (bukan jaringan).

> 📌 **Kenapa statis, bukan hosted seperti Latest Updates?** URL kanal resmi praktis tidak
> pernah berubah (akun Spotify/YouTube grup stabil bertahun-tahun). Menjadikannya bergantung
> jaringan hanya menambah titik gagal untuk data yang tak dinamis — dan hub ini justru paling
> dibutuhkan saat pengguna ingin cepat, termasuk saat sinyal buruk.

**Skema `OfficialPlatform`:**

| Field | Tipe | Wajib | Keterangan |
|-------|------|:----:|------------|
| `id` | string | ✅ | pengenal unik & stabil |
| `name` | string | ✅ | nama platform (mis. `Spotify`) |
| `url` | string | ✅ | URL kanal resmi (**wajib `https://`** — lihat §6) |
| `category` | string | ✅ | `music` · `video` · `social` · `community` |
| `handle` | string | — | nama akun (mis. `@hearts2hearts`) |

```json
[
  {
    "id": "spotify",
    "name": "Spotify",
    "url": "https://open.spotify.com/artist/…",
    "category": "music",
    "handle": null
  }
]
```

**Data Assumptions:**
- Field wajib hilang → **error**; URL non-`https` **ditolak** saat parsing (§6).
- **Urutan dalam file bermakna** — dipakai apa adanya di dalam tiap kategori (Product Owner
  yang menentukan prioritas tampilan); tidak ada pengurutan otomatis.
- Kategori di luar keempat nilai di atas tetap ditampilkan, dikelompokkan sebagai "Other".
- Isi dikurasi Product Owner dari sumber resmi (*Official-source-first*).

## 5. Arsitektur Capability

```text
lib/shared/services/
└── url_opener.dart                   # BARU — dipakai 4 fitur, bukan milik satu fitur

features/streaming_hub/
├── domain/
│   ├── official_platform.dart        # entity (murni)
│   ├── platform_repository.dart      # INTERFACE
│   └── grouped_platforms.dart        # fungsi MURNI: groupByCategory(platforms)
├── data/
│   └── asset_platform_repository.dart
└── presentation/
    ├── providers/platform_providers.dart
    ├── pages/streaming_hub_page.dart  # UC-1 + UC-2
    └── widgets/platform_card.dart
```

**`UrlOpener` — layanan bersama (kunci sprint ini):**
- Berada di **`lib/shared/services/`**, bukan di dalam fitur — karena **4 tempat** memakainya
  (Streaming Hub + 3 halaman detail). Tetap **domain-agnostic** (hanya menerima `String`),
  jadi tidak melanggar aturan Checkpoint 2.5.
- Dibungkus **provider Riverpod** (`urlOpenerProvider`) supaya **dapat di-*override* saat
  test** — tanpa ini, widget test akan benar-benar mencoba membuka browser.
- Mengembalikan **berhasil/gagal**; UI menampilkan `SnackBar` ringkas bila gagal
  (mis. tak ada aplikasi yang bisa menanganinya).

**Reuse Design System (tanpa komponen baru):** `AppCard`, `SectionHeader` (judul kategori),
`TypeBadge`, `LoadingView`/`EmptyView`/`ErrorView`, `StaggeredItem`.

**Perubahan berkas non-fitur:**
- `app_routes.dart` / `app_router.dart` — +`streamingHub` (satu rute, tanpa detail).
- `home_page.dart` — **Capability Card keempat** ("Official Channels"). Empat kartu → tata
  letak 2×2, dan **`Music` dikeluarkan dari Coming Soon** karena kapabilitas ini yang
  memenuhinya (menyelesaikan ketidakselarasan label yang tercatat di Sprint 3).
  *(Home sejak Design System V2 memakai quick action, dan sejak 2026-08-20 quick action
  "Music" menuju halaman Music — lihat §11.)*
- 3 halaman detail — tombol `SecondaryButton` "(soon)" menjadi aktif.

## 6. Keamanan Tautan

Membuka URL dari data eksternal berarti aplikasi mengantar pengguna ke luar. Aturan minimum:

- **Hanya skema `https`** yang diterima. URL dengan skema lain (`http`, `javascript:`,
  `file:`, custom scheme) **ditolak saat parsing** dan dianggap data rusak.
- Rasionalnya: `platforms.json` dikurasi Product Owner, tetapi `sourceUrl`/`officialUrl`
  pada Update/Event **berasal dari `updates.json` yang di-host** — memvalidasi skema
  mencegah tautan berbahaya masuk lewat jalur itu.
- **`mode: LaunchMode.externalApplication`** — membuka di aplikasi/browser sistem, bukan
  WebView dalam aplikasi, sehingga pengguna melihat bilah alamat asli dan tahu ia sudah
  keluar dari Hearts2spaceU.

## 7. Konfigurasi Native

Pertama kalinya menyentuh berkas platform. Yang dibutuhkan `url_launcher`:

| Platform | Perubahan | Alasan |
|----------|-----------|--------|
| **Android** | `<queries>` + `intent` untuk skema `https` di `AndroidManifest.xml` | Android 11+ menyembunyikan aplikasi lain; tanpa ini `canLaunchUrl` selalu `false` |
| **iOS** | *(tidak perlu)* | `LSApplicationQueriesSchemes` hanya untuk *custom scheme*; kita hanya memakai `https` |
| **macOS** | *(sudah ada)* | `com.apple.security.network.client` ditambahkan pada `383bb1a` |

## 8. Acceptance Criteria

- [ ] `assets/data/platforms.json` ada, ter-registrasi di `pubspec`, valid.
- [ ] UC-1: platform tampil dikelompokkan per kategori, urut sesuai file.
- [ ] UC-2: menekan platform membuka kanal resminya di **aplikasi/browser eksternal**.
- [ ] UC-3: ketiga tombol "(soon)" aktif dan membuka tautannya; label "(soon)" **dihapus**.
- [ ] URL non-`https` **ditolak** saat parsing (ada test-nya).
- [ ] Kegagalan membuka tautan menampilkan `SnackBar`, **tidak** membuat app diam saja.
- [ ] `UrlOpener` dapat di-*override* — **tidak satu pun test membuka browser sungguhan**.
- [ ] Home menampilkan **4 Capability Card** (2×2); `Music` **keluar** dari Coming Soon.
- [ ] Android `<queries>` ditambahkan.
- [ ] `flutter analyze` bersih & seluruh test hijau.

## 9. Definition of Done (Sprint 4)

- [ ] Spec ini **disetujui** PO.
- [ ] Dependency diratifikasi (audit `pubspec`) → `url_launcher`.
- [ ] Struktur **Data → Domain → Presentation** untuk `streaming_hub`.
- [ ] Seluruh **Acceptance Criteria** terpenuhi.
- [ ] `dart format` rapi & `flutter analyze` bersih.
- [ ] **Test perilaku:** unit (`parsePlatforms` termasuk penolakan non-https;
      `groupByCategory`; repository) + widget (state, pengelompokan, tap memanggil
      `UrlOpener` yang di-*mock*, kegagalan → SnackBar).
- [ ] **Tidak ada `TODO`/`FIXME`** di feature yang selesai.
- [ ] **Verifikasi runtime oleh PO** — tap benar-benar membuka aplikasi/situs yang tepat.
      *(Pelajaran dari `383bb1a`: analyze+test hijau ≠ berjalan di perangkat.)*
- [ ] **GitHub Flow**: merge → hapus branch → tag `v0.5.0` → **MVP LENGKAP** 🎉

## 10. Evolution Notes

**If official app deep links are wanted (open in the Spotify app, not the browser):**
```
https URLs only  →  + custom schemes (spotify:) + LSApplicationQueriesSchemes
```

**If platform links start changing often:**
```
bundled assets/platforms.json  →  hosted data/platforms.json (like updates)
```

**If brand icons are added:**
```
generic Material icons  →  bundled brand assets (mind trademark usage terms)
```

**If categories stabilize:**
```
category: String  →  enum PlatformCategory
```

---

## 11. Perubahan Setelah Rilis

### Judul "Music" → "Official Channels", dan pintu masuknya *(2026-08-20)*

Kapabilitas *Discography* membuat kata "Music" dipakai dua kali: More punya tile
"Discography" (rilis) **dan** tile "Music" (halaman ini). Dua pintu untuk satu
kapabilitas, padahal rilis-lah isi sebenarnya dari "Music"
([`discography.md`](discography.md) §7).

Yang berubah pada hub ini:

| | Sebelum | Sesudah |
|---|---------|---------|
| Judul halaman | "Music" | **"Official Channels"** |
| Pintu masuk More | tile "Music" | *(tidak ada — lewat halaman Music)* |
| Pintu masuk Home | quick action "Music" | *(tidak ada — lewat halaman Music)* |
| Pintu masuk lain | Release detail | Release detail **+ halaman Music** |

Judul barunya lebih jujur terhadap isinya: halaman ini mengelompokkan **music · video ·
social · community** (§4), jadi "Music" selalu menamai terlalu sempit — dan sekarang nama
itu sudah menamai layar lain.

**Ruang lingkup dan Non-Goal §2 tidak berubah.** Hub ini tetap *link out*, tetap tanpa
halaman detail platform, dan tetap bukan pemutar konten. Route **`/channels` tetap ada**
dan tetap dipanggil dengan nama; yang hilang hanya tile-nya di More.

## 12. Dokumen Terkait

| Hubungan | Dokumen |
|----------|---------|
| Definisi & Non-Goal kapabilitas | [`01`](../01_project_overview.md) · [`02`](../02_product_vision.md) |
| Fase & gerbang MVP | [`03`](../03_roadmap.md) |
| Arsitektur & Boundary | [`04`](../04_architecture.md) |
| `url_launcher` (sudah diratifikasi) | [`05`](../05_tech_stack.md) |
| Komponen & state UI | [`design-system-v1.md`](../design-system-v1.md) |
| Preseden pola | [`schedule.md`](schedule.md) · [`latest-updates.md`](latest-updates.md) |
