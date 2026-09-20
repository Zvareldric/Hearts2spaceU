# Design System V2 — Liquid Glass

> **Status:** 🟢 Aktif · **Dibuat:** 2026-07-30 · **Diperbarui:** 2026-07-30
> **Penanggung jawab:** Mohammad Rifqi Hidayat (Product Owner)
> **Epic:** Redesign "Perbaiki Hearts2Hearts Design"

Dokumen ini mencatat **apa yang berubah** dari
[`design-system-v1.md`](design-system-v1.md), bukan mengulangnya. Struktur & prinsip
sistem tetap dikunci [`docs/09_design_system.md`](09_design_system.md); sumber kebenaran
teknis tetap kode di `app/hearts2spaceu/lib/app/theme/`.

**Masih berlaku dari V1 tanpa perubahan:** tipografi (§3), spacing (§4), motion (§8),
dan aturan bahwa depth datang dari `AppShadows` di dalam komponen — bukan dari
Material elevation.

---

## 1. Yang Berubah, Ringkas

| Aspek | V1 | V2 |
|-------|----|----|
| Palet | baby blue + baby pink, tinta navy | sky blue + blossom pink, tinta plum |
| Latar | satu warna solid (`background`) | *ambient wash* — gradien + 4 blob pastel |
| Permukaan kartu | putih solid | kaca: putih translusen + tepi hairline |
| Navigasi | Home sebagai direktori 9 kartu | 5 tab di *floating glass nav bar* |
| **Judul halaman** | **`AppBar` Material** | **judul inline + tombol back bundar kaca** |
| Radius kartu | 20 | 22 |
| Shadow | tinta navy | tinta biru (`shadowTint`) |

Filosofi V1 — *"A calm companion, not a control panel"* — **tidak berubah**. V2 hanya
memindahkan sumber warna: dari kartu ke latar. Konten tetap bintangnya.

## 2. Palet

Sumber: `lib/app/theme/app_colors.dart`.

### Light

| Token | Hex | Kontras | Peran |
|-------|-----|---------|-------|
| `primary` | `#87CEEB` | 1.74:1 ⚠️ | sky blue — **fill saja** |
| `primaryStrong` | `#195B89` | 4.60:1 di wash telanjang · 7.27:1 putih di atasnya ✅ | CTA solid, tab aktif, label & tautan aksen |
| `secondary` | `#F8AFCB` | — | blossom pink — aksen sekunder |
| `secondaryStrong` | `#BD3272` | 3.10:1 di latar terburuk, termasuk hero | **ikon hati saja** (ambang non-text 3:1) |
| `ink` | `#16283C` | 14.4:1 | teks utama (navy) |
| `inkSoft` | `#3F566E` | 4.80:1 di wash telanjang | body copy, **dan semua teks sekunder yang duduk langsung di wash** |
| `inkMuted` | `#56697C` | 4.60:1 di kaca · 3.59:1 di wash ⚠️ | teks sekunder **di dalam kartu kaca saja** |
| `pastelMuted` | `#3C5269` | 4.60:1 di hero pastel | teks sekunder di atas isian pastel (lewat `LightSurface`) |
| `error` | `#DF5D5B` | 3.20:1 di tint terang | ikon kegagalan saja |
| `surfaceTint` | `#E6F4FB` | — | blok tanggal, avatar, track bar |
| `background` / `ambientBase` | `#F1F7FC` → `#FBF1F6` | — | dasar ambient wash |
| `shadowTint` | `#4F87AD` | — | haze biru, bukan hitam netral |

**`#D9C6FF` (lavender lama) sudah dipensiunkan.** Ia sempat tersisa di tiga tempat
setelah primary diganti — blob ambient, gradien tile Members, dan tint badge
`concert`. Ambient wash kini dibangun **hanya dari `primary` dan `secondary`**
(dua blob sky, dua blob pink), jadi latar tidak bisa melenceng dari brand lagi.
Dijaga oleh grup test *"the retired lavender is gone"*.

> ### ⚠️ `primary` dan `primaryStrong` tidak bisa saling tukar
>
> Sky blue brand-nya adalah tint terang: cuma **1.74:1** di atas putih. Ia boleh
> mengisi bentuk, tapi **tidak boleh membawa teks atau ikon**. Apa pun yang harus
> **dibaca** pakai `primaryStrong` — hue yang sama, diturunkan sampai lolos AA di
> atas putih *dan* di atas kartu kaca.
>
> Kenapa dua-duanya diuji: kandidat `#2477AE` lolos di atas putih (4.86) tapi
> **gagal di atas kaca (4.37)** — dan kaca justru tempat label aksen paling sering
> muncul ("See all", judul seksi di dalam kartu). Menguji hanya di atas putih akan
> meloloskan warna yang gagal di tempat yang paling banyak dipakai.
>
> Dikunci oleh `test/app/theme/app_colors_contrast_test.dart`.

> ### Di mana tiap tinta boleh duduk *(2026-09-20)*
>
> Kontras sebuah tinta bukan sifat tintanya, tapi sifat **pasangan** tinta dan
> latarnya. App ini punya tiga jenis latar, dan tiap jenis punya tintanya:
>
> | Latar | Teks utama | Teks sekunder |
> |-------|-----------|---------------|
> | Kartu kaca (`AppCard`) | `onSurface` | `onSurfaceVariant` (= `inkMuted`) |
> | Wash telanjang — header section, caption, tagline, state kosong/error | `onSurface` | `AppColors.inkSoftOf(context)` |
> | Isian pastel tetap — hero detail, tile ikon | tinta gelap di **kedua** mode, lewat `LightSurface` | `onSurfaceVariant` (= `pastelMuted` di dalamnya) |
>
> Aturan baris kedua yang paling mudah dilanggar. `inkMuted` lolos di atas kaca
> (4.60:1), tapi header section dan caption tidak punya kartu di bawahnya — di atas
> blob langit telanjang ia jatuh ke 3.59:1. Menggelapkan `inkMuted` sampai lolos di
> sana akan membuatnya nyaris sama dengan `inkSoft` dan meruntuhkan hierarki; jadi
> teks di wash naik satu tingkat, dan hierarkinya tetap utuh. Ini juga arah
> minimalis yang dikehendaki: judul section yang tegas, abu-abu hanya untuk metadata
> di dalam baris.
>
> Tidak ada warna teks yang diambil langsung dari token terang di widget — semuanya
> lewat `ColorScheme` atau `inkSoftOf`, supaya dark mode mendapat padanannya.
> Dikunci oleh `test/app/sweep/screen_sweep_test.dart`, yang merender setiap layar
> di kedua mode dan mengukur **setiap teks** terhadap semua lapisan di belakangnya.

> ### Violet dipensiunkan seluruhnya
>
> Palet lama dibangun di atas keluarga ungu (250–300°) — bukan hanya `#D9C6FF`,
> tapi seluruh keluarga tinta (`ink`, `inkSoft`, `inkMuted` semuanya plum) dan
> seluruh dark mode. Semuanya kini navy/slate.
>
> **Pink brand tidak ikut.** `#F8AFCB` ada di ~337°, itu magenta, bukan violet —
> band yang dijaga test adalah 250–300°.
>
> Dua perbaikan kontras ikut terbawa, keduanya cacat lama yang baru ketahuan saat
> warnanya dihitung: `inkMuted` selama ini **3.5:1** (teks sekunder, tidak pernah
> lolos AA) dan `navIdle` **1.7:1** (tab non-aktif nyaris tak terlihat).

### Dark

Navy dalam, bukan hitam — agar nuansa *dreamy* tetap hidup: `darkBackground` `#0D1620`,
`darkSurface` `#16232F`, `darkInk` `#E8F1F8`, `darkInkSoft` `#D4DDE6`, `darkInkMuted`
`#A2B6C6`, aksen sky blue/pink yang sama.

Badge tipe punya **tabel pasangan sendiri** untuk dark mode (`_darkStyles` di
`type_badge.dart`) — hue tiap tipe dipertahankan, tint digelapkan ke 32% dan label
diterangkan, masing-masing ≥4.5:1 pada *setiap* latar kartu gelap. Tint pastel mode
terang tidak bisa dipakai ulang: di atas kaca gelap ia jatuh ke 1.61–2.23:1.

Perhatikan perannya **terbalik** di dark mode: `darkPrimary` (`#87CEEB`) justru yang
terbaca — 8.9:1 di atas `darkSurface` — karena tint terang di atas latar gelap adalah
kombinasi berkontras tinggi. Itu sebabnya kontras dark diuji terpisah dari light.

## 3. Permukaan Kaca

Dua komponen, dua tujuan berbeda — **jangan ditukar**:

| Komponen | Blur | Dipakai untuk |
|----------|------|---------------|
| `AppCard` | ❌ tidak | semua kartu konten (list item, tile, hero) |
| `GlassSurface` | ✅ ya | *chrome* melayang: nav bar, header bulan yang di-pin |

`AppCard` **sengaja tidak** memakai `BackdropFilter`: satu render-target per item list
langsung terasa saat men-scroll daftar panjang. Fill translusen di atas ambient wash
sudah membawa tampilannya. Blur nyata hanya untuk permukaan yang menimpa konten, di
mana fill datar akan membuat teks di bawahnya tembus dan terlihat seperti bug.

| Token | Nilai | Peran |
|-------|-------|-------|
| `glass` | putih 55% | fill kartu |
| `glassBorder` | putih 70% | tepi hairline |
| `darkGlass` / `darkGlassBorder` | putih 8% / 15% | padanan dark mode |

## 4. Ambient Wash

`AmbientBackground` dipasang **sekali** membungkus navigator (`MaterialApp.builder`),
bukan per halaman. Konsekuensinya, dan ini penting:

- `scaffoldBackgroundColor` **transparan** di seluruh app, termasuk Scaffold bersarang
  di dalam tab shell.
- Latar tidak ikut beranimasi saat route berpindah — ia diam, halaman yang bergeser.
- Apa pun yang dulu mengandalkan `scaffoldBackgroundColor` untuk menutupi sesuatu kini
  harus memakai `GlassSurface` (lihat header bulan di Schedule).

Blob ditahan di alpha `0.78` (light) dan `0.16` (dark) — konstanta
`AmbientBackground.lightBlobOpacity` / `darkBlobOpacity`, supaya test kontras membaca
angka yang sama dengan yang digambar. Di kekuatan itu `inkMuted` tidak lolos di atas
blob telanjang; itu sebabnya ia dibatasi ke dalam kartu kaca (lihat *Di mana tiap
tinta boleh duduk* di §2).

### Permukaan pastel tetap — `LightSurface`

Gradien hero (`heroGradient`) dan tile ikon kapabilitas adalah pastel **di kedua
mode**. Konten di atasnya dibungkus `LightSurface`, yang memberinya tema terang: judul,
badge, dan tombol simpan otomatis memakai tinta untuk latar terang, bahkan saat app
dalam dark mode. Ia menerima **builder, bukan child** — gaya yang di-resolve dari
context luar membawa warna tema gelap di dalamnya, dan membungkusnya tidak mengubah
apa pun.

Kartu *tembus pandang* (update terbaru, teaser statistik) berbeda: tint-nya diturunkan
di dark mode (20% / 15%) karena kekuatan mode terang di atas kaca gelap menghasilkan
warna tengah yang tidak bisa dibaca tinta mana pun.

## 5. Navigasi — Tab Shell

`TabShell` (`lib/app/tab_shell.dart`) adalah route `/`. Lima tab: **Home · Gallery ·
Schedule · Collection · More**.

- Empat kapabilitas yang paling sering dibuka jadi satu tap dari mana saja; sisanya
  (Members, Music, Statistics, Latest Updates, Awards, Voting) di tab **More**.
- Halaman detail tetap `push` di atas shell — nav bar menyingkir saat membaca satu hal.
- `extendBody: true`, jadi konten tab scroll **di bawah** nav bar. Setiap scroll view
  tab wajib menyisakan `GlassNavBar.reservedSpace` di bawah, kalau tidak item
  terakhirnya tertutup kaca.
- `TabSwitcher.go(context, index)` untuk pindah tab dari dalam tab (dipakai "See all"
  di Home). No-op di luar shell, jadi halaman tab tetap bisa di-`push` sendiri.

## 6. Tidak Ada AppBar

Ini perubahan yang paling terasa. **Tidak satu pun halaman memakai `AppBar`.**
Semuanya lewat `PageHeading` (`lib/app/widgets/layout/page_heading.dart`):

| Bentuk | Dipakai di | Tampilan |
|--------|-----------|----------|
| `PageHeading` | root sebuah tab | judul inline 26px/w700 (`headlineMedium`) |
| `PageHeading.sub` | apa pun yang di-`push` | tombol back bundar 38px + judul 22px/w700 (`headlineSmall`) |

Dua konsekuensi yang wajib diikuti halaman baru:

1. **Header ditaruh di luar scroll view**, di atas `Expanded` yang membungkus
   kontennya — bukan di dalam list. Tanpa AppBar, tombol back bundar itu satu-satunya
   jalan keluar, jadi ia harus tetap di layar **di semua state**, termasuk saat
   loading dan setelah gagal. Header yang ikut ter-scroll akan mengunci pengguna
   di halaman yang sedang memuat. (Pengecualian: Home — header-nya konten, dan
   Home tidak punya tombol back.)
2. **Body dibungkus `SafeArea(bottom: false)`**, karena tidak ada lagi AppBar yang
   menyerap inset status bar.

Tombol back-nya dibangun di atas `IconButton` dengan tooltip back standar —
itu yang dicari `WidgetTester.pageBack()` dan screen reader, jadi menggantikan
AppBar tidak menghilangkan perilaku apa pun.

## 7. Warna Member

`Member` tidak punya field warna, dan menambahkannya berarti memasukkan keputusan
styling ke data kurasi. Jadi warna avatar **diturunkan** lewat `memberColor()`
(`features/official_information/presentation/member_palette.dart`).

Diturunkan dari **peringkat**, bukan hash:

```dart
Color memberColor(String memberId, Iterable<String> allMemberIds)
```

Bedanya penting. Versi pertama meng-hash id ke delapan slot, dan itu **bertabrakan**:
dari delapan member asli, tiga jatuh ke biru yang sama dan dua ke coral yang sama —
tiga warna tidak terpakai, dan avatar berhenti membedakan siapa pun. Peringkat
menjamin setiap member dapat warna berbeda selama jumlah member ≤ jumlah palet.

Id-nya **di-sort dulu**, bukan memakai urutan `members.json` apa adanya, supaya
Product Owner menyusun ulang file itu tidak mengecat ulang siapa pun. Menambah atau
menghapus member memang menggeser warna member setelahnya secara alfabetis — itu
harga yang diterima demi jaminan warna tidak kembar.

Konsekuensi di sisi pemanggil: `memberColor` butuh daftar member lengkap, jadi
`MemberCard` dan `MemberAvatar` **menerima `Color` yang sudah jadi** — halaman yang
memegang daftarnyalah yang menghitung. Di Collection, daftar yang dikirim adalah
**seluruh roster**, bukan hanya yang tersimpan; mengirim subset akan memberi member
warna titik yang berbeda dari avatarnya di layar lain.

## 8. Home

Berubah dari direktori menjadi *digest*: greeting → kartu pengumuman terbaru →
4 quick action → Up next → teaser statistik. Grid kapabilitas pindah ke More, dan
itulah yang membebaskan Home untuk memimpin dengan konten.

Kartu pengumuman **hilang tanpa suara** saat feed gagal dimuat (feed-nya lewat
jaringan). Ini teaser: halaman Latest Updates yang memiliki error state + Retry, dan
kartu error di Home akan menggeser seluruh halaman untuk sesuatu yang tidak diminta
pengguna.

## 9. Kosakata Warna Kategorikal (bukan brand)

Tiga himpunan warna **sengaja bukan** turunan `primary`/`secondary`, karena tugasnya
membedakan kategori — bukan mewakili brand. Kalau semuanya diseragamkan ke sky blue,
warnanya berhenti membawa informasi:

| Himpunan | Isi | Hue yang dipakai |
|----------|-----|------------------|
| `CapabilityGradients` | 7 pasang, satu per kapabilitas | sky, oranye, pink, cobalt, pink muda, amber, mint |
| `TypeBadge` tints | 7 tipe event | sky, pink, **hijau segar**, **coral**, **slate**, amber, mint |
| `member_palette` | 8 warna avatar | sky, rose, teal, magenta, cobalt, coral, hijau, amber |

Tidak satu pun violet. Dua penyesuaian yang perlu diketahui saat menambah kategori:

- `concert` mengambil sky blue (brand), jadi `event` pindah ke **slate** — dua
  badge biru akan berhenti membedakan kedua tipe itu.
- `fanmeeting` sempat pindah dari periwinkle ke teal, lalu *(2026-09-20)* ke
  **hijau segar**, dan `release` dari pink muda ke **coral**. Keduanya karena hue
  yang tampak berbeda di kertas ternyata tidak terbedakan di layar: `release` dan
  `broadcast` terpaut 1° — ΔE 6.4 di mode terang, **0.4 di dark mode**, alias warna
  yang sama — dan teal terjepit di antara sky dan mint. Hue baru dipilih dengan
  **mengukur**, bukan menebak: ΔE (Lab) terhadap setiap badge lain di kedua mode,
  mengambil pasangan yang menjauhkan badge yang dipindah paling jauh (≥ 11.8) tanpa
  keluar dari rentang hangat brand atau kembali ke pita violet.

> **Aturan saat menambah tipe badge:** setiap pasangan tint harus berjarak
> **ΔE ≥ 10** di atas kartunya, di kedua mode — dijaga grup test *"type badges can
> be told apart"*. Membandingkan derajat hue tidak cukup: palet lama lolos ukuran
> hue tapi gagal di tujuh pasangan saat diukur ΔE, termasuk `concert`/`event` di
> dark mode (9.58), yang ikut digeser sedikit ke arah indigo.

Warna avatar member **sengaja lebih pekat** dari pastel di tempat lain: huruf
inisialnya putih, jadi tiap warna harus lolos 3:1. Pastel yang digantikan berada di
1.85–2.36:1 — inisialnya nyaris tak terbaca di kedelapan warna.

## 10. Badge

`TypeBadge` kini memetakan tipe ke **(background, foreground, label)** dan menampilkan
label huruf besar. Tipe yang tidak dipetakan tetap tampil rapi — nilainya sendiri
dengan tanda hubung dibuka (`music-show` → "MUSIC SHOW") — sehingga fitur dengan
kosakata sendiri (Awards, Voting) tidak memaksa map ini menghafal semua domain.

Karena Flutter tidak punya `text-transform`, string-nya benar-benar di-uppercase; badge
membungkusnya dengan `Semantics(label:)` agar screen reader tidak mengejanya huruf per
huruf.

## 11. Refinement Minimalis *(2026-09-20)*

Arah yang diminta: **minimalis ala Spotify, dalam bahasa liquid glass, terasa
hidup**. Yang membuat V2 terasa ramai bukan warnanya — melainkan **jumlah
kotaknya**: tiap rilis, tiap event, tiap tombol cepat adalah kartu tersendiri
dengan bayangan dan tepi. Lima perubahan, semuanya di komponen bersama:

| Perubahan | Alasan |
|---|---|
| `AppCard` tanpa bayangan, bertepi cahaya (`GlassRim`) | layar penuh kartu berbayang terbaca seperti tumpukan kotak melayang; bayangan disisakan untuk kaca yang memang mengambang di atas konten (nav bar, header ter-pin) |
| `SectionHeader` → **tebal, huruf biasa** | teks kecil KAPITAL ber-tracking adalah cara paling dekoratif dan paling tidak terbaca untuk melabeli section |
| Blob wash 0.78 → **0.55** (gelap 0.16 → 0.12) | latar itu ruangan, bukan subjeknya; kontras pun hanya membaik |
| Tombol cepat Home kehilangan kartunya | tile gradiennya sudah berupa bentuk; mengotakinya menambah empat panel di layar tersibuk |
| Nav bar: **pil yang meluncur** menggantikan titik | penanda yang berpindah, bukan berkedip mati-hidup; lewat `AppMotion`, jadi reduced motion mendapatinya sudah di tempat |

`GlassRim` menggores tepi panel dengan gradien — paling terang di sisi yang
menghadap cahaya, memudar di sisi jauh. Hairline satu warna terbaca sebagai
*border yang digambar*; gradien inilah yang membuat permukaan tembus pandang
terbaca sebagai **kaca**.

`PinnedSectionHeader` menyatukan header ter-pin Schedule (bulan) dan Awards
(tahun). Diekstrak pada pemakaian **kedua**, menyimpang dari Rule of Three,
karena salinannya sudah menyimpang dan membawa dua cacat: tinggi tetap yang
tidak bisa tumbuh bersama teks, dan latar `scaffoldBackgroundColor` — yang sejak
ambient wash **transparan**, sehingga kartu terlihat menembus header saat
digulir. Memperbaiki bug yang sama dua kali lebih buruk daripada satu
implementasi benar.

More akhirnya memakai `PageHeading` seperti empat tab lainnya; ia satu-satunya
yang masih tertinggal dengan `AppBar` Material sejak V2.

> Seluruh refinement ini dijaga tiga sweep aksesibilitas yang sudah ada — semuanya
> tetap hijau tanpa pengecualian baru.

## 11. Hati Inline

Salinan Collection — *"Tap the heart on anything to keep it here"* — kini benar dari
daftar, bukan hanya dari halaman detail. `FavoriteButton` menggantikan chevron di
`EventCard`, dan muncul sebagai gelembung beku di atas setiap foto album. Album grid
turun dari 3 ke 2 kolom untuk memberi ruang caption + tombol simpan.

---

## Dokumen Terkait

- [`design-system-v1.md`](design-system-v1.md) — tipografi, spacing, motion (masih berlaku)
- [`09_design_system.md`](09_design_system.md) — sistem & prinsip
- [`specs/home-layout.md`](specs/home-layout.md) — spesifikasi Home
