# WMS Mobile - Log Filtering Guide

## Masalah

Log `gralloc4` dari Android system terlalu banyak dan menutupi log aplikasi WMS kita.

## Solusi: 3 Script PowerShell

### 📝 Script 1: `filter-wms-logs.ps1` (Live Filter)

**Fungsi:** Filter dan tampilkan HANYA log WMS dengan warna

**Cara Pakai:**

```powershell
cd D:\WORKSPACE\PROJECT\WMS\wms_mobile
.\filter-wms-logs.ps1
```

**Hasil:**

-   ✅ Hanya log WMS yang tampil
-   ✅ Warna berbeda per layer (Green=UI, Yellow=Provider, Cyan=Service)
-   ✅ Error merah, Success hijau
-   ❌ Log gralloc4 dan system noise TIDAK tampil

---

### 💾 Script 2: `filter-and-save-logs.ps1` (Filter + Save)

**Fungsi:** Filter log WMS, tampilkan DAN simpan ke file

**Cara Pakai:**

```powershell
cd D:\WORKSPACE\PROJECT\WMS\wms_mobile
.\filter-and-save-logs.ps1
```

**Hasil:**

-   ✅ Log WMS ditampilkan dengan warna
-   ✅ Auto-save ke file: `wms-logs-20251206-195530.txt`
-   ✅ Bisa review log nanti tanpa scroll
-   ✅ File bisa dibuka dengan Notepad/VS Code

**File Output Contoh:**

```
wms-logs-20251206-195530.txt
wms-logs-20251206-200145.txt
```

---

### 📡 Script 3: `view-wms-logs.ps1` (Live Logcat)

**Fungsi:** Monitor log LANGSUNG dari device (tanpa flutter run ulang)

**Cara Pakai:**

```powershell
cd D:\WORKSPACE\PROJECT\WMS\wms_mobile

# Jika app sudah running, jalankan ini di terminal TERPISAH
.\view-wms-logs.ps1
```

**Kegunaan:**

-   ✅ Tidak perlu run ulang app
-   ✅ Monitor log saat app sudah jalan
-   ✅ Lebih cepat karena langsung dari device
-   ✅ Press Ctrl+C untuk stop

---

## 🎨 Color Coding

| Warna      | Log Type    | Contoh                                                   |
| ---------- | ----------- | -------------------------------------------------------- |
| **Green**  | UI Layer    | `[WMS-UI-LOGIN]` `[WMS-UI-ADDITEM]` `[WMS-UI-DASHBOARD]` |
| **Yellow** | Provider    | `[WMS-PROVIDER]` `[WMS-AUTH-PROVIDER]`                   |
| **Cyan**   | Service/API | `[WMS-SERVICE]` `[WMS-AUTH-SERVICE]`                     |
| **Red**    | Error       | `❌ ERROR` `Failed`                                      |
| **Green**  | Success     | `✅ SUCCESS` `successful`                                |
| **Gray**   | Separator   | `════════════════`                                       |

---

## 📋 Cara Kerja Script

### Script menggunakan `Select-String` untuk filter:

```powershell
flutter run --hot | Select-String -Pattern "WMS-|═════"
```

**Pattern yang di-filter:**

-   `WMS-` → Semua log dengan prefix WMS-
-   `═════` → Separator garis

**Yang DIBUANG:**

-   `gralloc4` → Graphics allocator Android
-   `libc` → System library logs
-   `BLASTBufferQueue` → Graphics buffer
-   `OpenGLRenderer` → Renderer logs
-   Dan semua system noise lainnya

---

## 🚀 Quick Start

**Rekomendasi: Gunakan Script 2 (Save to File)**

1. **Buka PowerShell** di folder wms_mobile

    ```powershell
    cd D:\WORKSPACE\PROJECT\WMS\wms_mobile
    ```

2. **Jalankan script filter & save**

    ```powershell
    .\filter-and-save-logs.ps1
    ```

3. **Test aplikasi** seperti biasa:

    - Login
    - Create item
    - View dashboard
    - dll

4. **Review log** nanti:
    ```powershell
    notepad wms-logs-*.txt
    # atau
    code wms-logs-*.txt
    ```

---

## 💡 Tips

### Jika Flutter Run Error:

```powershell
# Gunakan script 3 untuk monitor log
# Di terminal 1: run app normal
flutter run --hot

# Di terminal 2: monitor log
.\view-wms-logs.ps1
```

### Mencari Log Tertentu:

```powershell
# Cari log login
Get-Content wms-logs-*.txt | Select-String "WMS-UI-LOGIN"

# Cari error saja
Get-Content wms-logs-*.txt | Select-String "❌|ERROR"

# Cari log dari provider
Get-Content wms-logs-*.txt | Select-String "WMS-PROVIDER"
```

### Clear Old Logs:

```powershell
# Hapus log lama (opsional)
Remove-Item wms-logs-*.txt
```

---

## 📊 Contoh Output

**Tanpa Filter (Berantakan):**

```
I/gralloc4(729): @set_metadata: update dataspace...
I/gralloc4(729): @set_metadata: update dataspace...
I/gralloc4(729): @set_metadata: update dataspace...
[WMS-PROVIDER] | fetchItems called  ← Susah diliat!
I/gralloc4(729): @set_metadata: update dataspace...
I/gralloc4(729): @set_metadata: update dataspace...
```

**Dengan Filter (Bersih):**

```
════════════════════════════════════════════════
[WMS-PROVIDER] 2025-12-06 20:00:01 | 🔄 fetchItems called
[WMS-PROVIDER] 2025-12-06 20:00:01 | ✓ Service initialized
[WMS-PROVIDER] 2025-12-06 20:00:01 | ⏳ State set to loading
════════════════════════════════════════════════
[WMS-SERVICE] 2025-12-06 20:00:01 | 🌐 getItems API called
[WMS-SERVICE] 2025-12-06 20:00:01 | 📨 Response received!
════════════════════════════════════════════════
```

**Jauh lebih mudah dibaca!** 🎉

---

## ⚠️ Troubleshooting

### Script tidak jalan:

```powershell
# Enable execution policy
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

### ADB tidak ditemukan:

```powershell
# Pastikan adb ada di PATH atau gunakan full path
C:\Users\YourUser\AppData\Local\Android\Sdk\platform-tools\adb.exe logcat ...
```

### Log masih berantakan:

-   Gunakan Script 2 (save to file)
-   Review file text, lebih mudah dibaca
-   Atau gunakan VS Code untuk buka file log

---

## 📁 File Structure

```
wms_mobile/
├── filter-wms-logs.ps1           # Live filter
├── filter-and-save-logs.ps1      # Filter + save
├── view-wms-logs.ps1             # Monitor logcat
├── wms-logs-20251206-195530.txt  # Output log (auto)
└── WMS_LOG_GUIDE.md              # Guide ini
```

---

**Selamat debugging dengan log yang bersih!** 🚀
