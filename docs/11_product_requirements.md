# 11 · Product Requirements Document — Hearts2spaceU

> **Status:** 🟠 Draft — menunggu persetujuan Product Owner  
> **Versi:** 1.0  
> **Dibuat:** 2026-09-12  
> **Penanggung jawab:** Mohammad Rifqi Hidayat — Product Owner

Dokumen ini adalah PRD tingkat produk untuk Hearts2spaceU. Ia menetapkan masalah,
target pengguna, outcome, scope, requirement lintas capability, metrik, risiko,
dan release gates. Dokumen ini tidak menggantikan spesifikasi capability,
keputusan arsitektur, atau design system.

---

## 1. Executive Summary

Hearts2spaceU adalah aplikasi mobile fan-made untuk penggemar Hearts2Hearts.
Aplikasi ini berfungsi sebagai **trusted companion**: memusatkan informasi,
jadwal, pembaruan, musik, galeri, statistik, voting, dan koleksi pribadi tanpa
menggantikan platform resmi.

Baseline saat ini sudah memiliki shell lima tab berbasis Design System V2,
Official Information, Schedule/Agenda, Latest Updates, Music/Discography,
Official Streaming Hub, Awards, Gallery, Voting, Statistics, Personal Collection,
dan state loading/empty/error/retry. Fase berikutnya memprioritaskan kualitas,
ketepatan data, accessibility, reliability, dan pembelajaran dari pengguna nyata.

### Product thesis

> Jika penggemar dapat menemukan informasi tepercaya, aktivitas terdekat, dan
> pintu menuju platform resmi dalam satu pengalaman yang cepat, jelas, dan
> menyenangkan, maka Hearts2spaceU dapat menjadi pendamping fandom yang dipakai
> berulang — bukan sekadar katalog informasi.

---

## 2. Problem Statement

Penggemar Hearts2Hearts harus berpindah antara banyak sumber untuk mencari profil
member, jadwal, rilis musik, konten terbaru, voting, galeri, dan platform resmi.
Sumber-sumber tersebut berbeda dalam format, tingkat kepercayaan, zona waktu, dan
frekuensi pembaruan, sehingga sulit dipantau secara konsisten.

Masalah ini paling terasa bagi penggemar aktif. Bila tidak diselesaikan, pengguna
akan tetap kehilangan aktivitas penting, salah memahami waktu event atau asal data,
dan tidak memiliki alasan kuat untuk kembali ke aplikasi.

### Evidence yang tersedia

- `h2hcalendar.com` menyediakan kalender fan-maintained dengan lebih dari 1.400
  event dan zona waktu per event.
- `heartsflix.carrd.co` mengindeks konten dan diskografi fandom dalam pengalaman
  yang terpisah-pisah.
- Repository telah berkembang menjadi banyak capability; kebutuhan produk sekarang
  bergeser dari sekadar menambah fitur ke menyatukan pengalaman dan kualitas.
- Belum ada telemetry produksi. Target numerik pada PRD ini adalah hipotesis awal.

---

## 3. Vision, Mission, Positioning

### Vision

Menjadi pendamping tepercaya bagi penggemar Hearts2Hearts di seluruh dunia,
dengan pengalaman fandom yang terorganisir, official-source-first, mudah diakses,
dan menyenangkan.

### Mission

1. Memusatkan informasi dan pembaruan yang relevan.
2. Membantu penggemar mengikuti aktivitas dan mengelola koleksi.
3. Mengarahkan pengguna ke platform resmi secara bertanggung jawab.
4. Berkembang bertahap berdasarkan kebutuhan, feedback, dan bukti penggunaan.

### Positioning

Hearts2spaceU adalah **companion layer**, bukan layanan streaming, pengganti
aplikasi resmi, media sosial, forum umum, marketplace, atau sumber distribusi ulang
konten berhak cipta.

### Product principles

| Prinsip | Implikasi |
|---|---|
| Official-source-first | Sumber resmi diprioritaskan; sumber fan-maintained diberi atribusi. |
| Fan-centric | Fitur dinilai dari manfaat aktivitas fan, bukan jumlah layar. |
| Privacy-first | Data pribadi minimum; fitur inti sebisa mungkin tanpa akun. |
| Incremental growth | Setiap fase menghasilkan nilai yang dapat diuji. |
| Honest states | Loading, empty, stale, partial failure, dan unavailable dijelaskan. |
| Accessible by default | Kontras, scaling, semantics, touch target, dan reduced motion dijaga. |

---

## 4. Target Users and Personas

### P-01 — Active Global Fan (primary)

Penggemar yang memeriksa aktivitas grup beberapa kali per minggu.

**Needs:** update terbaru, jadwal yang dapat dipercaya, waktu lokal + waktu sumber,
link resmi, dan penyimpanan item penting.

**Pain points:** sumber tersebar, perbedaan KST/JST, terlalu banyak link, dan
informasi penting tenggelam di media sosial.

### P-02 — Casual/New Fan (secondary)

Penggemar baru atau penggemar lama yang datang sesekali.

**Needs:** memahami grup dengan cepat dan menemukan member, musik, serta konten
penting tanpa mempelajari struktur aplikasi lebih dulu.

### P-03 — Collector/Organizer (secondary)

Penggemar yang ingin menyimpan event, foto, album, atau item favorit secara lokal.

**Needs:** save/unsave sederhana, tetap tersedia offline, dan privasi yang jelas.

### P-04 — Product Owner/Maintainer (internal)

Membutuhkan sumber data yang terlacak, perubahan yang dapat direview, quality gates,
dan scope yang terkendali.

---

## 5. Goals and Outcomes

| ID | Goal | Target awal dan cara ukur |
|---|---|---|
| G-01 | Mempercepat discovery | ≥80% peserta usability menemukan jadwal/update penting ≤30 detik. |
| G-02 | Meningkatkan trust | 100% remote/fan-maintained surfaces menampilkan source dan freshness/status. |
| G-03 | Meningkatkan task completion | ≥95% happy-path tests selesai; setiap error menyediakan recovery action. |
| G-04 | Meningkatkan accessibility | Tidak ada critical defect; critical flows tetap usable pada text scale 200%. |
| G-05 | Meningkatkan repeat value | Baseline analytics tersedia, lalu target D7/D30 ditetapkan setelah baseline. |
| G-06 | Menjaga quality | Format, analyze, test, CI, platform permission, dan release checklist pass. |

Jumlah layar, package, baris kode, atau event bukan metric keberhasilan produk.

---

## 6. Non-Goals and Strategic Boundaries

| Non-goal | Alasan |
|---|---|
| Streaming player | Konten tetap dikonsumsi melalui platform resmi; mengurangi copyright risk. |
| Media sosial/chat/forum | Membutuhkan moderation, identity, abuse handling, dan privacy model baru. |
| Marketplace/ticketing | Membutuhkan payment, inventory, fraud, legal, dan partner operation. |
| Akun wajib | Tidak sesuai privacy-first untuk informasi publik. |
| Impor semua konten internet | Menurunkan trust dan meningkatkan misinformation/copyright risk. |
| Push notification penuh pada fase ini | Membutuhkan permission, backend, preference, dan operational reliability. |
| Terjemahan otomatis tanpa review | Risiko salah konteks untuk nama, jadwal, dan pengumuman. |
| Menghapus data manual lama tanpa keputusan PO | Data tersebut bisa menjadi fallback atau audit trail. |

---

## 7. Scope and Phasing

### Phase 0 — Current baseline

| Capability | Outcome |
|---|---|
| Home | Orientasi, Up Next, dan entry point capability. |
| Official Information | Profil member dan informasi grup. |
| Schedule/Agenda | Aktivitas mendatang, agenda gabungan, detail event. |
| Latest Updates | Update network-backed dengan loading/error/retry. |
| Music/Discography | Rilis, tracklist, durasi, title track, platform links. |
| Streaming Hub | Deep link ke platform resmi, bukan player. |
| Awards/Statistics | Pencapaian dan ringkasan statistik. |
| Gallery | Album, viewer, remote-image fallback. |
| Voting | Vote cards, official links, partial failure states. |
| Collection | Local favorites melalui `shared_preferences`. |
| Design System V2 | Five-tab shell, liquid-glass surfaces, ambient wash, motion. |

### Phase 1 — Quality and Trust Foundation (prioritas berikutnya)

- perbaikan accessibility light/dark mode, contrast, text scaling, dan semantics;
- source attribution dan freshness indicator;
- offline/cache behavior yang jujur dan konsisten;
- privacy-preserving analytics dan error observability;
- visual refinement menuju **minimalist, Spotify-inspired liquid glass** tanpa
  menyalin aset atau identitas Spotify.

### Phase 2 — Deepen Fandom Utility

- search dan filter setelah ada bukti volume data membutuhkannya;
- saved schedule/reminder setelah notification architecture disetujui;
- export/import collection lokal;
- curated content hub dengan source dan copyright governance yang jelas.

### Phase 3 — Future Expansion

- multilingual content dengan review workflow;
- backend/admin content workflow;
- personalization berbasis consent;
- partner integrations;
- community atau commerce hanya melalui PRD terpisah.

---

## 8. User Stories

### Discovery

- As a new fan, I want to understand the group from Home so that I can explore
  without knowing the app structure.
- As an active fan, I want to see the next relevant activity so that I do not
  search several services.
- As a fan, I want each remote or fan-maintained surface to show source and
  freshness so that I can judge its reliability.

### Schedule and Agenda

- As a fan, I want local time and published source timezone together so that I can
  act on an event and cross-check it.
- As a fan, I want all-day events to say that no time is known so that the app
  never invents midnight.
- As a fan, I want refresh failure to preserve cached events so that the list does
  not disappear because the network blinks.

### Music and official links

- As a fan, I want releases newest-first so that I find the latest music quickly.
- As a fan, I want track title, duration, and title-track state so that I do not
  have to infer release structure.
- As a fan, I want one clear action to listen on official platforms so that the app
  does not pretend to host the content.

### Collection

- As a collector, I want to save/unsave an item from list or detail so that I can
  return to it later.
- As a privacy-conscious fan, I want collection data to remain local unless I
  explicitly opt into synchronization.

### Accessibility and resilience

- As a low-vision user, I want critical flows to remain usable at 200% text scale.
- As a screen-reader user, I want images, tabs, buttons, links, and cards labeled.
- As a motion-sensitive user, I want reduced-motion settings respected.
- As a user on unstable network, I want loading, empty, stale, partial-failure,
  and retry states explained clearly.

---

## 9. Functional Requirements

### P0 — Must-have

#### P0.1 Home orientation

- Home MUST communicate identity, current/upcoming context, and active entry points.
- Empty and error states MUST remain visible and actionable; sections MUST NOT be
  silently hidden merely because data is unavailable.
- Coming Soon items MUST be visibly disabled and MUST NOT pretend to work.

#### P0.2 Information trust

- Every remote or fan-maintained surface MUST show source attribution and freshness
  or availability status.
- Invalid remote rows MUST NOT be presented as valid data.
- Source failure MUST expose retry and/or cached fallback behavior.

#### P0.3 Schedule and Agenda

- Event data MUST preserve source timezone, all-day status, stable id, and source link.
- Different zones MUST show local time and published time; unknown/DST zones MUST
  retain the source label without unsafe conversion.
- Refresh failure MUST preserve the last usable cache.
- One malformed row MUST NOT take down the whole schedule.
- Agenda and Schedule MUST use identical time semantics.

#### P0.4 Music and official links

- Releases MUST sort by release date when known, otherwise by year.
- Missing tracklists MUST say that the list is not recorded; they MUST NOT imply
  zero songs.
- Duration MUST be shown only when sourced and valid.
- Official actions MUST open safe `https` links or report failure clearly.

#### P0.5 Personal collection

- Save/remove MUST work from supported list and detail surfaces.
- Controls MUST have a meaningful accessible label, visible state, and ≥44×44
  logical-pixel target.
- Collection MUST survive restart and corrupt storage MUST fail safely.

#### P0.6 Accessibility baseline

- Meaningful text/icon contrast MUST meet WCAG AA on actual light/dark glass surfaces.
- Critical flows MUST remain usable at 200% text scale on 360dp width.
- Images MUST have useful labels or be excluded from semantics when decorative.
- Tabs, icon actions, links, cards, and state views MUST have screen-reader labels.
- Reduced motion MUST remove non-essential animation.

#### P0.7 Release quality

- `dart format --set-exit-if-changed`, `flutter analyze`, relevant tests, CI, and
  release build checks MUST pass.
- Android network permissions and macOS entitlements MUST be verified for network
  features.
- User-visible data/source changes MUST be documented.

### P1 — Should-have

- Search/filter when evidence shows discovery friction.
- Saved schedule and optional reminders with explicit permission and timezone policy.
- Local collection export/import using a versioned format.
- Curator/admin workflow with review, rollback, and audit history.
- Privacy-reviewed analytics dashboard for Home → detail → official link funnels.

### P2 — Future considerations

- Multilingual UI/content.
- Account sync and cross-device preferences.
- Community features with moderation/reporting/blocking.
- Commerce or ticketing with partner, payment, fraud, legal, and support requirements.

---

## 10. Non-Functional Requirements

### Performance

- Target cold start to first meaningful Home content: ≤3 seconds on a mid-range
  device under normal conditions; recalibrate after measurement baseline.
- Cached Schedule MUST render before any network refresh.
- Remote requests MUST timeout and MUST NOT leave indefinite spinners.
- Images MUST lazy-load and provide placeholder/error states.

### Reliability

- Invalid single records MUST degrade locally; invalid payload envelope MUST fail
  clearly.
- Cached data MUST be distinguishable from live data.
- Refresh MUST be idempotent and MUST NOT duplicate entries.
- Release builds MUST be smoke-tested on supported platforms.

### Security and privacy

- Public browsing and local collection MUST NOT require an account.
- Logs MUST exclude personal data and private tokens by default.
- Only safe `https` links MAY be opened by user actions.
- Secrets MUST NOT be committed or shipped in artifacts.
- Retention/deletion rules MUST exist before analytics or sync.

### Accessibility

- Target WCAG 2.1 AA for text and meaningful UI contrast.
- Support system text scaling up to 200% for critical flows.
- Support screen readers, 44×44 touch targets, reduced motion, and non-color-only state.

### Localization and time

- Initial UI language: English; project collaboration/documentation: Indonesian.
- Events MUST preserve source timezone and distinguish source wall-clock from local time.
- Formatting MUST NOT invent missing precision.
- Minimum supported OS versions remain `[DECISION REQUIRED]` until fixed in `05_tech_stack.md`.

---

## 11. Data and Content Governance

### Source classification

| Class | Treatment |
|---|---|
| Official | Highest trust; retain source link and attribution. |
| Fan-maintained | Allowed when useful; visibly attributed and freshness-aware. |
| Internal curated | Reviewable via Git with owner and curation rationale. |
| User-local | Private by default; never treated as public source data. |

### Data quality rules

- Every record has a stable identifier.
- Dates/times preserve the source precision.
- Invalid optional fields degrade locally; invalid required envelope fails clearly.
- Data changes require a source note or curation rationale.
- Conflicting sources require a documented decision, not silent overwrite.
- Copyrighted media is linked responsibly; the app is not a redistribution host.

### Ownership

| Area | Accountable |
|---|---|
| Product scope/priorities | Product Owner |
| Source approval/curation | Product Owner, legal consultation when needed |
| UX/accessibility | Product Owner + Design/Engineering |
| Architecture/implementation | Engineering |
| Release readiness | Engineering + Product Owner |
| Privacy/copyright policy | Product Owner; legal review `[DECISION REQUIRED]` |

---

## 12. Analytics and Measurement Plan

Analytics MUST be privacy-preserving and policy-approved. No event justifies
collecting personal identity data that is not needed.

### Recommended events

| Event | Purpose | Properties |
|---|---|---|
| `home_viewed` | Entry/activation | app version, platform, locale |
| `capability_opened` | Discovery path | capability, entry point |
| `detail_opened` | Task depth | capability, item type |
| `official_link_opened` | Companion value | destination class, capability |
| `item_saved` / `item_unsaved` | Collection utility | item type, stable non-personal id |
| `schedule_refresh` | Freshness behavior | result, cached/live |
| `content_load_failed` | Reliability | capability, error class, retry result |

### Definitions

- **Activation:** user reaches a detail page or official link after opening Home.
- **Task completion:** intended action completes without an error/retry loop.
- **Freshness success:** live data or understandable cached state appears promptly.
- **Repeat usage:** app opens on at least two distinct days in seven days.

Review cadence: pre-release manual checks; first-week reliability review; first-month
activation/repeat-use review; quarterly roadmap review.

---

## 13. Release Gates

### Product

- [ ] Product Owner approves scope and blocking decisions.
- [ ] Core journeys pass on supported platforms.
- [ ] Source attribution/freshness is visible.
- [ ] Empty, loading, error, stale, partial-failure, and offline states are covered.
- [ ] Copyright/disclaimer placement is reviewed.

### Engineering

- [ ] Format, analyze, tests, and CI pass.
- [ ] Release builds install and start on supported platforms.
- [ ] Network permissions/entitlements are verified.
- [ ] No secrets or unintended personal data are shipped.
- [ ] Rollback/hotfix path is documented.

### Accessibility

- [ ] Contrast is measured on actual light/dark glass and ambient backgrounds.
- [ ] Critical flows pass 200% text scale at 360dp.
- [ ] Screen-reader labels verified for navigation, images, links, cards, actions.
- [ ] Reduced motion verified.
- [ ] Color is not the sole state signal.

---

## 14. Risks and Mitigations

| Risk | Impact | Mitigation | Owner |
|---|---|---|---|
| Fan source changes schema/offline | High | Cache, tolerant row parser, attribution, failure monitoring. | Engineering |
| Stale/contradictory data | High | Freshness, source classes, review notes, conflict policy. | Product Owner |
| Liquid glass reduces readability | High | Real-surface contrast tests, dark variants, opaque fallback. | Design/Engineering |
| Remote links/images break | Medium | Safe URL validation, placeholders, error states. | Engineering |
| Scope expands into social/commerce | High | Explicit non-goals and separate PRD. | Product Owner |
| Analytics harms privacy | High | Minimization, consent/policy review, retention limits. | Product Owner |
| Copyright/brand misuse | High | Disclaimer, link-out model, no unauthorized redistribution. | Product Owner |
| Release differs from tests | High | Device smoke tests, manifest/entitlement checks. | Engineering |
| Redesign regresses accessibility | High | Accessibility review in every design-system change. | Design/Engineering |

---

## 15. Dependencies and Delivery Plan

### Dependencies

- Flutter, Riverpod, `http`, `shared_preferences`, Design System V2.
- Official and fan-maintained remote sources.
- Platform network permissions and entitlements.
- GitHub Flow, CI, and capability specifications.
- Future: analytics, crash monitoring, notifications, backend/admin workflow, legal review.

### Phases

| Phase | Objective | Exit criteria |
|---|---|---|
| 0 — Alignment | Approve PRD, scope, owners, metrics | PO approves P0 and decisions. |
| 1 — Trust/accessibility | Fix contrast, scaling, semantics, attribution, stale/offline states | Accessibility and release gates pass. |
| 2 — Measurement | Add privacy-reviewed analytics and error taxonomy | One release cycle has baseline metrics. |
| 3 — Utility | Select search/filter/reminder based on evidence | Selected feature meets its own metric. |
| 4 — Platform | Add admin/backend only if operationally justified | Ownership, rollback, privacy controls exist. |
| 5 — Expansion | Localization, sync, partners, or community via separate PRDs | Initiative passes roadmap and risk review. |

Prioritization: safety/privacy/copyright/accessibility → reliability → data trust →
discovery/repeat use → new capabilities. Any scope addition must remove equivalent
scope or explicitly extend the timeline with PO approval.

---

## 16. Open Decisions

| ID | Question | Blocking | Owner | Recommendation |
|---|---|:---:|---|---|
| D-01 | Redesign liquid-glass menjadi epic atau polish bertahap? | Yes | Product Owner | Epic kecil: accessibility foundation lalu visual refinement. |
| D-02 | Minimum OS versions? | Yes | Engineering + PO | Kunci di `05_tech_stack.md`. |
| D-03 | Analytics provider dan privacy policy? | Yes | Product Owner | Event minimal, provider configurable. |
| D-04 | `events.json` lama menjadi fallback atau dihapus? | No | Product Owner | Pertahankan sampai strategi diputuskan. |
| D-05 | Fan-maintained source boleh jadi default jangka panjang? | No/architecture | Product Owner | Tetapkan source policy, freshness SLA, fallback. |
| D-06 | Kapan push notification dibangun? | No | Product Owner | Setelah demand dan permission strategy terbukti. |
| D-07 | Dukungan Bahasa Indonesia? | No | Product Owner | Setelah UI stabil dan ownership translation jelas. |
| D-08 | Kapan legal review formal dilakukan? | Yes before scale | Product Owner | Review disclaimer, copyright, takedown, attribution. |
| D-09 | Collection perlu sync lintas perangkat? | No | Product Owner | Tetap lokal sampai ada demand terukur. |
| D-10 | Definisi user aktif dan channel distribusi pertama? | Yes for metrics | Product Owner | Putuskan sebelum KPI dikunci. |

---

## 17. Traceability Matrix

| Objective | Capability | Requirement | Source |
|---|---|---|---|
| Trusted information | Official Information, Updates, Awards, Discography | P0.2, P0.4 | [`02_product_vision.md`](02_product_vision.md), capability specs |
| Organized fandom | Schedule, Agenda, Collection, Voting | P0.3, P0.5 | [`03_roadmap.md`](03_roadmap.md), capability specs |
| Consistent experience | Home, Gallery, Design System | P0.1, P0.6 | home spec, [`09_design_system.md`](09_design_system.md) |
| Official ecosystem | Streaming Hub, official links | P0.2, P0.4 | streaming/voting specs |
| Sustainable product | CI, tests, governance, privacy | P0.7, NFR | [`04_architecture.md`](04_architecture.md), [`06_coding_guidelines.md`](06_coding_guidelines.md) |

---

## 18. Approval Record

| Role | Name | Status | Date |
|---|---|---|---|
| Product Owner | Mohammad Rifqi Hidayat | ⏳ Pending | — |
| Engineering/Architecture | `[TODO]` | ⏳ Pending | — |
| Design/Accessibility | `[TODO]` | ⏳ Pending | — |
| Legal/Copyright | `[DECISION REQUIRED]` | ⏳ Pending | — |

Persetujuan PRD menetapkan arah dan P0 baseline; P1/P2 tetap membutuhkan scope
dan review implementasi masing-masing.

---

## 19. Related Documents

- [`01_project_overview.md`](01_project_overview.md)
- [`02_product_vision.md`](02_product_vision.md)
- [`03_roadmap.md`](03_roadmap.md)
- [`04_architecture.md`](04_architecture.md)
- [`05_tech_stack.md`](05_tech_stack.md)
- [`06_coding_guidelines.md`](06_coding_guidelines.md)
- [`07_git_workflow.md`](07_git_workflow.md)
- [`09_design_system.md`](09_design_system.md)
- [`10_backlog.md`](10_backlog.md)
- [`specs/agenda.md`](specs/agenda.md), [`specs/discography.md`](specs/discography.md), [`specs/schedule.md`](specs/schedule.md)

_Dokumen ini menurunkan arah dari dokumen fondasi dan menunggu persetujuan Product Owner._
