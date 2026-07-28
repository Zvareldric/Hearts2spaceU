# Spec · Awards — Sprint 6

> **Status:** 🟢 Disetujui — rev. 2 · **Dibuat:** 2026-07-28
> **Penanggung jawab:** Mohammad Rifqi Hidayat (Product Owner)
> **Branch:** `feature/awards`

Specification untuk penghargaan yang diraih Hearts2Hearts. Ditulis **sebelum** kode
([`08`](../08_ai_guidelines.md)); persetujuan dokumen ini adalah gerbang sebelum implementasi.

---

## 0. Konteks & Traceability

- **Capability:** **perluasan *Official Information*** — kapabilitas **MVP** yang sudah aktif
  ([`03`](../03_roadmap.md) baris 53), yang cakupannya sengaja dibuka:
  *"…dan **informasi resmi lainnya — bukan daftar tetap**"*.
- **Bukan** *Statistics* (Early Growth). Keputusan Product Owner 2026-07-28 → **tidak
  melompati gerbang fase** MVP → Early Growth yang belum divalidasi.
- **Rantai traceability:**
  - **Why** → *Trusted Information* + *Centralized Experience* ([`02`](../02_product_vision.md)).
  - **When** → masih fase **MVP**.
  - **How** → **ADR-001** + **Data Source Boundary** ([`04`](../04_architecture.md)).
  - **Tech** → aset statis — **tanpa dependency baru**.

> 📌 **Catatan konstitusi:** [`01`](../01_project_overview.md) memasukkan *"statistik"* ke
> ruang lingkup MVP sementara [`03`](../03_roadmap.md) menempatkan *Statistics* di Early
> Growth. Dicatat, **tidak diubah** di sprint ini.

## 1. Tujuan

Menampilkan **seluruh pencapaian resmi** Hearts2Hearts di satu tempat, sehingga penggemar
dapat melihat rekam jejak grup tanpa menelusuri sumber yang tersebar.

## 2. Ruang Lingkup Sprint 6

Product Owner menyediakan daftar **52 pencapaian**. Setelah dibahas, **ketiganya masuk**:

| Jenis | Jumlah | Contoh |
|-------|-------:|--------|
| Penghargaan ajang | ~36 | MAMA Best New Artist · Golden Disc Most Popular Artist · SMA Bonsang |
| **Kemenangan acara musik** | 13 | *RUDE!* di M Countdown · *FOCUS* di Show Champion |
| **Milestone platform** | 3 | YouTube Silver/Golden Play Button · TikTok Silver Award |
| *(di antaranya)* pencapaian **individual member** | 4 | KGMA Individual Trend (Carmen) · ISAC relay (4 member) |

**Masuk (In Scope):**
- **Daftar seluruh pencapaian**, dikelompokkan **per tahun** (terbaru dulu), header menempel.
- **Detail satu pencapaian**.
- Pembeda **jenis** lewat badge: `award` · `music-show` · `milestone`.
- Penanda **member** untuk pencapaian individual.
- Data dari **aset statis** yang dibundel.
- State **Loading / Empty / Error**; entry dari Home.

**Di luar (Out of Scope):**
- **Nominasi** — hanya yang diraih.
- Gambar piala/foto penerimaan.
- Statistik chart, angka penjualan, sertifikasi.

## 3. Use Cases

| ID | Sebagai | Saya ingin | Agar |
|----|---------|-----------|------|
| **UC-1** | penggemar | melihat pencapaian grup per tahun | memahami rekam jejak mereka sekilas |
| **UC-2** | penggemar | membuka detail satu pencapaian | tahu ajang, kategori, dan konteksnya |

## 4. Data yang Dibutuhkan

**Sumber:** `assets/data/awards.json` — **dibundel** (penghargaan tidak pernah berubah
setelah diberikan; ini data paling stabil di aplikasi).

**Skema `Award`:**

| Field | Tipe | Wajib | Keterangan |
|-------|------|:----:|------------|
| `id` | string | ✅ | pengenal unik & stabil |
| `title` | string | ✅ | kategori/nama pencapaian, mis. `Best New Artist` |
| `ceremony` | string | ✅ | ajang/penyelenggara, mis. `MAMA Awards`, `M Countdown`, `YouTube` |
| `year` | int | ✅ | **kunci** pengelompokan & pengurutan |
| `type` | string | — | `award` (default) · `music-show` · `milestone` |
| `awardedOn` | string (ISO 8601) | — | **hanya diisi bila tanggalnya benar-benar diketahui** |
| `work` | string | — | lagu/album terkait, mis. `RUDE!` |
| `members` | array&lt;string&gt; | — | diisi bila pencapaian **individual**, mis. `["Carmen"]` |
| `note` | string | — | keterangan tambahan, mis. `March 2025` |
| `sourceUrl` | string | — | tautan resmi (**wajib `https://`**, divalidasi seperti [`streaming-hub.md`](streaming-hub.md) §6) |

```json
[
  {
    "id": "mama-2025-best-new-artist",
    "title": "Best New Artist",
    "ceremony": "MAMA Awards",
    "year": 2025,
    "type": "award"
  },
  {
    "id": "kgma-2025-individual-trend-may-carmen",
    "title": "Individual Trend of May Rookie",
    "ceremony": "KGMA",
    "year": 2025,
    "members": ["Carmen"]
  }
]
```

> 📌 **Kenapa `year` (int), bukan tanggal penuh? (revisi rev. 2)** Sebagian besar entri
> **hanya diketahui tahunnya** (*"2025 MAMA Awards"*). Mewajibkan tanggal penuh memaksa
> mengisi `2025-01-01` — **mengarang data**, persis kesalahan yang `allDay` di
> [`schedule.md`](schedule.md) diciptakan untuk mencegah. Karena daftar sudah dikelompokkan
> per tahun, kartunya **tidak perlu menampilkan tanggal** sama sekali. Lebih jujur sekaligus
> lebih sederhana. `awardedOn` tersedia untuk entri yang tanggalnya memang pasti.

**Data Assumptions:**
- Hanya pencapaian yang **diraih**; nominasi tidak dicatat.
- Urutan **dalam satu tahun** mengikuti urutan sumber (*stable*) — Product Owner yang
  menentukan prioritas tampilan; tidak ada pengurutan otomatis di dalam tahun.
- Beberapa entri **kembar** (mis. *RUDE!* menang di M Countdown 2×, Music Core 2×) —
  kemungkinan minggu berbeda. Keduanya dipertahankan dengan `id` berbeda dan dibedakan
  lewat `note` bila informasinya tersedia.
- Isi dikurasi Product Owner. ⚠️ Sumber daftar ini **komunitas penggemar**; beberapa ajang
  di dalamnya berskala kecil/fan-run. Diterima atas penilaian Product Owner.

## 5. Arsitektur

```text
features/awards/
├── domain/
│   ├── award.dart                   # entity (murni)
│   ├── award_repository.dart        # INTERFACE
│   └── year_groups.dart             # fungsi MURNI: groupByYear(awards) — tahun terbaru dulu
├── data/
│   └── asset_award_repository.dart
└── presentation/
    ├── providers/award_providers.dart
    ├── pages/
    │   ├── awards_page.dart          # UC-1 (header tahun menempel)
    │   └── award_detail_page.dart    # UC-2
    └── widgets/award_card.dart
```

> 🔎 **Kenapa folder `features/awards/`, bukan di dalam `official_information/`?**
> Secara *roadmap* ini perluasan Official Information, tetapi struktur folder mengikuti
> **kohesi kode**, bukan taksonomi roadmap. `official_information/` saat ini **hanya berisi
> Member**; menaruh Award di sana mencampur dua domain. *(Efek samping: nama folder itu
> sebenarnya kurang akurat — merapikannya pekerjaan tersendiri.)*

**Pengurutan:** tahun **menurun** (2026 → 2025). Di dalam tahun: urutan sumber
dipertahankan (`groupByYear` murni, tidak menyortir isi tahun).

**Reuse Design System (tanpa komponen baru):** `AppCard`, `TypeBadge`, `SectionHeader`,
`MetaRow`, `LoadingView`/`EmptyView`/`ErrorView`, `StaggeredItem`, `ExternalLinkButton`.

**Perubahan berkas non-fitur:**
- `app_routes.dart` / `app_router.dart` — +`awards`, +`awardDetail`.
- `home_page.dart` — **Capability Card kelima** ("Awards"), baris ke-3 berdampingan slot kosong.
- `pubspec.yaml` — registrasi aset `awards.json`.

## 6. ⚠️ Keputusan yang Masih Terbuka — Duplikasi Header Menempel

Halaman ini butuh **header tahun menempel**, mekanisme yang sama dengan header bulan di
`schedule_page.dart` (`_MonthHeaderDelegate`, ±25 baris boilerplate `SliverPersistentHeaderDelegate`).

Ini **pemakaian ke-2**. **Rule of Three** yang Anda tetapkan: ekstraksi ke `shared`/`app`
dilakukan pada pemakaian **ke-3**.

| Pilihan | Konsekuensi |
|---------|-------------|
| **Patuhi Rule of Three** | Duplikasi ±25 baris di `awards_page.dart`. Konsisten dengan aturan Anda. |
| **Ekstrak sekarang** | `app/widgets/layout/pinned_section_header.dart` (generik: label + tinggi). Hemat duplikasi, tapi menyimpang dari aturan Anda sendiri. |

Rekomendasi saya: **patuhi Rule of Three** — aturan yang dilanggar sesekali "karena
kelihatannya masuk akal" akan berhenti menjadi aturan.

## 7. Dependency

**Tidak ada dependency baru.**

## 8. Acceptance Criteria

- [ ] `assets/data/awards.json` ada, ter-registrasi, valid, memuat **52 pencapaian**.
- [ ] UC-1: tampil dikelompokkan **per tahun** (terbaru di atas) dengan **header menempel**.
- [ ] Badge membedakan `award` · `music-show` · `milestone`.
- [ ] Pencapaian individual menampilkan **nama member**-nya.
- [ ] UC-2: detail menampilkan field yang ada; field `null` **tidak dirender**.
- [ ] **Tidak ada tanggal yang dikarang** — kartu tidak menampilkan tanggal kecuali
      `awardedOn` benar-benar diisi.
- [ ] `sourceUrl` non-`https` **ditolak saat parsing**.
- [ ] State **Loading / Empty / Error** tertangani.
- [ ] Navigasi list→detail via **Named Routes**; **back** kembali ke list.
- [ ] Home menampilkan **5 Capability Card**; tidak *overflow* di lebar 360dp
      **(dibuktikan test, bukan diklaim)**.
- [ ] `Award` = entity murni; parsing di Data; grouping di fungsi domain.

## 9. Definition of Done (Sprint 6)

- [ ] Spec ini **disetujui** PO.
- [ ] Struktur **Data → Domain → Presentation** untuk `awards`.
- [ ] Seluruh **Acceptance Criteria** terpenuhi.
- [ ] `dart format` rapi & `flutter analyze` bersih.
- [ ] **Test perilaku:** unit (`parseAwards` termasuk penolakan non-https & default `type`;
      `groupByYear` termasuk urutan menurun & stabilitas dalam tahun) + widget (state,
      pengelompokan tahun, badge, navigasi).
- [ ] **Tidak ada `TODO`/`FIXME`**.
- [ ] **Data diverifikasi PO.**
- [ ] **Verifikasi runtime oleh PO.**
- [ ] **GitHub Flow**: merge → hapus branch → tag `v0.7.0`.

## 10. Evolution Notes

**If nominations should be shown:**
```
wins only  →  + result: 'won' | 'nominated'
```

**If exact ceremony dates become available:**
```
year + optional awardedOn  →  awardedOn everywhere (drop the year fallback)
```

**If a third pinned-header list appears:**
```
duplicated delegate  →  app/widgets/layout/pinned_section_header.dart  (Rule of Three tercapai)
```

**If individual achievements should surface on member pages:**
```
members: [] on Award  →  Member Detail queries awards by member
```

**If trophy images are added:**
```
text only  →  + bundled/remote images
```

## 11. Dokumen Terkait

| Hubungan | Dokumen |
|----------|---------|
| Kapabilitas induk & fase | [`03`](../03_roadmap.md) |
| Nilai produk | [`02`](../02_product_vision.md) |
| Arsitektur & Boundary | [`04`](../04_architecture.md) |
| Pelajaran "jangan karang tanggal" | [`schedule.md`](schedule.md) |
| Aturan keamanan URL | [`streaming-hub.md`](streaming-hub.md) |
| Komponen & state UI | [`design-system-v1.md`](../design-system-v1.md) |
