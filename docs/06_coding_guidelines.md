# 06 · Coding Guidelines

> **Status:** 🟢 Terisi (MVP) · **Dibuat:** 2026-07-17 · **Diperbarui:** 2026-07-18
> **Penanggung jawab:** Mohammad Rifqi Hidayat (Project Owner)

Tujuan dokumen ini menjaga **konsistensi** dan **kualitas kode yang mudah dipelihara**. Panduan di sini merupakan turunan dari *project principles* dan konstitusi proyek (`01`–`05`) — bukan preferensi gaya pribadi.

---

## 1. Prinsip Penulisan Kode

- **Konsistensi & keterbacaan** di atas preferensi pribadi.
- **Consistency over Cleverness** — lebih baik memakai pola yang konsisten daripada solusi yang terlalu pintar tetapi sulit dipahami anggota tim lain. (Selaras *Learning First* & *Maintainability*.)
- Turunan langsung dari prinsip: *Learning First*, *Maintainability*, *Avoid Over-Engineering*, *Evolutionary Architecture*.
- **Lint sebagai alat, bukan target:**
  > **Linting adalah alat untuk menjaga konsistensi dan kualitas kode, bukan target yang harus dipenuhi demi menghilangkan seluruh warning.**

  Karena itu kita **menghindari**:
  - menambahkan `// ignore` tanpa alasan yang jelas,
  - mengubah kode menjadi kurang terbaca hanya untuk memuaskan lint,
  - mengikuti aturan secara membabi buta.

  Lint tetap menjadi **panduan**, sementara **kualitas desain dan keterbacaan** tetap menjadi prioritas.

## 2. Bahasa & Format

- Bahasa: **Dart**, mengikuti **Effective Dart** (panduan gaya resmi).
- **`dart format`** wajib dijalankan sebelum commit.
- **`flutter analyze`** harus **bersih** sebelum commit — dengan cara yang benar (memperbaiki akar masalah), **bukan** menutupinya dengan `ignore`.

## 3. Linting / Static Analysis Strategy — *Base + Evolution*

Yang **dikunci** adalah **kebijakan evolusi standar linting**, **bukan** nama package tertentu. Proyek **tidak** dikunci pada `very_good_analysis`.

- **Tahap MVP:** gunakan **`flutter_lints`** sebagai *baseline* resmi.
- **Tahap berikutnya:** aktifkan aturan tambahan **secara selektif berdasarkan kebutuhan nyata proyek** — bukan mengadopsi seluruh `very_good_analysis` sekaligus.
- Setiap aturan lint tambahan / penyimpangan dari *baseline* **wajib memiliki alasan yang terdokumentasi** (mis. komentar pada `analysis_options.yaml`).

*Traceability:* Learning First (tidak membebani di awal) · Evolutionary Architecture (standar tumbuh bersama kompleksitas) · Maintainability (pengetatan bertahap tanpa perombakan gaya).

## 4. Konvensi Penamaan

Mengikuti **Effective Dart**.

| Elemen | Konvensi | Contoh |
|--------|----------|--------|
| File & folder | `snake_case` | `home_page.dart` |
| Class / enum / typedef / extension | `UpperCamelCase` | `HomePage`, `FandomStatus` |
| Variabel / fungsi / parameter | `lowerCamelCase` | `fetchLatestUpdates` |
| Konstanta | `lowerCamelCase` | `defaultTimeout` |

- Gunakan nama **deskriptif**; hindari singkatan yang tidak jelas.

## 5. Struktur & Organisasi File

- Mengikuti **ADR-001 (Evolutionary Clean Architecture)** di [`04`](04_architecture.md): *feature-first* + pemisahan `presentation` ↔ `data`. Lapisan lain (`domain`, `usecases`, dll.) **ditambah saat menyelesaikan masalah nyata** (lihat tabel pemicu lapisan di `04`).
- Idealnya **satu file = satu tanggung jawab utama**.
- Struktur `lib/` akan di-*refactor* mengikuti ADR-001 pada tahap implementasi yang sesuai.

## 6. Konvensi State Management (Riverpod)

Mengikuti keputusan `05`.

- **Presentation Layer (UI) tetap tipis** — logika state berada di *provider*/*notifier*, bukan di widget.
- Gunakan **`AsyncValue`** untuk state asinkron (*loading* / *success* / *error*).
- Akses data **hanya melalui Data Source Boundary** — UI/State tidak memanggil sumber data secara langsung ([`04`](04_architecture.md)).
- Penamaan *provider* konsisten (mis. berakhiran `Provider`).

## 7. Error Handling

Bersifat **evolusioner** (mengikuti `04`).

- **MVP:** tangani error asinkron melalui `AsyncValue.error`, dengan `try/catch` sederhana di *data layer*.
- **Failure Abstraction** diperkenalkan **ketika strategi penanganan error menjadi lebih kompleks** (pemicu lapisan ADR-001).
- **Jangan menelan error diam-diam** (*no silent catch*).

## 8. Komentar & Dokumentasi Kode

- Komentar menjelaskan **"mengapa"**, bukan "apa" — kode yang baik sudah menjelaskan "apa".
- Gunakan **doc comment (`///`)** untuk API publik yang tidak trivial.
- Hindari komentar yang usang atau sekadar mengulang kode.
- Hindari komentar yang menjelaskan **apa** yang kode lakukan apabila nama fungsi dan struktur kode sudah cukup jelas.

## 9. Konvensi Testing

Mengikuti strategi pengujian `04` dan **berkembang mengikuti evolusi arsitektur** (lapisan baru → pengujiannya menyusul).

- **MVP:** **Unit Test** (logika/service) + **Widget Test** (layar/komponen kunci). *Integration Test* menyusul saat alur stabil.
- Pola **Arrange–Act–Assert**.
- Nama test **deskriptif** — menjelaskan perilaku yang diuji.
- **Test menguji perilaku (behavior), bukan implementasi internal** — memudahkan *refactor* tanpa merusak test.

## 10. Disiplin Dependency

- Setiap dependency baru **wajib dicatat** pada *Dependency Policy* di [`05`](05_tech_stack.md) (nama, alasan-tertelusur, alternatif, *version policy*).
- Tidak menambah package tanpa kebutuhan nyata (*Solve a Real Problem*).

## 11. Checklist Sebelum Commit

- [ ] `dart format` dijalankan
- [ ] `flutter analyze` bersih (dengan cara yang benar, bukan `ignore` serampangan)
- [ ] Test terkait lulus
- [ ] Tidak ada `print`/kode debug/komentar sampah
- [ ] Tidak ada `TODO`/`FIXME` baru tanpa alasan atau issue yang jelas
- [ ] Nama & struktur file sesuai panduan
- [ ] Dependency baru (jika ada) tercatat di `05`

---

## Dokumen Terkait

| Hubungan | Dokumen |
|----------|---------|
| Arsitektur app (struktur, layer, Data Source Boundary) | [`04_architecture.md`](04_architecture.md) |
| Teknologi (Riverpod, `http`, dll.) | [`05_tech_stack.md`](05_tech_stack.md) |
| Alur Git & konvensi commit | [`07_git_workflow.md`](07_git_workflow.md) |
| Cara kerja & prinsip kolaborasi | [`08_ai_guidelines.md`](08_ai_guidelines.md) |

_Turunan dari: [`04_architecture.md`](04_architecture.md) · [`05_tech_stack.md`](05_tech_stack.md)_
