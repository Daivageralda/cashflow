# 🌊 Cashflow — Product Design Document
## Bagian 1 · Product Strategy & Behavior

> *"Membantu setiap rupiah memiliki tujuan."*

---

## 🎯 1. Product Vision & Mission

### Vision
Menjadi pendamping finansial pribadi yang membuat penggunanya merasa **tenang, terarah, dan percaya diri** dalam setiap keputusan uang — bukan lewat angka yang menghakimi, tapi lewat insight yang membimbing.

### Mission

| # | Misi | Penjelasan |
|---|------|------------|
| 1 | **Menyederhanakan pencatatan** | Mencatat transaksi harus terasa ringan (manual cepat atau OCR), bukan pekerjaan rumah tambahan. |
| 2 | **Memvisualisasikan arus, bukan sekadar saldo** | Fokus ke *cashflow* — ke mana uang bergerak dan kenapa — bukan cuma angka statis di rekening. |
| 3 | **Memberi insight sebelum masalah terjadi** | AI mendeteksi pola dan memberi peringatan dini secara halus, bukan reaktif setelah saldo minus. |
| 4 | **Menjaga nada yang dewasa** | Tidak pernah membuat pengguna merasa bersalah atau bodoh soal uang. |
| 5 | **Membangun kebiasaan, bukan sekadar tracking** | Reminder, widget, dan insight dirancang untuk membentuk *habit loop* finansial yang sehat. |

---

## 💎 2. Core Values

| Value | Artinya dalam Produk |
|---|---|
| **Flow** | Uang harus terlihat *bergerak* dengan tujuan — bukan angka statis di tabel. |
| **Balance** | UI dan insight tidak boleh terasa berat sebelah (terlalu optimis atau terlalu menakut-nakuti). |
| **Discipline** | Fitur mendorong konsistensi kecil harian, bukan usaha besar sesekali. |
| **Clarity** | Setiap layar harus bisa dipahami dalam < 3 detik tanpa penjelasan tambahan. |
| **Intentional** | Tidak ada fitur "karena keren" — semua harus menjawab pertanyaan "apakah ini membantu keputusan finansial?" |
| **Growth** | Progres kecil dirayakan, bukan cuma target besar. |
| **Calm** | Warna, copywriting, animasi — semua menjauhi urgensi berlebihan. |
| **Insight** | Data mentah selalu diterjemahkan jadi kalimat yang actionable. |

---

## 👤 3. User Persona

### Primary Persona — *"The Builder"*

| Atribut | Detail |
|---|---|
| **Nama (contoh)** | Rai |
| **Umur** | 22 tahun |
| **Profesi** | Full-time Programmer |
| **Device** | iPhone (ekosistem Apple penuh — Mac, Watch, iCloud) |
| **Tech comfort** | Sangat tinggi — terbiasa dengan automation, AI tools, agentic workflow |
| **Financial literacy** | Menengah-tinggi, tapi sibuk sehingga butuh sistem yang *mengingatkan*, bukan yang perlu dipelajari |

**Goals**
- Tahu kondisi saldo real-time tanpa harus membuka banking app & menghitung manual.
- Punya sistem yang otomatis memperingatkan sebelum over-budget, bukan sesudahnya.
- Mencatat transaksi secepat mungkin (idealnya < 10 detik per transaksi).

**Frustrations**
- Aplikasi finance kebanyakan terasa seperti spreadsheet berbaju app — membosankan dan menghakimi.
- Kebanyakan app finance lokal tidak dirancang untuk ekosistem Apple (tidak ada widget, tidak native).
- Insight yang diberikan biasanya generik ("kamu boros bulan ini") tanpa konteks atau proyeksi.

**Behavior Patterns**
- Suka automasi & AI copilot dalam workflow apa pun (termasuk coding).
- Prefer kontrol manual atas konfigurasi penting — tidak suka *black box* yang mengubah sesuatu tanpa izin.
- Cek keuangan biasanya di 2 momen: pagi (cek saldo sebelum mulai hari) & malam (review pengeluaran hari itu).

**Quote yang mewakili**
> *"Aku nggak butuh app yang nyuruh aku hemat. Aku butuh app yang kasih tahu aku posisi sekarang, dan apa konsekuensinya kalau aku lanjut seperti ini."*

---

## 🧠 4. AI Personality & Tone of Voice

### Karakter AI: **"Dewasa, Tenang, Berbasis Fakta"**

AI Cashflow diposisikan sebagai **penasihat pribadi senior**, bukan alarm, bukan guru galak, dan bukan cheerleader berlebihan.

| Trait | Deskripsi |
|---|---|
| **Calm** | Tidak pernah panik, tidak pakai tanda seru berlebihan atau warna merah tanpa alasan kuat. |
| **Non-judgmental** | Tidak pernah menyalahkan kebiasaan pengguna secara langsung. |
| **Contextual** | Setiap insight selalu disertai proyeksi atau konsekuensi, bukan pernyataan kosong. |
| **Concise** | Insight singkat (1–2 kalimat), bukan esai. Detail tersedia jika pengguna tap untuk explore. |
| **Honest** | Tetap jujur soal risiko — hanya saja disampaikan sebagai informasi, bukan hukuman. |

### Do & Don't

| ❌ Hindari | ✅ Gunakan |
|---|---|
| "Pengeluaranmu terlalu besar." | "Jika pola pengeluaran minggu ini berlanjut, saldo akhir bulan diperkirakan masih aman di kisaran Rp X." |
| "Kamu boros di kategori makanan!" | "Kategori makanan naik 18% dibanding rata-rata 3 bulan terakhir." |
| "Awas saldo mau habis!!!" | "Berdasarkan kebiasaan saat ini, saldo diperkirakan menyentuh titik rendah sekitar tanggal 27." |
| "Kamu harus lebih disiplin." | "Budget kategori transportasi sudah terpakai 82% dengan sisa 9 hari." |

### Contoh Frasa Library

| Situasi | Contoh Insight |
|---|---|
| Budget mendekati limit (80%) | "Budget hiburan sudah terpakai 80%. Sisa alokasi sekitar Rp150.000 untuk 10 hari ke depan." |
| Pola pengeluaran naik | "Rata-rata pengeluaran harian minggu ini 22% lebih tinggi dari biasanya." |
| Progres positif | "Pengeluaran bulan ini 12% lebih rendah dari bulan lalu — tren yang bagus." |
| Prediksi saldo akhir bulan | "Dengan tren saat ini, saldo akhir bulan diperkirakan Rp X, ± Rp Y tergantung tagihan mendatang." |
| Tagihan mendekat | "Tagihan internet jatuh tempo dalam 3 hari, estimasi Rp350.000." |
| Anomali transaksi | "Transaksi hari ini di kategori belanja lebih besar dari biasanya — ingin ditandai sebagai pengeluaran khusus?" |

---

## 📱 5. Information Architecture

Struktur navigasi utama: **Tab Bar (5 tab)**, mengikuti pola aplikasi finance native iOS.

```
Cashflow
│
├── 🏠 Dashboard
│   ├── Saldo Overview (total + per akun jika multi-account di V2)
│   ├── Quick Insight Card (1 insight AI utama hari ini)
│   ├── Budget Snapshot (ringkas progress bar)
│   └── Transaksi Terbaru (5 terakhir)
│
├── 💸 Transaksi
│   ├── List Transaksi (filter: tanggal, kategori, tipe)
│   ├── Tambah Transaksi
│   │   ├── Manual Entry
│   │   └── Scan Struk (OCR)
│   ├── Detail Transaksi (edit/hapus)
│   └── Manajemen Kategori
│
├── 🎯 Budget
│   ├── Overview Budget (semua kategori)
│   ├── Detail Budget per Kategori
│   └── Riwayat Budget (bulan sebelumnya)
│
├── 🧠 AI Advisor
│   ├── Insight Feed (kronologis, seperti timeline)
│   ├── Prediksi Saldo (chart proyeksi)
│   ├── Tanya AI (free-form question / what-if simulation)
│   └── Rekomendasi Aktif
│
└── ⚙️ Lainnya
    ├── Reports
    │   ├── Laporan Bulanan
    │   ├── Analisis Pengeluaran (breakdown kategori, tren)
    │   └── Perbandingan Antar Bulan
    ├── Bills Reminder
    │   ├── List Tagihan
    │   └── Tambah/Edit Tagihan
    ├── Widgets Settings
    ├── Profile & Preferensi
    ├── Notifikasi
    └── Data & Privasi (export, backup, hapus data)
```

> Catatan: Reports & Bills Reminder digabung ke tab "Lainnya" untuk menjaga tab bar tetap 5 item sesuai HIG (idealnya maksimal 5 tab utama). Bisa dipromosikan jadi tab sendiri di V2 jika frekuensi penggunaan tinggi.

---

## 🗺️ 6. User Flow Utama

### Flow: Login → Dashboard → Transaksi → AI Advisor

```
[App Launch]
     │
     ▼
[Face ID / Passcode Check] ──(gagal 3x)──► [Fallback: Passcode manual]
     │ (berhasil)
     ▼
[First Launch?] ──(ya)──► [Onboarding Singkat: nama, currency, saldo awal]
     │ (tidak)                        │
     ▼                                ▼
[Dashboard] ◄───────────────────────────
     │
     ├──► [Tap Quick Insight Card] ──► [AI Advisor > Insight Detail]
     │
     ├──► [Tap "+"] ──► [Tambah Transaksi]
     │                       │
     │                       ├──► [Manual Entry] ──► [Pilih Kategori] ──► [Simpan] ──► [Dashboard update]
     │                       │
     │                       └──► [Scan Struk] ──► [OCR proses] ──► [Konfirmasi hasil scan] ──► [Simpan]
     │
     ├──► [Tab Transaksi] ──► [List] ──► [Tap item] ──► [Detail/Edit]
     │
     ├──► [Tab Budget] ──► [Lihat progress] ──► [Tap kategori] ──► [Detail Budget]
     │
     └──► [Tab AI Advisor]
              │
              ├──► [Insight Feed] (scroll insight harian/mingguan)
              ├──► [Tanya AI] ──► [Input pertanyaan bebas] ──► [Jawaban + visualisasi jika relevan]
              └──► [Prediksi Saldo] ──► [Chart proyeksi akhir bulan]
```

### Prinsip Flow
- **Auth setiap buka app** (karena data finansial sensitif & personal) via Face ID, dengan fallback passcode.
- **Onboarding hanya sekali**, singkat (≤ 3 layar), tidak memaksa isi semua data di awal.
- **Tambah transaksi maksimal 3 tap** dari Dashboard (tombol "+" mengambang selalu terlihat).
- **AI Advisor selalu bisa diakses**, tapi tidak pernah menjadi halangan (non-blocking) untuk alur pencatatan.

---

## 🧩 7. Daftar Fitur & Prioritas

### 🟢 MVP (Minimum Viable Product)
Fokus: mencatat & melihat kondisi cashflow dengan akurat.

| Fitur | Deskripsi |
|---|---|
| Transaction Management | Input income/expense manual + kategori kustom |
| Dashboard Saldo | Total saldo, ringkasan harian |
| Budget Dasar | Set budget per kategori + progress bar |
| Laporan Bulanan Sederhana | Total masuk/keluar per bulan, breakdown per kategori |
| Face ID / Passcode Lock | Keamanan dasar akses app |
| Local Persistence | Data tersimpan di device (offline-first) |

### 🟡 V1
Fokus: efisiensi input & automasi ringan.

| Fitur | Deskripsi |
|---|---|
| OCR Receipt Scan | Scan struk, auto-extract nominal & tanggal |
| Bills Reminder | Pengingat tagihan berulang (lokal notification) |
| iOS Widgets | Widget saldo, budget, reminder di Home Screen |
| AI Insight (Rule-based) | Insight berbasis aturan sederhana (threshold budget, tren mingguan) |
| Monthly Insight Notification | Ringkasan otomatis awal bulan |
| Spending Analysis | Analisis kebiasaan pengeluaran (grafik tren) |

### 🔵 V2
Fokus: AI sebagai copilot penuh & personalisasi mendalam.

| Fitur | Deskripsi |
|---|---|
| AI Financial Advisor (Conversational) | Tanya-jawab bebas, "what-if" simulation |
| Predictive Balance (ML-based) | Prediksi saldo akhir bulan berbasis pola historis, bukan sekadar rata-rata |
| Proactive Smart Suggestions | Saran penghematan personal berdasar histori |
| iCloud Sync / Multi-device | Sinkronisasi lewat CloudKit |
| Siri Shortcuts & App Intents | "Hei Siri, berapa saldo aku?" / catat transaksi via voice |
| Custom Categories Rules | Auto-kategorisasi transaksi berdasar pola sebelumnya |
| Data Export | Export ke CSV/PDF untuk backup atau analisis eksternal |

---

## 🤖 8. AI Advisor Behavior

### Prinsip Utama
AI **proaktif tapi tidak mengganggu** — insight diberikan di momen yang tepat, bukan setiap saat.

### Kapan AI Proaktif (push insight tanpa diminta)

| Trigger | Contoh |
|---|---|
| Budget mencapai ambang tertentu (mis. 80%, 100%) | Notifikasi/insight card muncul di Dashboard |
| Pola pengeluaran anomali terdeteksi | Transaksi jauh di atas rata-rata kategori |
| Ringkasan mingguan/bulanan | Setiap Senin pagi & awal bulan |
| Tagihan mendekati jatuh tempo | H-3 dan H-1 |
| Progres positif signifikan | Pengeluaran turun signifikan dibanding bulan lalu |
| Prediksi saldo mendekati negatif | Hanya jika proyeksi benar-benar berisiko |

**Rate limiting:** maksimal **1 insight proaktif utama per hari** di Dashboard (agar tidak terasa cerewet), kecuali kondisi kritis (mis. proyeksi saldo minus) yang boleh muncul kapan pun relevan. Insight sekunder lainnya masuk ke Insight Feed (tidak push notification), bisa dilihat kapan saja pengguna membuka tab AI Advisor.

### Kapan AI Menunggu (reaktif, hanya saat diminta)

| Situasi | Penjelasan |
|---|---|
| Pertanyaan bebas ("Kalau aku nabung 500rb/bulan, kapan bisa beli laptop baru?") | AI hanya menjawab saat user bertanya lewat "Tanya AI" |
| Simulasi skenario ("what-if") | Butuh input eksplisit dari user |
| Deep-dive analysis suatu kategori | User tap kategori tertentu untuk breakdown detail |
| Perbandingan custom (mis. bulan ini vs 3 bulan lalu) | Inisiatif eksplorasi user |

### Escalation Level (nada insight, bukan urgensi visual berlebihan)

| Level | Warna Aksen | Contoh |
|---|---|---|
| **Informative** (default) | Golden Amber (netral-positif) | Ringkasan rutin, progres |
| **Cautionary** | Burnt Orange (lebih pekat, tetap warm) | Budget 80–99%, tren naik signifikan |
| **Important** (bukan "alarm") | Charcoal Black dengan aksen tegas, teks tetap tenang | Proyeksi saldo negatif, tagihan H-1 |

> Catatan desain: tidak ada warna merah mencolok khas fintech konvensional — semua level tetap dalam palet warm brand agar brand personality "calm, tidak menghakimi" konsisten bahkan saat menyampaikan peringatan.
