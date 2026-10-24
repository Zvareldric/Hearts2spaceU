# Ikon aplikasi

Sumber ikon peluncur di semua platform. **Bukan rancangan baru** — ini brand mark
yang sudah ada di Home (sebelah wordmark): gradien `AppColors.heroGradient`
kiri-atas → kanan-bawah, dengan hati `Icons.favorite_rounded` putih seukuran 50%.
Dirender oleh Flutter sendiri, jadi glyph-nya identik dengan yang ada di app.

| Berkas | Isi | Dipakai untuk |
|---|---|---|
| `app-icon-1024.png` | gradien penuh + hati 50%, tanpa alpha | iOS (semua ukuran), App Store, dasar ikon macOS / Android lama / web |
| `app-icon-foreground-1024.png` | hati 33% di atas latar transparan | lapisan depan & monokrom *adaptive icon* Android 8+ |

## Aturan per platform

| Platform | Bentuk | Catatan |
|---|---|---|
| iOS | persegi penuh, **tanpa alpha** | App Store menolak alpha; iOS memotong sudutnya sendiri |
| macOS | kotak membulat 824/1024, radius ±22,5% | grid ikon macOS |
| Android 8+ | *adaptive*: latar gradien + hati 33% + monokrom | hati 33% = 50% dari area yang terlihat (72/108 dp) |
| Android 7 | kotak membulat, margin 4%, radius 20% | |
| Web | biasa (membulat) + *maskable* (penuh, hati 40%) | maskable harus aman dipotong lingkaran |

Kotak membulat dibuat dengan **mask sebagai kanal alpha**, bukan *paste* lewat
mask ke kanvas transparan — cara kedua mencampur setiap piksel tepi dengan hitam
dan menghasilkan tepi gelap (versi pertama ikon ini punya 227 piksel seperti itu).

Diketahui: launcher Pixel memotong label "Hearts2spaceU" (13 karakter) menjadi
"Hearts2spa…". Itu nama app-nya; memendekkannya adalah keputusan merek.
