import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Kart yazılarını telefonun metin okuma (TTS) motoruyla sesli okur.
///
/// Ön ve arka yüz için ayrı dil seçilebilir (örn. ön yüz Türkçe, arka yüz
/// İngilizce). Telefon sesi desteklemiyorsa uygulama çökmeden uyarı verir.
class SpeechService {
  static const String _frontLangKey = 'tts_front_lang';
  static const String _backLangKey = 'tts_back_lang';
  static const String _rateKey = 'tts_rate';
  static const String _autoKey = 'tts_auto_read';

  static const Map<String, String> languages = {
    'tr-TR': 'Türkçe',
    'en-US': 'İngilizce (ABD)',
    'en-GB': 'İngilizce (İngiltere)',
    'de-DE': 'Almanca',
    'fr-FR': 'Fransızca',
    'es-ES': 'İspanyolca',
    'it-IT': 'İtalyanca',
    'ru-RU': 'Rusça',
    'ar-SA': 'Arapça',
    'ja-JP': 'Japonca',
  };

  /// flutter_tts hız değerleri (Android'de 0.5 normal hızdır).
  static final Map<double, String> rates = {
    0.3: 'Yavaş',
    0.5: 'Normal',
    0.65: 'Hızlı',
  };

  static String frontLang = 'tr-TR';
  static String backLang = 'tr-TR';
  static double rate = 0.5;
  static bool autoRead = false;

  /// Şu an okunan metnin anahtarı (buton durumunu göstermek için).
  static final ValueNotifier<String?> speaking = ValueNotifier<String?>(null);

  static FlutterTts? _tts;
  static bool _loaded = false;

  static Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    frontLang = prefs.getString(_frontLangKey) ?? frontLang;
    backLang = prefs.getString(_backLangKey) ?? backLang;
    rate = prefs.getDouble(_rateKey) ?? rate;
    autoRead = prefs.getBool(_autoKey) ?? autoRead;
    _loaded = true;
  }

  static Future<void> save({String? front, String? back, double? newRate, bool? auto}) async {
    final prefs = await SharedPreferences.getInstance();
    if (front != null) {
      frontLang = front;
      await prefs.setString(_frontLangKey, front);
    }
    if (back != null) {
      backLang = back;
      await prefs.setString(_backLangKey, back);
    }
    if (newRate != null) {
      rate = newRate;
      await prefs.setDouble(_rateKey, newRate);
    }
    if (auto != null) {
      autoRead = auto;
      await prefs.setBool(_autoKey, auto);
    }
  }

  static FlutterTts _engine() {
    if (_tts != null) return _tts!;
    final tts = FlutterTts();
    tts.setCompletionHandler(() => speaking.value = null);
    tts.setCancelHandler(() => speaking.value = null);
    tts.setErrorHandler((_) => speaking.value = null);
    _tts = tts;
    return tts;
  }

  static String langFor({required bool front}) => front ? frontLang : backLang;

  /// Metni okur. Başarısız olursa kullanıcıya gösterilecek hata mesajını döndürür.
  static Future<String?> speak(String text, {required bool front, String? key}) async {
    final clean = text.trim();
    if (clean.isEmpty) return "Okunacak yazı yok.";
    await load();
    final lang = langFor(front: front);
    try {
      final tts = _engine();
      await tts.stop();
      final available = await tts.isLanguageAvailable(lang);
      if (available == false) {
        return "${languages[lang] ?? lang} ses paketi telefonda yok. "
            "Telefon ayarları > Metin okuma çıkışı bölümünden indirebilirsiniz.";
      }
      await tts.setLanguage(lang);
      await tts.setSpeechRate(rate);
      speaking.value = key ?? clean;
      await tts.speak(clean);
      return null;
    } catch (_) {
      speaking.value = null;
      return "Sesli okuma bu cihazda kullanılamıyor.";
    }
  }

  static Future<void> stop() async {
    speaking.value = null;
    try {
      await _tts?.stop();
    } catch (_) {}
  }
}

/// Kart üzerindeki hoparlör butonu. Okurken tekrar basılırsa durdurur.
class SpeakButton extends StatelessWidget {
  final String text;
  final bool front;
  final String speakKey;
  final Color color;
  final double size;

  const SpeakButton({
    super.key,
    required this.text,
    required this.front,
    required this.speakKey,
    required this.color,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: SpeechService.speaking,
      builder: (context, current, _) {
        final active = current == speakKey;
        return IconButton(
          tooltip: active ? "Durdur" : "Sesli oku",
          visualDensity: VisualDensity.compact,
          icon: Icon(active ? Icons.stop_circle_outlined : Icons.volume_up_rounded, size: size, color: color),
          onPressed: () async {
            if (active) {
              await SpeechService.stop();
              return;
            }
            final error = await SpeechService.speak(text, front: front, key: speakKey);
            if (error != null && context.mounted) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(error)));
            }
          },
        );
      },
    );
  }
}
