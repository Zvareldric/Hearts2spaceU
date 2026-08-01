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
| `primaryStrong` | `#1F6FA8` | 5.39:1 putih · 4.85:1 kaca ✅ | CTA solid, tab aktif, label aksen |
| `secondary` | `#F8AFCB` | — | blossom pink — aksen sekunder |
| `secondaryStrong` | `#D96FA0` | 3.12:1 | **ikon hati saja** (ambang non-text 3:1) |
| `ink` | `#16283C` | 14.4:1 | teks utama (navy) |
| `inkSoft` | `#3F566E` | 7.3:1 | body copy di dalam kartu kaca |
| `inkMuted` | `#60758A` | 4.6:1 ✅ | teks sekunder, label section |
| `navIdle` | `#6496B4` | 3.1:1 | tab tidak terpilih (ikon, ambang 3:1) |
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
`darkSurface` `#16232F`, `darkInk` `#E8F1F8`, aksen sky blue/pink yang sama.

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

Blob ditahan di alpha `0.78` (light): layar ponsel lebih tinggi dari frame desain
402×874, sehingga keempat blob lebih banyak bertumpuk dan `inkMuted` kehilangan kontras
di sudut pink pada kekuatan penuh.

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
| `TypeBadge` tints | 7 tipe event | sky, pink, **teal**, pink muda, **slate**, amber, mint |
| `member_palette` | 8 warna avatar | sky, rose, teal, magenta, cobalt, coral, hijau, amber |

Tidak satu pun violet. Dua penyesuaian yang perlu diketahui saat menambah kategori:

- `concert` mengambil sky blue (brand), jadi `event` pindah ke **slate** — dua
  badge biru akan berhenti membedakan kedua tipe itu.
- `fanmeeting` pindah dari periwinkle ke **teal**, satu-satunya hue dingin yang
  belum dipakai `concert` (sky) maupun `event` (slate).

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
