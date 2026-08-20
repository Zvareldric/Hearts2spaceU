# Spec · Agenda — Sprint 11

> **Status:** 🟠 Draft (menunggu approval Product Owner) · **Dibuat:** 2026-08-20
> **Penanggung jawab:** Mohammad Rifqi Hidayat (Product Owner)
> **Branch:** `feature/agenda` *(spec ini sendiri dikirim lewat `docs/fandom-support-spec`)*

Perwujudan **kedua** kapabilitas **Enhanced Fandom Support** (Early Growth), setelah
[`voting-hub.md`](voting-hub.md).

---

## 0. Konteks & Traceability

- **Capability:** *Enhanced Fandom Support* — fase **🟡 Early Growth**
  ([`03`](../03_roadmap.md) §3).
- **Why** → *Organized Fandom Experience* + *Consistent & Enjoyable Experience*
  ([`02`](../02_product_vision.md) §5).
- **Lingkup ditetapkan Product Owner (2026-08-20)** setelah analisis celah di bawah.

### Kenapa kapabilitas ini belum selesai

`Enhanced Fandom Support` sudah punya satu perwujudan — Voting Hub (Sprint 9). `03` §3 juga
memetakan **Personal Collection** (Sprint 8) ke *Value Proposition* yang sama. Jadi
pertanyaannya bukan "fitur fandom apa lagi", melainkan **apa yang masih kurang setelah
keduanya ada**.

Janji *Organized Fandom Experience* di [`02`](../02_product_vision.md) tersebar di empat
tempat, dan kalau disatukan isinya lebih spesifik dari yang terbaca sekilas:

| Sumber | Kalimatnya | Yang tersirat |
|--------|-----------|---------------|
| §4 Problem 3 | "aktivitas fandom — **mengikuti jadwal**, **mengelola koleksi pribadi**, **mengakses layanan resmi** — masih dilakukan secara terpisah" | tiga aktivitas disebut namanya |
| §5 Value | "membantu penggemar **mengelola** aktivitas fandom secara lebih teratur" | mengelola, bukan sekadar menampilkan |
| §2 Mission 2 | "mengelola **aktivitas** serta **koleksi pribadi** mereka" | dua hal terpisah — koleksi ≠ aktivitas |
| §3 Positioning | "mengikuti perkembangan **tanpa tertinggal**" | ada janji soal **waktu**, bukan cuma soal tempat |

Yang sudah ditutup:

| Janji | Ditutup oleh |
|-------|--------------|
| mengelola koleksi pribadi | [`personal-collection.md`](personal-collection.md) — Sprint 8 |
| mengakses layanan resmi | [`streaming-hub.md`](streaming-hub.md) — Sprint 4 |
| mengikuti jadwal | [`schedule.md`](schedule.md) — Sprint 2 |
| aktivitas dukungan (voting) | [`voting-hub.md`](voting-hub.md) — Sprint 9 |

**Yang tersisa: keempatnya berdiri sendiri-sendiri.** Home "Up next" hanya membaca
`upcomingEventsProvider` — Schedule saja. Voting yang tutup dua hari lagi hidup di tab lain.
Acara yang sudah ditandai favorit tidak diperlakukan berbeda dari yang belum. Aplikasi
memusatkan **informasi per kapabilitas**, tetapi belum memusatkan **agenda si penggemar**.
Tidak ada satu layar pun yang menjawab *"apa yang perlu saya lakukan minggu ini?"* — padahal
persis itu arti "mengelola aktivitas".

> ⚠️ **Batas yang dihormati.** Agenda tidak menambah sumber informasi baru dan tidak
> menerima masukan pengguna. Ia **tidak** menampung agenda buatan pengguna sendiri: item
> yang tidak bersumber dari data resmi yang dikurasi akan menjadikan aplikasi ini penampung
> konten pengguna, yang berlawanan dengan *Official-source-first* dan Non-Goal 5
> ([`02`](../02_product_vision.md) §9).

### Kandidat yang dibuang

| Ide | Gerbang yang menggagalkannya |
|-----|------------------------------|
| Komunitas / komentar / forum penggemar | **Vision-aligned** — Non-Goal 3 `02` §9 + `01` §7 |
| Unggah konten buatan penggemar | **Vision-aligned** — Non-Goal 2 & 3 |
| Marketplace / ticketing | **Vision-aligned** — `03` menaruhnya di 🔵 Future Expansion |
| Pelacak target streaming / *chart boosting* | **Value-first** — butuh angka jam-jaman; [`statistics.md`](statistics.md) §2 sudah menolak kelas data ini sebagai "cepat basi" |
| Gamifikasi keaktifan penggemar | **Value-first** — mengarang data tentang pengguna; bertabrakan dengan *Simplicity* & *Privacy-first* |
| Folder/catatan/ekspor koleksi | **bukan kapabilitas ini** — [`personal-collection.md`](personal-collection.md) §9 sudah memiliki jalur evolusinya |

### Corong Roadmap Principles ([`03`](../03_roadmap.md) §1)

1. **Vision-aligned** ✅ — murni mengorganisir apa yang sudah ada; tidak menambah konten,
   tidak menyentuh Non-Goal, tidak menggantikan platform resmi.
2. **Value-first** ✅ — menutup celah yang lahir langsung dari dua fitur **yang sudah
   dirilis**, bukan dari ide baru.
3. **Primary-Users-first** ✅ — penggemar aktif yang mengikuti kegiatan grup secara rutin
   adalah yang paling dirugikan ketika tenggat tersebar di beberapa tab.
4. **Evidence-informed** ⚠️ — **jujur: tidak ada spec yang menyebut celah ini.** Buktinya
   internal-kode: `home_page.dart` `_UpNextSection` hanya membaca `upcomingEventsProvider`,
   dan `openVotesProvider` tidak pernah dibaca di luar `features/voting`. Lebih lemah
   daripada bukti untuk *reminders* (lihat §8), dan itu diakui apa adanya.
5. **Incremental & Iterative** ✅ — nol dependency baru, nol berkas data baru, nol komponen
   Design System baru, nol perubahan pada lapisan `data/`. Sprint ini juga menjadi **fondasi
   yang diuji** bagi *reminders*: pertanyaan "apa yang layak diingatkan" dijawab di sini
   sebagai fungsi murni, bukan di dalam lapisan notifikasi tempat ia paling sulit diuji.

## 1. Tujuan

Menjawab satu pertanyaan yang **tidak dijawab oleh satu pun layar yang ada** — *"apa yang
perlu saya ikuti dalam waktu dekat?"* — dengan menyatukan seluruh hal berbatas waktu di
aplikasi ke satu daftar yang terurut tenggat dan dikelompokkan menurut kedekatannya.

Schedule menjawab **"kapan acaranya"**. Voting menjawab **"apa yang bisa saya dukung"**.
Agenda menjawab **"apa dulu"**.

## 2. Ruang Lingkup Sprint 11

**Masuk (In Scope):**
- **Halaman Agenda** — satu daftar gabungan **acara mendatang** (Schedule) dan **voting yang
  buka & akan datang** (Voting Hub), terurut tenggat terdekat lebih dulu.
- **Pengelompokan relatif:** *Today* · *This week* · *Later*.
- **Sisa waktu per baris**, dengan kata kerja yang benar per jenis: voting **"closes in
  3 days"**, acara **"in 3 days"**.
- **Penanda favorit** pada baris acara, memakai `FavoriteButton` yang sudah ada — menandai
  dari Agenda langsung muncul di Collection.
- **Tap:** baris acara → halaman detail acara; baris voting → membuka tautan voting resmi.
- **Kegagalan sebagian** ditangani: voting gagal dimuat **tidak** menjatuhkan seluruh
  halaman, tetapi **juga tidak disembunyikan diam-diam** (lihat §5).
- Entry dari **Home** — "See all" pada seksi *Up next*.

**Di luar (Out of Scope):**
- **Notifikasi / pengingat** — butuh dependency & izin platform; sprint tersendiri (§8).
- **Agenda buatan pengguna** (item, catatan, atau tenggat yang diketik sendiri) — lihat
  batas di §0.
- **Riwayat / item yang sudah lewat** — konsisten dengan Schedule dan Voting Hub yang
  keduanya menyembunyikan yang sudah lewat.
- **Mengubah isi seksi *Up next* di Home** — hanya tujuan "See all"-nya yang berubah
  (alasannya di §5).
- **Menandai voting sebagai favorit** — lihat §4.
- Filter, pencarian, atau pengurutan alternatif.

## 3. Use Cases

| ID | Sebagai | Saya ingin | Agar |
|----|---------|-----------|------|
| **UC-1** | penggemar | melihat semua hal berbatas waktu dalam satu daftar terurut | tahu apa yang perlu saya dahulukan tanpa memeriksa tiga tab |
| **UC-2** | penggemar | melihat mana yang hari ini, minggu ini, dan nanti | bisa merencanakan, bukan sekadar membaca daftar |
| **UC-3** | penggemar | menekan satu baris | langsung ke detail acaranya atau ke platform votingnya |
| **UC-4** | penggemar | menandai acara langsung dari Agenda | tidak perlu membuka halaman detail hanya untuk menyimpannya |

## 4. Data yang Dibutuhkan

> 🎯 **Tidak ada berkas data baru. Tidak ada skema baru. Tidak ada dependency baru.**

Agenda **tidak memiliki data sendiri.** Seluruh isinya berasal dari tiga sumber yang sudah
berjalan di aplikasi:

| Sumber | Berkas | Milik | Sifat |
|--------|--------|-------|-------|
| Acara mendatang | `assets/data/events.json` | [`schedule.md`](schedule.md) | dibundel |
| Voting buka & akan datang | `data/voting.json` | [`voting-hub.md`](voting-hub.md) | di-host |
| Penanda favorit | `shared_preferences` key `favorites` | [`personal-collection.md`](personal-collection.md) | milik pengguna, lokal |

**Siapa memasok apa:** `events.json` dan `voting.json` **dikurasi Product Owner dari
pengumuman resmi** — aturan yang sudah berlaku di kedua spec pemiliknya, dan tidak berubah
di sini. Agenda **tidak pernah** menambah, menebak, atau melengkapi entri; ia hanya membaca.

**Data Assumptions:**

- **Dua tenggat, dua arti.** `Event.startDateTime` adalah kapan sesuatu **mulai**;
  `VotingCampaign.closesAt` adalah kapan sesuatu **berakhir**. Keduanya diurutkan pada satu
  sumbu waktu, tetapi **kalimatnya wajib berbeda** — menulis "in 3 days" untuk voting akan
  terbaca sebagai "votingnya dibuka 3 hari lagi", padahal justru sebaliknya. Ini risiko
  kejujuran terbesar dari penggabungan ini dan dijaga oleh test.
- **Acara tanpa jam tetap tanpa jam.** `Event.allDay` dibawa apa adanya; Agenda tidak
  mencetak "00:00" untuk acara yang sumbernya hanya menyebut tanggal
  ([`schedule.md`](schedule.md) §4).
- **Waktu dibandingkan apa adanya**, mengikuti asumsi zona waktu tunggal di
  [`schedule.md`](schedule.md) §4. Agenda tidak memperkenalkan penanganan zona waktu baru.
- **Voting yang belum dibuka tetap ditampilkan**, diurutkan menurut `closesAt` tetapi
  ditandai *upcoming* — konsisten dengan Acceptance Criteria [`voting-hub.md`](voting-hub.md)
  yang melarang voting belum-buka tampak seolah sudah berjalan.
- **Daftar kosong itu normal**, bukan kegagalan. Di luar musim penghargaan dan di sela
  aktivitas grup, `EmptyView` adalah keadaan yang benar.
- **Tidak ada jendela waktu buatan.** Agenda menampilkan seluruh yang mendatang, tanpa
  memotong di "30 hari". Comeback yang diumumkan enam minggu sebelumnya justru hal yang
  paling direncanakan penggemar; memotongnya berarti menyembunyikan hal terpenting.

> ### ⚠️ Kenapa voting **tidak** bisa ditandai favorit
>
> `Favorite` sengaja dirancang agar jenis baru tidak menuntut perubahan penyimpanan
> ([`personal-collection.md`](personal-collection.md) §4), jadi menambah `vote:` secara
> teknis gratis. Tetap **tidak dilakukan**, karena hasilnya menyesatkan: Voting Hub
> **menyembunyikan voting yang sudah tutup**, dan Personal Collection **mengabaikan kunci
> yang sumbernya hilang tanpa menghapusnya**. Gabungan kedua aturan itu membuat voting yang
> ditandai **lenyap sendiri dari koleksi** saat tutup — pengguna melihat sesuatu yang mereka
> simpan hilang tanpa penjelasan. Menyimpan sesuatu yang pasti kedaluwarsa bukan fitur.

> ### ⚠️ Kenapa favorit **menandai**, bukan mengurutkan
>
> Menaikkan item favorit ke atas akan menghadirkan **kunci pengurutan kedua**, sehingga
> "yang paling atas" berhenti berarti "yang paling dekat tenggatnya" — merusak satu-satunya
> hal yang dijanjikan halaman ini. Favorit tampil sebagai penanda pada barisnya, dan
> urutannya tetap murni tenggat.

## 5. Arsitektur

```text
features/agenda/
├── domain/
│   ├── agenda_item.dart      # entity (murni): satu baris agenda, apa pun asalnya
│   └── build_agenda.dart     # fungsi MURNI: buildAgenda(...) + groupByProximity(...)
└── presentation/
    ├── providers/agenda_providers.dart
    ├── pages/agenda_page.dart
    └── widgets/agenda_row.dart
```

**Tidak ada `data/` dan tidak ada repository baru.** Agenda membaca ulang
`upcomingEventsProvider`, `openVotesProvider`, dan `favoritesProvider`. Menambah repository
untuk berkas yang sudah punya repository hanya menambah kode tanpa menambah kemampuan
(**ADR-001**: sebuah lapisan diperkenalkan hanya bila memecahkan masalah nyata,
[`04`](../04_architecture.md)).

> Ketergantungan **satu arah**: `agenda → {schedule, voting, collection}`. Preseden persis
> sama sudah ada dua kali — `features/collection` membaca lima fitur lain, dan
> `features/statistics` membaca `features/awards` ([`statistics.md`](statistics.md) §5).
> Yang dilarang adalah **Design System** bergantung pada entity fitur, bukan fitur pada fitur.

**`AgendaItem`** — entity kecil yang menyeragamkan dua bentuk data menjadi satu baris:
`kind` (`event` / `vote`), `id`, `title`, `subtitle` (lokasi acara / `organizer` voting),
`dueAt`, `isAllDay`, `isUpcomingVote`, dan `url` (hanya untuk voting). Ia **tidak** menyimpan
kalimat sisa waktu — itu urusan Presentation, mengikuti aturan yang sama di
[`voting-hub.md`](voting-hub.md) §5.

**`buildAgenda({events, votes, now})`** — fungsi **murni**, `now` sebagai parameter, pola
yang sama dengan `upcomingSorted` dan `openAndUpcoming`. Ia memetakan kedua entity menjadi
`AgendaItem`, mengurutkan `dueAt` menaik, dengan *tie-break* yang **ditetapkan dan diuji**:
pada waktu yang sama **voting lebih dulu** (voting adalah hal yang kedaluwarsa; acara masih
bisa disusul), lalu urutan sumber masing-masing.

> 📌 `buildAgenda` **tidak memfilter ulang** apa yang sudah difilter pemiliknya.
> `upcomingSorted` sudah membuang acara lampau dan `openAndUpcoming` sudah membuang voting
> yang tutup. Menyaring untuk kedua kalinya di sini akan menciptakan tempat kedua yang harus
> ikut diubah setiap kali aturan "masih relevan" bergeser.

**`groupByProximity(items, now)`** — fungsi murni kedua, membagi ke tiga keranjang:

| Keranjang | Batas |
|-----------|-------|
| **Today** | `dueAt` pada tanggal kalender yang sama dengan `now` |
| **This week** | setelah hari ini, sampai **`now` + 7 hari** |
| **Later** | sisanya |

*"This week" sengaja berarti **tujuh hari ke depan**, bukan minggu kalender* — minggu
kalender menuntut jawaban atas "hari pertama minggu itu Senin atau Minggu", pertanyaan
pelokalan yang jawabannya ada di `intl`, dependency yang belum kita punya dan tidak
dibutuhkan hanya untuk ini. Keranjang kosong **tidak** menampilkan header.

**Pengelompokan ini pula yang membedakan Agenda dari Schedule secara visual.** Schedule
mengelompokkan per **bulan**; kalau Agenda melakukan hal yang sama, ia akan terbaca sebagai
salinan kedua Schedule.

### Kegagalan sebagian — aturannya berbeda dari Home

Kedua sumber punya sifat kegagalan berbeda: `events.json` **dibundel** (gagal berarti
aplikasi ini rusak), `voting.json` lewat **jaringan** (gagal itu wajar).

| Yang gagal | Yang dilakukan halaman |
|------------|------------------------|
| Acara | `ErrorView` + Retry — asetnya tulang punggung halaman |
| Voting | daftar acara **tetap tampil**, disertai baris pemberitahuan kecil + Retry |

> ⚠️ **Voting yang gagal dimuat TIDAK boleh hilang diam-diam.** Ini sengaja **berbeda** dari
> kartu pengumuman di Home yang "hilang tanpa suara" ([`design-system-v2.md`](../design-system-v2.md)
> §8). Bedanya: Home adalah *teaser*, sedangkan halaman ini **seluruh gunanya adalah tenggat**.
> Diam-diam menghilangkan sebuah tenggat adalah persis kegagalan yang fitur ini dibuat untuk
> mencegah, dan pengguna akan menyimpulkan "tidak ada voting" padahal yang benar "kami tidak
> tahu".

Prinsipnya sendiri sudah ada di repo — [`discography.md`](discography.md) §3: *"satu
kapabilitas tidak boleh jatuh seluruhnya karena separuhnya gagal."*

**Membedakan jenis kegagalan voting** memakai ulang `votingErrorMessage` milik
`features/voting` ([`voting-hub.md`](voting-hub.md) §5), bukan menulis fungsi kedua yang
harus ikut diperbarui. Saat ini fungsi itu tinggal **di dalam** `voting_hub_page.dart`;
karena kini ada pemakai kedua, ia dipindah ke berkasnya sendiri
(`features/voting/presentation/voting_error_message.dart`) — memindahkan fungsi, bukan
menyalinnya, agar tetap satu-satunya tempat aturan itu ditulis.

### Reuse Design System V2 — tanpa komponen baru

`AppCard` · `TypeBadge` · `SectionHeader` · `MetaRow` · `PageHeading.sub` ·
`LoadingView`/`EmptyView`/`ErrorView` · `StaggeredItem` · `GlassNavBar.reservedSpace` ·
`FavoriteButton` · `UrlOpener` · token spacing/typography.

Baris voting memakai `TypeBadge` berlabel `vote`. **Tanpa menyentuh peta tipe**:
[`design-system-v2.md`](../design-system-v2.md) §10 menetapkan tipe yang tidak dipetakan
tetap tampil rapi sebagai nilainya sendiri — persis mekanisme yang sudah dipakai Awards dan
Voting.

### Penempatan & perubahan berkas non-fitur

- `app_routes.dart` / `app_router.dart` — **+1 rute** `agenda` (`/agenda`).
- `home_page.dart` — pada seksi *Up next*, tujuan **"See all"** berubah dari
  `TabSwitcher.go(context, TabShell.scheduleTab)` menjadi `push` ke `/agenda`. **Isi seksinya
  tidak diubah.**

> 📌 **Kenapa isi *Up next* di Home tidak ikut digabung?** [`discography.md`](discography.md)
> §3 sudah menolak menggabungkan dua `AsyncValue` dari dua fitur di satu layar, karena satu
> sumber gagal memaksa keputusan "layar ini state-nya apa". Slot *Up next* juga terikat
> **tinggi tetap** agar seksi di bawahnya tidak bergeser saat state berganti
> (`up_next_slot_height_test.dart`). Menggabungkan voting ke dalamnya berarti membongkar
> keputusan yang sudah ditimbang, di dalam sprint yang tujuannya justru bertambah kecil.
> Schedule tetap satu tap dari nav bar, jadi tidak ada jalan yang hilang.

> 📌 **Kenapa TIDAK ada tile di More?** More mendaftar **kapabilitas**; Agenda bukan
> kapabilitas baru, melainkan lapisan di atas dua kapabilitas yang sudah ada.
> Menaruhnya di sana akan menyiratkan sumber kebenaran ketiga untuk acara. Konsekuensinya
> **satu pintu masuk saja** — sama seperti `ReleaseStrip` yang menjadi satu-satunya pintu
> "See all" ke Discography dari Home. Bila PO menilai itu kurang terlihat, lihat §8.

## 6. Acceptance Criteria

- [ ] UC-1: acara mendatang **dan** voting buka/akan-datang tampil di satu daftar, terurut
      **tenggat terdekat dulu**, lintas kedua sumber *(ada test-nya)*.
- [ ] *Tie-break* pada tenggat yang sama: **voting lebih dulu**, lalu urutan sumber
      *(ada test-nya)*.
- [ ] UC-2: item terkelompok **Today / This week / Later**; batas "this week" adalah
      **`now` + 7 hari**; keranjang kosong **tidak** menampilkan header *(ada test-nya)*.
- [ ] Sisa waktu memakai kata kerja yang benar per jenis — voting **"closes in …"**, acara
      **"in …"** *(ada test-nya)*.
- [ ] Acara `allDay` **tidak** menampilkan jam apa pun *(ada test-nya)*.
- [ ] Voting yang belum dibuka ditandai jelas sebagai *upcoming*, tidak tampak sudah berjalan.
- [ ] UC-3: tap baris acara membuka **detail acara**; tap baris voting membuka **tautan resmi**
      di aplikasi/browser eksternal, gagal → `SnackBar` *(URL di-mock dalam test)*.
- [ ] UC-4: `FavoriteButton` pada baris acara menandai/menghapus, dan hasilnya **terlihat di
      halaman Collection** *(ada test-nya)*.
- [ ] Voting **gagal dimuat** → daftar acara **tetap tampil** disertai pemberitahuan + Retry;
      **tidak** hilang diam-diam *(ada test-nya)*.
- [ ] Acara gagal dimuat → `ErrorView` + Retry.
- [ ] Kedua sumber kosong → `EmptyView` yang menjelaskan **belum ada yang dijadwalkan**,
      bukan terkesan rusak.
- [ ] "See all" pada *Up next* di Home membuka **Agenda**, bukan tab Schedule
      *(ada test-nya)*.
- [ ] Tidak *overflow* pada lebar **360dp**, termasuk saat judul acara panjang
      *(dibuktikan test)*.
- [ ] Daftar menyisakan `GlassNavBar.reservedSpace` di bawah bila di-scroll di dalam shell.

## 7. Definition of Done (Sprint 11)

- [ ] Spec disetujui PO.
- [ ] **Tidak ada dependency baru. Tidak ada berkas data baru. Tidak ada komponen Design
      System baru.**
- [ ] Seluruh **Acceptance Criteria** terpenuhi.
- [ ] `dart format` rapi & `flutter analyze` bersih.
- [ ] **Test:** unit (`buildAgenda`: daftar kosong, penggabungan, urutan lintas sumber,
      tie-break, batas tepat `now`; `groupByProximity`: batas hari ini, batas hari ke-7,
      keranjang kosong) + widget (empat state, kegagalan sebagian, tap acara & voting,
      tombol favorit, `allDay`, penanda upcoming).
- [ ] **Verifikasi runtime oleh PO.**
- [ ] **GitHub Flow** ([`07`](../07_git_workflow.md)): PR → merge → hapus branch → tag
      **`v1.2.0`** *(SemVer minor di atas `v1.1.0`; penomoran final tetap keputusan PO)*.

## 8. Evolution Notes

**Reminders — kandidat kuat berikutnya, sengaja ditunda.**
```
daftar saja  →  + notifikasi lokal opt-in per item
```
Ini celah dengan **bukti internal terkuat**: [`schedule.md`](schedule.md) §2 dan
[`voting-hub.md`](voting-hub.md) §2 + §8 sama-sama menundanya secara tertulis. Ia ditunda
sekali lagi di sini bukan karena nilainya kecil, melainkan karena harganya berbeda kelas —
satu dependency baru, izin `POST_NOTIFICATIONS` (Android 13+), otorisasi iOS, dan penanganan
zona waktu **sungguhan** yang menabrak asumsi zona waktu tunggal di
[`schedule.md`](schedule.md) §4. Menggabungkannya ke sprint ini melanggar *Small Pull
Requests* ([`07`](../07_git_workflow.md) §5).

**`buildAgenda` adalah fondasi yang sengaja disiapkan untuk itu.** Saat reminders dikerjakan,
pertanyaan "apa yang layak diingatkan" sudah terjawab sebagai fungsi murni yang teruji, jadi
sprint tersebut hanya perlu menangani lapisan platform.

**Bila Agenda dinilai kurang terlihat dengan satu pintu masuk:**
```
hanya "See all" di Home  →  + tile di More
```
Menuntut **satu pasang `CapabilityGradients` baru**. Warnanya keputusan PO;
[`design-system-v2.md`](../design-system-v2.md) §9 mensyaratkan hue yang tidak bertabrakan
dengan tujuh yang sudah ada dan **bukan** violet (250–300°, sudah dipensiunkan).

**Bila pengguna ingin memilah agendanya:**
```
satu daftar  →  + filter "Saved only"
```
Ditunda karena menuntut kontrol filter yang belum ada di Design System V2, dan satu daftar
pendek belum membutuhkannya.

**Bila `Event` mendapat tanggal selesai** ([`schedule.md`](schedule.md) §4 mencatat ini
sebagai batasan yang diketahui):
```
acara multi-hari muncul di tanggal mulai  →  tampil rentangnya, dan tetap di "Today" selama berlangsung
```

**Bila riwayat diinginkan:**
```
hanya yang mendatang  →  + seksi "Recently passed"
```
Hati-hati: ini menyalin keputusan yang sudah diambil Schedule **dan** Voting Hub; mengubahnya
di satu tempat saja akan membuat ketiganya tidak sepakat soal apa itu "sudah lewat".

## 9. Dokumen Terkait

| Hubungan | Dokumen |
|----------|---------|
| Kapabilitas & fase, corong Roadmap Principles | [`03`](../03_roadmap.md) |
| Nilai yang ditutup & Non-Goals | [`02`](../02_product_vision.md) |
| Perwujudan pertama kapabilitas yang sama | [`voting-hub.md`](voting-hub.md) |
| Sumber acara, `allDay`, asumsi zona waktu | [`schedule.md`](schedule.md) |
| Kunci favorit & aturan sumber-hilang | [`personal-collection.md`](personal-collection.md) |
| Pola "membaca ulang provider fitur lain, tanpa repository baru" | [`statistics.md`](statistics.md) |
| Prinsip "separuh gagal ≠ seluruhnya gagal" | [`discography.md`](discography.md) |
| Komponen & token yang dipakai ulang | [`design-system-v2.md`](../design-system-v2.md) |
| Lapisan diperkenalkan hanya bila perlu (ADR-001) | [`04`](../04_architecture.md) |
