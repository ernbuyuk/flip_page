import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // JSON işlemleri için
import 'theme_provider.dart';

class NewNotePage extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final String? frontText;
  final String? backText;
  final bool isEditMode;
  final int? noteIndex;
  final String? folderName;
  final String? color;

  NewNotePage({
    required this.screenWidth,
    required this.screenHeight,
    this.frontText,
    this.backText,
    this.isEditMode = false,
    this.noteIndex,
    this.folderName,
    this.color,
  });

  @override
  _NewNotePageState createState() => _NewNotePageState();
}

class _NewNotePageState extends State<NewNotePage> with SingleTickerProviderStateMixin {
  bool _isFront = true;
  bool _isTextVisible = true;
  final TextEditingController _frontController = TextEditingController();
  final TextEditingController _backController = TextEditingController();
  late AnimationController _animationController;
  List<String> _folders = [];
  String _selectedColor = 'default';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _isFront = !_isFront;
            _animationController.reset();
            _isTextVisible = true;
          });
        }
      })
      ..addListener(() {
        if (_animationController.value > 0.50) {
          setState(() {
            _isTextVisible = false;
          });
        } else {
          setState(() {
            _isTextVisible = true;
          });
        }
      });

    // Eğer düzenleme modundaysa, mevcut kart bilgilerini yükle
    if (widget.isEditMode) {
      _frontController.text = widget.frontText ?? '';
      _backController.text = widget.backText ?? '';
      _selectedColor = widget.color ?? 'default';
    }

    _loadFolders();
  }

  Future<void> _loadFolders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? folders = prefs.getStringList("folders") ?? [];
    setState(() {
      _folders = folders;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _frontController.dispose();
    _backController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (_isNoteEmpty()) {
      // Kullanıcıya geri bildirim ver
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lütfen bir metin girin!")),
      );
      return; // Kaydetme işlemini durdur
    }

    // Kart bilgilerini JSON formatına dönüştür
    Map<String, String> noteData = {
      "frontText": _frontController.text,
      "backText": _backController.text,
      "folder": widget.folderName ?? "", // Kategori olarak klasör adı ekleniyor
      "color": _selectedColor, // Renk seçimi ekleniyor
    };
    String noteJson = jsonEncode(noteData);

    // SharedPreferences'e kaydet
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? notes = prefs.getStringList("notes") ?? [];

    if (widget.isEditMode && widget.noteIndex != null) {
      // Mevcut notu güncelle
      notes[widget.noteIndex!] = noteJson;
    } else {
      // Yeni notu ekle
      notes.add(noteJson);
    }

    await prefs.setStringList("notes", notes); // Listeyi güncelle

    // Kullanıcıya geri bildirim ver
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Not Kaydedildi!")),
    );

    // Input alanlarını temizle
    _frontController.clear();
    _backController.clear();

    // Düzenleme modunda kaydedildikten sonra geri dön
    if (widget.isEditMode) {
      Navigator.pop(context, notes);
    }
  }

  Future<void> _saveNoteToFolder(String folderName) async {
    if (_isNoteEmpty()) {
      // Kullanıcıya geri bildirim ver
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lütfen bir metin girin!")),
      );
      return; // Kaydetme işlemini durdur
    }

    // Kart bilgilerini JSON formatına dönüştür
    Map<String, String> noteData = {
      "frontText": _frontController.text,
      "backText": _backController.text,
      "folder": folderName, // Kategori olarak klasör adı ekleniyor
      "color": _selectedColor, // Renk seçimi ekleniyor
    };
    String noteJson = jsonEncode(noteData);

    // SharedPreferences'e kaydet
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? notes = prefs.getStringList("notes") ?? [];

    if (widget.isEditMode && widget.noteIndex != null) {
      // Mevcut notu güncelle
      notes[widget.noteIndex!] = noteJson;
    } else {
      // Yeni notu ekle
      notes.add(noteJson);
    }

    await prefs.setStringList("notes", notes); // Listeyi güncelle

    // Kullanıcıya geri bildirim ver
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Not Kaydedildi!")),
    );

    // Input alanlarını temizle
    _frontController.clear();
    _backController.clear();

    // Düzenleme modunda kaydedildikten sonra geri dön
    if (widget.isEditMode) {
      Navigator.pop(context, notes);
    }
  }

  void _showFolderSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Klasör Seç"),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _folders.length + 1, // Add 1 for the "Default" option
              itemBuilder: (context, index) {
                if (index == 0) {
                  return ListTile(
                    title: Text("Default"),
                    onTap: () {
                      _saveNoteToFolder("");
                      Navigator.of(context).pop();
                    },
                  );
                } else {
                  return ListTile(
                    title: Text(_folders[index - 1]),
                    onTap: () {
                      _saveNoteToFolder(_folders[index - 1]);
                      Navigator.of(context).pop();
                    },
                  );
                }
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text("İptal"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  bool _isNoteSaved = false; // Add a variable to track if the note is saved

  bool _isNoteEmpty() {
    return _frontController.text.isEmpty && _backController.text.isEmpty;
  }

  void _checkNoteSaved(BuildContext context) {
    if (_isNoteSaved || _isNoteEmpty()) {
      Navigator.pop(context);
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Emin misiniz?"),
            content: Text("Son yazdığınız not kaydedilmedi. Geri gitmek istediğinize emin misiniz?"),
            actions: [
              TextButton(
                child: Text("Hayır"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text("Evet"),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = widget.screenWidth;
    final screenHeight = widget.screenHeight;

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
                    "Yeni Not",
                    style: TextStyle(
                        fontSize: screenWidth * 0.1125, // Increased font size
                        fontWeight: FontWeight.w800,
                        fontFamily: "Cursive"),
                  ),
                  GestureDetector(
                    onTap: () {
                      _checkNoteSaved(context);
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
            SizedBox(height: screenHeight * 0.02),
            GestureDetector(
              onPanUpdate: (details) {
                if (details.delta.dx > 5) {
                  setState(() {
                    _animationController.forward();
                  });
                } else if (details.delta.dx < -5) {
                  setState(() {
                    _animationController.forward();
                  });
                }
              },
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(_animationController.value * 3.1416),
                    alignment: Alignment.center,
                    child: _isFront ? _buildFrontCard(screenWidth, screenHeight) : _buildBackCard(screenWidth, screenHeight),
                  );
                },
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            GestureDetector(
              onTap: () {
                setState(() {
                  _animationController.forward(); // Animasyonu başlat
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: widget.screenWidth * 0.05),
                decoration: BoxDecoration(
                  color: Color(0xFFF5F0EB), // Arka fonla aynı renk
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/flip.png', width: widget.screenWidth * 0.16, height: widget.screenHeight * 0.08), // Soldaki görsel
                          SizedBox(width: widget.screenWidth * 0.02), // Boşluk
                          Text(
                            "Sayfayı Çevir",
                            style: TextStyle(
                              fontSize: widget.screenWidth * 0.09375,
                              color: Colors.black,
                              fontWeight: FontWeight.w800,
                              fontFamily: "Cursive",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            // Color picker
            Container(
              padding: EdgeInsets.symmetric(horizontal: widget.screenWidth * 0.05),
              child: Column(
                children: [
                  Text(
                    "Kart Rengi",
                    style: TextStyle(
                      fontSize: widget.screenWidth * 0.05,
                      fontWeight: FontWeight.w700,
                      fontFamily: "Cursive",
                    ),
                  ),
                  SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: NoteColor.colorNames.map((colorName) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedColor = colorName;
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 5),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: NoteColor.getColor(colorName),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _selectedColor == colorName
                                    ? Colors.brown
                                    : Colors.grey,
                                width: _selectedColor == colorName ? 3 : 1,
                              ),
                            ),
                            child: _selectedColor == colorName
                                ? Icon(Icons.check, color: Colors.brown)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            GestureDetector(
              onTap: () {
                if (_folders.isEmpty) {
                  _saveNote();
                } else {
                  _showFolderSelectionDialog();
                }
                setState(() {
                  _isNoteSaved = true; // Mark the note as saved
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: widget.screenWidth * 0.05),
                decoration: BoxDecoration(
                  color: Color(0xFFF5F0EB), // Arka fonla aynı renk
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/file_yellow.png', width: widget.screenWidth * 0.16, height: widget.screenHeight * 0.08), // Soldaki görsel
                          SizedBox(width: widget.screenWidth * 0.02), // Boşluk
                          Text(
                            "Notu Kaydet",
                            style: TextStyle(
                              fontSize: widget.screenWidth * 0.09375,
                              color: Colors.black,
                              fontWeight: FontWeight.w800,
                              fontFamily: "Cursive",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFrontCard(double screenWidth, double screenHeight) {
    return Container(
      width: screenWidth * 0.95,
      height: screenHeight * 0.65,
      decoration: BoxDecoration(
        color: NoteColor.getColor(_selectedColor),
        image: DecorationImage(
          image: AssetImage("assets/card_template.png"),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            NoteColor.getColor(_selectedColor).withOpacity(0.3),
            BlendMode.softLight,
          ),
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: _isTextVisible
              ? TextField(
                  controller: _frontController,
                  maxLines: null,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: "Ön yüz yazısını buraya yazın...",
                    border: InputBorder.none,
                  ),
                  style: TextStyle(fontSize: screenWidth * 0.05625),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildBackCard(double screenWidth, double screenHeight) {
    return Container(
      width: screenWidth * 0.95,
      height: screenHeight * 0.65,
      decoration: BoxDecoration(
        color: NoteColor.getColor(_selectedColor),
        image: DecorationImage(
          image: AssetImage("assets/card_template.png"),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            NoteColor.getColor(_selectedColor).withOpacity(0.3),
            BlendMode.softLight,
          ),
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: _isTextVisible
              ? TextField(
                  controller: _backController,
                  maxLines: null,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: "Arka yüz yazısını buraya yazın...",
                    border: InputBorder.none,
                  ),
                  style: TextStyle(fontSize: screenWidth * 0.05625),
                )
              : null,
        ),
      ),
    );
  }
}