# Spec · Discography

> **Status:** 🟠 Draft (menunggu kurasi data Product Owner) · **Dibuat:** 2026-07-30
> **Penanggung jawab:** Mohammad Rifqi Hidayat (Product Owner)

Perwujudan kapabilitas **Discography** — setiap rilis Hearts2Hearts dari debut
sampai sekarang, beserta daftar lagunya.

---

## 0. Konteks & Traceability

- **Capability:** *Discography* — fase **🟡 Early Growth** ([`03`](../03_roadmap.md)
  §3, Capability Mapping), menjawab irisan "musik" yang sudah disebut di
  [`01`](../01_project_overview.md) §7 tapi belum digarap MVP.
- **Why** → *Trusted Information* + *Centralized Experience*
  ([`02`](../02_product_vision.md) §5) — nama rilis sebelumnya tersebar di Gallery
  (era foto), Awards (`work`), dan Schedule (event rilis); tidak ada satu tempat
  yang menjawab "apa saja diskografi mereka" (§1).

## 1. Tujuan

Fan ingin tahu **apa saja yang pernah dirilis** dan **lagu apa saja di dalamnya**.
Sebelum ini app punya nama rilis yang tersebar di tiga tempat — era foto di
Gallery, `work` di Awards, event rilis di Schedule — tapi tidak ada satu tempat
yang menjawab "apa saja diskografi mereka".

## 2. Use Cases

| ID | Sebagai fan, saya ingin… |
|----|--------------------------|
| UC-1 | melihat semua rilis, terbaru dulu |
| UC-2 | membuka satu rilis dan melihat daftar lagunya |
| UC-3 | melihat rilis terbaru langsung dari Home tanpa membuka menu |

## 3. Penempatan

Discography **bukan** tab nav bar. Nav bar dikunci 5 tab oleh Design System V2,
dan menambah tab keenam membuatnya padat.

| Pintu masuk | Bentuk |
|-------------|--------|
| **Home** | `ReleaseStrip` — deretan cover horizontal + "See all" (UC-3) |
| **More** | tile "Discography · Every release & track" |
| **Release detail** | baris "Listen on official platforms" → Streaming Hub |

Strip di Home dipilih karena dua alasan: mengisi ruang kosong Home dengan sesuatu
yang **konten**, bukan tombol, dan cover album adalah hal paling berwarna yang
dimiliki app ini.

Daftar penuhnya berbentuk **list**, bukan grid — Gallery sudah memiliki grid cover
2 kolom, dan grid kedua akan terbaca sebagai layar yang sama.

## 4. Data yang Dibutuhkan — dan Batasnya

Sumber: `assets/data/discography.json` (bundled, seperti `awards.json` — sebuah
rilis tidak berubah setelah keluar, jadi network round trip hanya menambah cara
untuk gagal).

| Field | Wajib | Catatan |
|-------|:-----:|---------|
| `id` | ✅ | dipakai route detail; harus unik |
| `title` | ✅ | |
| `year` | ✅ | kunci sort & tampilan minimum |
| `type` | — | `single` / `mini-album` / `album` |
| `releaseDate` | — | ISO date; mengalahkan `year` saat sorting |
| `note` | — | mis. `Japanese debut single` |
| `coverUrl` | — | wajib `https` (ditolak saat parse) |
| `tracks[]` | — | `{ "title": …, "isTitleTrack": bool }` |

> ### ⚠️ Yang belum terisi
>
> File yang di-commit berisi **7 rilis pada level rilis saja** — judul, tahun, dan
> cover, diambil dari data yang sudah ada di repo (`gallery.json`). `tracks` masih
> **kosong untuk semuanya**, dan `type`/`releaseDate` hanya terisi untuk dua rilis
> yang bisa disandarkan ke data repo:
>
> | Rilis | Dasar |
> |-------|-------|
> | Lemon Tang | `updates.json` — "Second mini album … released", 2026-06-01 |
> | Iconic Heart | `events.json` — Album & MV Release, 2026-08-12 |
>
> **Daftar lagu harus dikurasi Product Owner.** Tracklist tidak di-generate dan
> tidak dikira-kira: menuliskan lagu yang salah di app fan sama saja menyebarkan
> informasi keliru, dan itu lebih buruk daripada kolom kosong.
>
> UI-nya jujur soal ini — rilis tanpa tracklist menampilkan **"Track list not
> recorded yet."**, bukan panel kosong, dan kartunya tidak menulis "0 tracks"
> (yang akan terbaca sebagai rilis tanpa lagu). Prinsip yang sama dengan
> `Award.year`: jangan pernah mencetak hari yang tidak pernah disebut sumbernya.

Mengisinya cukup menambah array `tracks`, tanpa perubahan kode:

```json
{
  "id": "lemon-tang",
  "title": "Lemon Tang",
  "year": 2026,
  "type": "mini-album",
  "releaseDate": "2026-06-01",
  "tracks": [
    { "title": "Lemon Tang", "isTitleTrack": true },
    { "title": "…" }
  ]
}
```

## 5. Arsitektur

Mengikuti Evolutionary Clean Architecture yang sama dengan Awards:

```text
features/discography/
├── domain/          Release, Track, ReleaseRepository, newestFirst()
├── data/            AssetReleaseRepository (parse + validasi https)
└── presentation/
    ├── providers/   releaseRepositoryProvider, discographyProvider, releaseByIdProvider
    ├── pages/       DiscographyPage, ReleaseDetailPage
    └── widgets/     ReleaseCard, ReleaseCover, ReleaseStrip
```

- `newestFirst()` **murni**: tanpa clock, tanpa I/O, tidak memutasi input.
- Presentation bergantung pada `ReleaseRepository`, bukan kelas konkretnya, jadi
  sumber data bisa pindah (asset → network) tanpa UI tahu.
- `releaseByIdProvider` membaca list yang sudah dimuat — tanpa refetch.
- `ReleaseCover` memakai kembali `RemoteImage` milik Gallery, dengan `fallback`
  gradien brand: satu placeholder menangani tiga kondisi (tidak ada URL, sedang
  memuat, URL mati) sehingga slot cover tidak pernah jadi lubang kosong —
  penting terutama saat offline.

## 6. Acceptance Criteria

- [x] Rilis tampil terbaru dulu; `releaseDate` mengalahkan `year`; seri diputus oleh judul
- [x] Rilis tanpa tracklist berkata "not recorded yet", bukan panel kosong
- [x] `coverUrl` non-https ditolak saat parse
- [x] Cover yang gagal dimuat tetap tampil sebagai sleeve, bukan kotak kosong
- [x] Strip Home hilang tanpa suara kalau data gagal dimuat
- [ ] Tracklist terisi untuk seluruh rilis *(menunggu Product Owner)*

## 7. Evolution Notes

- **`type` String → enum** saat formatnya sudah stabil, sejalan dengan rencana
  `Event.type`.
- **Durasi lagu** belum ada di `Track`; ditambah kalau memang akan ditampilkan.
- **Link per rilis** (mis. Spotify URL tiap album) sengaja belum ada — saat ini
  detail mengarah ke Streaming Hub, agar Product Owner tidak perlu merawat
  tujuh set link.
- **Menggabungkan ke tab Music** adalah langkah berikutnya yang wajar: "Music"
  saat ini hanya tujuh link keluar, dan discography-lah isi sebenarnya dari
  kapabilitas itu. Dibiarkan terpisah dulu supaya diff-nya fokus.

## 8. Dokumen Terkait

- [`design-system-v2.md`](../design-system-v2.md) — komponen & token yang dipakai
- [`awards.md`](awards.md) — pola data kurasi + aturan "jangan mencetak yang tidak disebut sumber"
- [`gallery.md`](gallery.md) — `RemoteImage` dan degradasi gambar
- [`streaming-hub.md`](streaming-hub.md) — tujuan "Listen on official platforms"
