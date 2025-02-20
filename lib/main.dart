import 'package:flutter/material.dart';
import 'new_note_page.dart';
import 'my_notes_main_page.dart';

void main() {
  runApp(FlipPageApp());
}

class FlipPageApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FlipPage',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xFFF5F0EB),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.078125),
                Image.asset("assets/typewriter.png", width: screenWidth * 0.375),
                SizedBox(height: screenHeight * 0.0625),
                Padding(
                  padding: EdgeInsets.only(left: screenWidth * 0.109375),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "FlipPage",
                        style: TextStyle(
                          fontSize: screenWidth * 0.21875,
                          fontWeight: FontWeight.w900,
                          fontFamily: "Cursive",
                        ),
                      ),
                      Image.asset("assets/pencil.png", width: screenWidth * 0.21875, height: screenHeight * 0.109375),
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
                      fontFamily: "Cursive",
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
    );
  }
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
          Image.asset(assetImage, width: screenWidth * 0.25, height: screenHeight * 0.125),
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
          // SizedBox(width: screenWidth * 0.03125),
          Image.asset("assets/pencil.png", width: screenWidth * 0.1, height: screenHeight * 0.09),
        ],
      ),
    ),
  );
}