# Spec · Voting Hub — Sprint 9

> **Status:** 🟠 Draft (menunggu approval Product Owner) · **Dibuat:** 2026-07-29
> **Penanggung jawab:** Mohammad Rifqi Hidayat (Product Owner)
> **Branch:** `feature/voting-hub`

Perwujudan kapabilitas **Enhanced Fandom Support** (Early Growth).

---

## 0. Konteks & Traceability

- **Capability:** *Enhanced Fandom Support* — fase **🟡 Early Growth** ([`03`](../03_roadmap.md)).
  `03` hanya menyebut namanya; **isinya didefinisikan di sini** atas keputusan Product Owner
  2026-07-29.
- **Why** → *Organized Fandom Experience* + *Consistent & Enjoyable Experience*
  ([`02`](../02_product_vision.md)).
- **Dasar definisi:** konstitusi konsisten menyebut *"**mengelola** aktivitas fandom secara
  lebih teratur"* ([`02`](../02_product_vision.md) §Positioning) — membantu penggemar
  **mengorganisir**, bukan menyediakan ruang sosial.

> ⚠️ **Batas yang dihormati:** [`01`](../01_project_overview.md) §7 menaruh *"media sosial
> penuh / interaksi antar-penggemar"* di **luar cakupan**. Voting Hub **tidak** menampung
> komentar, forum, atau interaksi antar-pengguna — ia hanya mengantar ke platform voting
> resmi, persis seperti [`streaming-hub.md`](streaming-hub.md) mengantar ke platform musik.

## 1. Tujuan

Menyatukan **voting resmi yang sedang berlangsung** di satu tempat, lengkap dengan batas
waktunya — sehingga penggemar tidak melewatkan kesempatan mendukung grup hanya karena
informasinya tersebar.

## 2. Ruang Lingkup Sprint 9

**Masuk (In Scope):**
- **Daftar voting** yang **sedang buka** dan yang **akan datang**, terurut batas waktu terdekat.
- **Sisa waktu** tiap voting ("closes in 3 days").
- **Tap → membuka situs/aplikasi voting resmi** (`UrlOpener`, sudah ada).
- Voting yang **sudah tutup disembunyikan** — tautannya tak lagi berguna.
- State **Loading / Empty / Error**; entry dari Home.

**Di luar (Out of Scope):**
- **Voting di dalam aplikasi** — kita mengantar, bukan menyelenggarakan.
- Notifikasi/pengingat batas waktu (butuh package notifikasi — sprint tersendiri).
- Jumlah suara, peringkat, atau statistik voting.
- Komentar/diskusi antar-penggemar (**Non-Goal**, lihat §0).

## 3. Use Cases

| ID | Sebagai | Saya ingin | Agar |
|----|---------|-----------|------|
| **UC-1** | penggemar | melihat voting yang sedang berlangsung & batas waktunya | tidak melewatkan kesempatan mendukung |
| **UC-2** | penggemar | menekan satu voting | langsung dibawa ke platform resminya |

## 4. Data yang Dibutuhkan

**Sumber:** `data/voting.json` **di-host** — pola sama dengan
[`latest-updates.md`](latest-updates.md).

> 📌 **Kenapa di-host?** Voting muncul & tutup sepanjang tahun. Kalau dibundel, setiap
> kampanye baru menuntut rilis aplikasi — dan voting yang terlewat karena aplikasi belum
> diperbarui adalah kegagalan tujuan fitur ini.

**Skema `VotingCampaign`:**

| Field | Tipe | Wajib | Keterangan |
|-------|------|:----:|------------|
| `id` | string | ✅ | pengenal unik & stabil |
| `title` | string | ✅ | nama kategori/voting, mis. `Best Female Group` |
| `organizer` | string | ✅ | penyelenggara, mis. `MAMA Awards` |
| `url` | string | ✅ | tautan voting resmi (**wajib `https://`**) |
| `closesAt` | string (ISO 8601) | ✅ | **kunci** urutan & penyembunyian |
| `opensAt` | string (ISO 8601) | — | bila belum dibuka, tampil sebagai *upcoming* |
| `note` | string | — | keterangan, mis. `Daily voting` — **tampil di kartu** |

```json
[
  {
    "id": "mama-2026-best-female-group",
    "title": "Best Female Group",
    "organizer": "MAMA Awards",
    "url": "https://example.com/vote",
    "opensAt": "2026-10-01T00:00:00Z",
    "closesAt": "2026-11-20T15:00:00Z",
    "note": "Daily voting"
  }
]
```

**Data Assumptions:**
- `closesAt` wajib & valid; tanpa batas waktu, sebuah voting tak bisa disembunyikan saat
  kedaluwarsa — jadi entri tanpa itu ditolak.
- URL **wajib `https`** — divalidasi memakai `UrlOpener.isSafe` (aturan yang sama dengan
  [`streaming-hub.md`](streaming-hub.md) §6).
- **Waktu dibandingkan apa adanya**, konsisten dengan asumsi zona waktu tunggal di
  [`schedule.md`](schedule.md).
- Isi dikurasi Product Owner dari pengumuman resmi.
- ⚠️ **Daftar kosong itu normal.** Voting penghargaan umumnya terpusat di akhir tahun;
  di luar musim itu, `EmptyView` adalah keadaan yang benar, bukan kegagalan.
- ⚠️ **Gagal mengurai bukan gagal jaringan** *(amandemen 2026-08-20)*. `voting.json` yang
  rusak — bukan array, URL non-`https`, `closesAt` hilang — adalah kesalahan **di pihak
  kita**. Menyuruh pengguna "periksa koneksi Anda" mengarahkan mereka ke kerusakan yang
  tidak bisa mereka perbaiki, sekaligus menyembunyikan kesalahannya dari kita.

## 5. Arsitektur

```text
features/voting/
├── domain/
│   ├── voting_campaign.dart      # entity (murni) + status buka/akan datang
│   ├── voting_repository.dart    # INTERFACE
│   └── open_votes.dart           # fungsi MURNI: openAndUpcoming(campaigns, now)
├── data/
│   └── http_voting_repository.dart
└── presentation/
    ├── providers/voting_providers.dart
    ├── pages/voting_hub_page.dart
    └── widgets/voting_card.dart
```

**`openAndUpcoming(campaigns, now)`** — fungsi murni, menerima `now` sebagai parameter
(deterministik & mudah diuji, pola yang sama dengan `upcomingSorted` di
[`schedule.md`](schedule.md)). Membuang yang `closesAt` sudah lewat, mengurutkan **batas
waktu terdekat dulu**, dengan *stable tie-break* memakai urutan sumber.

**Sisa waktu** dihitung & diformat **di Presentation** — domain hanya menyimpan `DateTime`.

**`votingErrorMessage(error)`** — fungsi murni di Presentation yang memilih kalimat error
berdasarkan **jenis kegagalannya**: `FormatException`/`TypeError` dari `parseCampaigns`
berarti datanya rusak, sisanya berarti jaringannya. Cukup satu fungsi kecil; *Failure
Abstraction* belum dibutuhkan ([`06`](../06_coding_guidelines.md) §7).

**Reuse (tanpa komponen baru):** `AppCard`, `TypeBadge`, `SectionHeader`,
`LoadingView`/`EmptyView`/`ErrorView`, `StaggeredItem`, `UrlOpener`.

**Perubahan berkas non-fitur:** `app_routes.dart`/`app_router.dart` (+1 rute) ·
`home_page.dart` — **Capability Card kedelapan** ("Voting") mengisi slot kosong di baris
terakhir.

## 6. Acceptance Criteria

- [ ] `data/voting.json` ada di root repo, valid, dapat diakses publik.
- [ ] UC-1: hanya voting **buka & akan datang** yang tampil, terurut **batas terdekat dulu**;
      yang sudah tutup **tidak muncul** (ada test-nya).
- [ ] Voting yang belum dibuka ditandai jelas sebagai *upcoming*, bukan tampak bisa ditekan
      seolah sudah berjalan.
- [ ] Sisa waktu tampil dalam satuan yang wajar (hari/jam).
- [ ] UC-2: tap membuka tautan resmi di **aplikasi/browser eksternal**; gagal → `SnackBar`.
- [ ] URL non-`https` dan entri tanpa `closesAt` **ditolak saat parsing**.
- [ ] State **Loading / Empty / Error** tertangani; `EmptyView` menjelaskan bahwa **belum ada
      voting berlangsung**, bukan terkesan rusak.
- [ ] Kegagalan **data** dibedakan dari kegagalan **jaringan**: `voting.json` yang tak bisa
      diurai **tidak** menyuruh pengguna memeriksa koneksinya *(ada test-nya)*.
- [ ] `note` yang dikurasi **tampil di kartu**; entri tanpa `note` **tidak** menyisakan baris
      kosong *(ada test-nya)*.
- [ ] Home menampilkan **8 Capability Card**; tidak *overflow* di 360dp **(dibuktikan test)**.

## 7. Definition of Done (Sprint 9)

- [ ] Spec disetujui PO.
- [ ] **Tidak ada dependency baru.**
- [ ] Seluruh **Acceptance Criteria** terpenuhi.
- [ ] `dart format` rapi & `flutter analyze` bersih.
- [ ] **Test:** unit (`parseCampaigns`: https, `closesAt` wajib; `openAndUpcoming`: tutup
      dibuang, urutan, tie-break, batas tepat `now`; `votingErrorMessage`: data vs jaringan)
      + widget (state, tap membuka URL yang di-*mock*, penanda upcoming, `note` tampil).
- [ ] **Data dikurasi PO** — atau `[]` bila memang tak ada voting berlangsung.
- [ ] **Verifikasi runtime oleh PO.**
- [ ] **GitHub Flow**: merge → hapus branch → tag `v0.10.0`.

## 8. Evolution Notes

**If fans want reminders before a vote closes:**
```
list only  →  + local notifications (paket baru, sprint tersendiri)
```

**If closed votes should stay visible as history:**
```
hide closed  →  + a "Past votes" section
```

**If vote counts or rankings become available:**
```
link out only  →  + progress display (hati-hati: cepat basi)
```

## 9. Dokumen Terkait

| Hubungan | Dokumen |
|----------|---------|
| Kapabilitas & fase | [`03`](../03_roadmap.md) |
| Batas "bukan media sosial" | [`01`](../01_project_overview.md) §7 |
| Pola tautan keluar & keamanan URL | [`streaming-hub.md`](streaming-hub.md) |
| Pola filter waktu (`now` sebagai parameter) | [`schedule.md`](schedule.md) |
| Pola data di-host | [`latest-updates.md`](latest-updates.md) |
