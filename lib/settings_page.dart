import 'package:flutter/material.dart';
import 'export_import_helper.dart';
import 'statistics_page.dart';
import 'search_page.dart';
import 'navigation_helper.dart';
import 'theme_provider.dart';
import 'speech_service.dart';

class SettingsPage extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;

  SettingsPage({required this.screenWidth, required this.screenHeight});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;
  String _selectedLabelFont = AppFontSettings.defaultFontFamily;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
    _loadLabelFontPreference();
    SpeechService.load().then((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _loadThemePreference() async {
    await AppThemeController.load();
    if (!mounted) return;
    setState(() {
      _isDarkMode = AppThemeController.isDarkMode;
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    await AppThemeController.setDarkMode(value);
    if (!mounted) return;
    setState(() {
      _isDarkMode = value;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value ? "Karanlık mod etkinleştirildi." : "Aydınlık mod etkinleştirildi.",
        ),
      ),
    );
  }

  Future<void> _loadLabelFontPreference() async {
    await AppFontSettings.load();
    if (!mounted) return;
    setState(() {
      _selectedLabelFont = AppFontSettings.labelFontFamily;
    });
  }

  Future<void> _changeLabelFont(String fontFamily) async {
    await AppFontSettings.save(fontFamily);
    if (!mounted) return;
    setState(() {
      _selectedLabelFont = fontFamily;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Yazı tipi güncellendi.")),
    );
  }

  String _speechSummary() {
    final f = SpeechService.languages[SpeechService.frontLang] ?? SpeechService.frontLang;
    final b = SpeechService.languages[SpeechService.backLang] ?? SpeechService.backLang;
    return f == b ? "Dil: $f" : "Ön: $f · Arka: $b";
  }

  Future<void> _showSpeechSettings() async {
    await SpeechService.load();
    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheet) {
          Widget langPicker(String title, String value, ValueChanged<String> onChanged) {
            return ListTile(
              title: Text(title),
              trailing: DropdownButton<String>(
                value: value,
                underline: const SizedBox.shrink(),
                onChanged: (v) {
                  if (v != null) onChanged(v);
                },
                items: SpeechService.languages.entries
                    .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                    .toList(),
              ),
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ListTile(
                    leading: Icon(Icons.record_voice_over),
                    title: Text("Sesli Okuma", style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Örn. kelime çalışırken ön yüz Türkçe, arka yüz İngilizce."),
                  ),
                  langPicker("Ön yüz (soru) dili", SpeechService.frontLang, (v) async {
                    await SpeechService.save(front: v);
                    setSheet(() {});
                  }),
                  langPicker("Arka yüz (cevap) dili", SpeechService.backLang, (v) async {
                    await SpeechService.save(back: v);
                    setSheet(() {});
                  }),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: SegmentedButton<double>(
                      segments: SpeechService.rates.entries
                          .map((e) => ButtonSegment(value: e.key, label: Text(e.value)))
                          .toList(),
                      selected: {SpeechService.rate},
                      onSelectionChanged: (v) async {
                        await SpeechService.save(newRate: v.first);
                        setSheet(() {});
                      },
                    ),
                  ),
                  SwitchListTile(
                    title: const Text("Çalışırken otomatik oku"),
                    subtitle: const Text("Kart açılınca ya da çevrilince kendiliğinden okunur."),
                    value: SpeechService.autoRead,
                    onChanged: (v) async {
                      await SpeechService.save(auto: v);
                      setSheet(() {});
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.volume_up),
                            label: const FittedBox(child: Text("Ön yüzü dene")),
                            onPressed: () => _testSpeech(front: true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.volume_up),
                            label: const FittedBox(child: Text("Arka yüzü dene")),
                            onPressed: () => _testSpeech(front: false),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    if (mounted) setState(() {});
  }

  static const Map<String, String> _samples = {
    'tr-TR': 'Merhaba, FlipPage ile çalışmaya hazırım.',
    'en-US': 'Hello, I am ready to study with FlipPage.',
    'en-GB': 'Hello, I am ready to study with FlipPage.',
    'de-DE': 'Hallo, ich bin bereit zu lernen.',
    'fr-FR': 'Bonjour, je suis prêt à étudier.',
    'es-ES': 'Hola, estoy listo para estudiar.',
    'it-IT': 'Ciao, sono pronto a studiare.',
    'ru-RU': 'Привет, я готов учиться.',
    'ar-SA': 'مرحبا، أنا مستعد للدراسة.',
    'ja-JP': 'こんにちは、勉強の準備ができました。',
  };

  Future<void> _testSpeech({required bool front}) async {
    final lang = SpeechService.langFor(front: front);
    final error = await SpeechService.speak(_samples[lang] ?? 'FlipPage', front: front);
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  void _showFontPicker() {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(title: Text("Yazı Tipi", style: TextStyle(fontWeight: FontWeight.bold))),
            ...AppFontSettings.availableFonts.entries.map(
              (entry) => ListTile(
                title: Text(entry.value, style: TextStyle(fontFamily: entry.key, fontSize: 18)),
                trailing: entry.key == _selectedLabelFont ? const Icon(Icons.check, color: Colors.brown) : null,
                onTap: () {
                  Navigator.pop(sheetContext);
                  _changeLabelFont(entry.key);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: 12,
              left: widget.screenWidth * 0.05,
              right: widget.screenWidth * 0.05,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: widget.screenWidth * 0.09375),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "Ayarlar",
                      style: TextStyle(
                        fontSize: widget.screenWidth * 0.1,
                        fontWeight: FontWeight.w800,
                        fontFamily: AppFontSettings.labelFontFamily,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    closeOrGoHome(context);
                  },
                  child: Image.asset(
                    'assets/exit.png',
                    width: widget.screenWidth * 0.09375,
                    height: widget.screenWidth * 0.09375,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: widget.screenWidth * 0.05),
              children: [
                // Dark Mode Toggle
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SwitchListTile(
                    secondary: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                        color: Colors.indigo,
                        size: widget.screenWidth * 0.08,
                      ),
                    ),
                    title: Text(
                      "Karanlık Mod",
                      style: TextStyle(
                        fontSize: widget.screenWidth * 0.045,
                        fontWeight: FontWeight.w700,
                        fontFamily: AppFontSettings.labelFontFamily,
                      ),
                    ),
                    subtitle: Text(
                      "Göz dostu karanlık tema",
                      style: TextStyle(
                        fontSize: widget.screenWidth * 0.035,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    value: _isDarkMode,
                    onChanged: _toggleDarkMode,
                  ),
                ),
                SizedBox(height: widget.screenHeight * 0.02),
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.teal.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.text_fields,
                        color: Colors.teal,
                        size: widget.screenWidth * 0.08,
                      ),
                    ),
                    title: Text(
                      "Yazı Tipi",
                      style: TextStyle(
                        fontSize: widget.screenWidth * 0.045,
                        fontWeight: FontWeight.w700,
                        fontFamily: AppFontSettings.labelFontFamily,
                      ),
                    ),
                    subtitle: Text(
                      AppFontSettings.availableFonts[_selectedLabelFont] ?? "Buton ve başlık yazılarını değiştir",
                      style: TextStyle(
                        fontSize: widget.screenWidth * 0.035,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: widget.screenWidth * 0.04,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    onTap: _showFontPicker,
                  ),
                ),
                SizedBox(height: widget.screenHeight * 0.02),
                _buildSettingsCard(
                  context,
                  "Sesli Okuma",
                  _speechSummary(),
                  Icons.record_voice_over,
                  Colors.indigo,
                  _showSpeechSettings,
                ),
                SizedBox(height: widget.screenHeight * 0.02),
                _buildSettingsCard(
                  context,
                  "Not Ara",
                  "Notlarınızı hızlıca arayın",
                  Icons.search,
                  Colors.blue,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchPage(
                          screenWidth: widget.screenWidth,
                          screenHeight: widget.screenHeight,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: widget.screenHeight * 0.02),
                _buildSettingsCard(
                  context,
                  "İstatistikler",
                  "Not ve klasör istatistiklerinizi görün",
                  Icons.bar_chart,
                  Colors.purple,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StatisticsPage(
                          screenWidth: widget.screenWidth,
                          screenHeight: widget.screenHeight,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: widget.screenHeight * 0.02),
                _buildSettingsCard(
                  context,
                  "Notları Dışa Aktar",
                  "Notlarınızı yedekleyin",
                  Icons.upload_file,
                  Colors.green,
                  () async {
                    await ExportImportHelper.exportNotes(context);
                  },
                ),
                SizedBox(height: widget.screenHeight * 0.02),
                _buildSettingsCard(
                  context,
                  "Notları İçe Aktar",
                  "Yedeklenmiş notları geri yükleyin",
                  Icons.download,
                  Colors.orange,
                  () async {
                    await ExportImportHelper.importNotes(context);
                  },
                ),
                SizedBox(height: widget.screenHeight * 0.03),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(widget.screenWidth * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.brown),
                            SizedBox(width: 8),
                            Text(
                              "Hakkında",
                              style: TextStyle(
                                fontSize: widget.screenWidth * 0.05,
                                fontWeight: FontWeight.w700,
                                fontFamily: AppFontSettings.labelFontFamily,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          "FlipPage v1.3.0",
                          style: TextStyle(
                            fontSize: widget.screenWidth * 0.04,
                            fontWeight: FontWeight.w600,
                            fontFamily: AppFontSettings.labelFontFamily,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Flashcard tarzı not tutma uygulaması",
                          style: TextStyle(
                            fontSize: widget.screenWidth * 0.035,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: widget.screenWidth * 0.08,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: widget.screenWidth * 0.045,
            fontWeight: FontWeight.w700,
            fontFamily: AppFontSettings.labelFontFamily,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: widget.screenWidth * 0.035,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: widget.screenWidth * 0.04,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
