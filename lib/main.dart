import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'new_note_page.dart';
import 'my_notes_main_page.dart';
import 'settings_page.dart';
import 'theme_provider.dart';

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
          builder: (context, child) {
            if (child == null) {
              return const SizedBox.shrink();
            }
            return SafeArea(child: child);
          },
          home: HomePage(),
        );
      },
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Settings button at the top right
                  Padding(
                    padding: EdgeInsets.only(
                      top: screenHeight * 0.04,
                      right: screenWidth * 0.05,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
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
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.brown.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.settings,
                              color: Colors.brown,
                              size: screenWidth * 0.08,
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
                        Image.asset("assets/typewriter.png", width: screenWidth * 0.375),
                        SizedBox(height: screenHeight * 0.0625),
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
                                height: screenHeight * 0.109375,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.0625),
                        _buildButton(context, "Yeni Not", "assets/new_note.png", NewNotePage(screenWidth: screenWidth, screenHeight: screenHeight), screenWidth, screenHeight),
                        SizedBox(height: screenHeight * 0.03),
                        _buildButton(context, "Notlarım", "assets/my_notes.png", NewNotesMainPage(screenWidth: screenWidth, screenHeight: screenHeight), screenWidth, screenHeight),
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
                            "Kaydedilen bilgiler uygulama silinince kaybolacaktır",
                            style: TextStyle(
                              fontSize: screenWidth * 0.040625,
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

Widget _buildButton(BuildContext context, String text, String assetImage, Widget page, double screenWidth, double screenHeight) {
  return GestureDetector(
    onTap: () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    },
    child: Container(
      constraints: BoxConstraints(maxWidth: screenWidth * 0.9),
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: screenHeight * 0.01),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(assetImage, width: screenWidth * 0.2, height: screenHeight * 0.11),
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
          Image.asset("assets/pencil.png", width: screenWidth * 0.09, height: screenHeight * 0.08),
        ],
      ),
    ),
  );
}