# MovieDB – Aplikasi Katalog Film (SwiftUI)

Aplikasi iOS untuk menelusuri dan mengelola katalog film menggunakan **The Movie Database (TMDB) API**. Dibangun dengan SwiftUI, mengikuti arsitektur **MVVM** dan pola **Repository** dengan cache lokal (Core Data).

---

## Ringkasan Kode & Fitur

| Aspek | Keterangan |
|-------|------------|
| **Platform** | iOS 14.0 |
| **Bahasa & UI** | Swift 5, SwiftUI |
| **Arsitektur** | MVVM + Repository (cache-first) |
| **Data** | TMDB API, Core Data (favorit + cache detail/daftar film) |
| **Dependensi** | Kingfisher (gambar), RxSwift (paket) |

**Fitur yang tersedia:**

- **Tab Film Populer** – Daftar film populer dengan infinite scroll dan refresh.
- **Tab Pencarian** – Cari film dengan debounce; hasil dalam grid.
- **Tab Terbaru** – Film dari discover API dengan infinite scroll dan pull-to-refresh.
- **Tab Favorit** – Daftar film favorit tersimpan di Core Data; bisa tambah/hapus dari detail film.
- **Detail Film** – Tab About (info, genre, durasi), Reviews, Trailer (YouTube); tombol favorit di toolbar.
- **Cache** – Halaman daftar film dan detail (termasuk reviews & videos) di-cache lokal untuk performa dan penggunaan offline terbatas.
- **Error handling** – Pesan error dan saran pemulihan (mis. “Coba lagi”, “Cek koneksi”) lewat `AppError`.
- **Testing** – Unit test (ViewModel, NetworkService) dan UI test.

---

## i. Langkah-langkah Menjalankan Aplikasi

1. **Clone repositori**
   ```bash
   git clone https://github.com/yourusername/MovieDB.git
   cd MovieDB
   ```

2. **Buka proyek di Xcode**
   - Buka `MovieDB.xcodeproj` dengan Xcode 15+ (sesuai iOS 17.2).

3. **Resolve dependensi**
   - Xcode akan otomatis fetch Swift Package (Kingfisher, RxSwift). Jika belum, gunakan **File → Packages → Resolve Package Versions**.

4. **API Key TMDB**
   - API key sudah ada di `MovieDB/Utilities/Constants.swift`. Untuk production, disarankan pindah ke `xcconfig` atau environment agar tidak ikut di-repo.

5. **Jalankan di simulator atau perangkat**
   - Pilih target **MovieDB** dan device/simulator iOS 17.2+, lalu tekan **Run** (⌘R).

---

## ii. Pendekatan Pembuatan Aplikasi

- **MVVM** – Setiap layar utama punya ViewModel (`MovieListViewModel`, `PopularMoviesViewModel`, `SearchMoviesViewModel`, `MovieDetailViewModel`) yang mengelola state dan pemanggilan data; View hanya menampilkan UI dan meneruskan aksi.
- **Repository** – `MovieRepository` mengimplementasikan `MovieRepositoryProtocol` dengan strategi **cache-first**: baca dari Core Data dulu, jika tidak ada atau kadaluarsa baru memanggil `NetworkService` dan menyimpan hasil ke cache.
- **Lapisan jaringan** – `NetworkService` (protocol + implementasi) menangani semua panggilan TMDB (popular, discover, search, detail, reviews, videos) dengan `async/await` dan error mapping ke `AppError`.
- **Persistence** – Core Data dipakai untuk: (1) daftar favorit (`FavoritesStore`), (2) cache halaman daftar film, (3) cache detail film beserta reviews dan videos agar akses ulang cepat dan mengurangi API call.
- **UI** – SwiftUI dengan `NavigationStack`, `TabView`, grid (LazyVGrid), `searchable`, `refreshable`; gambar poster/backdrop via **Kingfisher** dengan placeholder.

Dengan pendekatan ini, aplikasi tetap terstruktur, mudah di-test (ViewModel dan NetworkService di-inject), dan nyaman dipakai dengan cache dan favorit lokal.

---

## iii. Keunggulan / Fitur Utama

1. **Empat sumber daftar film** – Film populer, pencarian, dan film terbaru (discover) di tab terpisah; plus tab Favorit untuk koleksi pribadi.
2. **Detail film lengkap** – Sinopsis, rating, durasi, genre, tanggal rilis; tab terpisah untuk ulasan (reviews) dan trailer YouTube.
3. **Favorit persisten** – Simpan dan hapus favorit dari layar detail; data tersimpan di Core Data dan tampil di tab Favorit.
4. **Cache cerdas** – Cache untuk daftar film per halaman dan untuk detail film (termasuk reviews & videos) agar loading cepat dan mengurangi penggunaan API.
5. **Pengalaman pengguna** – Infinite scroll, pull-to-refresh, pencarian dengan debounce, empty state dan error state yang informatif dengan saran pemulihan.
6. **Kualitas kode** – Pemisahan jelas antara View, ViewModel, Repository, dan Network; protocol untuk dependency injection; error handling terpusat; dilengkapi unit test dan UI test.

---

## Struktur Proyek (ringkas)

```
MovieDB/
├── MovieDBApp.swift          # Entry point
├── ContentView.swift         # TabView (Populer, Pencarian, Terbaru, Favorit)
├── Views/                    # MovieListView, PopularMoviesView, SearchMoviesView, FavoritesView, MovieDetailView
├── ViewModels/               # ViewModel per layar
├── Repositories/             # MovieRepository + protocol (cache + API)
├── Services/                 # NetworkService, FavoritesStore
├── Models/                   # Movie, MovieDetail, Review, Video, dll.
├── Utilities/                # Constants, AppError, CacheConstants
├── Extensions/               # ImageLoader
├── Persistence.swift         # Core Data stack
└── MovieDB.xcdatamodeld      # Model Core Data (FavoriteMovie, cache entities)
```

---

## Requirements

- **iOS** 17.2+
- **Xcode** 15+ (disarankan)
- **Swift** 5.x
- Koneksi internet untuk mengambil data dari TMDB (setelah cache, akses ulang bisa dari cache).

---

## Lisensi

Proyek ini untuk keperluan edukasi/demo. Penggunaan TMDB API tunduk pada [kebijakan TMDB](https://www.themoviedb.org/documentation/api/terms-of-use).
