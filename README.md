# 🌾 TarlaTakip - Akıllı Tarım Asistanı

**TarlaTakip**, çiftçilerin ve tarım profesyonellerinin tarlalarını dijital ortamda yönetmelerini, hava durumunu anlık takip etmelerini ve tarımsal faaliyetlerini planlamalarını sağlayan kapsamlı bir **Flutter** mobil uygulamasıdır.

---

## 🚀 Özellikler

* **📍 Tarlalarım:** Tüm tarlalarınızı harita üzerinde işaretleyin, alanlarını ve ekili ürünlerini kaydedin.
* **☁️ Anlık Hava Durumu:** Tarlalarınızın konumuna özel, tarımsal faaliyetleri etkileyebilecek anlık hava durumu verileri.
* **🗺️ İnteraktif Harita:** Google Maps API desteği ile tarlalarınızı görselleştirin ve konum tabanlı işlem yapın.
* **🔔 Bildirim Sistemi:** Sulama, ilaçlama ve hasat zamanlarını hatırlatan akıllı bildirimler.
* **💾 Çevrimdışı Destek:** Hive veritabanı sayesinde internet olmasa bile verilerinize erişin.

---

## 🛠 Kullanılan Teknolojiler

* **Framework:** [Flutter](https://flutter.dev/)
* **Veritabanı:** [Hive](https://pub.dev/packages/hive) (Local Storage)
* **Harita Hizmeti:** Google Maps Flutter
* **API:** OpenWeatherMap API

---

## ⚙️ Kurulum ve Çalıştırma

1.  **Projeyi Klonlayın:**
    ```bash
    git clone [https://github.com/hasantopal53/TarlaTakip.git](https://github.com/hasantopal53/TarlaTakip.git)
    ```
2.  **Bağımlılıkları Yükleyin:**
    ```bash
    flutter pub get
    ```
3.  **API Yapılandırması:**
    * `android/app/src/main/AndroidManifest.xml` dosyasındaki `YOUR_GOOGLE_MAPS_API_KEY` alanına kendi anahtarınızı ekleyin.
    * Hava durumu servisi dosyasındaki `YOUR_OPENWEATHERMAP_API_KEY` alanına kendi API anahtarınızı tanımlayın.
4.  **Çalıştırın:**
    ```bash
    flutter run
    ```

---

## 📄 Lisans

Bu proje **MIT Lisansı** ile lisanslanmıştır.
