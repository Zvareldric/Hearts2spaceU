# 01 · Project Overview

> **Status:** 🟢 Terisi (fondasi) · **Dibuat:** 2026-07-17 · **Diperbarui:** 2026-07-18
> **Penanggung jawab:** Mohammad Rifqi Hidayat (Project Owner)

Dokumen ini adalah *pintu masuk* project: gambaran umum **apa**, **kenapa**, dan **untuk siapa**. Pembahasan yang lebih dalam sengaja diletakkan di dokumen turunannya (lihat bagian [Dokumen Terkait](#dokumen-terkait--cakupan-lanjutan)).

---

## 1. Identitas Project

| Item         | Nilai                                          |
| ------------ | ---------------------------------------------- |
| Nama         | Hearts2spaceU                                  |
| Tema         | Hearts2Hearts (grup di bawah SM Entertainment) |
| Jenis Produk | Aplikasi mobile                                |
| Framework    | Flutter                                        |
| Tahap        | Planning                                       |
| Repository   | Publik di GitHub — URL`[TODO]`              |
| Lisensi      | Apache License 2.0                             |

## 2. Ringkasan

Hearts2spaceU adalah aplikasi mobile fandom *all-in-one* yang dirancang untuk penggemar **Hearts2Hearts** di seluruh dunia. Dalam satu platform terintegrasi, pengguna dapat mengakses informasi resmi grup (member, musik, jadwal, galeri, statistik), mengikuti aktivitas terbaru, mengelola koleksi pribadi, serta mendukung aktivitas fandom. Aplikasi **dikembangkan secara bertahap menggunakan pendekatan incremental**.

## 3. Tujuan Produk

Menyediakan satu platform terintegrasi yang memudahkan penggemar Hearts2Hearts mengakses informasi resmi, mengikuti perkembangan terbaru, mengelola aktivitas fandom, serta menikmati pengalaman fandom yang lebih terorganisir.

> Rumusan visi & misi yang lebih mendalam dibahas di [`02_product_vision.md`](02_product_vision.md).

## 4. Tujuan Pengembangan

Selain sebagai produk, Hearts2spaceU dikembangkan sebagai **project pembelajaran jangka panjang** sekaligus **portofolio profesional**, dengan menerapkan **praktik Software Engineering yang profesional**. Melalui project ini, penerapan berikut dilatih secara bertahap:

- **Mobile Development** (Flutter)
- **Backend Development**
- **Cloud Computing**

## 5. Target Pengguna

Aplikasi ditujukan untuk **seluruh penggemar Hearts2Hearts secara global** — dari penggemar yang baru mengenal grup hingga yang sudah lama mengikuti aktivitas mereka. **Bahasa awal yang direncanakan adalah Bahasa Inggris** agar dapat diakses lintas negara; dukungan bahasa lain dapat dipertimbangkan pada tahap berikutnya.

> Segmentasi pengguna yang lebih rinci (*Primary / Secondary / Future Audience*) dibahas di [`02_product_vision.md`](02_product_vision.md).

## 6. Prinsip Produk

Sebagai pengantar, Hearts2spaceU berpijak pada empat prinsip utama:

- **Official-source-first** — mengutamakan sumber resmi.
- **Fan-centric** — berorientasi pada kebutuhan penggemar.
- **Privacy-first** — menghormati privasi pengguna.
- **Incremental Growth** — berkembang secara bertahap.

> Penjabaran tiap prinsip dilakukan di dokumen terkait (mis. [`02_product_vision.md`](02_product_vision.md) dan dokumen desain).

## 7. Ruang Lingkup

**Masuk (MVP):**

- Informasi grup: member, musik, jadwal, galeri, statistik
- Mengikuti aktivitas terbaru
- Mengelola koleksi pribadi
- Dukungan aktivitas fandom
- **Official Streaming Hub** — menghubungkan pengguna ke platform streaming resmi via *deep link* (bukan pemutar konten)

**Di luar cakupan:**

- Hearts2spaceU **bukan** layanan streaming musik/video; konten tetap dinikmati melalui layanan resmi.

**Future Consideration** (mungkin dipertimbangkan di masa depan bila memberi nilai tambah nyata):

- Marketplace
- Media sosial penuh / interaksi antar-penggemar
- Penjualan tiket

> Rincian fitur beserta penjadwalannya dibahas di [`03_roadmap.md`](03_roadmap.md).

## 8. Disclaimer

Hearts2spaceU merupakan proyek *fan-made* independen dan **tidak berafiliasi, didukung, maupun disponsori** oleh SM Entertainment maupun Hearts2Hearts. Seluruh merek dagang dan materi berhak cipta adalah milik pemiliknya masing-masing.

---

## Dokumen Terkait & Cakupan Lanjutan

Overview ini sengaja dijaga tetap ringkas. Pembahasan lebih dalam ada di:

| Topik                                                    | Dokumen                                         |
| -------------------------------------------------------- | ----------------------------------------------- |
| Visi, misi, persona,*value proposition*, metrik sukses | [`02_product_vision.md`](02_product_vision.md) |
| Fase pengembangan & rincian fitur                        | [`03_roadmap.md`](03_roadmap.md)               |
| Keputusan arsitektur & teknis                            | [`04_architecture.md`](04_architecture.md)     |
| Teknologi (backend, database, cloud, dll.)               | [`05_tech_stack.md`](05_tech_stack.md)         |
