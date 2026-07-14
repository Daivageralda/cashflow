<div align="center">

<br />

<img src="https://capsule-render.vercel.app/api?type=waving&color=D4A853&height=120&section=header&animation=fadeIn" width="100%" />

# 💸 Cashflow

### *Membantu setiap rupiah memiliki tujuan.*

<br />

[![Swift](https://img.shields.io/badge/Swift-5.9-F05138?style=for-the-badge&logo=swift&logoColor=white)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-17+-000000?style=for-the-badge&logo=apple&logoColor=white)](https://developer.apple.com/ios/)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-Native-2A7AE4?style=for-the-badge&logo=swift&logoColor=white)](https://developer.apple.com/xcode/swiftui/)
[![SwiftData](https://img.shields.io/badge/SwiftData-Offline--first-5C4B8A?style=for-the-badge&logo=apple&logoColor=white)](https://developer.apple.com/documentation/swiftdata)
[![Supabase](https://img.shields.io/badge/Supabase-Cloud_Sync-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com)
[![WidgetKit](https://img.shields.io/badge/WidgetKit-Home_Screen-34C759?style=for-the-badge&logo=apple&logoColor=white)](https://developer.apple.com/documentation/widgetkit)

<br />

</div>

A native iOS personal finance app built entirely in **SwiftUI** — calm, fast, and intelligent. Designed for people who want clarity over their money without the guilt trip.

> *"I don't need an app that tells me to save. I need an app that shows me where I stand, and what happens if I keep going like this."*

---

## Contents

- [Features](#features)
- [App Previews](#app-previews)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Design Philosophy](#design-philosophy)
- [Getting Started](#getting-started)
- [Roadmap](#roadmap)

---

## Features

### Core

| Feature | Description | Status |
|---------|-------------|--------|
| **Auth & Onboarding** | Face ID / passcode lock + 3-screen first-run flow | ✅ |
| **Dashboard** | Net balance, AI quick insight, recent transactions | ✅ |
| **Transactions** | Full CRUD — custom categories, income/expense, OCR entry | ✅ |
| **Budget Tracker** | Per-category monthly budget with real-time progress bars | ✅ |
| **Reports** | Monthly breakdown, category analysis, period comparison | ✅ |
| **Bills Reminder** | Recurring bill tracking + local push notifications | ✅ |

### Intelligence

| Feature | Description | Status |
|---------|-------------|--------|
| **AI Advisor** | Rule-based insights + spending pattern detection via Sumopod API; togglable | ✅ |
| **OCR Scanner** | Receipt scan via Vision framework — auto-extracts amount & date | ✅ |

### Connectivity & Platform

| Feature | Description | Status |
|---------|-------------|--------|
| **Home Screen Widget** | Dual-mode WidgetKit widget — adapts content for Normal and Expense-Only modes | ✅ |
| **Cloud Backup** | Anonymous Supabase sync with real-time status in Settings | ✅ |
| **Settings** | App theme (Light / Dark / System), AI advisor toggle, account management | ✅ |
| **Expense-Only Mode** | Strips income tracking — every view, widget, and metric adapts | ✅ |

---

## App Previews

<table align="center">
  <tr>
    <td align="center" width="25%">
      <img src="docs/previews/IMG_2272.PNG" alt="Onboarding" />
    </td>
    <td align="center" width="25%">
      <img src="docs/previews/IMG_2273.PNG" alt="Onboarding 2" />
    </td>
    <td align="center" width="25%">
      <img src="docs/previews/IMG_2274.PNG" alt="Passcode Lock" />
    </td>
    <td align="center" width="25%">
      <img src="docs/previews/IMG_2275.PNG" alt="Dashboard" />
    </td>
  </tr>
  <tr>
    <td align="center" width="25%">
      <img src="docs/previews/IMG_2276.PNG" alt="Transactions" />
    </td>
    <td align="center" width="25%">
      <img src="docs/previews/IMG_2278.PNG" alt="Category Budgets" />
    </td>
    <td align="center" width="25%">
      <img src="docs/previews/IMG_2279.PNG" alt="AI Advisor" />
    </td>
    <td align="center" width="25%">
      <img src="docs/previews/IMG_2280.PNG" alt="Bills" />
    </td>
  </tr>
  <tr>
    <td align="center" width="25%">
      <img src="docs/previews/IMG_2281.PNG" alt="Reports" />
    </td>
    <td align="center" width="25%">
      <img src="docs/previews/IMG_2282.PNG" alt="OCR Scanner" />
    </td>
    <td align="center" width="25%">
      <img src="docs/previews/IMG_2283.PNG" alt="Widget" />
    </td>
    <td align="center" width="25%">
      <img src="docs/previews/IMG_2277.PNG" alt="Overview" />
    </td>
  </tr>
</table>

---

## Architecture

```
cashflow/
├── App/                    # Entry point, root navigation, environment injection
├── Core/
│   ├── DesignSystem/       # Tokens (color, type, spacing), reusable components
│   ├── Persistence/        # SwiftData models: Transaction, Budget, Bill, Category
│   └── Services/           # SyncEngine (Supabase), NotificationService, OCR
├── Features/
│   ├── Auth/               # Face ID lock + LocalAuthentication
│   ├── Onboarding/         # 3-page first-run flow
│   ├── Dashboard/          # Balance overview, AI insight card, recent transactions
│   ├── Transactions/       # List, add, edit, delete, OCR import
│   ├── Budget/             # Per-category budget with live progress
│   ├── Reports/            # Monthly charts, period comparisons
│   ├── AIAdvisor/          # Insight feed + Sumopod API
│   ├── Bills/              # Recurring bills + local notifications
│   ├── OCR/                # Vision framework receipt scanner
│   └── Widgets/            # WidgetKit provider + dual-mode views
└── CashFlow Widget/        # Widget Extension target (separate bundle)
```

**Offline-first.** All data lives in SwiftData on-device. No account required.

**Cloud sync** (optional). `SyncEngine` handles anonymous Supabase auth and row-level sync. Real-time status — ✅ Synced / ⚠️ Warning / ❌ Failed — is visible in the Settings tab.

**Widget data bridge.** `DashboardViewModel` writes balance, spending, last transaction details, and the current mode flag to an App Group (`group.com.dumeg.cashflow`) shared `UserDefaults`. The widget extension reads this and calls `WidgetCenter.shared.reloadAllTimelines()` on every transaction save.

---

## Tech Stack

| Layer | Technology | Notes |
|---|---|---|
| Language | Swift 5.9 | |
| UI | SwiftUI | |
| Persistence | SwiftData | Replaces Core Data; cleaner model definitions, native @Observable support |
| Cloud Sync | Supabase | Anonymous auth — no sign-up required; RLS policies per user UUID |
| AI / Insights | Sumopod API | GPT-backed rule engine; toggleable so users can go distraction-free |
| OCR | Vision + VisionKit | On-device; no server roundtrip for receipt scanning |
| Widgets | WidgetKit | Dual-mode: adapts layout based on app's active mode |
| Notifications | UserNotifications | Local only; bills reminder scheduler |
| Biometric Auth | LocalAuthentication | Face ID / Touch ID app lock |
| Minimum iOS | 17.0 | Required for SwiftData |

---

## Design Philosophy

Four constraints every screen must satisfy:

1. **Scannable in < 3 seconds.** No critical information buried in submenus.
2. **Calm palette.** Warm ambers — information, not judgment.
3. **No guilt language.** `"Category X is 18% above your 3-month average"` — not `"You're overspending!"`.
4. **Native feel.** HIG-conformant. Should feel like it shipped with the OS.

The AI Advisor uses three escalation levels — *Informative*, *Cautionary*, *Important* — expressed through tone and subtle color shifts. Never aggressive alerts. Can be disabled entirely from Settings for a focus-first experience.

---

## Getting Started

### Prerequisites

- Xcode 15.4+
- iOS 17+ device or Simulator
- macOS Sonoma 14+

### Installation

```bash
git clone https://github.com/Daivageralda/cashflow.git
cd cashflow
open cashflow.xcodeproj
```

> **Signing:** Open `Signing & Capabilities` for both the `cashflow` and `CashFlow WidgetExtension` targets. Select your personal team. Xcode provisions automatically.

### Widget Setup

1. Target `cashflow` → **Build Phases** → confirm `CashFlow WidgetExtension` in **Target Dependencies**
2. Confirm **Copy Files** phase: Destination = `Plugins and Foundation Extensions`, `Code Sign On Copy` = ✅
3. Confirm `CashflowWidget.swift` has **Target Membership** checked for `CashFlow WidgetExtension`
4. `Cmd + R` — the widget appears in the iOS Add Widget gallery

> **Widget behavior:** In Normal Mode the widget shows net balance + monthly spending burn rate. In Expense-Only Mode it switches to total expenses as the hero metric, plus last transaction detail on the medium size.

### Cloud Sync

Supabase sync activates automatically with no configuration. Sync status is visible in **Settings → Cloud Backup**. Anonymous — no login, no data leaves your device namespace.

---

## Roadmap

```
V1 (current)                          V2 (planned)
────────────────────────────────────  ────────────────────────────────────
OCR receipt scanning                  Conversational AI chat
Bills & recurring reminders           ML-based balance prediction
iOS Home Screen Widgets               iCloud Sync (CloudKit)
AI Advisor (togglable)                Siri Shortcuts
Supabase optional cloud backup        CSV / PDF export
App theme: Light / Dark / System
Expense-Only mode
```

---

## License

MIT © [Daivageralda](https://github.com/Daivageralda)

<div align="center">

<br />

<img src="https://capsule-render.vercel.app/api?type=waving&color=D4A853&height=80&section=footer" width="100%" />

</div>
