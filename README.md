# Hearts2spaceU

**Hearts2spaceU** is an all-in-one Flutter application designed for Hearts2Hearts fans to access official information, schedules, music releases, event schedules, and personal collections in a single experience.

---

## 🚧 Project Status

**Current Status:** 🟢 MVP complete

### Current Phase
Release 1.4.0 – Quality and Trust Foundation (PRD Phase 1)

### Next Milestone
Release gates on real devices · Measurement (PRD Phase 2, awaiting decision D-03)

Sprints 1–4 deliver every MVP capability — **Official Information (Member Profiles)**,
**Schedule (Upcoming Events)**, **Latest Updates**, and the **Official Streaming Hub** —
built on the documented Evolutionary Clean Architecture. Release 0.3.0 added
**Design System V1**: brand tokens, reusable components, and motion shared by every screen.
Release 1.0.0 rebuilds the app on **Design System V2** — a five-tab shell, glass surfaces over
a single ambient wash, and an accessibility pass that brought every badge, label, and avatar
colour up to AA.

Sprints 5–6 added all-day events with the real 2026 schedule, and **Awards** — 52
achievements grouped by year.

Release 1.4.0 moves the **Schedule** onto a live community calendar, cached on the device
and shown on both the reader's clock and the one it was published on; gives every release
in **Music** its track list; and makes the whole app readable in **both light and dark mode**.
Every screen is now rendered and measured by three test sweeps — contrast on the surfaces
it actually draws, 200% text at 360dp without losing a word, and screen-reader labels with
48×48 touch targets — before a change can merge.

Two capabilities proved the architecture holds as needs change: Latest Updates is served
over the network behind the same repository contract the bundled features use, and the
Streaming Hub links out to official platforms without the app ever hosting content itself.

---

## ✨ Project Goals

- Provide a centralized platform for Hearts2Hearts fans.
- Deliver official and structured information.
- Build a scalable Flutter application using Evolutionary Clean Architecture.
- Serve as a long-term software engineering portfolio.

---

## 📁 Repository Structure

```text
Hearts2spaceU/
├── app/
│   └── hearts2spaceu/         # Flutter application
├── assets/                    # Branding, design assets, screenshots
├── docs/                      # Project documentation
├── README.md
└── .gitignore
```

Additional components (such as `backend/`, `infra/`, or `packages/`) will only be introduced when justified by future architectural decisions.

---

## 📚 Documentation

The complete project documentation is located inside the `docs/` directory.

| Document | Description |
|----------|-------------|
| 01 | Project Overview |
| 02 | Product Vision |
| 03 | Roadmap |
| 04 | Architecture |
| 05 | Technology Stack |
| 06 | Coding Guidelines |
| 07 | Git Workflow |
| 08 | AI Guidelines |
| 09 | Design System |
| 10 | Backlog |
| 11 | Product Requirements Document — product-level requirements, metrics, scope, and release gates |

> Documents **01–10** serve as the project's governance and architectural foundation.

---

## 🛠 Technology Stack

| Category | Technology |
|----------|------------|
| Framework | Flutter |
| Language | Dart |
| Architecture | Evolutionary Clean Architecture |
| State Management | Riverpod |
| HTTP Client | http |
| Routing | Named Routes |
| Linting | flutter_lints |
| Version Control | Git + GitHub |

For complete technical decisions, see **docs/05_tech_stack.md**.

---

## 🚀 Getting Started

Clone the repository:

```bash
git clone https://github.com/Zvareldric/Hearts2spaceU.git
```

Go to the Flutter application:

```bash
cd Hearts2spaceU/app/hearts2spaceu
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

---

## 🗺 Roadmap

Current development focus:

- ✅ Project Foundation
- ✅ Official Information — Member Profiles (MVP slice)
- ✅ Schedule — Upcoming Events (MVP slice)
- ✅ Latest Updates (MVP slice)
- ✅ Official Streaming Hub
- ✅ Awards
- ✅ Gallery
- ✅ Personal Collection
- ✅ Voting Hub
- ✅ Statistics
- ✅ Discography
- ✅ Design System V2
- ✅ Agenda — events and votes on one timeline
- ✅ Accessibility — WCAG 2.1 AA in light and dark mode, 200% text, screen readers
- ⏳ Release gates on real devices
- ⏳ Measurement · Reminders (see PRD §15–16)

For the complete roadmap, see **docs/03_roadmap.md**.

---

## 🤝 Contributing

This project is currently maintained by the project owner.

A `CONTRIBUTING.md` guide will be added before external contributions are accepted.

---

## 📄 License

This project is licensed under the **Apache License 2.0**.
