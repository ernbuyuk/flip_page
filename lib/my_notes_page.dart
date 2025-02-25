import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math'; // Import dart:math for shuffling
import 'new_note_page.dart';

class MyNotesPage extends StatefulWidget {
  final bool isEditMode;
  final String? folderName;

  MyNotesPage({this.isEditMode = false, this.folderName});

  @override
  _MyNotesPageState createState() => _MyNotesPageState();
}

class _MyNotesPageState extends State<MyNotesPage> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _notes = [];
  int currentIndex = 0;
  Offset _offset = Offset.zero;
  late AnimationController _animationController;
  bool _isFront = true;
  bool _isFlipping = false;
  bool _isTextVisible = true;

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
            _isFlipping = false;
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

    _loadNotes();
  }

  Future<void> _loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? notesJson = prefs.getStringList("notes") ?? [];
    setState(() {
      _notes = notesJson.map((note) => jsonDecode(note) as Map<String, dynamic>).toList();
      if (widget.folderName != null && widget.folderName != "Karışık") {
        _notes = _notes.where((note) => note['folder'] == widget.folderName).toList();
      }
      _notes.shuffle(Random()); // Shuffle the notes
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _offset = Offset(details.localPosition.dx - MediaQuery.of(context).size.width / 2, 0);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_offset.dx.abs() > 100) {
      bool isNext = _offset.dx < 0;
      setState(() {
        currentIndex = isNext
            ? (currentIndex + 1) % _notes.length
            : (currentIndex - 1 + _notes.length) % _notes.length;
      });
    }
    setState(() {
      _offset = Offset.zero;
    });
  }

  void _flipCard() {
    if (!_isFlipping) {
      setState(() {
        _isFlipping = true;
        _animationController.forward();
      });
    }
  }

  void _resetFlip() {
    if (!_isFront) {
      setState(() {
        _animationController.forward();
      });
    }
  }

  void _deleteNote() {
    setState(() {
      if (_notes.isNotEmpty) {
        _notes.removeAt(currentIndex);
        if (_notes.isEmpty) {
          currentIndex = 0;
        } else {
          currentIndex = currentIndex % _notes.length;
        }
      }
    });
    _saveNotes();
  }

  void _editNote() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewNotePage(
          screenWidth: MediaQuery.of(context).size.width,
          screenHeight: MediaQuery.of(context).size.height,
          frontText: _notes[currentIndex]['frontText'],
          backText: _notes[currentIndex]['backText'],
          isEditMode: true,
          noteIndex: currentIndex,
          folderName: widget.folderName,
        ),
      ),
    ).then((updatedNotes) {
      if (updatedNotes != null) {
        setState(() {
          _notes = (updatedNotes as List<String>).map<Map<String, dynamic>>((note) => jsonDecode(note)).toList();
          if (widget.folderName != null && widget.folderName != "Karışık") {
            _notes = _notes.where((note) => note['folder'] == widget.folderName).toList();
          }
        });
      }
    });
  }

  Future<void> _saveNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> notesJson = _notes.map((note) => jsonEncode(note)).toList();
    prefs.setStringList("notes", notesJson);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

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
                      width: screenWidth * 0.11,
                    ),
                  ),
                  Text(
                    widget.folderName ?? "Notlarım",
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
              child: Center(
                child: _notes.isEmpty
                    ? const Text(
                        "Kayıtlı not bulunamadı.",
                        style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                      )
                    : GestureDetector(
                        onHorizontalDragUpdate: _onDragUpdate,
                        onHorizontalDragEnd: _onDragEnd,
                        onLongPress: _flipCard,
                        onLongPressEnd: (details) => _resetFlip(),
                        child: Stack(
                          alignment: Alignment.center,
                          children: _buildCardStack(),
                        ),
                      ),
              ),
            ),
            if (widget.isEditMode)
              Padding(
                padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _deleteNote,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                        decoration: BoxDecoration(
                          color: Color(0xFFF5F0EB), // Arka fonla aynı renk
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          children: [
                            Image.asset('assets/delete.png', width: screenWidth * 0.16, height: screenHeight * 0.08), // Soldaki görsel
                            SizedBox(width: screenWidth * 0.02), // Boşluk
                            Text(
                              "Sil",
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
                    SizedBox(width: screenWidth * 0.05),
                    GestureDetector(
                      onTap: _editNote,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                        decoration: BoxDecoration(
                          color: Color(0xFFF5F0EB), // Arka fonla aynı renk
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          children: [
                            Image.asset('assets/edit.png', width: screenWidth * 0.16, height: screenHeight * 0.08), // Soldaki görsel
                            SizedBox(width: screenWidth * 0.02), // Boşluk
                            Text(
                              "Düzenle",
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
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCardStack() {
    List<Widget> stack = [];
    int displayCount = _notes.length < 8 ? _notes.length : 8;

    for (int i = 0; i < displayCount; i++) {
      int noteIndex = (currentIndex + i) % _notes.length;
      double scale = i == 0 ? 1.0 : 0.95;
      double opacity = i < 0 ? 0.0 : 1.0;
      double positionOffset = i * 20.0 + 50;

      stack.add(Positioned(
        bottom: positionOffset,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Transform.translate(
              offset: i == 0 ? _offset : Offset.zero,
              child: _buildNoteCard(_notes[noteIndex], i == 0),
            ),
          ),
        ),
      ));
    }

    return stack.reversed.toList();
  }

  Widget _buildNoteCard(Map<String, dynamic> note, bool isTopCard) {
    String folderName = note["folder"] ?? "(default)";
    if (!isTopCard) {
      return _buildCard(note["frontText"] ?? "Ön Yüz", false, folderName);
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(_animationController.value * 3.1416),
          alignment: Alignment.center,
          child: _isFront ? _buildFront(note, folderName) : _buildBack(note, folderName),
        );
      },
    );
  }

  Widget _buildFront(Map<String, dynamic> note, String folderName) {
    return _buildCard(note["frontText"] ?? "Ön Yüz", true, folderName);
  }

  Widget _buildBack(Map<String, dynamic> note, String folderName) {
    return _buildCard(note["backText"] ?? "Arka Yüz", true, folderName);
  }

  
  Widget _buildCard(String text, bool isTopCard, String folderName) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * 0.90, // 250 / 400 = 0.625
      height: screenHeight * 0.60, // 350 / 800 = 0.4375
      decoration: BoxDecoration(
        color: Colors.brown.shade100,
        borderRadius: BorderRadius.circular(screenWidth * 0.0375), // 15 / 400 = 0.0375
        border: Border.all(color: Colors.brown, width: screenWidth * 0.0075), // 3 / 400 = 0.0075
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: screenWidth * 0.025, // 10 / 400 = 0.025
            spreadRadius: screenWidth * 0.005, // 2 / 400 = 0.005
            offset: Offset(screenWidth * 0.0075, screenHeight * 0.015), // (3 / 400, 6 / 800) = (0.0075, 0.015)
          ),
        ],
        image: const DecorationImage(
          image: AssetImage("assets/card_template.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          if (isTopCard && _isTextVisible)
            Center(
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.04), // 16 / 400 = 0.04
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold), // 20 / 400 = 0.05
                ),
              ),
            ),
          Positioned(
            top: screenHeight * 0.02, // 16 / 800 = 0.02
            right: screenWidth * 0.15, // 16 / 400 = 0.02
            child: Opacity(
              opacity: 0.5, // Şeffaflık
              child: Text(
                folderName.isEmpty ? "(default)" :"($folderName)",
                style: TextStyle(
                  fontSize: screenWidth * 0.04, // 16 / 400 = 0.04
                  fontStyle: FontStyle.italic,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}