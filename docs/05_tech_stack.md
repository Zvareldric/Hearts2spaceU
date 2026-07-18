# 05 · Tech Stack

> **Status:** 🟢 Terisi (MVP) · **Dibuat:** 2026-07-17 · **Diperbarui:** 2026-07-18
> **Penanggung jawab:** Mohammad Rifqi Hidayat (Project Owner)

Dokumen ini mencatat **teknologi yang dipakai** beserta **alasannya yang tertelusur**. Aturan utamanya: setiap teknologi harus dapat ditelusuri kembali ke **Product Vision**, **Roadmap**, atau **keputusan arsitektur** — bukan dipilih karena tren atau "best practice".

> Karena **ADR-002** ([`04_architecture.md`](04_architecture.md)) menunda arsitektur sistem (backend, database, cloud, dll.), dokumen ini fokus pada teknologi yang **relevan untuk MVP** dan menandai sisanya *deferred*.

---

## 1. Tech Selection Criteria

Setiap kandidat teknologi dinilai terhadap kriteria berikut:

1. **Traceability-first** — dapat ditelusuri ke Vision / Roadmap / keputusan arsitektur.
2. **Learning First** — mendukung pemahaman; kurva belajar wajar untuk tahap sekarang.
3. **Solve a Real Problem** *(ADR-001)* — dipilih hanya saat ada kebutuhan nyata MVP; tidak menambah dependency prematur.
4. **Fit with Architecture** — selaras Evolutionary Clean Architecture (mendukung *Testability* & *Data Source Boundary*).
5. **Maintainability & Maturity** — matang, dokumentasi & komunitas memadai, aktif dipelihara.
6. **Evolvability** — tidak mengunci; dapat diganti saat kebutuhan berubah.

## 2. Sudah Diputuskan

| Kategori | Pilihan | Traceability |
|----------|---------|--------------|
| **Frontend Framework** | **Flutter** | Ditetapkan Product Owner ([`01`](01_project_overview.md)) |
| **Bahasa** | **Dart** | Konsekuensi langsung Flutter |

## 3. Teknologi MVP

Teknologi yang dibutuhkan untuk membangun MVP, masing-masing tertelusur ke konstitusi proyek.

### State Management — **Riverpod**

Alasan:
- Selaras dengan **ADR-001 (Evolutionary Clean Architecture)** — dapat tumbuh dari sederhana ke kompleks tanpa berganti arsitektur.
- Sangat cocok untuk karakter MVP yang **read-mostly** dan banyak menggunakan data **asinkron**.
- **`AsyncValue`** menyederhanakan pengelolaan state *loading*, *success*, dan *error* tanpa boilerplate berlebih.
- **Sekaligus menyediakan dependency injection** yang cukup untuk MVP, sehingga tidak perlu menambah package DI terpisah (*Avoid Over-Engineering*) dan mendukung **Data Source Boundary** ([`04`](04_architecture.md)).
- Mudah diuji (**Testability**) dan berkembang tanpa mengganti arsitektur ketika aplikasi bertambah kompleks.

> 📌 Riverpod dipilih **bukan karena popularitasnya**, tetapi karena memberikan **keseimbangan terbaik** antara kesederhanaan implementasi MVP dan kemampuan berkembang mengikuti *Evolutionary Clean Architecture*.

**Decision Review**
- **Status:** Accepted
- **Review Trigger** — evaluasi ulang bila: (a) Riverpod tidak lagi memenuhi kebutuhan aplikasi; (b) arsitektur berubah; (c) muncul *constraint* baru.

### Dependency Injection — **Ditangani oleh Riverpod**

Karena memilih Riverpod, **tidak menggunakan package DI terpisah** pada MVP. Apabila di masa depan muncul kebutuhan yang tidak lagi dapat ditangani secara alami oleh Riverpod, keputusan ini dapat **dievaluasi kembali**.

### Networking — **`http`**

Package `http` cukup untuk kebutuhan MVP (mengambil data di balik *Data Source Boundary*).

> 📌 Migrasi ke **`dio`** dilakukan ketika benar-benar muncul kebutuhan seperti *interceptor*, *retry*, *upload/download progress*, atau konfigurasi networking yang lebih kompleks. Perpindahan ini **tidak boleh mengubah kode di Presentation Layer** karena dilindungi oleh **Data Source Boundary** ([`04`](04_architecture.md)).

### Navigation — **Named Routes bawaan Flutter**

Untuk MVP dengan jumlah layar terbatas, *named routes* bawaan sudah memadai.

> 📌 Evaluasi terhadap **`go_router`** dilakukan ketika mulai muncul kebutuhan seperti: *nested navigation*, *deep linking* yang lebih kompleks, *route guarding*, atau struktur navigasi yang semakin besar.

### Deep-link Launcher — **`url_launcher`**

Membuka platform streaming resmi dari dalam aplikasi. Langsung mendukung kapabilitas **Official Streaming Hub** ([`03`](03_roadmap.md)) dan memenuhi prinsip *Solve a Real Problem*.

## 4. Deferred Technologies

Ditunda mengikuti **ADR-002 (Deferred System Architecture)** dan roadmap. Ditunda bukan diabaikan — diputuskan saat stage yang membutuhkannya tiba.

| Kategori | Status | Alasan / Traceability |
|----------|--------|------------------------|
| Backend Framework | ⏸️ Deferred | ADR-002; MVP tanpa backend |
| Database | ⏸️ Deferred | ADR-002 |
| Cloud Provider | ⏸️ Deferred | ADR-002 |
| Deployment Strategy | ⏸️ Deferred | ADR-002 |
| Authentication | ⏸️ Deferred | ADR-002; MVP mengakses info publik/resmi |
| Monitoring | ⏸️ Deferred | ADR-002 |
| Logging (terstruktur) | ⏸️ Deferred | ADR-002 |
| Local Database | ⏸️ Deferred | Diperkenalkan saat dibutuhkan oleh salah satu dari: *Personal Collection*, *Offline capability*, atau *Caching* (tiga kebutuhan berbeda) |
| CI/CD | ⏸️ Deferred | Diperkenalkan saat repository & pengujian matang |

## 5. Dependency Policy

> Sesuai *Avoid Over-Engineering* & *Traceability*: setiap dependency baru **wajib** dicatat.

| Package / Tool | Untuk apa | Traceability | Version Policy | Alternatif dipertimbangkan | Tanggal |
|----------------|-----------|--------------|----------------|----------------------------|---------|
| `flutter_riverpod` | State management + DI | ADR-001, Data Source Boundary, Testability | Follow latest stable major version | Provider, Bloc/Cubit | 2026-07-18 |
| `http` | Networking (ambil data) | Kapabilitas Official Information/Latest Updates | Follow latest stable major version | `dio` | 2026-07-18 |
| `url_launcher` | Buka platform resmi | Kapabilitas Official Streaming Hub | Follow latest stable major version | — | 2026-07-18 |

---

## Dokumen Terkait

| Hubungan | Dokumen |
|----------|---------|
| **Why & What** — sumber kebutuhan | [`02_product_vision.md`](02_product_vision.md) |
| **When** — kapabilitas yang memandu kebutuhan teknologi | [`03_roadmap.md`](03_roadmap.md) |
| **How** — keputusan arsitektur (ADR-001/002) yang menautkan pilihan teknologi | [`04_architecture.md`](04_architecture.md) |
| **Backlog** — detail item & Definition of Ready/Done | [`10_backlog.md`](10_backlog.md) |

_Turunan dari: [`03_roadmap.md`](03_roadmap.md) · [`04_architecture.md`](04_architecture.md)_
