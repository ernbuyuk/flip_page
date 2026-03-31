# FlipPage

FlipPage, flashcard tarzında not tutma ve çalışma uygulamasıdır. Flutter ile geliştirilmiştir.

## Özellikler

### 📝 Not Yönetimi
- **Yeni Not Oluşturma**: Ön ve arka yüzü olan flashcard tarzı notlar oluşturun
- **Not Düzenleme**: Mevcut notları düzenleyin
- **Not Silme**: İstenmeyen notları silin
- **Renk Kodlama**: Notlarınızı 7 farklı renkle kategorize edin (Sarı, Pembe, Mavi, Yeşil, Turuncu, Mor, Varsayılan)
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
