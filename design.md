# 🎨 Cashflow — Product Design Document
## Bagian 2 · Design System, Motion & Arsitektur Teknis

---

## 🎨 1. Design System

### 1.1 Color Palette

Palet dasar dari brand brief, diperluas menjadi token siap-pakai untuk Light & Dark Mode (wajib di iOS sesuai HIG).

#### Brand Colors (Sumber)

| Role | Nama | Hex |
|---|---|---|
| Primary | Charcoal Black | `#1A1A1A` |
| Secondary | Burnt Orange | `#C96B2C` |
| Accent | Golden Amber | `#E89A45` |
| Support | Walnut Brown | `#6B4B2A` |
| Background | Warm White | `#F8F7F4` |

#### Extended Semantic Tokens

Palet asli hanya 5 warna — untuk kebutuhan app real (state, hierarchy teks, border), ditambahkan neutral scale & semantic warna yang tetap "warm" agar tidak terasa seperti fintech generik (hindari hijau/merah saturasi tinggi).

| Token | Light Mode | Dark Mode | Penggunaan |
|---|---|---|---|
| `bg/primary` | `#F8F7F4` (Warm White) | `#1A1A1A` (Charcoal Black) | Background utama |
| `bg/secondary` | `#EFEDE8` | `#242424` | Card, surface |
| `bg/tertiary` | `#E6E3DC` | `#2E2E2E` | Input field, chip inactive |
| `text/primary` | `#1A1A1A` | `#F8F7F4` | Judul, angka saldo |
| `text/secondary` | `#5C5A54` | `#B8B5AD` | Subteks, label |
| `text/tertiary` | `#8A877E` | `#7A776E` | Placeholder, disabled |
| `accent/primary` | `#C96B2C` (Burnt Orange) | `#D97B3D` | CTA, tab aktif, highlight |
| `accent/secondary` | `#E89A45` (Golden Amber) | `#E89A45` | Progress, insight positif |
| `support/brown` | `#6B4B2A` | `#8A6740` | Ikon sekunder, divider tegas |
| `state/success` | `#7A8B5C` (olive-green muted) | `#8FA36E` | Pengeluaran turun, target tercapai |
| `state/caution` | `#C96B2C` (Burnt Orange) | `#D97B3D` | Budget 80–99% |
| `state/critical` | `#A8492C` (burnt red-brown, tetap warm) | `#B85A3A` | Proyeksi saldo negatif |
| `border/default` | `#E0DDD5` | `#3A3A3A` | Divider, outline card |

> Semua state color sengaja diturunkan dari keluarga oranye-cokelat (bukan hijau/merah RGB murni) supaya tetap terasa "satu keluarga warna", sesuai brand personality *calm & tidak menghakimi*.

### 1.2 Typography

Mengikuti **San Francisco (SF Pro Display / SF Pro Text)** sesuai Apple HIG — tidak perlu custom font, otomatis mendukung Dynamic Type & aksesibilitas.

| Style | Font | Size / Line Height | Weight | Penggunaan |
|---|---|---|---|---|
| Large Title | SF Pro Display | 34 / 41 | Bold | Judul halaman utama (Dashboard, Reports) |
| Title 1 | SF Pro Display | 28 / 34 | Bold | Saldo utama |
| Title 2 | SF Pro Display | 22 / 28 | Semibold | Judul section |
| Title 3 | SF Pro Display | 20 / 25 | Semibold | Judul card |
| Headline | SF Pro Text | 17 / 22 | Semibold | Label penting, nama transaksi |
| Body | SF Pro Text | 17 / 22 | Regular | Teks umum |
| Callout | SF Pro Text | 16 / 21 | Regular | Insight AI text |
| Subheadline | SF Pro Text | 15 / 20 | Regular | Deskripsi sekunder |
| Footnote | SF Pro Text | 13 / 18 | Regular | Metadata (tanggal, waktu) |
| Caption 1 | SF Pro Text | 12 / 16 | Regular | Label kecil, badge |
| Caption 2 | SF Pro Text | 11 / 13 | Medium | Micro-label (widget) |

**Aturan:**
- Gunakan **SF Pro Display** hanya untuk ukuran ≥ 20pt (judul & angka besar).
- Gunakan **SF Pro Text** untuk semua ukuran ≤ 17pt (body & UI text).
- Angka saldo/nominal selalu pakai fitur **Tabular Figures** (`monospacedDigit()`) agar tidak "bergoyang" saat berubah.
- Wajib mendukung **Dynamic Type** hingga minimal *Accessibility Large*.

### 1.3 Spacing System

8pt grid, konsisten dengan HIG dan mendukung layout yang "banyak white space" sesuai brief.

| Token | Value | Penggunaan |
|---|---|---|
| `space/4` | 4pt | Gap antar ikon-teks kecil |
| `space/8` | 8pt | Gap internal komponen kecil |
| `space/12` | 12pt | Padding chip/tag |
| `space/16` | 16pt | Padding standar card, margin horizontal layar |
| `space/20` | 20pt | Gap antar card dalam list |
| `space/24` | 24pt | Section spacing |
| `space/32` | 32pt | Spacing antar major section |
| `space/40` | 40pt | Top spacing halaman besar |
| `space/48` | 48pt | Spacing onboarding/empty state |
| `space/64` | 64pt | Spacing hero/splash |

### 1.4 Corner Radius

Mengikuti karakter "rounded, halus, elegan" dari brief.

| Token | Value | Penggunaan |
|---|---|---|
| `radius/xs` | 8pt | Chip, badge, tag kategori |
| `radius/sm` | 12pt | Button, input field |
| `radius/md` | 16pt | Card standar (transaksi, budget) |
| `radius/lg` | 20pt | Card besar (Dashboard hero card) |
| `radius/xl` | 24pt | Sheet/modal (top corners) |
| `radius/full` | 999pt | Avatar, icon button bulat |

### 1.5 Elevation

Karena brand personality *minimalis & calm*, elevation dibuat sangat halus — hindari shadow berat khas skeuomorphism.

| Level | Shadow (Light Mode) | Dark Mode | Penggunaan |
|---|---|---|---|
| `elevation/0` | none | none | Background, flat surface |
| `elevation/1` | `0 1px 2px rgba(26,26,26,0.04)` | border `1px #3A3A3A` | Card standar |
| `elevation/2` | `0 2px 8px rgba(26,26,26,0.06)` | border + subtle glow `#C96B2C 8%` | Card aktif/selected |
| `elevation/3` | `0 4px 16px rgba(26,26,26,0.08)` | sama + shadow halus | Floating Action Button |
| `elevation/4` | `0 8px 24px rgba(26,26,26,0.12)` | sama, lebih jelas | Modal / Sheet |

> Di Dark Mode, sebisa mungkin **gunakan border tipis + sedikit peningkatan brightness surface**, bukan shadow gelap (shadow tidak terlihat baik di atas background gelap) — pendekatan standar iOS Dark Mode.

### 1.6 Iconography

- Basis: **SF Symbols** (weight: Regular/Medium, mengikuti Dynamic Type teks di sekitarnya).
- Custom icon (jika perlu, misal untuk logo flow) mengikuti gaya: **rounded, minimal, monoline, negative space konsisten** seperti pada logo.
- Ukuran ikon standar: `20pt` (inline dengan teks), `24pt` (tab bar, list), `28pt` (tombol utama/FAB).
- Warna ikon default: `text/secondary`; ikon aktif/aksi: `accent/primary`.

---

## ✨ 2. Motion & Animation Guidelines

### Prinsip Utama
Animasi harus **purposeful & calm** — membantu pemahaman perubahan state, bukan sekadar dekorasi.

| Prinsip | Aturan |
|---|---|
| **Subtle over flashy** | Tidak ada bounce ekstrem atau efek "playful" berlebihan — sesuai brand *premium & calm*. |
| **Spring-based motion** | Gunakan `spring(response: 0.35, dampingFraction: 0.85)` sebagai default untuk transisi UI. |
| **Duration guideline** | Micro-interaction: 150–200ms. Transisi antar view: 300–400ms. Modal/sheet: 350–450ms. |
| **Easing** | `easeInOut` untuk fade, spring untuk perpindahan posisi/skala. |
| **Haptic pairing** | Setiap konfirmasi aksi (simpan transaksi) → `UIImpactFeedbackGenerator(.light)`. Pencapaian target budget → `UINotificationFeedbackGenerator(.success)`. |

### Pola Animasi Spesifik

| Komponen | Perilaku |
|---|---|
| **Angka Saldo** | Count-up/count-down animation saat berubah (durasi 400–600ms, easeOut), bukan loncat instan. |
| **Progress Bar Budget** | Fill animation dari 0 ke nilai aktual saat card muncul, damping halus. |
| **Insight Card (AI)** | Slide-in dari bawah + fade, delay bertahap (stagger 50ms) jika lebih dari satu card muncul bersamaan. |
| **Transisi Tab** | Cross-fade halus, tanpa slide horizontal drastis (kecuali antar level navigasi dalam 1 tab). |
| **Pull-to-refresh Insight** | Custom refresh indicator berbasis logo flow (garis animasi bergerak, bukan spinner generik). |
| **Empty State** | Fade-in halus (300ms) tanpa ilustrasi playful berlebihan — cukup ikon monoline + teks singkat. |
| **Sheet/Modal (Tambah Transaksi)** | Present dengan `presentationDetents`, drag-to-dismiss aktif, corner radius `24pt` di atas. |

---

## 📐 3. Apple Human Interface Guidelines (HIG) — Checklist Kepatuhan

| Area HIG | Implementasi di Cashflow |
|---|---|
| **Clarity** | Tipografi SF Pro dengan hierarchy jelas, whitespace luas, 1 CTA utama per layar. |
| **Deference** | UI tidak "berteriak" — warna brand dipakai sebagai aksen, bukan mendominasi seluruh layar. |
| **Depth** | Elevation halus + sheet presentation untuk membedakan layer konten. |
| **Dynamic Type** | Semua teks scalable, layout diuji hingga *Accessibility Extra Large*. |
| **Dark Mode** | Wajib didukung penuh sejak MVP — token warna sudah dipetakan (lihat 1.1). |
| **Safe Area & Layout Margins** | Semua layar respek terhadap safe area (notch, Dynamic Island, home indicator). |
| **Accessibility (VoiceOver)** | Semua elemen interaktif punya `accessibilityLabel` deskriptif; kontras teks minimal 4.5:1. |
| **Standard Navigation** | Tab Bar (5 item) + Navigation Bar dengan Large Title yang collapse saat scroll. |
| **Haptics** | Digunakan secara konsisten sesuai HIG (light untuk konfirmasi, success/warning untuk hasil penting). |
| **Widgets (WidgetKit)** | Widget Saldo, Budget, Reminder mengikuti spesifikasi ukuran resmi (Small/Medium/Large) dan *Widget-in-Lock-Screen* jika relevan (V1/V2). |
| **SF Symbols** | Semua ikon sistem pakai SF Symbols, weight menyesuaikan teks sekitar. |
| **Biometric Transparency** | Face ID diminta dengan penjelasan jelas (`NSFaceIDUsageDescription` deskriptif), fallback passcode selalu tersedia. |
| **Modal Presentation** | Sheet (`.sheet`) untuk aksi sekunder (tambah transaksi), full screen cover hanya untuk onboarding. |
| **Error States** | Pesan error human-readable, selalu beri jalan keluar (retry/edit), tidak pernah dead-end. |
| **App Intents / Siri (V2)** | Aksi utama (cek saldo, catat transaksi) diekspos lewat App Intents untuk Siri & Shortcuts. |

---

## 🏗️ 4. Struktur Project Swift & Arsitektur Aplikasi

### 4.1 Pilihan Arsitektur

**MVVM + Clean-lite Layering**, dengan **SwiftUI + Swift Concurrency (async/await)**, dan **SwiftData** sebagai persistence layer (offline-first, native, siap untuk sinkronisasi CloudKit di V2).

```
┌─────────────────────────────────────────────┐
│                    View (SwiftUI)            │  ← Presentational, minim logic
├─────────────────────────────────────────────┤
│                  ViewModel                    │  ← @Observable, state & aksi UI
├─────────────────────────────────────────────┤
│         Service / UseCase Layer               │  ← Business logic (AI insight, prediksi,
│                                                │     OCR processing, budget calculation)
├─────────────────────────────────────────────┤
│           Repository Layer                    │  ← Abstraksi akses data
├─────────────────────────────────────────────┤
│    Persistence (SwiftData) / Network (opsional)│
└─────────────────────────────────────────────┘
```

**Alasan pemilihan:**
- **MVVM** paling natural untuk SwiftUI, minim boilerplate dibanding VIPER/Clean penuh — cocok untuk personal project yang harus tetap maintainable solo.
- **Repository pattern** dipisah supaya AI Advisor & Prediction Service bisa diuji/diganti tanpa menyentuh UI (misal: ganti rule-based engine di V1 ke model ML di V2 tanpa refactor besar).
- **SwiftData** dipilih atas Core Data murni karena sintaks modern, native Swift, dan siap CloudKit sync untuk fitur iCloud di V2.

### 4.2 Struktur Folder

```
Cashflow/
├── CashflowApp.swift                  # Entry point (@main)
│
├── App/
│   ├── AppState.swift                 # Global observable state (auth status, dsb.)
│   ├── AppEnvironment.swift           # DI container sederhana
│   └── RootView.swift                 # Root switcher (Onboarding / Auth / Main)
│
├── Core/
│   ├── DesignSystem/
│   │   ├── Tokens/
│   │   │   ├── Colors.swift
│   │   │   ├── Typography.swift
│   │   │   ├── Spacing.swift
│   │   │   └── Radius.swift
│   │   └── Components/
│   │       ├── PrimaryButton.swift
│   │       ├── InsightCard.swift
│   │       ├── BudgetProgressBar.swift
│   │       ├── TransactionRow.swift
│   │       └── EmptyStateView.swift
│   │
│   ├── Persistence/
│   │   ├── Models/                    # @Model SwiftData entities
│   │   │   ├── Transaction.swift
│   │   │   ├── Category.swift
│   │   │   ├── Budget.swift
│   │   │   └── Bill.swift
│   │   └── PersistenceController.swift
│   │
│   ├── Extensions/
│   │   ├── Date+Formatting.swift
│   │   ├── Double+Currency.swift
│   │   └── View+Modifiers.swift
│   │
│   └── Utils/
│       ├── CurrencyFormatter.swift
│       └── HapticManager.swift
│
├── Features/
│   ├── Onboarding/
│   │   ├── Views/
│   │   └── ViewModels/
│   │
│   ├── Auth/
│   │   ├── Views/                     # Face ID / Passcode screen
│   │   ├── ViewModels/
│   │   └── Services/
│   │       └── BiometricAuthService.swift
│   │
│   ├── Dashboard/
│   │   ├── Views/
│   │   │   ├── DashboardView.swift
│   │   │   └── QuickInsightCardView.swift
│   │   └── ViewModels/
│   │       └── DashboardViewModel.swift
│   │
│   ├── Transactions/
│   │   ├── Views/
│   │   │   ├── TransactionListView.swift
│   │   │   ├── AddTransactionView.swift
│   │   │   └── TransactionDetailView.swift
│   │   ├── ViewModels/
│   │   └── OCR/
│   │       └── ReceiptScannerService.swift   # VisionKit + Vision framework
│   │
│   ├── Budget/
│   │   ├── Views/
│   │   └── ViewModels/
│   │
│   ├── Reports/
│   │   ├── Views/
│   │   └── ViewModels/
│   │
│   ├── AIAdvisor/
│   │   ├── Views/
│   │   │   ├── InsightFeedView.swift
│   │   │   ├── AskAIView.swift
│   │   │   └── PredictionChartView.swift
│   │   ├── ViewModels/
│   │   └── Services/
│   │       ├── InsightEngine.swift           # Rule-based (V1) → pluggable ke ML (V2)
│   │       ├── PredictionService.swift
│   │       └── ProactiveTriggerScheduler.swift
│   │
│   ├── BillsReminder/
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   └── Services/
│   │       └── NotificationScheduler.swift   # UserNotifications framework
│   │
│   └── Settings/
│       ├── Views/
│       └── ViewModels/
│
├── Widgets/
│   ├── CashflowWidgetBundle.swift
│   ├── BalanceWidget/
│   ├── BudgetWidget/
│   └── ReminderWidget/
│
├── Resources/
│   ├── Assets.xcassets                # App icon, color sets, image sets
│   └── Localizable.strings
│
├── CashflowTests/
│   ├── ViewModelTests/
│   └── ServiceTests/
│
└── CashflowUITests/
```

### 4.3 Prinsip Implementasi Kunci

| Area | Pendekatan |
|---|---|
| **State Management** | `@Observable` ViewModel (Swift Observation framework) per feature, di-inject via `AppEnvironment`. |
| **Dependency Injection** | Container ringan manual (bukan library eksternal) — cukup untuk skala personal app. |
| **AI/Insight Layer** | `InsightEngine` sebagai protocol → implementasi awal rule-based (V1), bisa diganti implementasi ML/LLM-based (V2) tanpa ubah ViewModel. |
| **OCR** | `VisionKit` (`VNDocumentCameraViewController`) untuk scan + `Vision` (`VNRecognizeTextRequest`) untuk ekstraksi teks nominal. |
| **Notifikasi** | `UNUserNotificationCenter` untuk bills reminder & ringkasan proaktif, dijadwalkan lokal (privacy-first, tanpa server). |
| **Widget** | `WidgetKit` + `App Group` untuk share data antara app utama & widget via SwiftData/UserDefaults suite. |
| **Sinkronisasi (V2)** | `SwiftData` + `CloudKit` container otomatis untuk sync antar device tanpa backend custom. |
| **Testing** | ViewModel & Service diuji lewat protocol-based mocking (`XCTest`), UI test untuk flow kritikal (tambah transaksi, auth). |

### 4.4 Data Flow Singkat

```
User Action (View)
     │
     ▼
ViewModel (validasi input, update state)
     │
     ▼
Service/UseCase (business logic: hitung budget, generate insight)
     │
     ▼
Repository (abstraksi CRUD)
     │
     ▼
SwiftData (persist) ──► (opsional, V2) CloudKit sync
     │
     ▼
ViewModel observes perubahan ──► View re-render otomatis
```

---

*Dokumen ini adalah living document — update seiring iterasi desain & pengembangan Cashflow.*
