# Spec · Statistics — Sprint 10

> **Status:** 🟠 Draft (menunggu approval Product Owner) · **Dibuat:** 2026-07-29
> **Penanggung jawab:** Mohammad Rifqi Hidayat (Product Owner)
> **Branch:** `feature/statistics`

Perwujudan kapabilitas **Statistics** (Early Growth).

---

## 0. Konteks & Traceability

- **Capability:** *Statistics* — fase **🟡 Early Growth** ([`03`](../03_roadmap.md) §Capability
  Mapping, mendukung *Consistent & Enjoyable Experience*).
- **Lingkup ditetapkan Product Owner (2026-07-29):** **"rekor & pencapaian tetap"** —
  bukan angka yang cepat basi.

> ⚠️ **Keputusan lingkup yang menentukan seluruh desain ini.**
> Angka streaming, posisi tangga lagu, dan jumlah penonton **berubah tiap jam**. Menampilkannya
> berarti aplikasi ini rutin menyajikan angka yang salah — melanggar *Trusted Information*
> ([`02`](../02_product_vision.md)). Rekor tetap ("berapa piala yang pernah dimenangkan")
> tidak pernah basi: ia hanya bertambah.

## 1. Tujuan

Menjawab pertanyaan yang **tidak terjawab oleh daftar** — *"seberapa jauh Hearts2Hearts sudah
melangkah?"* — dengan merangkum pencapaian yang sudah tercatat menjadi beberapa angka yang
bisa dibaca dalam hitungan detik.

Halaman Awards menjawab **"apa saja"**. Statistics menjawab **"seberapa banyak"**.

## 2. Ruang Lingkup Sprint 10

**Masuk (In Scope):**
- **Ringkasan karier:** total pencapaian, piala ajang penghargaan, kemenangan acara musik,
  jumlah ajang berbeda, jumlah karya yang berprestasi.
- **Rincian per tahun** — berapa pencapaian tiap tahun, dengan batang proporsional sederhana.
- **Kemenangan acara musik per karya** — mis. `RUDE!` sekian kali.
- **Milestone platform** ditampilkan apa adanya (3 entri: YouTube/TikTok).
- Tap sebuah tahun → membuka **Awards** (daftar lengkapnya sudah ada di sana).
- State **Loading / Empty / Error**; entry dari Home.

**Di luar (Out of Scope):**
- **Angka yang cepat basi:** streaming, chart, jumlah penonton, follower. *(keputusan PO)*
- **Statistik pribadi pengguna** (berapa favorit yang saya simpan) — menarik, tapi itu milik
  Personal Collection, bukan kapabilitas ini.
- Perbandingan dengan grup lain — kita bukan situs peringkat.
- Grafik interaktif / *charting library*.

## 3. Use Cases

| ID | Sebagai | Saya ingin | Agar |
|----|---------|-----------|------|
| **UC-1** | penggemar | melihat ringkasan pencapaian grup dalam satu layar | paham sejauh mana perjalanan mereka tanpa membaca 52 entri |
| **UC-2** | penggemar baru | melihat perkembangan per tahun | tahu grup ini sedang menanjak |
| **UC-3** | penggemar | menekan satu tahun | melihat daftar lengkap pencapaian tahun itu di Awards |

## 4. Data yang Dibutuhkan

> 🎯 **Tidak ada berkas data baru. Tidak ada dependency baru.**

Seluruh angka **dihitung dari `assets/data/awards.json` yang sudah ada** — sumber yang sama
persis dengan halaman Awards.

**Kenapa dihitung, bukan disimpan?**

| Kalau disimpan (`statistics.json`) | Kalau dihitung |
|---|---|
| Dua sumber kebenaran untuk fakta yang sama | Satu sumber |
| PO menambah 1 piala → **wajib ingat** memperbarui angkanya | Angka ikut berubah sendiri |
| Bisa berbeda dari halaman Awards tanpa ketahuan | **Mustahil** bertentangan |

Ini penerapan langsung *Avoid Over-Engineering* ([`04`](../04_architecture.md)): angka
turunan tidak perlu tempat penyimpanan sendiri.

**Yang bisa dihitung dari skema `Award` saat ini** (`id`, `title`, `ceremony`, `year`,
`type`, `work`, `members`, `note`):

| Angka | Dari |
|-------|------|
| Total pencapaian | jumlah entri |
| Piala ajang penghargaan | `type == 'award'` |
| Kemenangan acara musik | `type == 'music-show'` |
| Milestone | `type == 'milestone'` |
| Jumlah ajang berbeda | `ceremony` unik |
| Karya berprestasi | `work` unik (non-null) |
| Per tahun | kelompokkan `year` |
| Kemenangan acara musik per karya | `type == 'music-show'` dikelompokkan `work` |

**Data Assumptions:**
- ⚠️ **Angka ini adalah "yang tercatat di aplikasi", bukan klaim resmi yang lengkap.**
  Isinya dikurasi PO dari sumber publik, jadi bisa saja ada piala yang belum terdaftar.
  Halaman **wajib** menyatakan ini secara jujur di bagian bawah — jangan biarkan angka
  hasil kurasi tampak seperti angka resmi.
- **Tidak ada rekor bertanggal** ("kemenangan pertama pada 3 Maret") karena `Award` hanya
  menyimpan `year` — dan itu disengaja ([`awards.md`](awards.md) §4: mengarang tanggal =
  menyatakan hal yang tak pernah disebut sumbernya).
- Data kosong → `EmptyView`, bukan deretan angka nol yang menyesatkan.

## 5. Arsitektur

```text
features/statistics/
├── domain/
│   └── career_stats.dart        # fungsi MURNI: computeStats(List<Award>)
└── presentation/
    ├── providers/statistics_providers.dart
    ├── pages/statistics_page.dart
    └── widgets/
        ├── stat_tile.dart       # satu angka besar + label
        └── year_bar.dart        # satu baris tahun + batang proporsional
```

**Tidak ada `data/` dan tidak ada repository baru.** Statistics **membaca ulang
`awardRepositoryProvider`** milik `features/awards`. Menambah repository kedua untuk berkas
yang sama hanya menambah kode tanpa menambah kemampuan (ADR-001: sebuah lapisan diperkenalkan
hanya bila memecahkan masalah nyata).

> Ketergantungan **satu arah** `statistics → awards`. Preseden sudah ada: `features/collection`
> membaca beberapa fitur lain. Yang dilarang (Checkpoint 2.5) adalah **Design System**
> bergantung pada entity fitur — bukan fitur pada fitur.

**`computeStats(awards)`** — fungsi murni, tanpa `DateTime.now()`: hasilnya hanya bergantung
pada masukan, jadi sepenuhnya deterministik saat diuji.

**Batang proporsional** digambar dengan `FractionallySizedBox` + `Container` berwarna —
Flutter bawaan. **Tidak menambah `fl_chart` atau sejenisnya**: satu batang horizontal tidak
membenarkan satu dependency (docs/05 §Dependency Policy).

**Reuse:** `AppCard`, `SectionHeader`, `LoadingView`/`EmptyView`/`ErrorView`, `StaggeredItem`,
token spacing/typography.

**Perubahan berkas non-fitur:** `app_routes.dart`/`app_router.dart` (+1 rute) ·
`home_page.dart` — **Capability Card kesembilan** ("Statistics"). Sembilan kartu berarti baris
terakhir hanya berisi satu kartu; slot sisanya dibiarkan kosong (`Expanded` kosong) agar lebar
kartu tetap seragam, **bukan** satu kartu melebar sendiri.

## 6. Acceptance Criteria

- [ ] UC-1: ringkasan karier tampil di layar pertama tanpa perlu scroll (360dp).
- [ ] UC-2: rincian per tahun tampil urut **tahun terbaru dulu**, dengan batang proporsional
      terhadap tahun tertinggi.
- [ ] UC-3: menekan satu tahun membuka halaman **Awards**.
- [ ] Semua angka **cocok** dengan isi `awards.json` — dibuktikan test yang menghitung dari
      aset asli, bukan dari angka yang ditulis tangan.
- [ ] Halaman menyatakan dengan jelas bahwa angka berasal dari **data yang tercatat di
      aplikasi**.
- [ ] Daftar kosong → `EmptyView`; **tidak** menampilkan "0" berderet.
- [ ] State **Loading / Error** tertangani.
- [ ] Home menampilkan **9 Capability Card**; tidak *overflow* di 360dp **(dibuktikan test)**.

## 7. Definition of Done (Sprint 10)

- [ ] Spec disetujui PO.
- [ ] **Tidak ada dependency baru. Tidak ada berkas data baru.**
- [ ] Seluruh **Acceptance Criteria** terpenuhi.
- [ ] `dart format` rapi & `flutter analyze` bersih.
- [ ] **Test:** unit (`computeStats`: daftar kosong, hitungan per tipe, `ceremony`/`work`
      unik, kelompok tahun urut turun, karya tanpa `work` tidak dihitung) + konsistensi
      terhadap aset asli + widget (state, tap tahun → Awards).
- [ ] **Verifikasi runtime oleh PO.**
- [ ] **GitHub Flow**: merge → hapus branch → tag `v0.11.0`.

## 8. Evolution Notes

**Bila `Award.awardedOn` mulai terisi:**
```
rekor per tahun  →  + rekor bertanggal ("kemenangan pertama", "beruntun")
```

**Bila statistik pribadi diinginkan:**
```
statistik grup  →  bagian terpisah di Personal Collection (bukan di sini)
```

**Bila data chart/streaming resmi tersedia dan stabil:**
```
rekor tetap  →  + angka bergerak, DI HALAMAN TERPISAH dengan stempel waktu
```
Jangan campur angka tetap dan angka basi di satu layar — pengguna tak bisa membedakan mana
yang masih benar.

## 9. Dokumen Terkait

| Hubungan | Dokumen |
|----------|---------|
| Kapabilitas & fase | [`03`](../03_roadmap.md) |
| Sumber data & alasan hanya menyimpan `year` | [`awards.md`](awards.md) |
| Kebijakan dependency | [`05`](../05_tech_stack.md) |
| Lapisan diperkenalkan hanya bila perlu (ADR-001) | [`04`](../04_architecture.md) |
