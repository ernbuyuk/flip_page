import 'package:flutter/material.dart';
import 'my_notes_page.dart'; // Import the MyNotesPage
import 'folder_page.dart'; // Import the FolderPage
import 'study_mode_page.dart'; // Import the StudyModePage

class NewNotesMainPage extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;

  NewNotesMainPage({required this.screenWidth, required this.screenHeight});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F0EB),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.04, left: screenWidth * 0.05, right: screenWidth * 0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: screenWidth * 0.075), // Placeholder for alignment
                  Text(
                    "Notlarım",
                    style: TextStyle(
                        fontSize: screenWidth * 0.1125, // Increased font size
                        fontWeight: FontWeight.w800,
                        fontFamily: "Cursive"),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Image.asset(
                      'assets/exit.png',
                      width: screenWidth * 0.09375,
                      height: screenHeight * 0.06,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.08), // Space between header and buttons
            _buildButton(context, 'Karışık', 'assets/karisik.png', MyNotesPage(), screenWidth, screenHeight),
            SizedBox(height: screenHeight * 0.03),
            _buildButton(context, 'Özel', 'assets/ozel.png', FolderPage(screenWidth: screenWidth, screenHeight: screenHeight), screenWidth, screenHeight),
            SizedBox(height: screenHeight * 0.03),
            _buildButton(context, 'Çalışma Modu', 'assets/flip.png', StudyModePage(screenWidth: screenWidth, screenHeight: screenHeight), screenWidth, screenHeight),
            SizedBox(height: screenHeight * 0.03),
            _buildButton(context, 'Düzenle', 'assets/duzenle.png', MyNotesPage(isEditMode: true), screenWidth, screenHeight),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, String assetImage, Widget page, double screenWidth, double screenHeight) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenHeight * 0.01),
        decoration: BoxDecoration(
          color: Color(0xFFF5F0EB),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(assetImage, width: screenWidth * 0.25, height: screenHeight * 0.125),
            ),
            SizedBox(width: screenWidth * 0.03125),
            Text(
              text,
              style: TextStyle(
                fontSize: screenWidth * 0.09375,
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontFamily: "Cursive",
              ),
            ),
            SizedBox(width: screenWidth * 0.0125),
            Image.asset("assets/pencil.png", width: screenWidth * 0.1, height: screenHeight * 0.09),
          ],
        ),
      ),
    );
  }
}