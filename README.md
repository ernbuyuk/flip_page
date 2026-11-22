# FlipPage

FlipPage, soru-cevap mantığıyla çalışan dijital not kartları (flashcard) ile kalıcı öğrenmeyi hedefleyen bir Android uygulamasıdır. Flutter ile geliştirilmiştir.

Kartın ön yüzüne soruyu, arka yüzüne cevabı yazarsınız; uygulama her kartı ne zaman tekrar etmeniz gerektiğini **aralıklı tekrar** ile hesaplar, kartları **sesli okuyabilir** ve tamamen **çevrimdışı** çalışır.

[![Google Play'de Dene](https://img.shields.io/badge/Google%20Play-FlipPage-34A853?style=for-the-badge&logo=googleplay&logoColor=white)](https://play.google.com/store/apps/details?id=com.bg.flip_page)

https://play.google.com/store/apps/details?id=com.bg.flip_page

**Güncel sürüm:** 1.3.0 (5) · **Hedef API:** 36 (Android 16) · **Minimum:** Android 7.0 (API 24)

## Özellikler

### 🔁 Aralıklı Tekrar
- Çalışma modu varsayılan olarak sadece **tekrar zamanı gelen** kartları getirir.
- Bilinen kartın aralığı büyür: 1 gün → 3 gün → ~1 hafta → … (en fazla 1 yıl). Bilinmeyen kart aynı gün tekrar gelir ve daha sık gösterilir.
- Ana sayfada **"Bugün N tekrar"** rozeti; dokununca bugünkü kartlarla çalışma başlar.
- Notlarım'daki Çalışma Modu butonunda klasörün tekrar sayısı görünür.
- Bugünkü kartlar bitince "Bugünlük bu kadar!" ekranı ve sıradaki tekrar günü gösterilir; istenirse tüm kartlar yine de çalışılabilir.

### 🔊 Sesli Okuma
- Kartlardaki hoparlör butonu yazıyı telefonun metin okuma (TTS) motoruyla okur; okurken tekrar basınca durur.
- **Ayarlar > Sesli Okuma**: ön ve arka yüz için ayrı dil (Türkçe, İngilizce, Almanca, Fransızca, İspanyolca, İtalyanca, Rusça, Arapça, Japonca), okuma hızı ve "çalışırken otomatik oku".
- Seçilen dilin ses paketi telefonda yoksa uygulama çökmez, nereden indirileceğini söyler.

### 🎨 Renkli Kart Temaları
- 7 tema: **Klasik, Fikir, Sevgi, Okul, Doğa, Önemli, Hayal**.
- Seçilen tema kartın tamamını, süslü çerçevesini ve filigran simgesini değiştirir; yeni not, not listesi, çalışma modu ve aramada aynı tasarım kullanılır.

### 📚 Çalışma Modu
- Kartı çevir, "Biliyorum" / "Bilmiyorum" de. Puan kartın ilk cevabıyla hesaplanır.
- Bilinmeyen kartlar tur sonunda **bir kez** tekrar gösterilir; oturum her zaman sonuç ekranıyla biter.
- Seçenekler (⋮): sadece bugünkü tekrarlar, kartları otomatik oku, önce zor kartlar, cevaptan başla.
- Sonuç ekranı: doğru, yanlış, başarı oranı ve tekrarda öğrenilen kartlar.

### 📝 Not ve Klasör Yönetimi
- Not oluşturma, düzenleme, silme (onaylı) ve paylaşma.
- Not yazarken renk ve klasör seçimi; kaydedilmemiş not varken geri tuşunda uyarı.
- Klasör oluşturma, yeniden adlandırma ve not sayıları. Klasör silinirken notlar varsayılana taşınabilir ya da birlikte silinebilir.
- Karışık mod: tüm notlar karışık sırayla. Kartlar kaydırılarak gezilir, dokunarak çevrilir.

### 🔍 Arama ve İstatistikler
- Ön yüz, arka yüz veya klasör adına göre arama.
- İstatistikler: not ve klasör sayısı, çalışılan kartlar, başarı oranı, bugünkü tekrarlar, öğrenilen kartlar (21+ gün aralık), klasör dağılımı ve en çok zorlanılan kartlar.

### 💾 Yedekleme
- Tüm notlar ve klasörler JSON olarak dışa aktarılır ve geri yüklenir. Tekrar zamanlaması da yedeğe dahildir.
- İçe aktarırken aynı notlar tekrar eklenmez.

### 🌙 Görünüm ve Uyum
- Karanlık mod ve el yazısı dahil farklı yazı tipleri.
- Küçük ekranlı telefonlardan tabletlere kadar butonlar kaydırma gerektirmeden görünür; çentik, 3 tuşlu gezinme ve büyük sistem yazı boyutu desteklenir.

## Kullanım

### Not oluşturma
1. Ana sayfada **Yeni Not**'a dokunun.
2. Üstten kart temasını ve klasörü seçin.
3. Ön yüze soruyu yazın, **Sayfayı Çevir** ile arka yüze cevabı yazın.
4. **Notu Kaydet**.

### Çalışma
1. Ana sayfadaki **"Bugün N tekrar"** rozetine ya da **Notlarım > Çalışma Modu**'na dokunun.
2. Soruyu okuyun, **Cevabı Göster** ile kartı çevirin. Hoparlöre basarak dinleyebilirsiniz.
3. **Biliyorum** veya **Bilmiyorum** seçin. Uygulama kartın bir sonraki tekrar gününü planlar.

### Sesli okuma ayarı
**Ayarlar > Sesli Okuma**. Örneğin İngilizce kelime çalışırken ön yüz dilini "İngilizce", arka yüz dilini "Türkçe" yapın.

### Yedekleme
**Ayarlar > Notları Dışa Aktar** ile yedek alın, **Notları İçe Aktar** ile geri yükleyin.

> ⚠️ Notlar telefonda saklanır ve uygulama kaldırılınca silinir. Düzenli olarak yedek alın.

## Proje Yapısı

| Dosya | Görevi |
|---|---|
| `lib/main.dart` | Uygulama girişi, ana sayfa, `SafeLayout` (sistem çubuklarına göre güvenli alan), "Bugün N tekrar" rozeti |
| `lib/note_storage.dart` | Notların tek erişim noktası (id'li kayıt, klasör işlemleri) ve `SpacedRepetition` zamanlaması |
| `lib/note_card.dart` | Renkli kart tasarımı (`NoteCard`), etiket ve renk seçici |
| `lib/speech_service.dart` | Sesli okuma servisi, ayarları ve hoparlör butonu |
| `lib/new_note_page.dart` | Not oluşturma/düzenleme |
| `lib/my_notes_page.dart` | Kart listesi (kaydır/çevir), düzenleme modu |
| `lib/study_mode_page.dart` | Çalışma modu |
| `lib/folder_page.dart` | Klasörler |
| `lib/statistics_page.dart`, `lib/search_page.dart`, `lib/settings_page.dart` | İstatistik, arama, ayarlar |
| `lib/export_import_helper.dart` | JSON yedekleme ve istatistik hesapları |
| `lib/theme_provider.dart` | Tema, yazı tipi ve kart renk paleti |
| `assets/card_frame.png` | Kart çerçevesi (şeffaf, temaya göre renklendirilir) |

### Not veri biçimi
Notlar `SharedPreferences` içinde JSON olarak tutulur:

```json
{
  "id": "…", "frontText": "Apple", "backText": "Elma",
  "folder": "İngilizce", "color": "green",
  "correctCount": 3, "wrongCount": 1, "lastReviewedAt": "…",
  "interval": 3, "ease": 2.55, "dueAt": "2026-11-25T00:00:00.000"
}
```

`id` olmayan eski notlara ilk açılışta otomatik id atanır; `dueAt` olmayan notlar hemen çalışılabilir sayılır.

## Geliştirme

### Gereksinimler
- Flutter 3.38+ (stable)
- JDK 17
- Android SDK: platform 36, build-tools 36.0.0, NDK 28.2.13676358, CMake 3.22.1

### Çalıştırma
```bash
flutter pub get
```
```bash
flutter run
```

### Bağımlılıklar
- `shared_preferences`: yerel veri saklama
- `flutter_tts`: sesli okuma
- `file_picker`, `path_provider`: yedek dosyası seçme/kaydetme
- `share_plus`: not ve yedek paylaşma
- `intl`: tarih biçimleri

### Testler
```bash
flutter test
```

92 test şunları doğrular:
- **Ekran uyumu:** 7 cihaz profilinde (320x568 küçük ekran, çentikli, 3 tuşlu gezinme, %130–150 yazı boyutu, klavye açık, tablet yatay) tüm sayfalar taşmadan çizilir ve ana butonlar kaydırmadan görünür.
- **Veri doğruluğu:** id ataması, doğru notun düzenlenmesi/silinmesi, klasör taşıma ve yeniden adlandırma.
- **Çalışma modu:** oturumun her zaman bitmesi, tekrar turu.
- **Aralıklı tekrar:** aralıkların (1 → 3 → 8 gün) ve tekrar günlerinin hesaplanması, "Bugünlük bu kadar" ekranı, ana sayfa rozeti.
- **Sesli okuma:** doğru dil ve metinle okuma, TTS yokken çökmeden uyarı.

## Yayınlama

### İmzalama
Release imzası `android/key.properties` dosyasından okunur. Bu dosya ve anahtar (`.jks`) git'e eklenmez:

```properties
storePassword=…
keyPassword=…
keyAlias=…
storeFile=/tam/yol/upload-keystore.jks
```

### AAB oluşturma
```bash
flutter build appbundle --release
```

Çıktı: `build/app/outputs/bundle/release/app-release.aab`. Önce Play Console'da **dahili test** kanalına yükleyip deneyin, sonra üretime çıkın.

### AAB'yi cihazda/emülatörde deneme
Play'in yaptığı gibi cihaza özel APK'lar üretip kurmak için (test anahtarıyla imzalanır):

```bash
java -jar tools/bundletool.jar build-apks --bundle=build/app/outputs/bundle/release/app-release.aab --output=flip.apks --connected-device --ks=<test.jks> --ks-key-alias=<alias> --ks-pass=pass:<şifre>
```
```bash
java -jar tools/bundletool.jar install-apks --apks=flip.apks
```

> Play sürümü kurulu bir telefonda farklı anahtarla imzalı paket kurulamaz. Önce kaldırmak notları siler; gerçek telefonda dahili test kanalını kullanın.

### Android 15/16 ve 16 KB sayfa boyutu
- `compileSdk = 36`, `targetSdk = 36` (Google Play'in 31 Ağustos 2026 hedef API şartı).
- Edge-to-edge görünüm açıktır; sayfalar `SafeLayout` ile sistem çubuklarının dışında kalır.
- Uygulama dikey kilitlidir. Android 16, 600dp üzeri ekranlarda (tablet, katlanabilir) bu kilidi yok sayar; sayfalar yatay ekranda da çalışacak şekilde esnektir.
- Android 16'nın geri hareketi için `enableOnBackInvokedCallback` açıktır.
- AGP 8.7.3; JNI kütüphaneleri modern paketleme (`useLegacyPackaging = false`) ile 16 KB hizalı üretilir.

16 KB hizalama kontrolü:

```bash
bash scripts/verify_16kb.sh
```

Script bağlı cihaz yoksa `adb` adımında durur; diğer iki kontrol elle de çalıştırılabilir:

```bash
java -jar tools/bundletool.jar dump config --bundle=build/app/outputs/bundle/release/app-release.aab | grep alignment
```
```bash
zipalign -c -P 16 -v 4 build/app/outputs/flutter-apk/app-release.apk
```

Beklenen sonuçlar: `PAGE_ALIGNMENT_16K` ve `Verification successful`.

## Sürüm Geçmişi

### 1.3.0
- **Aralıklı tekrar:** zamanı gelen kartlar, "Bugün N tekrar" rozeti, "Bugünlük bu kadar" ekranı, yeni istatistikler (bugünkü tekrar, öğrenilen).
- **Sesli okuma:** hoparlör butonu, ön/arka yüz için ayrı dil, hız ve otomatik okuma.
- **Renkli kart temaları:** renk kartın tamamını, çerçevesini ve simgesini değiştirir.
- **Düzeltmeler:**
  - Çalışma modunda "Bilmiyorum" denen kart sonsuz tekrar ediyor, oturum bitmiyordu.
  - Sonuç ekranında dar telefonlarda taşma vardı.

### 1.2.0
- **Android 16 (API 36)** hedefleniyor.
- **Ekran uyumu:** Bazı telefonlarda butonların aşağıda kalıp kaydırma gerektirmesi düzeltildi.
- **Veri hataları:**
  - Karışık listede "Düzenle" yanlış notu değiştirebiliyordu.
  - Klasör içinde silme diğer klasörlerin notlarını silebiliyordu.
- **Karanlık mod:** beyaz zemin üstüne beyaz yazı sorunları giderildi.
- **Yenilikler:**
  - Not rengi ve klasör seçimi
  - Silme onayı
  - Klasör yeniden adlandırma ve not sayıları
  - Klasör silerken notları taşıma
  - Çalışma modunda "önce zor kartlar" ve "cevaptan başla"
  - Kart bazında doğru/yanlış takibi
  - İçe aktarmada yinelenen notların atlanması
  - Geri tuşunda kaydedilmemiş not uyarısı

## Lisans

Bu proje özel bir projedir.

## İletişim

Sorular veya öneriler için issue açabilirsiniz.
