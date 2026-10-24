# Spec · Reminders — Sprint 12

> **Status:** 🟠 Draft (menunggu approval Product Owner) · **Dibuat:** 2026-08-23
> **Penanggung jawab:** Mohammad Rifqi Hidayat (Product Owner)
> **Branch:** `feature/reminders` *(spec ini sendiri dikirim lewat `docs/reminders`)*

Perwujudan **ketiga** kapabilitas **Enhanced Fandom Support** (Early Growth), setelah
[`voting-hub.md`](voting-hub.md) dan [`agenda.md`](agenda.md).

---

## 0. Konteks & Traceability

- **Capability:** *Enhanced Fandom Support* — fase **🟡 Early Growth**
  ([`03`](../03_roadmap.md) §3).
- **Why** → *Organized Fandom Experience* ([`02`](../02_product_vision.md) §5).
- **Backlog:** **B-001** ([`10`](../10_backlog.md) §7) — 🔴 High, ditandai *"kandidat terkuat
  sprint berikutnya"*.

### Kenapa ini, dan kenapa sekarang

Ini **satu-satunya item di backlog yang penundaannya tertulis tiga kali**, masing-masing
oleh spec yang berbeda dan pada sprint yang berbeda:

| Sumber | Kalimatnya | Sprint |
|--------|-----------|--------|
| [`schedule.md`](schedule.md) §2 | Out of Scope: "…filter/kategori, **pengingat/notifikasi**" | 2 |
| [`voting-hub.md`](voting-hub.md) §2 | Out of Scope: "**Notifikasi/pengingat batas waktu** (butuh package notifikasi — sprint tersendiri)" | 9 |
| [`voting-hub.md`](voting-hub.md) §8 | *"If fans want reminders before a vote closes"* | 9 |
| [`agenda.md`](agenda.md) §8 | "**Reminders — kandidat kuat berikutnya, sengaja ditunda.**" | 11 |

[`03`](../03_roadmap.md) §1 menempatkan **Evidence-informed** sebagai prinsip keempat, dan di
sinilah buktinya paling kuat: tidak ada ide lain di repo ini yang tiga penulisnya sendiri
sepakat menundanya *sambil* mencatat bahwa ia layak dikerjakan.

### Celah yang tersisa setelah Agenda

Sprint 11 menutup pertanyaan **"apa dulu"** — tetapi hanya bagi penggemar yang **sedang
membuka aplikasi**. Tenggat yang harus diingat untuk diperiksa tetaplah tenggat yang bisa
terlewat.

[`02`](../02_product_vision.md) §3 Positioning menjanjikan penggemar dapat "mengikuti
perkembangan **tanpa tertinggal**". Setelah Sprint 11, aplikasi sudah bisa menjawab *apa yang
paling dekat* — tetapi **hanya bila ditanya**. Voting yang tutup Jumat tengah malam tidak
menjadi lebih tidak terlewat karena ia terurut di baris paling atas; ia hanya terlewat lebih
rapi.

> **Agenda menjawab "apa dulu" saat aplikasi dibuka. Reminders menjawabnya saat aplikasi
> tidak dibuka.** Itu seluruh perbedaan antara keduanya, dan alasan yang satu tidak
> menggantikan yang lain.

**Fondasinya sudah berdiri dan sudah teruji.** [`agenda.md`](agenda.md) §8 menyiapkan ini
secara eksplisit: pertanyaan *"apa yang layak diingatkan"* sudah dijawab `buildAgenda`
sebagai fungsi murni. Sprint ini karena itu **tidak menyentuh pertanyaan apa pun tentang
konten** — seluruh pekerjaannya ada di lapisan platform dan di satu keputusan baru: *kapan*
mengingatkan.

### Kenapa harganya beda kelas — dan itu diakui

[`agenda.md`](agenda.md) §8 menunda ini bukan karena nilainya kecil, melainkan karena
biayanya berbeda jenis. Tiga di antaranya nyata dan tidak bisa dihindari:

1. **Dependency baru** — dan setelah diperiksa, jumlahnya **dua, bukan satu** seperti yang
   diperkirakan `agenda.md` §8. `flutter_local_notifications` menjadwalkan; ia menuntut
   `timezone` untuk melakukannya (lihat §4). Perkiraan lama dikoreksi di sini apa adanya.
2. **Izin platform** — `POST_NOTIFICATIONS` (Android 13+) dan otorisasi iOS. Izin yang
   ditolak adalah **keadaan normal**, bukan error, dan harus terlihat sebagai keadaan.
3. **Waktu yang benar-benar dijadwalkan** — selama ini `DateTime` hanya *ditampilkan*.
   Menjadwalkannya menabrak asumsi zona waktu tunggal [`schedule.md`](schedule.md) §4.
   Bagaimana tabrakan itu diselesaikan **tanpa** memperluas sprint ada di §4.

### Kandidat yang dibuang

| Ide | Gerbang yang menggagalkannya |
|-----|------------------------------|
| **Push / remote notification** (server mengirim) | **Incremental** — menuntut backend; ADR-002 masih ⏸️ Deferred ([`04`](../04_architecture.md) §7). B-002 memblokirnya, bukan sprint ini. |
| **Notifikasi otomatis untuk setiap item baru** (tanpa opt-in) | **Vision-aligned** — *Simplicity* & Non-Goal 4 ([`02`](../02_product_vision.md) §9). Pengingat yang tidak diminta adalah spam, dan spam mengajari pengguna mematikan notifikasi aplikasi ini selamanya. |
| **Pengingat untuk agenda buatan pengguna** | **bukan kapabilitas ini** — batas yang sama persis dengan [`agenda.md`](agenda.md) §0. |
| **Badge angka di ikon aplikasi** | **Value-first** — menuntut dependency ketiga, perilakunya berbeda-beda per peluncur Android, dan tidak menjawab pertanyaan apa pun yang notifikasi belum jawab. |
| **Pengingat lewat email / WhatsApp** | **Vision-aligned** — menuntut backend *dan* data pribadi; Non-Goal 4 ([`02`](../02_product_vision.md) §9). |
| **Alarm presisi-detik** (`SCHEDULE_EXACT_ALARM`) | **Value-first** — lihat §5. Izin yang dibatasi Google Play, ditukar dengan ketelitian yang tidak dibutuhkan pengingat fandom. |

### Corong Roadmap Principles ([`03`](../03_roadmap.md) §1)

1. **Vision-aligned** ✅ — memperkuat janji "tanpa tertinggal"; tidak menambah konten, tidak
   menyentuh Non-Goal. Notifikasi seluruhnya **lokal**: tidak ada data yang meninggalkan
   perangkat, sejalan *Privacy-first*.
2. **Value-first** ✅ — menutup celah yang lahir dari fitur yang **sudah dirilis** (Sprint 11),
   bukan dari ide baru.
3. **Primary-Users-first** ✅ — penggemar aktif yang mengikuti voting berbatas waktu adalah
   yang paling dirugikan ketika tenggat lewat tanpa disadari.
4. **Evidence-informed** ✅ — **bukti internal terkuat yang dimiliki repo ini** (tabel di
   atas). Berbeda dari [`agenda.md`](agenda.md) §0 yang jujur mencatat buktinya lemah,
   di sini justru sebaliknya.
5. **Incremental & Iterative** ⚠️ — **jujur: ini sprint pertama sejak Design System V2 yang
   menambah dependency.** Nol berkas data baru dan nol komponen Design System baru tetap
   dipertahankan, tetapi klaim "nol dependency baru" **tidak** bisa dibuat di sini.
   [`05`](../05_tech_stack.md) §5 mewajibkan tiap dependency dicatat beserta alternatif yang
   dipertimbangkan; §4 spec ini melakukannya.

## 1. Tujuan

Membuat tenggat yang **sudah diketahui aplikasi** sampai ke penggemar **pada waktu yang masih
bisa ditindaklanjuti**, tanpa menuntut mereka membuka aplikasi untuk mengetahuinya.

Schedule menjawab **"kapan acaranya"**. Voting menjawab **"apa yang bisa saya dukung"**.
Agenda menjawab **"apa dulu"**. Reminders menjawab **"ingatkan saya"**.

## 2. Ruang Lingkup Sprint 12

**Masuk (In Scope):**
- **Opt-in per item** pada baris Agenda — satu tombol lonceng, pola yang sama dengan
  `FavoriteButton`. Berlaku untuk **acara maupun voting** (alasan asimetrinya di §4).
- **Satu notifikasi lokal terjadwal per item** yang di-opt-in, pada waktu yang ditetapkan
  fungsi murni `reminderFireTime` (§5).
- **Izin diminta pada opt-in pertama**, bukan saat aplikasi dibuka. Ditolak → keadaannya
  **terlihat dan dijelaskan**, tombol tidak menyala seolah berhasil.
- **Rekonsiliasi saat data berubah** — item yang hilang dari sumber setelah pemuatan yang
  **berhasil** dibatalkan pengingatnya; sumber yang **gagal dimuat** tidak membatalkan
  apa pun (§4).
- **Mematikan satu pengingat** lewat tombol yang sama.
- Acara `allDay` diingatkan pada **jam yang beradab**, bukan tengah malam (§5).

**Di luar (Out of Scope):**
- **Push / remote notification** — menuntut backend (ADR-002); lihat §0 dan B-002.
- **Lead time yang bisa dipilih pengguna** — satu aturan dulu, lihat §8.
- **Lebih dari satu pengingat per item** (mis. H-7 *dan* H-1) — lihat §8.
- **Pengingat berulang** — tidak ada satu pun sumber data yang berulang.
- **Pengingat untuk apa pun di luar Agenda** — Agenda sudah menjadi definisi tunggal
  "hal berbatas waktu di aplikasi ini". Menambah sumber kedua di sini akan membuat dua
  jawaban untuk pertanyaan yang sama.
- **Zona waktu per-item** — batasan yang diwarisi, bukan yang diperkenalkan; lihat §4 & §8.
- **Halaman daftar pengingat tersendiri** — Agenda **adalah** daftarnya; baris yang
  di-opt-in menunjukkannya sendiri. Halaman kedua yang isinya subset halaman pertama
  menambah tempat tanpa menambah jawaban.

## 3. Use Cases

| ID | Sebagai | Saya ingin | Agar |
|----|---------|-----------|------|
| **UC-1** | penggemar | menyalakan pengingat pada satu baris Agenda | tidak perlu mengingat sendiri kapan harus kembali |
| **UC-2** | penggemar | menerima pemberitahuan sebelum tenggatnya | masih sempat menonton atau memberi suara |
| **UC-3** | penggemar | tahu kalau izin notifikasi belum diberikan | mengerti kenapa pengingat tidak muncul, alih-alih mengira aplikasinya rusak |
| **UC-4** | penggemar | mematikan pengingat yang tidak lagi saya inginkan | daftar notifikasi saya tetap milik saya |

## 4. Data yang Dibutuhkan

> 🎯 **Tidak ada berkas data baru. Tidak ada skema kurasi baru.**
> **Ada dua dependency baru** — dicatat di bawah sesuai [`05`](../05_tech_stack.md) §5.

Isi pengingat seluruhnya berasal dari `AgendaItem` yang sudah dibangun `buildAgenda`
([`agenda.md`](agenda.md) §5). Sprint ini **tidak membaca satu berkas data pun secara
langsung**.

**Yang dimiliki sprint ini** hanyalah satu himpunan pilihan pengguna:

| Yang disimpan | Di mana | Bentuk |
|---------------|---------|--------|
| Item yang di-opt-in | `shared_preferences`, key `reminders` | JSON array of string |

**Kunci pengingat:** `"<kind>:<id>"` — mis. `event:tima-2026-day-1`, `vote:mama-2026-worldwide`.
Satu ruang nama datar, **pola yang sama persis** dengan `favorites`
([`personal-collection.md`](personal-collection.md) §4) — dipakai ulang, bukan disalin
alasannya: menambah jenis baru tidak menuntut perubahan penyimpanan.

> 📌 **Key terpisah, bukan menumpang `favorites`.** Menandai dan mengingatkan adalah dua
> maksud berbeda: "saya ingin menyimpan ini" ≠ "bangunkan saya untuk ini". Menyatukannya
> membuat menghapus favorit diam-diam membatalkan pengingat, dan itu kejutan yang tidak
> diminta siapa pun.

**Dependency baru** ([`05`](../05_tech_stack.md) §5 — tabel di sana ditambah pada sprint ini):

| Package | Untuk apa | Alternatif dipertimbangkan |
|---------|-----------|----------------------------|
| `flutter_local_notifications` | Menjadwalkan & membatalkan notifikasi lokal, meminta izin | `awesome_notifications` — lebih banyak kemampuan (tombol aksi, notifikasi kaya) yang tidak satu pun dibutuhkan di sini, dengan permukaan API jauh lebih besar. Menulis sendiri lewat `MethodChannel` ditolak: itu memelihara dua kode platform demi menghindari satu dependency. |
| `timezone` | **Dituntut** `flutter_local_notifications` untuk `zonedSchedule` | Tidak ada — bukan pilihan bebas. `zonedSchedule` menerima `TZDateTime`, dan penjadwalan tanpa zona waktu adalah API yang sudah usang di package tersebut. |

**Data Assumptions:**

- **Zona waktu: asumsi lama dipakai, bukan diganti.** `DateTime` dari `events.json` dan
  `voting.json` adalah waktu tanpa zona, dan [`schedule.md`](schedule.md) §4 menetapkan ia
  "dipakai apa adanya". Reminders **menafsirkannya pada zona waktu perangkat** — yang persis
  merupakan arti "apa adanya" bagi seluruh UI yang sudah ada. `timezone` dipakai **hanya**
  untuk mengubah waktu lokal itu menjadi `TZDateTime`, **bukan** untuk memperkenalkan zona
  waktu per-item.
  > ⚠️ **Batasan yang diketahui dan sengaja tidak ditutup di sini:** bila sumber resmi
  > menyebut jam KST sementara perangkat pengguna di WIB, pengingatnya meleset sebesar
  > selisih itu — persis sebagaimana **tampilannya** sudah meleset sejak Sprint 2.
  > Memperbaikinya menuntut `startDateTime` membawa zona waktunya sendiri, yaitu perubahan
  > **skema milik [`schedule.md`](schedule.md)**, bukan milik sprint ini. Dicatat di §8.
- **Kunci yang sumbernya hilang dibatalkan — tetapi hanya setelah pemuatan yang berhasil.**
  Di sinilah aturannya **sengaja berbeda** dari `favorites`
  ([`personal-collection.md`](personal-collection.md) §4), yang mengabaikan kunci hilang
  tanpa menghapusnya. Alasannya: favorit adalah **catatan**, pengingat adalah **tindakan
  terjadwal**. Menyimpan catatan yang sumbernya sedang gagal dimuat itu benar; membiarkan
  notifikasi menyala tentang voting yang sudah dibatalkan itu tidak.
  **`voting.json` gagal dimuat bukan berarti votingnya hilang**, jadi rekonsiliasi hanya
  berjalan pada `AsyncData`, tidak pernah pada `AsyncError`.
- **Penyimpanan rusak/tak terbaca → dianggap tidak ada pengingat**, bukan crash — aturan yang
  sama dengan [`personal-collection.md`](personal-collection.md) §4.
- **Izin yang ditolak bukan error.** Ia keadaan yang sah dan bisa berubah kapan saja dari
  Pengaturan sistem; aplikasi membacanya ulang, tidak menyimpannya sebagai kegagalan.
- **Notifikasi yang sudah tayang tidak ditarik kembali.** Setelah sistem menampilkannya, ia
  milik pengguna.

> ### ⚠️ Kenapa voting **bisa** diingatkan, padahal **tidak bisa** ditandai favorit
>
> [`agenda.md`](agenda.md) §4 menolak `vote:` masuk `favorites` karena voting yang ditandai
> akan **lenyap sendiri dari koleksi** saat tutup — pengguna kehilangan sesuatu yang mereka
> simpan, tanpa penjelasan.
>
> Pengingat tidak punya masalah itu, karena **justru berlawanan arah**: pengingat memang
> dirancang untuk **berbunyi lalu selesai**. Sesuatu yang pasti kedaluwarsa adalah alasan
> buruk untuk disimpan, tetapi alasan **terbaik** untuk diingatkan — dan voting adalah
> satu-satunya hal di aplikasi ini yang benar-benar hangus bila terlewat.

## 5. Arsitektur

```text
features/reminders/
├── domain/
│   ├── reminder.dart              # entity (murni): satu pengingat terjadwal
│   ├── plan_reminders.dart        # fungsi MURNI: reminderFireTime(...) + planReminders(...)
│   └── reminder_scheduler.dart    # interface — sekat yang menjauhkan test dari platform
├── data/
│   ├── prefs_reminder_repository.dart      # himpunan opt-in (shared_preferences)
│   └── local_notification_scheduler.dart   # implementasi flutter_local_notifications
└── presentation/
    ├── providers/reminder_providers.dart
    └── widgets/reminder_button.dart
```

**Kenapa sprint ini punya `data/` padahal Agenda tidak.** [`agenda.md`](agenda.md) §5 menolak
menambah repository karena tidak ada sumber data baru — hanya provider yang sudah ada. Di
sini keadaannya berbeda dan ADR-001 ([`04`](../04_architecture.md) §4) terpenuhi pada dua
barisnya sekaligus:

| Kriteria `04` §4 | Terpenuhi karena |
|------------------|------------------|
| **Repository Interface** — "butuh abstraksi untuk pengujian" | Tanpa sekat, tiap widget test menyentuh *platform channel* yang tidak ada di `flutter test`. `ReminderScheduler` adalah sekat itu. |
| **Domain Entity** — "model domain berbeda dari representasi data" | `flutter_local_notifications` menuntut `id` **int**; domain bekerja dengan kunci `"<kind>:<id>"`. Perbedaan itu nyata, bukan seremonial. |

> Lapisan di sini **memecahkan masalah nyata** — persis syarat yang membuat Agenda **tidak**
> boleh menambahnya. Prinsip yang sama menghasilkan jawaban berbeda karena keadaannya
> berbeda; itu memang cara ADR-001 dimaksudkan bekerja.

Ketergantungan tetap **satu arah**: `reminders → agenda → {schedule, voting, collection}`.

### Dua fungsi murni — inti yang diuji tanpa platform

**`reminderFireTime(item, now)` → `DateTime?`** — menjawab *kapan berbunyi*, dan itu
satu-satunya pertanyaan baru yang dibawa sprint ini. Aturannya berjenjang, dan dipilih supaya
**tidak pernah menjadwalkan sesuatu yang tidak berguna**:

| Urutan | Kandidat | Dipakai bila |
|--------|----------|--------------|
| 1 | `dueAt` − **24 jam** | masih di masa depan terhadap `now` |
| 2 | `dueAt` − **1 jam** | kandidat 1 sudah lewat, kandidat ini belum |
| — | **`null`** | keduanya lewat → terlalu dekat untuk berguna; tombol **tidak tersedia**, dan alasannya terlihat |

*Kenapa berjenjang, bukan satu angka:* penggemar yang menemukan voting **20 jam sebelum
tutup** justru yang paling butuh diingatkan. Aturan satu-angka akan menolaknya diam-diam —
kegagalan yang persis sama dengan yang fitur ini dibuat untuk mencegah.

**Acara `allDay` adalah pengecualian yang wajib.** `dueAt`-nya tengah malam
([`schedule.md`](schedule.md) §4 — sumbernya hanya menyebut tanggal), jadi "24 jam sebelum"
berarti **tengah malam sehari sebelumnya**. Membangunkan orang pukul 00:00 untuk mengabarkan
acara besok adalah cara tercepat membuat notifikasi aplikasi ini dimatikan permanen. Karena
itu: **acara `allDay` berbunyi pukul 09:00 pada hari sebelumnya.**

> 📌 Ini kelanjutan langsung dari keputusan `allDay` di [`schedule.md`](schedule.md) §4. Di
> sana: **jangan cetak "00:00"** yang tidak diketahui. Di sini: **jangan berbunyi pukul
> 00:00** yang sama tidak diketahuinya. Satu batasan data, dua akibat, satu sikap.

**`planReminders({items, optedIn, now})`** — fungsi murni kedua: memetakan himpunan kunci
opt-in ke daftar `Reminder` yang seharusnya terjadwal, membuang yang `reminderFireTime`-nya
`null`. `now` sebagai parameter, **pola yang sama** dengan `upcomingSorted`, `openAndUpcoming`,
dan `buildAgenda`.

Hasilnya menjadi **satu-satunya kebenaran** tentang apa yang harus terjadwal; lapisan data
membandingkannya dengan apa yang **sedang** terjadwal, lalu menjadwalkan selisihnya dan
membatalkan sisanya. Rekonsiliasi karena itu **tidak punya cabang keputusan sendiri** — ia
hanya menyamakan dua himpunan.

**`Reminder`** — entity kecil: `key`, `fireAt`, `title`, `body`. Ia **tidak** menyimpan
`int id` platform; itu urusan lapisan data (lihat di bawah), mengikuti aturan yang sama yang
membuat `AgendaItem` tidak menyimpan kalimat sisa waktu.

**Id notifikasi** diturunkan **deterministik** dari `key` (hash stabil → int 32-bit).
Deterministik supaya menjadwal ulang **menimpa**, bukan menggandakan — id acak akan membuat
satu item berbunyi dua kali setelah aplikasi dibuka dua kali.

### Izin — diminta pada saat yang benar

| Keadaan | Yang dilakukan |
|---------|----------------|
| Belum pernah ditanya | Diminta **saat opt-in pertama**, bukan saat aplikasi dibuka |
| Diberikan | Pengingat dijadwalkan; tombol menyala |
| **Ditolak** | Tombol **tidak menyala**; `SnackBar` menjelaskan pengingat butuh izin notifikasi dan menawarkan jalan ke Pengaturan sistem |

> ⚠️ **Tombol yang menyala tanpa izin adalah kebohongan** — pengguna akan menunggu
> notifikasi yang tidak akan pernah datang. Ini bentuk kegagalan yang sama yang ditolak
> [`agenda.md`](agenda.md) §5 pada voting yang gagal dimuat: **jangan diam-diam.**

**Meminta izin saat aplikasi dibuka ditolak.** Dialog yang muncul sebelum pengguna
menginginkan apa pun adalah dialog yang ditolak, dan di Android 13+ penolakan itu
**menghanguskan kesempatan bertanya lagi**. Ditanya tepat setelah menekan lonceng, maksudnya
sudah jelas bagi pengguna.

**Alarm presisi tidak diminta.** Android 12+ membatasi `SCHEDULE_EXACT_ALARM`, dan Google
Play menuntut pembenaran untuk memakainya. Penjadwalan dipakai dengan mode **inexact** —
sistem boleh menggeser beberapa menit demi baterai. Pengingat yang dirancang berbunyi 24 jam
sebelumnya tidak menjadi kurang berguna karena bergeser sepuluh menit; izin yang dibatasi
toko aplikasi adalah harga yang jauh lebih mahal daripada ketelitian yang tidak dibutuhkan.

### Reuse Design System V2 — tanpa komponen baru

`AppCard` · `TypeBadge` · `MetaRow` · `SectionHeader` · `SnackBar` · token spacing/typography
— seluruhnya sudah ada.

`ReminderButton` **bukan komponen Design System baru**: ia tinggal di dalam fitur, persis
seperti `AgendaRow` (Sprint 11) dan `FavoriteButton` (Sprint 8) yang juga tidak tinggal di
`app/widgets/`. Aturannya tidak berubah — yang dilarang adalah Design System bergantung pada
entity fitur, bukan sebaliknya.

### Penempatan & perubahan berkas non-fitur

- `AgendaRow` — slot kanan bertambah **satu** tombol lonceng, sehingga menjadi
  `[lonceng][favorit]` untuk acara dan `[lonceng][ikon tujuan]` untuk voting. **Isi baris
  selebihnya tidak diubah.** Batas **360dp dengan judul panjang** yang sudah dijaga test
  Sprint 11 tetap wajib hijau — dan kini dengan satu kontrol lebih banyak.
- `main.dart` — inisialisasi `flutter_local_notifications` + basis data zona waktu, sekali
  saat *startup*.
- `AndroidManifest.xml` / `Info.plist` — deklarasi izin notifikasi.
- `05_tech_stack.md` §5 — dua baris dependency baru (§4).

> 📌 **Tidak ada rute baru dan tidak ada tile di More.** Reminders bukan halaman; ia sifat
> yang menempel pada baris Agenda. Alasannya sama dengan yang menolak tile More untuk Agenda
> ([`agenda.md`](agenda.md) §5): More mendaftar **kapabilitas**, dan ini bukan kapabilitas —
> ini perilaku satu tombol.

## 6. Acceptance Criteria

- [ ] UC-1: menekan lonceng pada baris Agenda menyalakan pengingat item itu, dan keadaannya
      **bertahan setelah aplikasi ditutup** *(ada test-nya)*.
- [ ] `reminderFireTime`: **24 jam sebelum** bila masih di masa depan; **1 jam sebelum** bila
      tidak; **`null`** bila keduanya lewat — termasuk **kasus batas tepat** *(ada test-nya)*.
- [ ] Acara **`allDay` berbunyi pukul 09:00 hari sebelumnya**, bukan tengah malam
      *(ada test-nya)*.
- [ ] `planReminders` hanya menjadwalkan item yang **di-opt-in**, membuang yang
      `reminderFireTime`-nya `null`, dan **tidak memutasi** masukannya *(ada test-nya)*.
- [ ] Voting **dan** acara sama-sama bisa diingatkan; kalimat notifikasinya memakai **kata
      kerja yang benar per jenis** — voting "closes", acara "starts" — mengikuti aturan yang
      sama dengan `agendaDueLabel` *(ada test-nya)*.
- [ ] Id notifikasi **deterministik**: menjadwalkan ulang kunci yang sama **menimpa**, tidak
      menggandakan *(ada test-nya)*.
- [ ] UC-3: izin **ditolak** → tombol **tidak menyala** + `SnackBar` yang menjelaskan; tidak
      ada pengingat yang tampak aktif padahal tidak *(ada test-nya)*.
- [ ] Izin diminta **pada opt-in pertama**, bukan saat *startup* *(ada test-nya)*.
- [ ] UC-4: mematikan lonceng **membatalkan** notifikasi terjadwal *(ada test-nya)*.
- [ ] Item yang **hilang dari sumber** setelah pemuatan **berhasil** → pengingatnya
      dibatalkan; sumber yang **gagal dimuat** → **tidak ada** yang dibatalkan
      *(ada test-nya — dua kasus terpisah)*.
- [ ] Penyimpanan rusak → dianggap tidak ada pengingat, **bukan crash** *(ada test-nya)*.
- [ ] Tidak *overflow* pada lebar **360dp** dengan judul acara panjang **dan** kedua kontrol
      terpasang *(dibuktikan test)*.
- [ ] Seluruh test Sprint 11 tetap hijau — `AgendaRow` berubah, perilakunya tidak.

## 7. Definition of Done (Sprint 12)

- [ ] Spec disetujui PO.
- [ ] **Tidak ada berkas data baru. Tidak ada komponen Design System baru.**
      **Dua dependency baru**, tercatat di [`05`](../05_tech_stack.md) §5 beserta alternatif
      yang dipertimbangkan.
- [ ] Seluruh **Acceptance Criteria** terpenuhi.
- [ ] `dart format` rapi & `flutter analyze` bersih.
- [ ] **Test:** unit (`reminderFireTime` termasuk kasus batas & `allDay`; `planReminders`;
      id deterministik; rekonsiliasi berhasil-vs-gagal) + widget (opt-in & bertahan, izin
      ditolak, mematikan, 360dp).
- [ ] **Verifikasi runtime oleh PO pada perangkat nyata** — Android 13+ **dan** iOS bila
      tersedia. Notifikasi lokal adalah satu-satunya fitur di aplikasi ini yang **tidak bisa
      dibuktikan `flutter test`**; sekat `ReminderScheduler` membuat logikanya teruji, tetapi
      hanya perangkat yang membuktikan ia benar-benar berbunyi.
- [ ] **GitHub Flow** ([`07`](../07_git_workflow.md)): PR → merge → hapus branch → tag
      **`v1.4.0`** *(SemVer minor di atas `v1.3.0`; penomoran final tetap keputusan PO)*.

## 8. Evolution Notes

**Lead time yang dipilih pengguna.**
```
24 jam (berjenjang ke 1 jam)  →  + pilihan per item atau preferensi global
```
Ditunda karena menuntut kontrol pilihan yang belum ada di Design System V2 — hambatan yang
sama persis dengan filter "Saved only" ([`agenda.md`](agenda.md) §8, B-010). Satu aturan yang
benar lebih dulu; pilihan menyusul bila terbukti diminta.

**Lebih dari satu pengingat per item.**
```
satu pengingat  →  + H-7 dan H-1
```
`planReminders` sudah mengembalikan *daftar*, jadi bentuknya sudah siap. Yang ditunda adalah
keputusan produknya: dua notifikasi untuk satu hal adalah tempat paling mudah fitur ini
berubah menjadi gangguan.

**Zona waktu sungguhan.**
```
zona waktu perangkat  →  `startDateTime` membawa zona waktunya sendiri
```
Ini **perubahan skema milik [`schedule.md`](schedule.md) §4**, bukan milik sprint ini, dan ia
memperbaiki **tampilan** sekaligus **pengingat** — dua fitur dengan satu perbaikan. Dikerjakan
di sana, bukan di sini.

**Bila backend akhirnya ada** (B-002 / ADR-002):
```
notifikasi lokal terjadwal  →  + push untuk pengumuman yang belum ada saat aplikasi terakhir dibuka
```
Hati-hati: keduanya menjawab pertanyaan berbeda. Lokal mengingatkan **apa yang sudah
diketahui**; push mengabarkan **apa yang belum**. Yang satu tidak menggantikan yang lain.

**Bila `Event` mendapat tanggal selesai** (B-009):
```
mengingatkan sebelum mulai  →  + tetap relevan selama acara berlangsung
```

## 9. Dokumen Terkait

| Hubungan | Dokumen |
|----------|---------|
| Item backlog & prioritasnya (**B-001**) | [`10`](../10_backlog.md) |
| Kapabilitas & fase, corong Roadmap Principles | [`03`](../03_roadmap.md) |
| Nilai yang ditutup & Non-Goals | [`02`](../02_product_vision.md) |
| Fondasi yang dipakai — `AgendaItem`, `buildAgenda`, baris Agenda | [`agenda.md`](agenda.md) |
| Sumber acara, `allDay`, asumsi zona waktu yang diwarisi | [`schedule.md`](schedule.md) |
| Tenggat voting & penundaan yang tertulis | [`voting-hub.md`](voting-hub.md) |
| Pola penyimpanan pilihan pengguna & aturan sumber-hilang | [`personal-collection.md`](personal-collection.md) |
| Dependency Policy — tempat dua dependency baru dicatat | [`05`](../05_tech_stack.md) |
| Lapisan diperkenalkan hanya bila perlu (ADR-001) | [`04`](../04_architecture.md) |
| Komponen & token yang dipakai ulang | [`design-system-v2.md`](../design-system-v2.md) |
