import 'package:flutter/material.dart';
import 'export_import_helper.dart';
import 'statistics_page.dart';
import 'search_page.dart';
import 'navigation_helper.dart';
import 'theme_provider.dart';

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
          value ? "Karanlik mod etkinlestirildi." : "Aydinlik mod etkinlestirildi.",
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
      SnackBar(content: Text("Yazi tipi guncellendi.")),
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
              top: widget.screenHeight * 0.04,
              left: widget.screenWidth * 0.05,
              right: widget.screenWidth * 0.05,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: widget.screenWidth * 0.075),
                Text(
                  "Ayarlar",
                  style: TextStyle(
                    fontSize: widget.screenWidth * 0.1125,
                    fontWeight: FontWeight.w800,
                    fontFamily: AppFontSettings.labelFontFamily,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    closeOrGoHome(context);
                  },
                  child: Image.asset(
                    'assets/exit.png',
                    width: widget.screenWidth * 0.09375,
                    height: widget.screenHeight * 0.06,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: widget.screenHeight * 0.05),
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
                      "Yazi Tipi",
                      style: TextStyle(
                        fontSize: widget.screenWidth * 0.045,
                        fontWeight: FontWeight.w700,
                        fontFamily: AppFontSettings.labelFontFamily,
                      ),
                    ),
                    subtitle: Text(
                      "Buton ve baslik yazilarini degistir",
                      style: TextStyle(
                        fontSize: widget.screenWidth * 0.035,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedLabelFont,
                        items: AppFontSettings.availableFonts.entries
                            .map(
                              (entry) => DropdownMenuItem<String>(
                                value: entry.key,
                                child: Text(
                                  entry.value,
                                  style: TextStyle(fontFamily: entry.key),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            _changeLabelFont(value);
                          }
                        },
                      ),
                    ),
                  ),
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
                          "FlipPage v1.1.0",
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
