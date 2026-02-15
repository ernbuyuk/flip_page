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

⚠️ Kaydedilen bilgiler uygulama silinince kaybolacaktır. Düzenli olarak notlarınızı dışa aktararak yedekleyin!

## Geliştirme

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
