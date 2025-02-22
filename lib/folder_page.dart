import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FolderPage extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;

  FolderPage({required this.screenWidth, required this.screenHeight});

  @override
  _FolderPageState createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {
  List<String> _folders = [];

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? folders = prefs.getStringList("folders") ?? [];
    setState(() {
      _folders = folders;
    });
  }

  Future<void> _saveFolders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList("folders", _folders);
  }

  void _addFolder(String folderName) {
    setState(() {
      _folders.add(folderName);
    });
    _saveFolders();
  }

  void _showAddFolderDialog() {
    TextEditingController folderController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Klasör Oluştur"),
          content: TextField(
            controller: folderController,
            decoration: InputDecoration(hintText: "Klasör Adı"),
          ),
          actions: [
            TextButton(
              child: Text("İptal"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Oluştur"),
              onPressed: () {
                _addFolder(folderController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = widget.screenHeight;
    double screenWidth = widget.screenWidth;

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
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Image.asset(
                      'assets/backpage.png',
                      width: screenWidth * 0.09375,
                      height: screenHeight * 0.06,
                    ),
                  ),
                  Text(
                    "Klasörler",
                    style: TextStyle(
                        fontSize: screenWidth * 0.1125, // Increased font size
                        fontWeight: FontWeight.w800,
                        fontFamily: "Cursive"),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
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
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(screenWidth * 0.05),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: screenWidth * 0.05,
                  mainAxisSpacing: screenHeight * 0.05,
                ),
                itemCount: _folders.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // Klasör içeriğine gitme işlemi burada yapılacak
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: Offset(3, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _folders[index],
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: screenHeight * 0.02),
              child: GestureDetector(
                onTap: _showAddFolderDialog,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F0EB), // Arka fonla aynı renk
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/file_yellowqq.png', width: screenWidth * 0.16, height: screenHeight * 0.08), // Soldaki görsel
                      SizedBox(width: screenWidth * 0.02), // Boşluk
                      Text(
                        "Klasör Oluştur",
                        style: TextStyle(
                          fontSize: screenWidth * 0.09375,
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                          fontFamily: "Cursive",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}