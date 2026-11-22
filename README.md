# FlipPage

FlipPage, flashcard tarzında not tutma ve çalışma uygulamasıdır. Flutter ile geliştirilmiştir.

## Uygulama Bilgisi

FlipPage; soru-cevap mantığıyla çalışan dijital kartlar (flashcard) üzerinden düzenli tekrar yapmanızı sağlayan bir not ve öğrenme uygulamasıdır. Hızlı not oluşturma, klasörleme, arama, çalışma modu ve yedekleme özellikleriyle bireysel öğrenme sürecini sade bir arayüzde toplar.

Android uygulama mağazasından uygulamayı denemek için:

[![Google Play'de Dene](https://img.shields.io/badge/Google%20Play-FlipPage-34A853?style=for-the-badge&logo=googleplay&logoColor=white)](https://play.google.com/store/apps/details?id=com.bg.flip_page)

https://play.google.com/store/apps/details?id=com.bg.flip_page

## Özellikler

### 📝 Not Yönetimi
- **Yeni Not Oluşturma**: Ön ve arka yüzü olan flashcard tarzı notlar oluşturun
- **Not Düzenleme**: Mevcut notları düzenleyin
- **Not Silme**: İstenmeyen notları silin
- **Renkli Kart Temaları**: 7 kart teması; kartın tamamı, çerçevesi ve simgesi renge göre değişir (Klasik, Fikir, Sevgi, Okul, Doğa, Önemli, Hayal)
- **Not Paylaşma**: Tek tek notları başkalarıyla paylaşın

### 📁 Klasör Organizasyonu
- **Özel Klasörler**: Notlarınızı klasörlere ayırın
- **Karışık Mod**: Tüm notları karışık bir şekilde görüntüleyin
- **Klasöre Göre Filtreleme**: Belirli bir klasördeki notları görüntüleyin

### 🔍 Arama ve İstatistikler
- **Gelişmiş Arama**: Notlarınızı ön yüz, arka yüz veya klasör adına göre arayın
- **İstatistikler**: 
  - Toplam not sayısı
  - Klasör sayısı
  - Klasörlere göre not dağılımı

### 📚 Çalışma Modu
- **İnteraktif Çalışma**: Flashcard'larınızla interaktif olarak çalışın
- **İlerleme Takibi**: Doğru ve yanlış cevaplarınızı takip edin
- **Başarı Oranı**: Çalışma seansınızın sonunda detaylı istatistikler görün
- **Yanlış Cevapların Tekrarı**: Yanlış bildikleriniz otomatik olarak tekrar gösterilir

### 💾 Yedekleme ve Geri Yükleme
- **Dışa Aktarma**: Tüm notlarınızı ve klasörlerinizi JSON formatında dışa aktarın
- **İçe Aktarma**: Yedeklenmiş notları geri yükleyin
- **Veri Güvenliği**: Notlarınızı güvenli bir şekilde yedekleyin

### 🎨 Görünüm
- **Karanlık Mod**: Göz dostu karanlık tema desteği
- **Renkli Kartlar**: Notlarınızı renklendirerek görsel olarak organize edin
- **Responsive Tasarım**: Farklı ekran boyutlarına uyumlu tasarım

## v1.3.0 Değişiklikleri

- **Aralıklı tekrar**: Çalışma modu artık sadece tekrar zamanı gelen kartları getirir. Bilinen kartın tekrar aralığı büyür (1 gün → 3 gün → ~1 hafta → ...), bilinmeyen kart aynı gün tekrar gelir. Ana sayfada "Bugün N tekrar" rozeti, Notlarım'da çalışma butonunda tekrar sayısı, istatistiklerde "Bugün Tekrar" ve "Öğrenildi" (21+ gün aralık) kartları. İstenirse çalışma menüsünden "Sadece bugünkü tekrarlar" kapatılıp tüm kartlar çalışılabilir.
- **Sesli okuma**: Kartlardaki hoparlör butonuyla yazı telefonun metin okuma motoruyla okunur. Ayarlar > Sesli Okuma'dan ön ve arka yüz için ayrı dil (Türkçe, İngilizce, Almanca, ...), okuma hızı ve "çalışırken otomatik oku" seçilebilir.
- **Renkli kart temaları**: Seçilen renk kartın tamamını, çerçevesini ve simgesini değiştirir.
- **Düzeltme**: Çalışma modunda "Bilmiyorum" denen kart sonsuz kez tekrar ediliyor, oturum bitmiyordu. Artık bilinmeyen kart tur sonunda bir kez tekrar gösterilir.

## v1.2.0 Değişiklikleri

- **Android 16 (API 36)** hedefleniyor (Google Play hedef API şartı).
- **Ekran uyumu**: Butonların bazı telefonlarda aşağıda kalması/kaydırma gerektirmesi düzeltildi. Sayfalar artık sistem çubukları (çentik, 3 tuşlu gezinme) hariç gerçekten kullanılabilir alana göre boyutlanıyor; aşırı büyük sistem yazı boyutu sınırlandırıldı; klavye açıkken Kaydet/Çevir butonları görünür kalıyor.
- **Veri hatası düzeltmeleri**: Karıştırılmış listede "Düzenle" yanlış notu değiştirebiliyordu; klasör görünümünde silme diğer klasörlerin notlarını silebiliyordu. Notlara artık benzersiz `id` atanıyor (eski notlar otomatik taşınır).
- **Karanlık mod**: Klasör kartları, arama kutusu ve not kartlarında beyaz üstüne beyaz yazı sorunu giderildi.
- **Yeni**: Renkli kart temaları (kartın tamamı, çerçevesi ve simgesi renge göre değişir), not rengi seçimi, not oluştururken klasör seçimi, sil onayı, klasör yeniden adlandırma ve not sayıları, klasör silerken notları taşıma seçeneği, çalışma modunda "önce zor kartlar" ve "cevaptan başla", kart bazında doğru/yanlış takibi, istatistiklerde başarı oranı ve en zor kartlar, yedek içe aktarırken yinelenen notların atlanması, sistem geri tuşunda kaydedilmemiş not uyarısı.

### Testler

`flutter test` 7 farklı ekran profilinde (320x568 küçük ekran, çentikli, 3 tuşlu gezinmeli, %130–150 yazı boyutu, klavye açık, tablet yatay) tüm sayfaların taşma yapmadığını ve ana butonların kaydırmadan görünür olduğunu doğrular.

## Kurulum

1. Flutter SDK'nın yüklü olduğundan emin olun
2. Bağımlılıkları yükleyin:
```bash
flutter pub get
```

3. Uygulamayı çalıştırın:
```bash
flutter run
```

## Bağımlılıklar

- `flutter`: Flutter framework
- `cupertino_icons`: iOS stil ikonlar
- `shared_preferences`: Yerel veri saklama
- `file_picker`: Dosya seçme için
- `path_provider`: Dosya yolları için
- `share_plus`: Paylaşım özelliği için
- `intl`: Uluslararasılaştırma için

## Kullanım

### Not Oluşturma
1. Ana sayfadan "Yeni Not" butonuna tıklayın
2. Kartın ön yüzüne soruyu yazın
3. "Sayfayı Çevir" ile arka yüze geçin ve cevabı yazın
4. İstediğiniz rengi seçin
5. "Notu Kaydet" ile kaydedin

### Çalışma Modu
1. "Notlarım" > "Çalışma Modu" seçin
2. Soru kartını okuyun ve cevabı düşünün
3. Karta dokunarak cevabı görün
4. "Biliyorum" veya "Bilmiyorum" butonlarından birini seçin
5. Oturum sonunda istatistiklerinizi görün

### Yedekleme
1. Ana sayfadan ayarlar (⚙️) ikonuna tıklayın
2. "Notları Dışa Aktar" seçeneğini seçin
3. Dosyayı paylaşın veya kaydedin

## Önemli Not

⚠️ Kaydedilen bilgiler uygulama kaldırıldığında (uninstall) kaybolacaktır. Düzenli olarak notlarınızı "Notları Dışa Aktar" özelliğini kullanarak yedekleyin!

## Android 15 ve 16 KB Notu

- Proje Android tarafinda `compileSdk = 36` ile derlenir.
- Uygulama yalnızca dikey (`portrait`) kullanıma kilitlidir.
- Edge-to-edge gorunum Flutter tarafinda `SystemUiMode.edgeToEdge` ile etkinlestirilir.
- AGP 8.5.1+ gereksinimi karsilanir (projede AGP 8.7.3 kullanilir).
- JNI kutuphaneleri modern paketleme ile (`useLegacyPackaging = false`) uretilir.

Release almadan once asagidaki kontrolleri calistirin:

```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

Uretilen paketin 16 KB hizalama kontrolleri icin:

```bash
bundletool dump config --bundle=build/app/outputs/bundle/release/app-release.aab | grep alignment
zipalign -c -P 16 -v 4 build/app/outputs/flutter-apk/app-release.apk
adb shell getconf PAGE_SIZE
```

Tek komutla kontrol icin:

```bash
bash scripts/verify_16kb.sh
```

Script `bundletool` / `zipalign` / `adb` bulamazsa Linux icin hizli kurulum:

```bash
export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$PATH"
sdkmanager "platform-tools" "build-tools;36.0.0"

# bundletool icin:
# 1) PATH'e bundletool binary ekleyin
# veya
# 2) bundletool.jar dosyasini tools/bundletool.jar olarak koyun
```

- `bundletool` cikisinda `PAGE_ALIGNMENT_16K` beklenir.
- `adb shell getconf PAGE_SIZE` komutu 16 KB test ortami icin `16384` donmelidir.

16 KB page-size uyumlulugu icin, final AAB dosyasini Android 15 (API 35+) cihaz/emulator uzerinde acilis ve temel akislarda test edin. Flutter/engine kaynakli native kutuphane uyumsuzlugu gorurseniz Flutter SDK'yi guncel stable surume yukselterek yeniden release alin.

## Gelistirme

Bu proje Flutter ile geliştirilmiştir. Katkıda bulunmak için:

1. Projeyi fork edin
2. Feature branch oluşturun (`git checkout -b feature/AmazingFeature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add some AmazingFeature'`)
4. Branch'inizi push edin (`git push origin feature/AmazingFeature`)
5. Pull Request oluşturun

## Lisans

Bu proje özel bir projedir.

## İletişim

Sorular veya öneriler için issue açabilirsiniz.
