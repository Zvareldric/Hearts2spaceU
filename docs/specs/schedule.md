# Spec · Schedule — Sprint 2 (Upcoming Events)

> **Status:** 🟢 Disetujui — rev. 1 · **Dibuat:** 2026-07-18 · **Diperbarui:** 2026-07-18
> **Penanggung jawab:** Mohammad Rifqi Hidayat (Product Owner)
> **Tahap:** Specification (sebelum kode) · **Branch:** `feature/schedule`

Specification untuk capability kedua. Ditulis **sebelum** kode (alur [`08`](../08_ai_guidelines.md)); persetujuan dokumen ini adalah gerbang sebelum audit `pubspec` & implementasi.

---

## 0. Konteks & Traceability

- **Capability:** *Schedule* — kapabilitas roadmap MVP ([`03`](../03_roadmap.md)); jadwal aktivitas resmi Hearts2Hearts.
- **Slice Sprint 2:** **Upcoming Events** (daftar acara mendatang → detail acara). Tampilan kalender & acara lampau **di luar** Sprint 2.
- **Rantai traceability:**
  - **Why** → Value Proposition *Centralized Experience* + *Organized Fandom Experience* ([`02`](../02_product_vision.md)); membantu penggemar **tetap terhubung** dengan aktivitas grup (Vision).
  - **When** → fase **MVP – Validate the Core Value** ([`03`](../03_roadmap.md)).
  - **How** → **ADR-001 Evolutionary Clean Architecture** + **Data Source Boundary** ([`04`](../04_architecture.md)).
  - **Tech** → **Riverpod** & **Named Routes** ([`05`](../05_tech_stack.md)).
- **Yang BARU vs Sprint 1** (bukan strukturnya, tapi): **penanganan waktu** — filter *upcoming* vs *past*, urutkan by tanggal, format tanggal+jam di lapisan yang benar.

## 1. Tujuan Capability

Menyediakan **jadwal aktivitas resmi** Hearts2Hearts secara terpusat. Sprint 2 dipersempit ke: menampilkan **acara yang akan datang**, terurut waktu, dari data yang dikurasi dari sumber resmi.

Tujuan Sprint (validasi): membuktikan vertikal Data→Domain→Presentation **menggeneralisasi** ke capability baru + bentuk data berbeda, dan menangani **logika waktu** pada lapisan yang tepat.

## 2. Ruang Lingkup Sprint 2

**Masuk (In Scope):**
- **Daftar acara mendatang** (memfilter yang sudah lewat), **terurut** tanggal menaik.
- **Detail satu acara**.
- Data dari **static JSON** yang dibundel sebagai aset.
- State **Loading / Empty / Error** ([`09`](../09_design_system.md)).
- Navigasi via **Named Routes**; entry dari Home.

**Di luar (Out of Scope):**
- Tampilan kalender, acara lampau/arsip, filter/kategori, pengingat/notifikasi.
- Sumber data dinamis (hosted JSON / API), caching, offline.
- Membuka `officialUrl` (butuh `url_launcher`).
- Zona waktu multi-region & pelokalan tanggal (`intl`).

## 3. Use Cases

| ID | Sebagai | Saya ingin | Agar |
|----|---------|-----------|------|
| **UC-1** | penggemar | melihat daftar acara mendatang terurut waktu | tahu apa yang akan terjadi & kapan |
| **UC-2** | penggemar | membuka detail satu acara | mengetahui rincian acara dari sumber resmi |

**State (per [`09`](../09_design_system.md)):** Loading (baca/parse aset) · Success (daftar/detail) · **Empty** (tak ada acara mendatang — sub-kasus `data`) · Error (gagal baca/parse).

## 4. Data yang Dibutuhkan

**Sumber:** `assets/data/events.json` (dibundel).

**Skema `Event`:**

| Field | Tipe | Wajib | Keterangan |
|-------|------|:----:|------------|
| `id` | string | ✅ | pengenal unik & stabil |
| `title` | string | ✅ | judul acara (dipakai di daftar) |
| `startDateTime` | string (ISO 8601) | ✅ | **kunci** sort/filter; **disimpan ISO**, di-*parse* → `DateTime` di Data, **diformat hanya di Presentation** |
| `type` | string | — | mis. `concert`, `broadcast`, `release`, `fanmeeting` (String dulu; *enum* = evolusi) |
| `location` | string | — | lokasi/tempat |
| `description` | string | — | deskripsi singkat |
| `officialUrl` | string | — | tautan resmi (disimpan; **membuka** ditunda) |

```json
[
  {
    "id": "evt-01",
    "title": "…",
    "startDateTime": "20XX-XX-XXT19:00:00",
    "type": "concert",
    "location": "…",
    "description": "…",
    "officialUrl": null
  }
]
```

> ⚠️ **Official-source-first:** isi `events.json` dikurasi Product Owner dari sumber resmi. Spec menetapkan **skema**, bukan nilai.

**Data Assumptions:**
- `startDateTime` adalah ISO 8601 valid; bila field wajib (`id`/`title`/`startDateTime`) hilang atau `startDateTime` tak dapat di-parse → dianggap **error** (dilempar, ditangkap jadi Error state).
- Semua `startDateTime` diasumsikan pada **satu zona waktu** (tanpa tz per-event untuk MVP); nilai dipakai apa adanya.
- `id` diasumsikan **unik** (sumber bersih; tanpa deduplikasi).
- **Urutan dalam file bermakna** — dipakai sebagai *tie-break* stabil saat dua event berwaktu sama.
- Field opsional boleh `null`/absen.

## 5. Arsitektur Capability

**ADR-001** + **Data Source Boundary**, pola *feature-first*, **lean**.

```text
features/schedule/
├── domain/
│   ├── event.dart                   # entity Event (murni)
│   ├── event_repository.dart        # INTERFACE (kontrak)
│   └── upcoming_events.dart         # fungsi MURNI: upcomingSorted(events, now)
├── data/
│   └── asset_event_repository.dart  # implements EventRepository; baca events.json
└── presentation/
    ├── providers/
    │   └── event_providers.dart     # eventRepositoryProvider + upcomingEventsProvider
    ├── pages/
    │   ├── schedule_page.dart        # UC-1 (Loading/Empty/Error/Data)
    │   └── event_detail_page.dart    # UC-2
    └── widgets/
        ├── event_card.dart
        ├── loading_view.dart         # DUPLIKAT (Rule of Three)
        ├── empty_view.dart           # DUPLIKAT
        └── error_view.dart           # DUPLIKAT
```

**Logika waktu — di mana:**
- **Parsing** ISO→`DateTime`: **Data layer** (`asset_event_repository`), seperti `birthDate` Sprint 1.
- **Filter *upcoming* + sort**: fungsi **murni** `upcomingSorted(List<Event> events, DateTime now)` di **domain** — dipanggil oleh `upcomingEventsProvider` dengan `DateTime.now()`. Karena murni & menerima `now` sebagai parameter, ia **deterministik & mudah di-unit-test** (tanpa jam nyata). Urutan **menaik** by `startDateTime`; bila **sama**, pertahankan **urutan sumber data** (*stable sort* — diimplementasikan dengan indeks asli sebagai tie-break, karena `List.sort` Dart tidak dijamin stabil).
- **Formatting** tanggal+jam: **Presentation** saja (manual, tanpa `intl` untuk MVP).

> Prinsip Anda dijaga: logika (filter/sort) ada di **provider + fungsi domain**, bukan di widget. Widget hanya `ref.watch` + render + navigasi.

**Keputusan lapisan (ADR-001):**

| Lapisan | Sprint 2 | Alasan |
|---------|----------|--------|
| Domain Entity (`Event`) | ✅ | inti model |
| Repository **Interface** | ✅ | konsisten dgn keputusan PO Sprint 1; kuatkan Boundary & test |
| Fungsi query murni (`upcomingSorted`) | ✅ | aturan kecil & jelas; cukup fungsi murni — **belum** perlu Use Case |
| Data (1 impl) | ✅ | satu sumber statis |
| Use Case / Mapper / Failure | ⏸️ ditunda | belum ada pemicu (ADR-001) |

**Perubahan berkas non-fitur:** `app_routes.dart` (+`schedule`, +`eventDetail`), `app_router.dart` (+2 case; detail terima `id` via `arguments`), `home_page.dart` (+ tombol "Schedule").

> **Rule of Three (keputusan PO):** `loading_view`/`empty_view`/`error_view` = **pemakaian ke-2** → **diduplikasi lokal**, belum dipindah ke `lib/shared/`. Pemakaian **ke-3** yang memicu ekstraksi.

## 6. Dependency yang Diperlukan

> Diratifikasi pada audit `pubspec` setelah spec disetujui.

**DITAMBAH:** **tidak ada paket baru.** `flutter_riverpod` sudah ada; `dart:convert` + `rootBundle` bawaan SDK.

**Registrasi aset:** `assets/data/events.json` di `pubspec` (`flutter/assets`).

**Sengaja TIDAK dipakai:** `http`/`dio` (sumber lokal), `url_launcher` (buka tautan di luar scope), `intl` (format manual dulu — hindari dependency prematur; evolusi saat butuh pelokalan).

## 7. Acceptance Criteria

- [ ] `assets/data/events.json` ada, ter-registrasi, valid.
- [ ] UC-1: hanya acara **mendatang** yang tampil, **terurut tanggal menaik**; acara lampau **tidak** tampil.
- [ ] UC-2: menekan acara membuka detail berisi field yang tersedia, dengan tanggal+jam **terformat**.
- [ ] State **Loading / Empty / Error** ketiganya tertangani.
- [ ] Navigasi list→detail via **Named Routes**; **back** kembali ke list.
- [ ] Field opsional yang `null`/absen **tidak dirender** (tak ada label/baris kosong).
- [ ] Dua event berwaktu sama tampil dalam **urutan sumber data** (*stable sort*).
- [ ] `Event` = entity murni; parsing di Data; filter/sort di fungsi domain/provider; format hanya di Presentation.

## 8. Definition of Done (Sprint 2)

- [ ] Spec ini **disetujui** PO.
- [ ] **Reusabilitas arsitektur Sprint 1 tervalidasi** — pola Domain/Data/Provider/Presentation + Data Source Boundary menggeneralisasi ke capability baru **tanpa** perubahan fondasi.
- [ ] Dependency diratifikasi (audit `pubspec`) → hanya registrasi aset `events.json` (tanpa paket baru).
- [ ] Struktur **Data → Domain → Presentation** untuk `schedule`.
- [ ] Seluruh **Acceptance Criteria** terpenuhi.
- [ ] Project **buildable**; `dart format` rapi & `flutter analyze` **bersih** ([`06`](../06_coding_guidelines.md)).
- [ ] **Test perilaku:** unit (`parseEvents`; `upcomingSorted` — lampau terbuang, mendatang terurut, batas = `now`) + widget (state + navigasi + acara lampau tak tampil).
- [ ] **Tidak ada `TODO`/`FIXME`/placeholder** di feature yang selesai.
- [ ] **GitHub Flow** ([`07`](../07_git_workflow.md)): self-review → PR → merge → hapus branch → tag `v0.2.0`.

## 9. Evolution Notes

Peta evolusi yang diantisipasi (arsitektur sekarang sengaja dibuat dapat berevolusi):

**If the schedule becomes remote:**
```
AssetEventRepository  →  HttpEventRepository
```
di balik `EventRepository` — Presentation & Provider **tidak berubah** (janji Data Source Boundary).

**If event categories stabilize:**
```
type: String  →  enum EventType
```

**If date localization becomes necessary:**
```
Manual formatting  →  intl
```

## 10. Dokumen Terkait

| Hubungan | Dokumen |
|----------|---------|
| Nilai & kapabilitas | [`02`](../02_product_vision.md) · [`03`](../03_roadmap.md) |
| Aturan arsitektur | [`04`](../04_architecture.md) |
| Teknologi | [`05`](../05_tech_stack.md) |
| Standar & DoD | [`06`](../06_coding_guidelines.md) · [`10`](../10_backlog.md) |
| Alur kerja & Git | [`08`](../08_ai_guidelines.md) · [`07`](../07_git_workflow.md) |
| State UI | [`09`](../09_design_system.md) |
| Preseden pola | [`official-information.md`](official-information.md) |
