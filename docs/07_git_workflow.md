# 07 · Git Workflow

> **Status:** 🟢 Terisi · **Dibuat:** 2026-07-17 · **Diperbarui:** 2026-08-20
> **Penanggung jawab:** Mohammad Rifqi Hidayat (Project Owner)

Dokumen ini mengatur cara mengelola versi kode. **Git** adalah langkah terakhir pada alur kerja proyek ([`08`](08_ai_guidelines.md)), tetapi aturannya disepakati lebih awal agar konsisten.

---

## 1. Version Control

| Item | Keputusan | Traceability |
|------|-----------|--------------|
| Tool | **Git** | Standar industri; mendukung workflow proyek |
| Hosting | **GitHub (repository publik)** | Ditetapkan di [`01`](01_project_overview.md) — belajar & portofolio "in the open" |

## 2. Branching Strategy — **GitHub Flow**

> **Prinsip inti: _Branches are temporary; `main` is the single source of truth._**

- Setiap pekerjaan dilakukan pada **feature branch berumur pendek**.
- Setelah selesai dan di-*merge*, **branch dihapus**.
- **`main` harus selalu dalam kondisi *buildable*** dan menjadi representasi terbaru proyek.

**Alasan (traceability):**
- **Learning First** — cukup sederhana untuk dipelajari & diterapkan konsisten.
- **Avoid Over-Engineering** — tanpa `develop`/`release`/`hotfix` branch yang belum diperlukan.
- **Review** ([`08`](08_ai_guidelines.md)) — setiap perubahan melewati *self-review* sebelum *merge*.
- **Repo publik** ([`01`](01_project_overview.md)) — mudah dipahami bila proyek menjadi kolaboratif.

> 🔄 Sesuai *Evolutionary Architecture*: bila kompleksitas tim atau proses rilis meningkat, strategi ini dapat dievaluasi kembali. Tidak menambah `develop` branch atau Git Flow sebelum ada kebutuhan nyata.

**Penamaan branch** — **wajib** salah satu prefix berikut, diikuti nama pekerjaan dalam
`kebab-case`: `feature/latest-updates` · `fix/navigation` · `docs/architecture` ·
`refactor/home-module`.

> ⚠️ **Nama branch menyebut pekerjaannya, bukan alat yang dipakai** *(amandemen 2026-08-20)*.
> Prefix di atas memberi tahu pembaca **jenis perubahannya** sebelum ia membuka satu berkas
> pun. Nama IDE, editor, atau asisten yang kebetulan dipakai tidak menjelaskan apa-apa
> tentang isi branch — jadi tidak dipakai sebagai prefix maupun disisipkan di dalam nama.
> Alat bisa berganti; yang dicatat riwayat adalah pekerjaannya.

## 3. Merge Workflow

```mermaid
flowchart LR
    M1["main"] -->|1 · branch dari main| F["feature branch<br/>(pendek & terfokus)"]
    F -->|2 · satu perubahan| F
    F -->|"3 · checklist &nbsp;·&nbsp; 4 · self-review"| PR{"PR<br/>(quality gate)"}
    PR -->|5 · merge| M2["main (buildable)"]
    PR -->|6 · hapus branch| Del["🗑️ branch dihapus"]
```

1. Buat **feature branch** dari `main`.
2. Kerjakan **satu perubahan yang terfokus**.
3. Jalankan **checklist** (`dart format`, `flutter analyze`, test terkait — lihat [`06`](06_coding_guidelines.md)).
4. Lakukan **self-review** sebelum membuka PR.
5. **Merge** ke `main` melalui PR.
6. **Hapus** feature branch.

> 🔑 Untuk proyek solo, **PR berfungsi sebagai *quality gate***, bukan sekadar media kolaborasi. Tujuannya **memisahkan fase implementasi dan fase review** agar disiplin *engineering* tetap terjaga meskipun hanya ada satu developer.

## 4. Commit Conventions — Conventional Commits

- Format: **`type(scope): subject`**.
- Tipe umum: `feat`, `fix`, `docs`, `refactor`, `chore`, `test`, `style`, `build`.
- **Bahasa commit: Inggris** — konsisten dengan repo publik/global & tujuan portofolio.
- Subject ringkas & imperatif (mis. `feat(home): add latest updates section`).

**Kepemilikan commit** *(amandemen 2026-08-20)*. Proyek ini dikerjakan **solo**: seluruh
commit tercatat atas nama Project Owner, pada **author maupun committer**. Commit **tidak**
memuat trailer atribusi pihak lain — `Co-Authored-By:`, `*-Session:`, dan sejenisnya —
termasuk atribusi alat bantu. Aturan yang sama berlaku untuk **judul & deskripsi PR**.
Sebelum commit pertama di sebuah klon, pastikan `git config user.name` dan `user.email`
menunjuk identitas Project Owner.

> 📌 **Kenapa ini perlu diatur?** GitHub menyusun daftar *Contributors* dari **author commit
> di default branch** — dan juga membaca trailer `Co-Authored-By:`. Satu trailer yang lolos
> sudah cukup untuk menambahkan akun asing ke halaman repo. Membersihkannya menuntut
> penulisan ulang riwayat (`git filter-branch` lalu `push --force`) beserta seluruh risikonya;
> mencegahnya hanya menuntut satu baris `git config`.

## 5. Pull Request Conventions

- Deskripsi PR menjelaskan **apa** & **mengapa**, serta tautan ke item/konteks terkait bila ada.
- PR wajib **lolos checklist `06`** sebelum di-*merge*. Sejak 2026-07-30 checklist ini
  dijalankan otomatis oleh **CI** (`.github/workflows/ci.yml`, lihat [`05`](05_tech_stack.md) §6)
  — bukan lagi bergantung pada ingatan.
- **Small Pull Requests** — usahakan setiap PR tetap **kecil dan berfokus pada satu tujuan** agar review lebih mudah (selaras filosofi *feature branch* pendek).
- **Hindari menggabungkan beberapa fitur yang tidak berkaitan** dalam satu PR.
- Riwayat dijaga tetap bersih (mis. *squash* commit kecil bila perlu).

### Pengecualian: PR besar yang dibenarkan *(amandemen 2026-07-27)*

Dua poin di atas tetap menjadi **ideal yang dituju**, bukan larangan mutlak. Sebuah PR besar
**boleh** dilakukan apabila:

1. pekerjaannya **berurutan di atas satu branch** sehingga tidak praktis dipecah tanpa
   membongkar riwayat, **atau**
2. memecahnya justru **menghasilkan `main` yang tidak utuh** (mis. fitur mendarat tanpa
   fondasi visual yang menopangnya).

Syaratnya: **alasan dicatat pada deskripsi PR**, dan bila PR memuat lebih dari satu tahap
pekerjaan, tiap tahap **ditandai dengan tag** (mis. `v0.2.0`, `v0.3.0`) agar evolusi proyek
tetap terbaca.

> 📌 Latar amandemen: PR **Release 0.3.0 (Design System V1)** memuat 16 commit dari
> 7 *checkpoint* yang saling bergantung — token → komponen → tiap layar → motion.
> Memecahnya akan menempatkan komponen di `main` tanpa layar yang memakainya, atau
> layar yang separuh bergaya lama. Keputusan Product Owner, 2026-07-27.

## 6. `.gitignore`

- Gunakan `.gitignore` standar Flutter.
- Pastikan **artefak build** (`build/`, `.dart_tool/`), **secret**, dan **file environment** **tidak** ikut ter-commit.

## 7. Tagging & Release

- Skema versi: **SemVer** (`vMAJOR.MINOR.PATCH`) — diterapkan **ketika rilis mulai dibutuhkan**.
- Pra-MVP, penandaan rilis belum diperlukan (*Avoid Over-Engineering*).

---

## Checklist Setup Awal (saat Git diaktifkan)

> ℹ️ Repository belum di-inisialisasi Git hingga saat ini.

- [ ] `git init` di root `Hearts2spaceU/`
- [ ] Buat `.gitignore` yang sesuai (Flutter)
- [ ] Commit pertama: fondasi dokumentasi (`docs/`, `.ai/`, `README.md`)
- [ ] Hubungkan ke remote GitHub (publik)

## Dokumen Terkait

| Hubungan | Dokumen |
|----------|---------|
| Alur kerja proyek (tahap Review & Git) | [`08_ai_guidelines.md`](08_ai_guidelines.md) |
| Checklist sebelum commit | [`06_coding_guidelines.md`](06_coding_guidelines.md) |
| Backlog & item pekerjaan | [`10_backlog.md`](10_backlog.md) |

_Turunan dari: [`08_ai_guidelines.md`](08_ai_guidelines.md) · [`06_coding_guidelines.md`](06_coding_guidelines.md)_
