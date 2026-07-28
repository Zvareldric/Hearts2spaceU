# Spec · Gallery — Sprint 7

> **Status:** 🟢 Disetujui · **Dibuat:** 2026-07-28
> **Penanggung jawab:** Mohammad Rifqi Hidayat (Product Owner)
> **Branch:** `feature/gallery`

Kapabilitas **Early Growth** pertama. Ditulis **sebelum** kode ([`08`](../08_ai_guidelines.md)).

---

## 0. Konteks & Traceability

- **Capability:** *Gallery* — fase **🟡 Early Growth** ([`03`](../03_roadmap.md)).
- **Gerbang fase MVP → Early Growth dibuka 2026-07-28** atas keputusan Product Owner
  ([`03`](../03_roadmap.md) §Status fase). Catatan kejujuran ada di sana: kriteria aslinya
  menuntut bukti dari pengguna nyata, yang belum tersedia karena app belum dirilis.
- **Why** → *Centralized Experience* + *Consistent & Enjoyable Experience* ([`02`](../02_product_vision.md)).
- **How** → **ADR-001** + **Data Source Boundary** ([`04`](../04_architecture.md)).
- **Yang BARU:** kapabilitas pertama yang menampilkan **gambar**, dan pertama yang punya
  **tiga tingkat navigasi**.

## 1. Tujuan

Menyediakan galeri foto resmi Hearts2Hearts yang tertata per album/era, sehingga penggemar
dapat menikmati dokumentasi visual grup tanpa berpindah platform.

## 2. Ruang Lingkup Sprint 7

**Masuk (In Scope):**
- **Daftar album** (mis. *The Chase*, *FOCUS*, *Lemon Tang*) dengan foto sampul.
- **Grid foto** di dalam satu album.
- **Penampil layar penuh** — geser antar foto dalam album.
- Gambar dimuat dari **URL** memakai `Image.network` (bawaan Flutter).
- State **Loading / Empty / Error** untuk data **dan** untuk tiap gambar.

**Di luar (Out of Scope):**
- **Cache gambar ke disk** — `Image.network` sudah punya cache memori; cache disk butuh
  package (`cached_network_image`), ditunda sampai terbukti perlu.
- Unduh/simpan foto ke perangkat, bagikan, jadikan wallpaper.
- Zoom/pinch pada penampil penuh.
- Unggahan pengguna (bertentangan dengan *Official-source-first*).

## 3. Use Cases

| ID | Sebagai | Saya ingin | Agar |
|----|---------|-----------|------|
| **UC-1** | penggemar | melihat daftar album foto | memilih era yang ingin dilihat |
| **UC-2** | penggemar | melihat grid foto satu album | memindai isinya sekilas |
| **UC-3** | penggemar | membuka foto layar penuh & menggesernya | menikmati fotonya dengan jelas |

## 4. Data yang Dibutuhkan

**Sumber:** `data/gallery.json` **di-host** di root repo, diambil lewat jaringan —
pola yang sama dengan [`latest-updates.md`](latest-updates.md).

```
https://raw.githubusercontent.com/Zvareldric/Hearts2spaceU/main/data/gallery.json
```

> 📌 **Kenapa di-host, bukan dibundel?** Membundel foto membuat ukuran aplikasi membengkak
> dan setiap foto baru menuntut rilis ulang. Dengan URL, menambah foto cukup satu commit.

**Skema — `Album` memuat `Photo`:**

| Field (Album) | Tipe | Wajib | Keterangan |
|-------|------|:----:|------------|
| `id` | string | ✅ | pengenal unik & stabil |
| `title` | string | ✅ | nama album/era, mis. `Lemon Tang` |
| `year` | int | — | tahun era, untuk urutan/konteks |
| `coverUrl` | string | ✅ | foto sampul (**wajib `https://`**) |
| `photos` | array&lt;Photo&gt; | ✅ | minimal 1 |

| Field (Photo) | Tipe | Wajib | Keterangan |
|-------|------|:----:|------------|
| `id` | string | ✅ | unik **dalam album** |
| `url` | string | ✅ | URL gambar (**wajib `https://`**) |
| `caption` | string | — | keterangan singkat |

```json
[
  {
    "id": "lemon-tang",
    "title": "Lemon Tang",
    "year": 2026,
    "coverUrl": "https://example.com/lemon-tang/cover.jpg",
    "photos": [
      { "id": "01", "url": "https://example.com/lemon-tang/01.jpg", "caption": null }
    ]
  }
]
```

**Data Assumptions:**
- Seluruh URL **wajib `https`** — divalidasi saat parsing memakai `UrlOpener.isSafe`
  (aturan yang sama dengan [`streaming-hub.md`](streaming-hub.md) §6).
- Album **tanpa foto** ditolak saat parsing (album kosong tak ada gunanya).
- Urutan album & foto **mengikuti urutan sumber** — keputusan kurasi Product Owner.
- **Tautan bisa mati.** URL pihak ketiga di luar kendali kita; UI wajib menangani gambar
  gagal muat per-item, bukan merusak seluruh halaman.

## 5. ⚠️ Hak Cipta

Foto resmi adalah milik **SM Entertainment**. Proyek ini sudah memuat *disclaimer fan-made*
([`01`](../01_project_overview.md) §8). Dua batas yang dipegang sprint ini:

- **Tidak menyalin/menyimpan ulang** foto ke repo — hanya menunjuk URL sumbernya.
- **Tidak menyediakan fitur unduh** (di luar cakupan, §2).

Product Owner yang menentukan URL mana yang layak dipakai. Ini catatan teknis, **bukan
nasihat hukum**.

## 6. Arsitektur

```text
features/gallery/
├── domain/
│   ├── photo.dart
│   ├── album.dart
│   └── gallery_repository.dart      # INTERFACE
├── data/
│   └── http_gallery_repository.dart
└── presentation/
    ├── providers/gallery_providers.dart
    ├── pages/
    │   ├── albums_page.dart          # UC-1
    │   ├── album_page.dart           # UC-2 (grid)
    │   └── photo_viewer_page.dart    # UC-3 (PageView layar penuh)
    └── widgets/
        ├── album_card.dart
        └── photo_tile.dart
```

**Semua widget gambar memakai bawaan Flutter — nol package:**
- `Image.network` dengan **`loadingBuilder`** (placeholder saat memuat) dan
  **`errorBuilder`** (ikon "gambar tak tersedia" bila URL mati).
- `GridView.builder` untuk grid; `PageView` untuk geser layar penuh.
- **`Hero`** dari `photo_tile` ke penampil penuh — pola yang sudah dipakai di avatar Member.

**Navigasi & argumen:** `photoViewer` menerima `(String albumId, int initialIndex)` lewat
`RouteSettings.arguments` (Dart record — tanpa kelas argumen baru).

**Reuse Design System:** `AppCard`, `SectionHeader`, `LoadingView`/`EmptyView`/`ErrorView`,
`StaggeredItem`.

**Perubahan berkas non-fitur:** `app_routes.dart`/`app_router.dart` (+3 rute) ·
`home_page.dart` — **Gallery keluar dari *Coming Soon* menjadi Capability Card keenam**
(menyisakan Collection sendirian di Coming Soon).

## 7. Dependency

**Tidak ada dependency baru.** `http` (sudah ada) untuk JSON; `Image.network` bawaan
Flutter untuk gambar.

## 8. Acceptance Criteria

- [ ] `data/gallery.json` ada di root repo, valid, dapat diakses publik.
- [ ] UC-1: album tampil dengan sampulnya.
- [ ] UC-2: grid foto tampil; tap membuka penampil penuh **pada foto yang ditekan**.
- [ ] UC-3: penampil penuh dapat digeser antar foto dalam album yang sama.
- [ ] **Satu gambar gagal muat tidak merusak halaman** — hanya tile itu yang menampilkan
      placeholder error (ada test-nya).
- [ ] URL non-`https` **ditolak saat parsing**; album tanpa foto ditolak.
- [ ] State **Loading / Empty / Error** tertangani di tingkat data.
- [ ] Navigasi tiga tingkat + **back** berfungsi di tiap tingkat.
- [ ] Home menampilkan **6 Capability Card**; Coming Soon tersisa Collection.
- [ ] Tidak *overflow* di lebar 360dp **(dibuktikan test)**.

## 9. Definition of Done (Sprint 7)

- [ ] Spec disetujui PO.
- [ ] Struktur **Data → Domain → Presentation**.
- [ ] Seluruh **Acceptance Criteria** terpenuhi.
- [ ] `dart format` rapi & `flutter analyze` bersih.
- [ ] **Test:** unit (`parseAlbums`: https, album kosong, nested photos) + widget (state,
      grid, navigasi 3 tingkat, gambar gagal muat).
- [ ] **Data disediakan & diverifikasi PO** — URL foto harus dari sumber resmi.
- [ ] **Verifikasi runtime oleh PO** — gambar benar-benar tampil.
- [ ] **GitHub Flow**: merge → hapus branch → tag `v0.8.0`.

## 10. Evolution Notes

**If images load slowly on repeat visits:**
```
Image.network  →  cached_network_image (cache disk)
```

**If users want to zoom:**
```
PageView  →  + InteractiveViewer (bawaan Flutter)
```

**If the photo list per album grows large:**
```
load all  →  pagination / lazy loading
```

**If dead links become common:**
```
errorBuilder per tile  →  + validasi URL berkala di sisi data
```

## 11. Dokumen Terkait

| Hubungan | Dokumen |
|----------|---------|
| Fase & gerbang | [`03`](../03_roadmap.md) |
| Arsitektur & Boundary | [`04`](../04_architecture.md) |
| Pola data di-host | [`latest-updates.md`](latest-updates.md) |
| Aturan keamanan URL | [`streaming-hub.md`](streaming-hub.md) |
| Disclaimer fan-made | [`01`](../01_project_overview.md) §8 |
