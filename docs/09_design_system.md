# 09 · Design System

> **Status:** 🟢 Terisi (sistem) · **Dibuat:** 2026-07-17 · **Diperbarui:** 2026-07-18
> **Penanggung jawab:** Mohammad Rifqi Hidayat (Project Owner)

Dokumen ini menetapkan **sistem desain** Hearts2spaceU — *struktur* dan *prinsip* yang menjaga UI tetap konsisten dan dapat berkembang. Yang dikunci adalah **sistemnya, bukan tampilannya**.

> 🎨 **Di luar cakupan dokumen ini (ditunda ke desain visual):** warna konkret, tema visual, dan estetika. Menetapkan *sistem* lebih dulu memastikan konsistensi UI apa pun tampilan akhirnya nanti — selaras filosofi "kunci prinsip, biarkan detail berevolusi".
>
> 📝 Nilai warna *placeholder* di `app/hearts2spaceu/lib/app/theme/` **bukan** keputusan desain.

---

## 1. Design Principles

- **Consistency** — komponen & pola yang sama dipakai berulang; hindari variasi tanpa alasan.
- **Simplicity** *(Core Value `02`)* — antarmuka yang menyederhanakan, bukan mempersulit.
- **Fan-centric** *(`02`)* — keputusan UI melayani kebutuhan penggemar.
- **Token-driven** — keputusan visual diambil dari *design tokens*, bukan nilai acak (*magic values*).
- **Accessible by default** — aksesibilitas adalah bawaan, bukan tambahan.
- **Evolutionary** — sistem dapat diperkaya bertahap tanpa merombak yang sudah ada.

## 2. Design Tokens

*Design token* = **satu sumber kebenaran** untuk keputusan visual, diberi nama **semantik** (bukan nilai mentah yang tersebar di kode).

- Kategori token: **color**, **typography**, **spacing**, **radius** (sudut), **elevation** (bayangan), **duration** (animasi).
- Penamaan **semantik/peran**, mis. `color.surface`, `color.onPrimary`, `spacing.md` — bukan `blue500` yang tersebar.
- **Nilai konkret token = keputusan desain visual (TBD).** Yang dikunci: *keberadaan* lapisan token dan penggunaannya sebagai satu-satunya sumber.
- Token berdiam di *theme layer* aplikasi (mis. `lib/app/theme/`), selaras ADR-001 (`04`).

## 3. Typography Scale

- Menggunakan **skala tipografi bertingkat (modular scale)** dengan **peran bernama** — mis. `display`, `headline`, `title`, `body`, `label` (gaya Material 3).
- UI memakai **gaya bernama** dari skala, **bukan** ukuran font ad-hoc.
- **Font family & ukuran konkret = keputusan visual (TBD).** Yang dikunci: adanya skala dan pemakaian peran bernama.

## 4. Spacing System

- Spacing mengikuti **skala berbasis satu *base unit*** dengan langkah bernama: `xs`, `sm`, `md`, `lg`, `xl`, `xxl`.
- Semua jarak (padding, margin, gap) memakai **token spacing**, bukan angka lepas (*magic numbers*).
- Nilai *base unit* konkret (mis. kelipatan 4) ditetapkan saat desain visual; yang dikunci adalah **sistem berbasis skala**-nya.

## 5. Component Principles

- **Reusable** — komponen berulang dibuat sekali, dipakai ulang; hindari duplikasi.
- **Shared vs feature-specific** — komponen lintas-fitur di `shared/widgets/`; komponen khusus fitur di `features/<x>/presentation/widgets/` (selaras struktur `04`).
- **Stateful visual states** — tiap komponen mempertimbangkan state: *default*, *pressed/focused*, *disabled*, *loading*, *error*, *empty*.
- **Loading, Empty, dan Error adalah bagian pengalaman pengguna** yang harus dirancang secara konsisten — bukan sekadar kondisi teknis.
- **Single responsibility** — satu komponen, satu tanggung jawab; komposisi di atas konfigurasi berlebih.
- **Token-based** — komponen menata diri dari token, bukan nilai keras.

## 6. Accessibility

Target: **WCAG 2.1 Level AA** sebagai *baseline*.

- **Kontras** warna teks/latar memadai (dinilai saat warna ditetapkan).
- **Ukuran target sentuh** memadai (mis. mengikuti panduan platform).
- **Teks dapat diskalakan** (menghormati pengaturan ukuran font pengguna).
- **Label semantik** untuk elemen interaktif (dukungan *screen reader*).
- Tidak mengandalkan **warna saja** untuk menyampaikan makna.

## 7. Iconography

- Menggunakan **satu set ikon yang konsisten** (gaya seragam) di seluruh aplikasi.
- Ukuran ikon mengikuti **token** (selaras spacing/typography).
- Ikon interaktif memiliki **label aksesibilitas**.
- **Pilihan set ikon konkret = keputusan visual (TBD).**

## 8. Responsiveness

- **Layout fleksibel/adaptif** — memakai unit relatif & widget fleksibel, hindari dimensi keras.
- **Breakpoint** untuk menyesuaikan tata letak pada ukuran layar berbeda (ponsel kecil → besar; potensi tablet).
- Konten lebar (tabel, diagram) dapat digulir dalam wadahnya sendiri.
- Menghormati *safe area* dan orientasi perangkat.
- **Content-first** — layout menyesuaikan demi **konten**, bukan sekadar memperbesar elemen saat layar lebih besar.

## 9. Motion & Animation Principles

*Filosofi, bukan implementasi.*

- Animasi **mendukung pemahaman** (memberi konteks & umpan balik), bukan dekorasi.
- **Hindari animasi berlebihan** yang mengganggu atau memperlambat.
- Durasi & *easing* diambil dari **design tokens** (mis. `duration.*`).
- **Hormati preferensi *reduced motion*** bila nanti didukung.

---

## Catatan Cakupan

Dokumen ini mengunci **sistem** desain. Hal-hal berikut sengaja **ditunda**:
- Warna, tema visual, estetika, *light/dark theme* konkret → **desain visual**.
- Persona & *user flow* UX detail → dokumen desain/UX.
- Nilai konkret token, font, dan ukuran → ditetapkan saat desain visual, lalu dituangkan sebagai token.

## Dokumen Terkait

| Hubungan | Dokumen |
|----------|---------|
| Nilai produk (Simplicity, Fan-centric) yang memandu UI | [`02_product_vision.md`](02_product_vision.md) |
| Struktur komponen (`shared/` vs `features/`) | [`04_architecture.md`](04_architecture.md) |
| Item pekerjaan UI | [`10_backlog.md`](10_backlog.md) |

_Turunan dari: [`02_product_vision.md`](02_product_vision.md) · [`04_architecture.md`](04_architecture.md)_
