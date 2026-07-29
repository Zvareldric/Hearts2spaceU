# Spec · Personal Collection — Sprint 8

> **Status:** 🟢 Disetujui · **Dibuat:** 2026-07-28
> **Penanggung jawab:** Mohammad Rifqi Hidayat (Product Owner)
> **Branch:** `feature/collection`

Kapabilitas **Early Growth**, dan **yang pertama menyimpan data pengguna**.

---

## 0. Konteks & Traceability

- **Capability:** *Personal Collection* — fase **🟡 Early Growth** ([`03`](../03_roadmap.md)).
- **Why** → *Organized Fandom Experience* ([`02`](../02_product_vision.md)).
- **Yang BARU:** kapabilitas pertama yang **menulis** data (semua sebelumnya hanya membaca),
  dan pertama yang punya **penyimpanan lokal**.

### 🔑 ADR-002 terjawab tanpa database

[`04`](../04_architecture.md) menunda *Local Database* dengan pemicu tertulis:
*"diperkenalkan saat dibutuhkan oleh **Personal Collection**, Offline, atau Caching"*.
Pemicunya kini tiba — **tetapi kebutuhannya tidak memerlukan database.**

Koleksi pribadi di sini hanyalah **himpunan ID** yang ditandai pengguna. Tidak ada query,
relasi, atau migrasi skema. Satu string JSON di `shared_preferences` sudah cukup untuk
ribuan entri.

> 📌 Menunda database **tetap berlaku**. Yang berubah: kita membuktikan kebutuhannya bisa
> dipenuhi selapis lebih ringan. Pemicu asli tetap hidup untuk *Offline* dan *Caching*.

## 1. Tujuan

Memberi penggemar satu tempat berisi hal-hal yang mereka tandai sendiri — foto, acara,
penghargaan — sehingga aplikasi terasa **milik mereka**, bukan sekadar katalog.

## 2. Ruang Lingkup Sprint 8

**Masuk (In Scope):**
- **Tombol favorit** pada halaman detail: Photo, Event, Award, Member, Update.
- **Halaman Collection** — semua yang ditandai, dikelompokkan per jenis.
- Penyimpanan **lokal di perangkat**, bertahan setelah aplikasi ditutup.
- Menghapus tanda favorit dari mana saja.

**Di luar (Out of Scope):**
- **Sinkronisasi antar perangkat / akun** — butuh backend & autentikasi (ADR-002).
- Katalog merch fisik, wishlist, catatan pribadi, penilaian.
- Ekspor/impor koleksi.
- Folder/koleksi bernama buatan pengguna.

## 3. Use Cases

| ID | Sebagai | Saya ingin | Agar |
|----|---------|-----------|------|
| **UC-1** | penggemar | menandai favorit dari halaman detail | menyimpan yang berkesan bagi saya |
| **UC-2** | penggemar | melihat semua favorit di satu tempat | menemukannya kembali dengan cepat |
| **UC-3** | penggemar | menghapus tanda favorit | koleksi tetap sesuai keinginan saya |

## 4. Data & Penyimpanan

**Bukan data kurasi** — ini satu-satunya data yang **dibuat pengguna**, jadi tak ada
berkas JSON yang di-host maupun dibundel.

**Kunci favorit:** `"<type>:<id>"` — mis. `photo:lemon-tang/01`, `event:tima-2026-day-1`.
Satu ruang nama datar, sehingga menambah jenis baru tak menuntut perubahan penyimpanan.

**Disimpan sebagai:** satu entri `shared_preferences`, key `favorites`, berisi **JSON array
of string**.

```json
["award:mama-2025-best-new-artist", "photo:lemon-tang/01", "event:tima-2026-day-1"]
```

**Data Assumptions:**
- Urutan dalam penyimpanan **tidak bermakna**; tampilan mengurutkan sendiri.
- Kunci yang **tak lagi ada** di data sumber (mis. foto dihapus dari `gallery.json`)
  **diabaikan saat menampilkan**, tidak dihapus otomatis — data pengguna tidak dibuang
  diam-diam hanya karena sumbernya sedang gagal dimuat.
- Penyimpanan rusak/tak terbaca → dianggap koleksi kosong, **bukan crash**.

## 5. Arsitektur

```text
lib/shared/services/
└── favorites_store.dart            # BARU — baca/tulis shared_preferences

features/collection/
├── domain/
│   ├── favorite.dart               # entity: type + id (+ parsing kunci)
│   └── favorites_repository.dart   # INTERFACE
├── data/
│   └── prefs_favorites_repository.dart
└── presentation/
    ├── providers/favorites_providers.dart
    ├── pages/collection_page.dart
    └── widgets/favorite_button.dart   # dipakai 5 halaman detail
```

**`favorite_button.dart` berada di `features/collection/`**, bukan `app/widgets/` —
ia mengetahui domain favorit. Halaman detail feature lain memakainya; ini **satu-satunya
titik** di mana feature lain menyentuh Collection.

**State:** `favoritesProvider` (`AsyncNotifier` atau `FutureProvider` + notifier) menyimpan
`Set<String>`. Menandai/menghapus memperbarui set **lalu** menulis ke penyimpanan — UI
langsung merespons.

**Halaman Collection** memotong kunci per jenis, lalu mencocokkannya ke data yang sudah
dimuat provider masing-masing (`albumsProvider`, `upcomingEventsProvider`, dst.) untuk
menampilkan kartu yang sudah ada. **Tidak ada kartu baru** — pakai ulang seluruhnya.

**Perubahan berkas non-fitur:**
- 5 halaman detail — tambah `FavoriteButton`.
- `app_routes.dart`/`app_router.dart` — +`collection`.
- `home_page.dart` — **Collection keluar dari *Coming Soon*** menjadi Capability Card
  ketujuh. **Coming Soon habis** → seksinya dihapus dari Home.
- `pubspec.yaml` + [`05`](../05_tech_stack.md) — catat `shared_preferences`.

## 6. Dependency

**`shared_preferences`** — satu package resmi Flutter.

Dicatat di [`05`](../05_tech_stack.md) sesuai *Dependency Policy*. Alternatif yang
dipertimbangkan & ditolak: `drift`/`isar` (berlebihan untuk daftar ID),
`path_provider`+`dart:io` (sama-sama 1 package, tapi kita harus menangani
baca/tulis/korupsi sendiri).

## 7. Acceptance Criteria

- [ ] Menandai favorit di halaman detail lalu **menutup & membuka ulang aplikasi** —
      tandanya masih ada (ada test-nya).
- [ ] Menghapus tanda dari halaman detail **maupun** dari halaman Collection.
- [ ] Collection menampilkan favorit **dikelompokkan per jenis**, memakai kartu yang sudah ada.
- [ ] Kunci yang sumbernya hilang **diabaikan**, tidak membuat crash dan tidak dihapus.
- [ ] Penyimpanan rusak → koleksi kosong, **bukan crash** (ada test-nya).
- [ ] Collection kosong → `EmptyView` yang mengarahkan pengguna menandai sesuatu.
- [ ] Home menampilkan **7 Capability Card**; seksi **Coming Soon dihapus**.
- [ ] Tidak *overflow* di lebar 360dp **(dibuktikan test)**.
- [ ] **Tidak ada test yang menyentuh penyimpanan asli** — repository di-*override*.

## 8. Definition of Done (Sprint 8)

- [ ] Spec disetujui PO.
- [ ] `shared_preferences` diratifikasi & dicatat di [`05`](../05_tech_stack.md).
- [ ] Seluruh **Acceptance Criteria** terpenuhi.
- [ ] `dart format` rapi & `flutter analyze` bersih.
- [ ] **Test:** unit (parsing kunci, penyimpanan rusak, tandai/hapus) + widget (tombol
      favorit, halaman Collection, persistensi).
- [ ] **Verifikasi runtime oleh PO** — tandai, tutup app, buka lagi, tandanya bertahan.
- [ ] **GitHub Flow**: merge → hapus branch → tag `v0.9.0`.

## 9. Evolution Notes

**If favorites should sync across devices:**
```
shared_preferences  →  backend + auth (ADR-002)
```

**If the collection grows complex (notes, ratings, merch attributes):**
```
Set<String> in prefs  →  local database (drift/isar) — pemicu ADR-002 hidup lagi
```

**If users want named collections:**
```
one flat set  →  collections with ids and titles
```

## 10. Dokumen Terkait

| Hubungan | Dokumen |
|----------|---------|
| Fase & kapabilitas | [`03`](../03_roadmap.md) |
| ADR-002 (penundaan database) | [`04`](../04_architecture.md) |
| Dependency Policy | [`05`](../05_tech_stack.md) |
| Kartu & state yang dipakai ulang | [`design-system-v1.md`](../design-system-v1.md) |
