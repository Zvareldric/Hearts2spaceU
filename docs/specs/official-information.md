# Spec · Official Information — Sprint 1 (Member Profiles)

> **Status:** 🟢 Disetujui — rev. 1 · **Dibuat:** 2026-07-18 · **Diperbarui:** 2026-07-18
> **Penanggung jawab:** Mohammad Rifqi Hidayat (Product Owner)
> **Tahap:** Specification (sebelum kode) · **Branch:** `feature/official-information`

Dokumen ini adalah **Specification** (niat, bukan rekaman) untuk capability pertama. Ia ditulis **sebelum** kode sesuai alur kerja [`08`](../08_ai_guidelines.md). Persetujuan atas dokumen ini adalah gerbang sebelum audit `pubspec` dan implementasi.

---

## 0. Konteks & Traceability

- **Capability:** *Official Information* — kapabilitas MVP pada [`03_roadmap.md`](../03_roadmap.md).
- **Slice Sprint 1:** **Member Profiles** (daftar member → detail member). Slice lain dari capability ini (music, schedule, gallery, statistics) **di luar** Sprint 1.
- **Rantai traceability:**
  - **Why** → Value Proposition *Centralized Experience* + *Trusted Information* ([`02`](../02_product_vision.md)); prinsip *Official-source-first* ([`01`](../01_project_overview.md)).
  - **When** → kapabilitas *Official Information* di fase **MVP – Validate the Core Value** ([`03`](../03_roadmap.md)).
  - **How** → **ADR-001 Evolutionary Clean Architecture** + **Data Source Boundary** ([`04`](../04_architecture.md)).
  - **Tech** → **Riverpod** (state) & **Named Routes** ([`05`](../05_tech_stack.md)).
- **Prinsip Sprint 1 (dipegang):** *Capability drives implementation · Dependencies follow capabilities · Evolutionary Architecture over premature optimization.*

## 1. Tujuan Capability

Menyediakan **informasi resmi Hearts2Hearts yang terpusat dan tepercaya** di dalam aplikasi. Untuk Sprint 1, tujuan dipersempit menjadi: **memperkenalkan anggota grup** kepada penggemar melalui daftar member dan halaman detail tiap member, bersumber dari data yang **dikurasi dari sumber resmi**.

Tujuan Sprint (validasi): membuktikan bahwa vertikal **Data → Domain → Presentation** dapat berdiri di atas fondasi yang disepakati, menghasilkan pengalaman sederhana namun benar-benar berguna, tanpa dependency/arsitektur berlebih.

## 2. Ruang Lingkup Sprint 1

**Masuk (In Scope):**
- Menampilkan **daftar member** (nama panggung + info ringkas).
- Menampilkan **detail satu member**.
- Data dari **static JSON** yang dibundel sebagai aset aplikasi.
- Penanganan state **Loading / Empty / Error** ([`09`](../09_design_system.md)).
- Navigasi antar layar via **Named Routes**.

**Di luar (Out of Scope) — untuk sprint berikutnya:**
- Slice lain Official Information: music, schedule, gallery, statistics.
- Kapabilitas MVP lain: *Latest Updates*, *Official Streaming Hub*.
- Search, filter, favorit, share, edit data.
- Sumber data dinamis (hosted JSON / API / backend), caching, offline persistence.
- Foto member asli (Sprint 1 memakai **placeholder avatar**; aset gambar ditunda).
- Autentikasi, analitik, i18n/multibahasa.

## 3. Use Cases

| ID | Sebagai | Saya ingin | Agar |
|----|---------|-----------|------|
| **UC-1** | penggemar | melihat daftar member Hearts2Hearts | mengenali anggota grup dalam satu tempat |
| **UC-2** | penggemar | membuka detail satu member | mengetahui profil member dari sumber resmi |

**State yang wajib dirancang (per [`09`](../09_design_system.md)) untuk UC-1/UC-2:**
- **Loading** — saat membaca & mem-parsing aset JSON.
- **Success** — data tampil (daftar / detail).
- **Empty** — daftar member kosong (mis. file valid tapi tanpa isi).
- **Error** — aset gagal dibaca atau JSON gagal di-parse; tampilkan pesan yang ramah, bukan crash.

## 4. Data yang Dibutuhkan

**Sumber:** satu berkas JSON statis, dibundel sebagai aset: `assets/data/members.json`.

**Skema `Member` (minimal):**

| Field | Tipe | Wajib | Keterangan |
|-------|------|:----:|------------|
| `id` | string | ✅ | pengenal unik & stabil |
| `stageName` | string | ✅ | nama panggung (dipakai di daftar) |
| `fullName` | string | — | nama lengkap |
| `birthDate` | string (ISO `YYYY-MM-DD`) | — | tanggal lahir; **disimpan ISO, diformat hanya di Presentation** |
| `positions` | array&lt;string&gt; | — | mis. `["Vocalist","Dancer"]` |
| `profileImage` | string | — | referensi gambar profil; bila kosong → placeholder avatar |
| `officialProfileUrl` | string | — | URL profil resmi member (disimpan; **membuka**-nya ditunda) |

**Contoh struktur (nilai ilustratif — bukan data final):**

```json
[
  {
    "id": "member-01",
    "stageName": "…",
    "fullName": "…",
    "birthDate": "20XX-XX-XX",
    "positions": ["…"],
    "profileImage": null,
    "officialProfileUrl": null
  }
]
```

> ⚠️ **Official-source-first:** isi `members.json` **dikurasi Product Owner dari sumber resmi**. Spec ini hanya menetapkan **skema**, bukan nilai. Tidak ada data personal yang dikarang-karang.

**Catatan skema:**
- `birthDate` disimpan dalam format **ISO** (`YYYY-MM-DD`); **pemformatan tampilan hanya dilakukan di Presentation Layer** — domain & data tidak memformat tanggal (*Separation of Concerns*, [`04`](../04_architecture.md)).
- `officialProfileUrl` **disimpan** di model sejak Sprint 1, tetapi **membukanya** (butuh `url_launcher`) tetap **di luar** Sprint 1 — field boleh **ditampilkan sebagai teks**, belum sebagai aksi.

## 5. Arsitektur Capability

Mengikuti **ADR-001 (Evolutionary Clean Architecture)** dan **Data Source Boundary** ([`04`](../04_architecture.md)), dengan pola **feature-first**. Prinsip: *bentuk hanya lapisan yang benar-benar dibutuhkan slice ini*.

**Berkas baru (lean) di `lib/features/official_information/`:**

```text
features/official_information/
├── domain/
│   ├── member.dart                  # entity Member (murni, tanpa pengetahuan JSON)
│   └── member_repository.dart       # INTERFACE (kontrak) — abstract class
├── data/
│   └── asset_member_repository.dart # implements MemberRepository; baca aset JSON → decode → List<Member>
└── presentation/
    ├── providers/
    │   └── member_providers.dart    # Riverpod: repository (via interface) + AsyncValue<List<Member>>
    ├── pages/
    │   ├── member_list_page.dart   # UC-1 (+ Loading/Empty/Error)
    │   └── member_detail_page.dart # UC-2
    └── widgets/
        ├── member_card.dart
        └── async_state_views.dart  # tampilan Loading/Empty/Error yang konsisten
```

**Aliran data (searah, di balik Boundary):**

```text
members.json (aset)
   ↓  rootBundle + dart:convert           ← MENGISOLASI mekanisme sumber
MemberRepository (interface) → List<Member> (domain)   [impl: AssetMemberRepository]
   ↓  Riverpod (AsyncValue)
Presentation (list / detail)
```

**Keputusan lapisan (ADR-001 — layer diperkenalkan hanya bila memecahkan masalah nyata):**

| Lapisan | Sprint 1 | Alasan / trigger ADR-001 |
|---------|----------|--------------------------|
| **Domain Entity** (`Member`) | ✅ dibuat | inti model; memenuhi DoD "Domain terbentuk" |
| **Data (Repository)** | ✅ interface + 1 impl | `MemberRepository` (kontrak, domain) + `AssetMemberRepository` (impl, data) |
| **Repository *Interface*** | ✅ dibuat (keputusan PO) | biaya rendah; memperkuat **Data Source Boundary** jangka panjang & mempermudah *mock* untuk test — diadopsi sejak Sprint 1 |
| **Use Case** | ⏸️ ditunda | belum ada aturan bisnis berarti (hanya baca & tampil) |
| **DTO + Mapper** | ⏸️ ditunda | pemetaan JSON→`Member` nyaris 1:1; dipetakan inline di data layer, tanpa kelas Mapper |
| **Failure abstraction** | ⏸️ ditunda | error-handling masih sederhana (gagal baca/parse) |

**Perubahan pada berkas yang sudah ada (bukan restrukturisasi):**
- `lib/main.dart` — bungkus app dengan **`ProviderScope`** (mengaktifkan Riverpod). *Ini kebutuhan nyata pertama akan Riverpod.*
- `lib/routes/app_routes.dart` — tambah konstanta rute `memberList`, `memberDetail`.
- `lib/routes/app_router.dart` — daftarkan kedua rute; detail menerima argumen (`id`/`Member`) via `RouteSettings.arguments`.

> Struktur `features/home/` **tidak disentuh** (sesuai instruksi). `official_information` sengaja lebih lean daripada skeleton `home` — konsisten dengan ADR-001, dan `home` belum berisi kode nyata sehingga bukan pola yang sedang diikuti.

## 6. Dependency yang Diperlukan

> Diratifikasi pada **audit `pubspec`** (langkah setelah spec disetujui). Di sini analisis + usulannya.

**Diusulkan DITAMBAH (1 paket):**

| Paket | Untuk | Kenapa capability ini membutuhkannya |
|-------|-------|--------------------------------------|
| `flutter_riverpod` | State + DI | `AsyncValue` menangani Loading/Success/Empty/Error secara ringkas; **override provider** membuat repository dapat di-*mock* untuk widget/unit test (DoD butuh test). Mengeksekusi keputusan [`05`](../05_tech_stack.md), dipicu kebutuhan nyata — bukan sekadar "ada di docs/05". |

**Alternatif dipertimbangkan & DITOLAK untuk sekarang:** `FutureBuilder` + injeksi via konstruktor (0 paket). Ditolak karena penanganan Empty/Error kurang rapi/kurang dapat dipakai ulang, dan injeksi untuk test lebih berbelit dibanding override Riverpod.

**Sengaja TIDAK ditambah (dependencies follow capabilities):**

| Paket | Alasan tidak dipakai di Sprint 1 |
|-------|----------------------------------|
| `http` / `dio` | tidak ada jaringan — data dari aset lokal |
| `url_launcher` | tidak ada tautan keluar di slice ini (milik *Official Streaming Hub*) |
| `json_serializable` / `freezed` | `fromJson` manual untuk satu model kecil sudah cukup; hindari codegen prematur |
| local DB (mis. `isar`/`drift`) | tidak ada persistence/caching/offline di slice ini |

**Bawaan SDK (tanpa paket):** `dart:convert` (`jsonDecode`), `flutter/services.dart` (`rootBundle`).

**Registrasi aset (`pubspec` → `flutter/assets`):** `assets/data/members.json`.

## 7. Acceptance Criteria

- [ ] `assets/data/members.json` ada, ter-registrasi di `pubspec`, dan valid.
- [ ] UC-1: daftar member tampil dari JSON; tiap item menampilkan `stageName`.
- [ ] UC-2: menekan satu member membuka halaman detail berisi field yang tersedia.
- [ ] State **Loading / Empty / Error** ketiganya tertangani & dapat direproduksi.
- [ ] Navigasi list→detail memakai **Named Routes** (bukan push widget langsung).
- [ ] Navigasi **kembali** berfungsi: List → Detail → (back) → List, dan daftar tetap tampil.
- [ ] `Member` = entity domain murni; parsing JSON berada di data layer.
- [ ] Tidak ada `magic value` warna/spacing yang melanggar arah [`09`](../09_design_system.md) (placeholder token boleh).

## 8. Definition of Done (Sprint 1)

Selaras DoD Anda + [`06`](../06_coding_guidelines.md)/[`07`](../07_git_workflow.md)/[`10`](../10_backlog.md):

- [ ] Spec ini **disetujui** Product Owner.
- [ ] Dependency minimum **diratifikasi** (audit `pubspec`) → `flutter_riverpod` + registrasi aset.
- [ ] Struktur **Data → Domain → Presentation** terbentuk untuk `official_information`.
- [ ] Seluruh **Acceptance Criteria** terpenuhi.
- [ ] Project **buildable** (`flutter run` jalan di `main` setelah merge).
- [ ] `dart format` rapi & `flutter analyze` **bersih** ([`06`](../06_coding_guidelines.md)).
- [ ] **Test menguji perilaku:** unit test parsing/repository (sukses & error) + widget test list/detail (termasuk state).
- [ ] **Tidak ada `TODO`/`FIXME`/placeholder** yang tersisa di feature yang dinyatakan selesai ([`06`](../06_coding_guidelines.md)).
- [ ] **GitHub Flow** ([`07`](../07_git_workflow.md)): self-review → PR → merge ke `main` → hapus branch.

## 9. Dokumen Terkait

| Hubungan | Dokumen |
|----------|---------|
| Nilai & kapabilitas yang divalidasi | [`02`](../02_product_vision.md) · [`03`](../03_roadmap.md) |
| Aturan arsitektur (ADR-001, Boundary) | [`04`](../04_architecture.md) |
| Pilihan teknologi (Riverpod, Named Routes) | [`05`](../05_tech_stack.md) |
| Standar kode & DoD | [`06`](../06_coding_guidelines.md) · [`10`](../10_backlog.md) |
| Alur kerja & Git | [`08`](../08_ai_guidelines.md) · [`07`](../07_git_workflow.md) |
| State UI (Loading/Empty/Error) | [`09`](../09_design_system.md) |
