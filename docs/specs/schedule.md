# Spec · Schedule — Sprint 2 (Upcoming Events)

> **Status:** 🟢 Disetujui — rev. 2 · **Dibuat:** 2026-07-18 · **Diperbarui:** 2026-09-12
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

**Sumber:** API publik [h2hcalendar.com](https://h2hcalendar.com) *(sejak 2026-09-12 — lihat
amandemen di bawah)*. Sebelumnya `assets/data/events.json` (dibundel).

**Skema `Event`:**

| Field | Tipe | Wajib | Keterangan |
|-------|------|:----:|------------|
| `id` | string | ✅ | pengenal unik & stabil |
| `title` | string | ✅ | judul acara (dipakai di daftar) |
| `startDateTime` | string (ISO 8601) | ✅ | **kunci** sort/filter; **disimpan ISO**, di-*parse* → `DateTime` di Data, **diformat hanya di Presentation** |
| `allDay` | boolean | — | `true` bila acara **hanya punya tanggal**, tanpa jam pasti. Default `false`. *(ditambahkan 2026-07-28 — lihat catatan di bawah)* |
| `type` | string | — | mis. `concert`, `broadcast`, `release`, `fanmeeting` (String dulu; *enum* = evolusi) |
| `location` | string | — | lokasi/tempat |
| `description` | string | — | deskripsi singkat |
| `officialUrl` | string | — | tautan resmi; **wajib `https`**, kalau bukan → dibuang (event-nya tetap) |
| `zoneLabel` | string | — | nama jam yang dipakai `startDateTime`, mis. `KST`. *(2026-09-12)* |
| `zoneOffset` | Duration | — | selisih `zoneLabel` terhadap UTC. Kosong = zona tidak bisa dipastikan, jam tidak dikonversi. *(2026-09-12)* |

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

> 📌 **Kenapa `allDay` ditambahkan (amandemen 2026-07-28).** Jadwal resmi nyata ternyata
> sebagian besar hanya mencantumkan **tanggal**, tanpa jam. Karena `startDateTime` wajib
> berisi tanggal *dan* jam, mengisinya `T00:00:00` membuat UI menampilkan **"00:00"** —
> informasi yang **keliru**, seolah acaranya tengah malam. `allDay` membuat ketidaktahuan itu
> **eksplisit** alih-alih menyamarkannya sebagai data palsu.
>
> Alternatif yang **ditolak**: menebak jam yang "masuk akal" per jenis acara — itu mengarang
> data yang tidak ada di sumber, melanggar *Official-source-first*.
>
> **Batasan yang diketahui:** skema belum punya tanggal **selesai**, sehingga acara
> multi-hari (mis. fansign 17–18 Sep) disimpan memakai **tanggal mulai** saja. Rentangnya
> disebutkan di `description`. Lihat *Evolution Notes*.

> 📌 **Kenapa sumbernya pindah ke API kalender (amandemen 2026-09-12, keputusan PO).**
> `events.json` berisi 20 event hasil kurasi manual dari sebuah gambar jadwal, dan tidak
> pernah diperbarui lagi. [h2hcalendar.com](https://h2hcalendar.com) — dikelola S2U
> Philippines — membuka API JSON publik berisi **1.452 baris**, diperbarui harian, lengkap
> dengan jam dan zona waktu per event. PO memilih **fetch langsung** ke API mereka.
>
> **Risiko yang disampaikan sebelum keputusan, dan tetap berlaku:** app kita jadi bergantung
> pada server fan lain tanpa kontrak apa pun; skema mereka bisa berubah kapan saja dan
> servernya bisa mati. Yang meredam risiko itu ada di §5 — satu baris rusak tidak
> menjatuhkan tab, dan salinan terakhir disimpan lokal.
>
> **Aturan impor:**
>
> | Kasus | Perlakuan | Alasan |
> |-------|-----------|--------|
> | `yearly: true` | dilewati | Ulang tahun member disimpan pada tanggal **kejadian pertama** (2006–2010), jadi tanggalnya tidak berarti apa-apa. Ulang tahun sudah ada di Member Detail. |
> | Baris tanpa `id`/`title`/`date` valid | dilewati | Feed milik orang lain; satu baris rusak tidak boleh mengosongkan Schedule. |
> | `time` kosong | `allDay: true` | Aturan `allDay` yang sudah ada — jangan mencetak 00:00 yang tidak pernah disebut sumber. |
> | `source` bukan `https` | tautan dibuang, event tetap | Tautan adalah bagian paling tidak penting di baris itu. |
> | Payload bukan array | **error** | Ini "kalendernya sedang down", bukan "satu baris rusak". |
> | `cat` tak dikenal app | diteruskan apa adanya | `TypeBadge` sudah menangani tipe asing dengan pill netral. |

**Data Assumptions:**
- Bila **seluruh payload** tidak bisa dibaca → **error** (ditangkap jadi Error state). Bila **satu baris** tidak bisa dibaca → baris itu dilewati, sisanya tetap tampil.
- `startDateTime` adalah **jam dinding di zona `zoneLabel`**, bukan instant absolut. Konversi ke jam pembaca dilakukan di presentation lewat `toReaderClock`.
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

**✅ Sudah terjadi (2026-09-12) — the schedule became remote:**
```
AssetEventRepository  →  CalendarEventRepository + CachedEventRepository
```
Janji Data Source Boundary **ditepati**: `EventRepository` hanya bertambah satu parameter
opsional (`forceRefresh`), dan `upcomingSorted` / `groupByMonth` / `EventCard` / Agenda /
Home tidak berubah sama sekali. Yang berubah hanya isi `eventRepositoryProvider`.

> ⚠️ **Utang yang ditinggalkan:** `AssetEventRepository` dan `assets/data/events.json`
> (20 event kurasi PO) **tidak lagi dipakai** app, tapi belum dihapus — menghapus data
> kurasi PO bukan keputusan yang boleh diambil sendiri. Pilihannya: hapus, atau pakai
> sebagai bekal offline saat kalender tidak bisa dihubungi dan cache masih kosong.

**If event categories stabilize:**
```
type: String  →  enum EventType
```

**If multi-day events need to show their full range:**
```
startDateTime only  →  + endDateTime (optional)
```

**If date localization becomes necessary:**
```
Manual formatting  →  intl
```

**If the calendar starts using a zone with daylight saving:**
```
tabel offset tetap  →  paket `timezone`
```
Sekarang hanya `Europe/Paris` (1 dari 1.452 baris) yang tidak bisa dikonversi, dan event
seperti itu ditampilkan apa adanya dengan labelnya. Kalau jumlahnya bertambah banyak,
barulah sebuah paket tz sepadan dengan bobotnya.

**If the reader wants to filter the feed:**
```
semua kategori  →  filter chip per kategori
```
PO memutuskan **semua 1.452 event masuk** (2026-09-12). Dalam praktiknya `upcomingSorted`
sudah memangkasnya jadi ~29 event mendatang, jadi kekhawatiran "Schedule berubah jadi feed"
belum terbukti. Filter baru diperlukan kalau kalender mulai mengisi jauh ke depan.

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
