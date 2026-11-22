import 'package:flutter/material.dart';
import 'my_notes_page.dart';
import 'folder_page.dart';
import 'navigation_helper.dart';
import 'theme_provider.dart';

class NewNotesMainPage extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;

  const NewNotesMainPage({super.key, required this.screenWidth, required this.screenHeight});

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
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 12, left: screenWidth * 0.05, right: screenWidth * 0.05),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: screenWidth * 0.09375),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "Notlarım",
                              style: TextStyle(
                                fontSize: screenWidth * 0.1,
                                fontWeight: FontWeight.w800,
                                fontFamily: AppFontSettings.labelFontFamily,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => closeOrGoHome(context),
                          child: Image.asset(
                            'assets/exit.png',
                            width: screenWidth * 0.09375,
                            height: screenWidth * 0.09375,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: h * 0.07),
                  _buildButton(context, 'Karışık', 'assets/karisik.png', const MyNotesPage(), screenWidth, h),
                  SizedBox(height: h * 0.03),
                  _buildButton(context, 'Özel', 'assets/ozel.png',
                      FolderPage(screenWidth: screenWidth, screenHeight: screenHeight), screenWidth, h),
                  SizedBox(height: h * 0.03),
                  _buildButton(
                      context, 'Düzenle', 'assets/duzenle.png', const MyNotesPage(isEditMode: true), screenWidth, h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, String assetImage, Widget page, double screenWidth, double h) {
    final imageHeight = (h * 0.12).clamp(48.0, 120.0);
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        constraints: BoxConstraints(maxWidth: screenWidth * 0.92),
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(assetImage, width: screenWidth * 0.25, height: imageHeight),
            SizedBox(width: screenWidth * 0.03),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: screenWidth * 0.09375,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                    fontFamily: AppFontSettings.labelFontFamily,
                  ),
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.0125),
            Image.asset("assets/pencil.png", width: screenWidth * 0.1, height: imageHeight * 0.7),
          ],
        ),
      ),
    );
  }
}
