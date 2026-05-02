# 🌾 TarlaTakip - Smart Agriculture Assistant

[![English](https://img.shields.io/badge/Language-English-blue.svg)](#-tarlatakip---smart-agriculture-assistant) 
[![Türkçe](https://img.shields.io/badge/Dil-Türkçe-red.svg)](#-tarlatakip---akıllı-tarım-asistanı)

> [!TIP]
> **🇹🇷 Türkçe okumak için sayfanın altına inebilir veya yukarıdaki Türkçe etiketine tıklayabilirsiniz.**

**TarlaTakip** is a comprehensive **Flutter** mobile application that enables farmers and agricultural professionals to manage their fields digitally, track real-time weather conditions, and plan agricultural activities efficiently.

---

## 🚀 Features

* **📍 My Fields:** Mark all your fields on the map, record their areas, and cultivated crops.
* **☁️ Real-time Weather:** Localized weather data for your specific field locations that may affect agricultural activities.
* **🗺️ Interactive Map:** Visualize your fields and perform location-based operations with Google Maps API support.
* **🔔 Notification System:** Smart notifications reminding you of irrigation, spraying, and harvest times.
* **💾 Offline Support:** Access your data even without an internet connection, thanks to the Hive database.

---

## 🛠 Tech Stack

* **Framework:** [Flutter](https://flutter.dev/)
* **Database:** [Hive](https://pub.dev/packages/hive) (Local Storage)
* **Map Service:** Google Maps Flutter
* **API:** OpenWeatherMap API

---

## ⚙️ Installation & Setup

1.  **Clone the Project:**
    ```bash
    git clone [https://github.com/hasantopal53/TarlaTakip.git](https://github.com/hasantopal53/TarlaTakip.git)
    ```
2.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```
3.  **API Configuration:**
    * Add your own API key to the `YOUR_GOOGLE_MAPS_API_KEY` field in `android/app/src/main/AndroidManifest.xml`.
    * Define your API key in the `YOUR_OPENWEATHERMAP_API_KEY` field within the weather service file.
4.  **Run the App:**
    ```bash
    flutter run
    ```

---

## 📄 License

This project is licensed under the **MIT License**.

<br>
<br>

---

# 🇹🇷 🌾 TarlaTakip - Akıllı Tarım Asistanı

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
