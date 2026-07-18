# assets/ — Project & Brand Assets

Aset tingkat **project** yang dipakai lintas komponen atau untuk keperluan **non-runtime** (dokumentasi, GitHub, store, proses desain).

> ⚠️ **Beda dengan aset runtime Flutter.** Aset yang benar-benar dimuat aplikasi saat berjalan (di-*bundle* lewat `pubspec.yaml`) **tetap** di `app/hearts2spaceu/assets/`. File di sini **tidak** ikut ter-bundle ke aplikasi — jadi ukuran build tetap ramping.

> 🗳️ Keputusan **D2 & D6** (2026-07-18): root `assets/` = aset bersama/project · `app/hearts2spaceu/assets/` = aset runtime.

## Isi — root `assets/` (non-runtime)
| Folder | Untuk apa | Contoh |
|--------|-----------|--------|
| `branding/` | Identitas visual (sumber) | **logo**, sumber ikon aplikasi, banner |
| `design/` | Aset proses desain | **mockup**, wireframe, **Figma export** |
| `screenshots/` | Tangkapan layar aplikasi | untuk README, GitHub, store listing |

## Lawannya — `app/hearts2spaceu/assets/` (runtime)
Khusus aset yang **dipakai aplikasi saat berjalan** dan didaftarkan di `pubspec.yaml`, mis.:

| Jenis | Contoh |
|-------|--------|
| `image/` | gambar/bitmap yang tampil di UI |
| `font/` | berkas font aplikasi |
| `lottie/` | animasi Lottie |
| `svg/` | ikon/vektor |

> 🕒 Folder runtime di atas **belum dibuat** — sesuai *Incremental*, tiap folder dibuat **saat** ada aset pertamanya, **bersamaan** dengan mendaftarkannya di `pubspec.yaml`. (Folder aset kosong yang terdaftar di pubspec bisa memicu error build.)

## Aturan
- Simpan **sumber** di root `assets/`; hasil olah untuk runtime disalin/di-generate ke `app/hearts2spaceu/assets/`.
- Hindari menyimpan file sangat besar tanpa perlu — repo bisa membengkak.
- Folder kosong dijaga oleh `.gitkeep`; hapus saat sudah terisi file asli.
