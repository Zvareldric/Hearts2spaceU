# Spec · Latest Updates — Sprint 3

> **Status:** 🟢 Disetujui (tanpa revisi) · **Dibuat:** 2026-07-27
> **Penanggung jawab:** Mohammad Rifqi Hidayat (Product Owner)
> **Branch:** `feature/latest-updates`

Specification untuk kapabilitas MVP ketiga. Ditulis **sebelum** kode ([`08`](../08_ai_guidelines.md));
persetujuan dokumen ini adalah gerbang sebelum audit `pubspec` & implementasi.

---

## 0. Konteks & Traceability

- **Capability:** *Latest Updates* — kapabilitas **MVP** ([`03`](../03_roadmap.md)).
- **Slice Sprint 3:** daftar kabar terbaru → detail kabar.
- **Rantai traceability:**
  - **Why** → *Centralized Experience* + *Trusted Information* ([`02`](../02_product_vision.md));
    "mengikuti aktivitas terbaru" ([`01`](../01_project_overview.md)).
  - **When** → fase **MVP** — menuntaskan kapabilitas MVP kedua dari tiga.
  - **How** → **ADR-001** + **Data Source Boundary** ([`04`](../04_architecture.md)).
  - **Tech** → **Riverpod**, **Named Routes**, dan — untuk pertama kalinya — **`http`** ([`05`](../05_tech_stack.md)).
- **Yang BARU vs Sprint 1 & 2:** sumber data **jaringan**, bukan aset lokal. Inilah momen
  yang diantisipasi **Data Source Boundary** sejak `04` ditulis.

## 1. Tujuan Capability

Menyediakan **kabar & aktivitas terbaru resmi** Hearts2Hearts di dalam aplikasi, sehingga
penggemar tidak perlu berpindah-pindah platform untuk tahu apa yang sedang terjadi.

Tujuan Sprint (validasi): membuktikan bahwa **mengganti sumber data dari aset lokal ke
jaringan tidak menuntut perubahan pada Presentation maupun State layer** — janji utama
Data Source Boundary.

## 2. Ruang Lingkup Sprint 3

**Masuk (In Scope):**
- **Daftar kabar terbaru**, terurut **waktu terbit menurun** (terbaru dulu).
- **Detail satu kabar**.
- Data dari **hosted JSON** yang diambil lewat jaringan (`http`).
- State **Loading / Empty / Error** — dengan **error jaringan** sebagai kasus nyata pertama.
- Navigasi via **Named Routes**; entry dari Home.

**Di luar (Out of Scope):**
- Caching / offline / penyimpanan lokal (ADR-002 — ditunda).
- *Pull-to-refresh*, *infinite scroll*, paginasi.
- Notifikasi push, penanda "sudah dibaca", bookmark.
- Membuka `sourceUrl` ke browser (butuh `url_launcher` — milik *Official Streaming Hub*).
- Gambar dari jaringan (`imageUrl` disimpan, belum ditampilkan).

## 3. Use Cases

| ID | Sebagai | Saya ingin | Agar |
|----|---------|-----------|------|
| **UC-1** | penggemar | melihat daftar kabar terbaru terurut waktu | tahu apa yang sedang terjadi |
| **UC-2** | penggemar | membuka detail satu kabar | membaca isinya dari sumber resmi |

**State (per [`09`](../09_design_system.md)):** Loading · Success · **Empty** (belum ada kabar)
· **Error** (gagal jaringan / parsing) — semuanya sudah tersedia dari Design System V1.

## 4. Data yang Dibutuhkan

**Sumber:** JSON **di-host**, diambil saat runtime.

**Usulan lokasi host (perlu persetujuan Anda):**
```
https://raw.githubusercontent.com/Zvareldric/Hearts2spaceU/main/data/updates.json
```
Berkas berada di folder **`data/` di root repo** — sengaja **dipisah** dari
`app/hearts2spaceu/assets/` agar jelas bedanya: `assets/` = dibundel ke dalam app,
`data/` = diambil lewat jaringan. Alasan memilih GitHub raw: gratis, sudah Anda kuasai,
ter-*version control*, tanpa infrastruktur baru — dan **memperbarui kabar cukup dengan
commit, tanpa merilis ulang aplikasi** (justru inti dari keputusan ini).

**Skema `Update`:**

| Field | Tipe | Wajib | Keterangan |
|-------|------|:----:|------------|
| `id` | string | ✅ | pengenal unik & stabil |
| `title` | string | ✅ | judul kabar |
| `publishedAt` | string (ISO 8601) | ✅ | **kunci** sort; disimpan ISO, di-*parse* di Data, **diformat hanya di Presentation** |
| `summary` | string | — | ringkasan singkat (tampil di kartu) |
| `body` | string | — | isi lengkap (tampil di detail) |
| `category` | string | — | mis. `announcement`, `release`, `award` (String dulu; *enum* = evolusi) |
| `sourceUrl` | string | — | tautan sumber resmi (disimpan; **membuka** ditunda) |
| `imageUrl` | string | — | gambar (disimpan; **menampilkan** ditunda) |

```json
[
  {
    "id": "iconic-heart-announcement",
    "title": "…",
    "publishedAt": "2026-07-05T10:00:00Z",
    "summary": "…",
    "category": "announcement",
    "sourceUrl": null
  }
]
```

**Data Assumptions:**
- `publishedAt` adalah ISO 8601 valid; field wajib hilang / tanggal rusak → **error**.
- Urutan dalam file **tidak** bermakna (berbeda dari `events.json`) — urutan ditentukan
  `publishedAt`; bila **sama**, dipertahankan urutan sumber (*stable sort*, sama seperti `03`).
- `id` unik; tanpa deduplikasi.
- Isi dikurasi Product Owner dari sumber resmi (*Official-source-first*).

## 5. Arsitektur Capability

**ADR-001** + **Data Source Boundary**, pola *feature-first*, **lean** — struktur identik
dengan `schedule`, hanya implementasi Data-nya yang berbeda.

```text
features/latest_updates/
├── domain/
│   ├── update.dart                  # entity Update (murni)
│   ├── update_repository.dart       # INTERFACE (kontrak)
│   └── latest_first.dart            # fungsi MURNI: latestFirst(updates)
├── data/
│   └── http_update_repository.dart  # implements UpdateRepository; ambil via http
└── presentation/
    ├── providers/update_providers.dart
    ├── pages/
    │   ├── latest_updates_page.dart  # UC-1
    │   └── update_detail_page.dart   # UC-2
    └── widgets/
        └── update_card.dart          # dibangun dari AppCard + TypeBadge
```

**Yang membuktikan Data Source Boundary:** `HttpUpdateRepository` menggantikan peran
`AssetXxxRepository` **di balik interface yang sama**. Provider, halaman, dan widget
**tidak tahu** datanya datang dari jaringan — strukturnya sama persis dengan Schedule.

**Penanganan jaringan (baru):**
- **Timeout** 10 detik — agar Loading tidak menggantung selamanya.
- Status non-200 → dilempar sebagai error → ditangkap provider → **`ErrorView` + Retry**
  (komponen yang sudah ada; tombol Retry akhirnya punya makna sesungguhnya —
  kegagalan jaringan memang **transien**, tak seperti aset lokal).
- **Auto-retry Riverpod tetap dimatikan** — Retry eksplisit lebih dapat diprediksi & sudah
  jadi pola aplikasi. *(Dapat dievaluasi ulang; lihat Evolution Notes.)*

**Reuse Design System (tanpa komponen baru):** `AppCard`, `TypeBadge`, `SectionHeader`,
`MetaRow`, `LoadingView`/`EmptyView`/`ErrorView`, `StaggeredItem`, `MetaRow`.

**Perubahan berkas non-fitur:** `app_routes.dart` (+`latestUpdates`, +`updateDetail`),
`app_router.dart` (+2 case), `home_page.dart` — kartu **"News" dipindah dari *Coming Soon*
menjadi *Capability Card* aktif** (lihat §6).

## 6. Keselarasan Penamaan Home

Kartu *Coming Soon* di Home saat ini memakai label **"News"**, sementara roadmap
menyebutnya **"Latest Updates"**. Sprint ini menyelaraskannya:

- Kartu "News" **keluar** dari grid *Coming Soon* → menjadi **Capability Card ketiga**
  berlabel **"Latest Updates"**, subjudul mis. *"What's happening now"*.
- Grid *Coming Soon* menyisakan **3 kartu** (Collection · Gallery · Music) → tata letaknya
  perlu disesuaikan (mis. 1 baris 3 kolom, atau 2+1).

> 📌 Label "Music" juga tidak selaras kosakata roadmap (kemungkinan maksudnya
> *Official Streaming Hub*). **Sengaja tidak diubah di sprint ini** agar scope tetap fokus —
> dicatat sebagai *housekeeping* untuk sprint berikutnya.

## 7. Dependency yang Diperlukan

> Diratifikasi pada audit `pubspec` setelah spec disetujui.

**DITAMBAH:** **`http`** — sudah diratifikasi di [`05`](../05_tech_stack.md) sejak 2026-07-18
dengan traceability yang **menyebut kapabilitas ini secara eksplisit**
(*"Kapabilitas Official Information/Latest Updates"*). Menambahkannya sekarang adalah
**menjalankan keputusan yang sudah ada**, bukan keputusan fondasi baru.

**Sengaja TIDAK dipakai:** `dio` (kebutuhan masih sederhana), `url_launcher` (di luar scope),
`intl` (format manual), local DB / `cached_network_image` (caching & gambar ditunda).

## 8. Acceptance Criteria

- [ ] `data/updates.json` ada di root repo, valid, dan dapat diakses publik via URL raw.
- [ ] UC-1: daftar kabar tampil dari **jaringan**, terurut **terbaru dulu**.
- [ ] UC-2: menekan kabar membuka detail; field opsional yang `null` **tidak dirender**.
- [ ] **Loading / Empty / Error** ketiganya tertangani; **error jaringan** menampilkan
      `ErrorView` + Retry yang benar-benar berfungsi memulihkan.
- [ ] Navigasi list→detail via **Named Routes**; **back** kembali ke list.
- [ ] Home menampilkan **Latest Updates sebagai Capability Card aktif**; grid Coming Soon
      tersisa 3 kartu dengan tata letak rapi.
- [ ] `Update` = entity murni; parsing di Data; sort di fungsi domain; format hanya di Presentation.
- [ ] **Presentation & Provider layer berpola identik dengan Schedule** — bukti Data Source
      Boundary bekerja meski sumber datanya berbeda total.

## 9. Definition of Done (Sprint 3)

- [ ] Spec ini **disetujui** PO.
- [ ] Dependency diratifikasi (audit `pubspec`) → `http`.
- [ ] Struktur **Data → Domain → Presentation** untuk `latest_updates`.
- [ ] Seluruh **Acceptance Criteria** terpenuhi.
- [ ] `dart format` rapi & `flutter analyze` **bersih**.
- [ ] **Test perilaku:** unit (`parseUpdates`; `latestFirst` — urutan menurun, tie-break stabil;
      repository: sukses / status non-200 / body rusak, memakai **mock HTTP client** tanpa
      jaringan nyata) + widget (Loading/Data/Empty/Error/Retry/Navigation).
- [ ] **Tidak ada `TODO`/`FIXME`** di feature yang selesai.
- [ ] **GitHub Flow**: self-review → merge → hapus branch → tag `v0.4.0`.

## 10. Evolution Notes

**If updates need to work offline:**
```
HttpUpdateRepository  →  + local cache (local DB / file cache)
```

**If the feed grows large:**
```
fetch-all  →  pagination / infinite scroll
```

**If network needs grow (interceptor, retry policy, upload):**
```
http  →  dio
```

**If network failures prove common:**
```
manual Retry only  →  re-enable Riverpod auto-retry (transient failures)
```

**If categories stabilize:**
```
category: String  →  enum UpdateCategory
```

**If the hosted JSON outgrows GitHub raw:**
```
GitHub raw  →  CDN / backend API (ADR-002)
```

## 11. Dokumen Terkait

| Hubungan | Dokumen |
|----------|---------|
| Nilai & kapabilitas | [`02`](../02_product_vision.md) · [`03`](../03_roadmap.md) |
| Aturan arsitektur & Boundary | [`04`](../04_architecture.md) |
| Teknologi (`http` sudah diratifikasi) | [`05`](../05_tech_stack.md) |
| Standar & DoD | [`06`](../06_coding_guidelines.md) · [`10`](../10_backlog.md) |
| Alur kerja & Git | [`08`](../08_ai_guidelines.md) · [`07`](../07_git_workflow.md) |
| Komponen & state UI | [`design-system-v1.md`](../design-system-v1.md) · [`09`](../09_design_system.md) |
| Preseden pola | [`schedule.md`](schedule.md) |
