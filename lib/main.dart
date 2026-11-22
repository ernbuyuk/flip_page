import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'new_note_page.dart';
import 'my_notes_main_page.dart';
import 'settings_page.dart';
import 'theme_provider.dart';
import 'note_storage.dart';
import 'study_mode_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await AppThemeController.load();
  await AppFontSettings.load();
  runApp(FlipPageApp());
}

class FlipPageApp extends StatelessWidget {
  final ThemeProvider _themeProvider = ThemeProvider();

  FlipPageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppThemeController.themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'FlipPage',
          theme: _themeProvider.lightTheme,
          darkTheme: _themeProvider.darkTheme,
          themeMode: mode,
          builder: (context, child) => SafeLayout(child: child),
          home: HomePage(),
        );
      },
    );
  }
}

/// Tüm sayfaları sistem çubuklarından (durum çubuğu, gezinme çubuğu, çentik)
/// koruyan sarmalayıcı.
///
/// Uygulama edge-to-edge çizildiği için `MediaQuery.size` sistem çubuklarını
/// da içerir. Sayfalar yüksekliklerini `size.height * oran` ile hesapladığından,
/// büyük çentikli / 3 tuşlu gezinmeli telefonlarda içerik ekrana sığmıyor ve
/// butonlar aşağıda kalıyordu. Burada sayfalara yalnızca gerçekten kullanılabilir
/// alanın boyutu verilir ve aşırı büyük sistem yazı boyutu sınırlandırılır.
class SafeLayout extends StatelessWidget {
  final Widget? child;

  const SafeLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (child == null) {
      return const SizedBox.shrink();
    }
    final mq = MediaQuery.of(context);
    final padding = mq.padding;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final safeSize = Size(
      (mq.size.width - padding.horizontal).clamp(0.0, double.infinity),
      (mq.size.height - padding.vertical).clamp(0.0, double.infinity),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
      ),
      child: ColoredBox(
        color: theme.scaffoldBackgroundColor,
        child: MediaQuery(
          data: mq.copyWith(
            textScaler: mq.textScaler.clamp(minScaleFactor: 0.85, maxScaleFactor: 1.15),
          ),
          child: SafeArea(
            child: Builder(
              builder: (innerContext) => MediaQuery(
                data: MediaQuery.of(innerContext).copyWith(size: safeSize),
                child: child!,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final h = constraints.maxHeight;
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Settings button at the top right
                  Padding(
                    padding: EdgeInsets.only(
                      top: h * 0.02,
                      right: screenWidth * 0.05,
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: screenWidth * 0.05),
                        const Expanded(child: Align(alignment: Alignment.centerLeft, child: DueReviewChip())),
                        Semantics(
                          button: true,
                          label: 'Ayarlar',
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SettingsPage(
                                    screenWidth: screenWidth,
                                    screenHeight: screenHeight,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.brown.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.settings,
                                color: Colors.brown,
                                size: (screenWidth * 0.08).clamp(24.0, 40.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/typewriter.png",
                          width: screenWidth * 0.375,
                          height: h * 0.16,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: h * 0.04),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    "FlipPage",
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.21875,
                                      fontWeight: FontWeight.w900,
                                      fontFamily: AppFontSettings.labelFontFamily,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              Image.asset(
                                "assets/pencil.png",
                                width: screenWidth * 0.18,
                                height: h * 0.1,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: h * 0.05),
                        _buildButton(context, "Yeni Not", "assets/new_note.png",
                            NewNotePage(screenWidth: screenWidth, screenHeight: screenHeight), screenWidth, h),
                        SizedBox(height: h * 0.025),
                        _buildButton(context, "Notlarım", "assets/my_notes.png",
                            NewNotesMainPage(screenWidth: screenWidth, screenHeight: screenHeight), screenWidth, h),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(screenWidth * 0.04125),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/caution.png", width: screenWidth * 0.03125),
                        SizedBox(width: screenWidth * 0.02),
                        Expanded(
                          child: Text(
                            "Kaydedilen bilgiler uygulama silinince kaybolacaktır. Ayarlar'dan yedek alabilirsiniz.",
                            style: TextStyle(
                              fontSize: screenWidth * 0.036,
                              fontWeight: FontWeight.bold,
                              fontFamily: AppFontSettings.labelFontFamily,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
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
  }
}

Widget _buildButton(
    BuildContext context, String text, String assetImage, Widget page, double screenWidth, double availableHeight) {
  return GestureDetector(
    onTap: () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    },
    child: Container(
      constraints: BoxConstraints(maxWidth: screenWidth * 0.9),
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: availableHeight * 0.008),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(assetImage, width: screenWidth * 0.2, height: availableHeight * 0.1),
          SizedBox(width: screenWidth * 0.02),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenWidth * 0.085,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w700,
                fontFamily: AppFontSettings.labelFontFamily,
              ),
            ),
          ),
          SizedBox(width: screenWidth * 0.02),
          Image.asset("assets/pencil.png", width: screenWidth * 0.09, height: availableHeight * 0.075),
        ],
      ),
    ),
  );
}

/// Ana sayfada "Bugün N tekrar" rozeti. Dokununca bugünkü kartlarla çalışma başlar.
class DueReviewChip extends StatefulWidget {
  const DueReviewChip({super.key});

  @override
  State<DueReviewChip> createState() => _DueReviewChipState();
}

class _DueReviewChipState extends State<DueReviewChip> {
  int _total = 0;
  int _due = 0;

  @override
  void initState() {
    super.initState();
    NoteStorage.changes.addListener(_refresh);
    _refresh();
  }

  @override
  void dispose() {
    NoteStorage.changes.removeListener(_refresh);
    super.dispose();
  }

  Future<void> _refresh() async {
    final notes = await NoteStorage.loadNotes();
    if (!mounted) return;
    setState(() {
      _total = notes.length;
      _due = SpacedRepetition.dueCount(notes);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_total == 0) return const SizedBox.shrink();
    final size = MediaQuery.of(context).size;
    final hasDue = _due > 0;
    final color = hasDue ? Colors.deepOrange : Colors.green;
    return Semantics(
      button: hasDue,
      label: hasDue ? 'Bugün $_due kart tekrar bekliyor' : 'Bugünkü tekrarlar tamam',
      child: Material(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: hasDue
              ? () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudyModePage(screenWidth: size.width, screenHeight: size.height),
                    ),
                  );
                  _refresh();
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(hasDue ? Icons.replay_circle_filled : Icons.task_alt, color: color, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    hasDue ? "Bugün $_due tekrar" : "Bugünlük tamam",
                    style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
