# TarlaTakip — Sunum planı (MCBÜ şablonu)

Bu dosya `Proje_Sunum_Şablonu.pdf` ile birlikte kullanılır. PowerPoint’te şablonu açıp aşağıdaki metinleri slaytlara yapıştırın; **ekran görüntülerini (SS)** işaretli yerlere ekleyin.

**GitHub:** https://github.com/hasantopal53/TarlaTakip

---

## Şablon hakkında (önemli)

Üniversite şablonu **8 slayt**. Ders sunumu için **12–15 slayt** hedefleniyorsa:

1. PowerPoint’te şablonu `.pptx` olarak açın (PDF’den “PowerPoint’e dönüştür” veya şablonun orijinal PPTX’i varsa onu kullanın).
2. **Slayt 3** (boş bölüm) ve **Slayt 4** (görsel alan) ve **Slayt 7** (boş) slaytlarını **çoğaltın** — ekran görüntüleri ve mimari için.
3. Üst bilgi (logo, fakülte) şablonda kalır; sadece gövde metnini değiştirin.

**Ekran görüntüsü (SS) nasıl eklenir?**

- Emülatör veya telefonda uygulamayı açın → istenen ekran → `Ctrl+S` veya Android Studio **Camera** ikonu.
- PowerPoint: **Ekle → Resimler → Bu cihaz** → slayttaki boş alana veya “Figür” slaydına sürükleyin.
- Altına şablondaki gibi yazın: `Şekil 1. Ana sayfa — tarla seçimi ve hava kartı`
- 7 ekran için en az **4–6 SS** yeterli (Ana sayfa, Harita, Tarlalar, Maliyet veya Görev, Hava, Ayarlar).

---

## Slayt eşlemesi (8 slayt şablon → 14 slayt öneri)

| # | Şablon slaytı | TarlaTakip konusu |
|---|----------------|-------------------|
| 1 | Kapak | Proje adı, ders, öğrenci, danışman |
| 2 | Proje organizasyonu | Sunum akışı (içindekiler) |
| 3 | Bölüm başlığı | Problem ve çözüm |
| 4 | Görsel / figür | **[SS] Ana sayfa** veya mimari diyagram |
| 5 | Grafik | İsteğe bağlı: maliyet kategorileri (yoksa tablo slaytına kaydır) |
| 6 | Tablo | Hoca isterleri karşılama tablosu |
| 7 | Boş | **[SS] Harita + Tarlalar** (2 resim yan yana) |
| 8 | Kaynakça | GitHub + API kaynakları |

**Ek slaytlar (3, 4, 7 kopyaları):** Teknoloji, Mimari, UI bileşenleri, API, Hive+Provider, Harita+Bildirim, Demo planı, Sonuç.

---

## Slayt 1 — Kapak (şablon slayt 1)

**Sunum Başlığı:** TarlaTakip — Akıllı Tarım Asistanı  

**Kod - Ders Adı:** [Ders kodunuz] — Mobil Programlama  

**Numara, Ad-Soyad:** [Öğrenci no] — [Ad Soyad]  

**Danışman:** [Danışman adı]  

**Fakülte, Bölüm:** Manisa Celal Bayar Üniversitesi — [Bölümünüz]  

**202…:** 2025–2026 (veya güncel dönem)

**Konuşmacı notu:** Tek cümle: Flutter ile geliştirilmiş, tarla/hava/maliyet/görev takibi yapan mobil uygulama.

---

## Slayt 2 — Proje organizasyonu (şablon slayt 2)

1. Problem ve çözüm  
2. Kullanılan teknolojiler  
3. Uygulama mimarisi  
4. Ekranlar ve arayüz bileşenleri  
5. Hoca isterlerinin karşılanması  
6. Harita, bildirim ve API entegrasyonu  
7. Canlı demo ve sonuç  
8. Kaynak kod (GitHub)

---

## Slayt 3 — Problem ve çözüm

**Bölüm Başlığı:** Problem ve çözümümüz

**Problem**

- Tarla, maliyet, görev ve hava bilgisi dağınık (defter, farklı uygulamalar).
- Küçük/orta ölçekli çiftçi için tek mobil çözüm ihtiyacı.

**Çözüm — TarlaTakip**

- Tarlaları haritada gösterme ve kayıt (CRUD).
- OpenWeatherMap ile anlık hava ve 5 günlük tahmin; sulama önerisi.
- Maliyet ve görev takibi; görev günü yerel bildirim.
- Veriler cihazda (Hive); internet olmadan kayıtlar okunur.

**Konuşmacı notu:** Hedef kullanıcı çiftçi; arayüz Türkçe.

---

## Slayt 4 — Teknoloji yığını

**Bölüm Başlığı:** Kullanılan teknolojiler

| Katman | Teknoloji |
|--------|-----------|
| Framework | Flutter (Dart), Material Design 3 |
| State | Provider |
| Yerel veri | Hive (tarla, maliyet, görev) |
| Harita / konum | google_maps_flutter, geolocator |
| Ağ | http → OpenWeatherMap REST |
| Bildirim | flutter_local_notifications |
| Android derleme | Gradle (Kotlin DSL) |
| Geliştirme | Android Studio, Git/GitHub |

**Konuşmacı notu:** Dart kodu Flutter ile derlenir; APK Gradle ile oluşur.

---

## Slayt 5 — Mimari (metin veya diyagram — Figür slaytı uygun)

**Grafik Başlığı:** Uygulama mimarisi

Aşağıdaki metni slayta kutu diyagramı olarak yerleştirin veya basit şekil ile çizin:

```
[Kullanıcı]
      ↓
[Flutter UI — 7 ekran]
      ↓
[Provider — state]
      ↓
┌─────────────────────┬──────────────────────┐
│ Hive (cihaz)        │ OpenWeatherMap API   │
│ tarla / maliyet /   │ Google Maps API      │
│ görev               │ GPS (geolocator)     │
└─────────────────────┴──────────────────────┘
```

**Şekil 1.** TarlaTakip katmanlı mimari

---

## Slayt 6–7 — Ekranlar (SS slaytları)

**Bölüm Başlığı:** Uygulama ekranları (1/2)

- **[EKRAN GÖRÜNTÜSÜ]** Ana sayfa — tarla çipleri, hava, sulama, görev özeti  
- **[EKRAN GÖRÜNTÜSÜ]** Harita — marker, uzun bas ile tarla  

**Bölüm Başlığı:** Uygulama ekranları (2/2)

- **[EKRAN GÖRÜNTÜSÜ]** Tarlalar — liste / form  
- **[EKRAN GÖRÜNTÜSÜ]** Maliyetler veya Görevler  
- **[EKRAN GÖRÜNTÜSÜ]** Hava durumu — tahmin sekmesi  
- **[EKRAN GÖRÜNTÜSÜ]** Ayarlar — izinler  

**Konuşmacı notu:** Yedi ayrı ekran; alt menüde 5 sekme, hava ve ayarlar yan menüden.

---

## Slayt 8 — UI bileşenleri

**Bölüm Başlığı:** Kullanılan arayüz bileşenleri

Scaffold, AppBar / SliverAppBar, NavigationBar (5 sekme), Drawer, ListView, Card, TextField, FloatingActionButton, TabBar, ModalBottomSheet, RefreshIndicator, Row/Column, Consumer (Provider).

**Konuşmacı notu:** Derste işlenen layout şartının üzerinde çeşitlilik.

---

## Slayt 9 — Hoca isterleri (şablon slayt 6 — TABLO)

**Tablo 1.** Mobil programlama dönem projesi isterleri

| İster | Puan | Durum | Projede karşılık |
|-------|------|--------|------------------|
| En az 5 farklı ekran tasarımı | 20 | Karşılanıyor | 7 ekran: Ana, Harita, Tarlalar, Maliyet, Görev, Hava, Ayarlar |
| En az 5 layout/UI elemanı | 20 | Karşılanıyor | Scaffold, AppBar, NavigationBar, Drawer, ListView, Card, FAB, TabBar, BottomSheet, … |
| İleri özellik: harita + bildirim | 20 | Karşılanıyor | Google Maps; görev tarihi yerel bildirim (08:00) |
| Servisten veri, UI’da gösterme | 20 | Karşılanıyor | OpenWeatherMap → WeatherService → WeatherProvider → kartlar |
| Ek ister (2×10) | 20 | ≥2 madde | (1) Hive + Provider (2) Konum/GPS (3) pubspec/Gradle kütüphaneleri, Git |

**Konuşmacı notu:** Ek isterde medya oynatıcı ve ML yok; bunu dürüstçe söyleyebilirsiniz.

---

## Slayt 10 — Harita ve bildirim

**Bölüm Başlığı:** İleri özellikler

**Harita:** Google Maps; tarlalar marker; uzun basarak konum seçimi; “Konumum” ile GPS.

**Bildirim:** Görev tarihinde `flutter_local_notifications`; ayarlardan izin.

---

## Slayt 11 — API entegrasyonu

**Bölüm Başlığı:** OpenWeatherMap API

- REST + JSON → `WeatherService` → `WeatherProvider` → UI  
- Ana sayfada hava, **seçilen tarlanın koordinatına** göre  
- Nem/rüzgar/sıcaklık; sulama önerisi mantığı arayüzde  

**Konuşmacı notu:** Emülatör GPS ABD gösterebilir; ana sayfa tarla koordinatını kullanır.

---

## Slayt 12 — Hive, Provider, konum

**Bölüm Başlığı:** Yerel veri ve ekranlar arası paylaşım

- Hive: `fields`, `costs`, `tasks` kutuları  
- Provider: Field, Cost, Task, Weather, Navigation  
- Harita / maliyet / görev / ana sayfa aynı tarla listesini kullanır  
- Geolocator + permission_handler  

---

## Slayt 13 — Canlı demo planı (5–6 dk)

1. Uygulamayı emülatörde çalıştır (Run).  
2. Ana sayfa: Tarla1 / Tarla2 seç → hava + sulama + görevler.  
3. Harita: marker, kısa uzun bas.  
4. Tarlalar: bir kayıt göster.  
5. Maliyet veya Görev: kısa liste.  
6. Menü → Hava: tahmin sekmesi.  
7. Son: GitHub linki (ayrı dosya teslim yok).

**Demo öncesi kontrol listesi**

- [ ] En az 2 tarla koordinatlı (ör. Fethiye civarı) — Tarla1, Tarla2  
- [ ] En az 1 yaklaşan görev (bildirim göstermek için)  
- [ ] Emülatörde internet açık  
- [ ] Harici servis bağlantıları (hava, harita) yapılandırılmış  
- [ ] SS’ler sunuma eklenmiş  

---

## Slayt 14 — Sonuç ve gelecek

**Bölüm Başlığı:** Sonuç ve gelecek çalışmalar

**Sonuç:** TarlaTakip, çiftçinin tarla, maliyet, görev ve hava ihtiyacını tek uygulamada toplar; ders isterlerini karşılar.

**Gelecek (opsiyonel slayt):** Bulut senkron, kullanıcı hesabı, hasat verimi grafikleri, cihaz takvimi entegrasyonu.

**Kısıtlar (dürüst):** Medya oynatıcı yok; ML yok; rehber API yok; harici servis ayarları geliştirme ortamında.

---

## Slayt 15 — Kaynakça (şablon slayt 8)

[1] Proje kaynak kodu: https://github.com/hasantopal53/TarlaTakip  

[2] Flutter: https://docs.flutter.dev  

[3] OpenWeatherMap API: https://openweathermap.org/api  

[4] Google Maps Platform: https://developers.google.com/maps  

---

## Claude / AI’ya verilecek kısa komut (kopyala-yapıştır)

Şablonu doldurduktan sonra ek slayt metni isterseniz:

> Aşağıdaki SUNUM_PLANI.md içeriğine göre Türkçe 14 slaytlık sunum metni üret. Her slaytta: başlık, 4–6 madde, konuşmacı notu. [GITHUB: https://github.com/hasantopal53/TarlaTakip]. Cursor/AI kullanımından bahsetme.

---

*Son güncelleme: proje kodu ile uyumlu (lib/ altında 7 ekran, Provider, Hive, harita, bildirim, hava API).*
