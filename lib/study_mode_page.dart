import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import 'theme_provider.dart';

class StudyModePage extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final String? folderName;

  StudyModePage({
    required this.screenWidth,
    required this.screenHeight,
    this.folderName,
  });

  @override
  _StudyModePageState createState() => _StudyModePageState();
}

class _StudyModePageState extends State<StudyModePage> {
  static const String _mixedFolderName = 'Karışık';

  List<Map<String, dynamic>> _notes = [];
  List<Map<String, dynamic>> _studyQueue = [];
  int currentIndex = 0;
  bool _isFront = true;
  int _correctCount = 0;
  int _incorrectCount = 0;
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? notesJson = prefs.getStringList("notes") ?? [];
    List<Map<String, dynamic>> allNotes =
        notesJson.map((note) => jsonDecode(note) as Map<String, dynamic>).toList();

    // Filter by folder if specified
    if (widget.folderName != null && widget.folderName != _mixedFolderName) {
      allNotes = allNotes.where((note) => note['folder'] == widget.folderName).toList();
    }

    // Shuffle for random order
    allNotes.shuffle(Random());

    setState(() {
      _notes = allNotes;
      _studyQueue = List.from(_notes);
    });
  }

  void _flipCard() {
    setState(() {
      _isFront = !_isFront;
    });
  }

  void _markCorrect() {
    setState(() {
      _correctCount++;
      _nextCard();
    });
  }

  void _markIncorrect() {
    setState(() {
      _incorrectCount++;
      // Add card back to queue for review
      if (currentIndex < _studyQueue.length) {
        _studyQueue.add(_studyQueue[currentIndex]);
      }
      _nextCard();
    });
  }

  void _nextCard() {
    if (currentIndex < _studyQueue.length - 1) {
      setState(() {
        currentIndex++;
        _isFront = true;
      });
    } else {
      setState(() {
        _showResult = true;
      });
    }
  }

  void _restartStudy() {
    setState(() {
      currentIndex = 0;
      _correctCount = 0;
      _incorrectCount = 0;
      _showResult = false;
      _isFront = true;
      _studyQueue = List.from(_notes);
      _studyQueue.shuffle(Random());
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showResult) {
      return _buildResultScreen();
    }

    if (_studyQueue.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox,
                size: 100,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              SizedBox(height: 20),
              Text(
                "Çalışılacak not bulunamadı",
                style: TextStyle(
                  fontSize: widget.screenWidth * 0.05,
                  fontFamily: "Cursive",
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Geri Dön"),
              ),
            ],
          ),
        ),
      );
    }

    Map<String, dynamic> currentNote = _studyQueue[currentIndex];
    String cardColor = currentNote['color'] ?? 'default';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.only(
              top: widget.screenHeight * 0.01,
              left: widget.screenWidth * 0.05,
              right: widget.screenWidth * 0.05,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: widget.screenWidth * 0.11,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(Icons.arrow_back, size: widget.screenWidth * 0.075),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "Çalışma Modu",
                          style: TextStyle(
                            fontSize: widget.screenWidth * 0.08,
                            fontWeight: FontWeight.w800,
                            fontFamily: "Cursive",
                          ),
                        ),
                      ),
                      Text(
                        "${currentIndex + 1} / ${_studyQueue.length}",
                        style: TextStyle(
                          fontSize: widget.screenWidth * 0.04,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: widget.screenWidth * 0.2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          "$_correctCount",
                          style: TextStyle(
                            fontSize: widget.screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: widget.screenHeight * 0.03),

          // Progress bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.screenWidth * 0.05),
            child: LinearProgressIndicator(
              value: (currentIndex + 1) / _studyQueue.length,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.brown),
              minHeight: 8,
            ),
          ),
          SizedBox(height: widget.screenHeight * 0.03),

          // Card
          GestureDetector(
            onTap: _flipCard,
            child: _buildCardContent(
              _isFront
                  ? (currentNote['frontText'] ?? '')
                  : (currentNote['backText'] ?? ''),
              cardColor,
              _isFront ? "Dokunarak çevir" : "Cevabı biliyor musun?",
            ),
          ),
          SizedBox(height: widget.screenHeight * 0.03),

          // Action buttons (only show after flipping)
          if (!_isFront)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: widget.screenWidth * 0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    "Bilmiyorum",
                    Icons.close,
                    Colors.red,
                    _markIncorrect,
                  ),
                  _buildActionButton(
                    "Biliyorum",
                    Icons.check,
                    Colors.green,
                    _markCorrect,
                  ),
                ],
              ),
            ),
        ],
      ),
      ),
    );
  }

  Widget _buildCardContent(String text, String cardColor, String hint) {
    return Container(
      width: widget.screenWidth * 0.9,
      height: widget.screenHeight * 0.5,
      decoration: BoxDecoration(
        color: NoteColor.getColor(cardColor),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(widget.screenWidth * 0.05),
                child: SingleChildScrollView(
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: widget.screenWidth * 0.055,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 15),
            child: Text(
              hint,
              style: TextStyle(
                fontSize: widget.screenWidth * 0.035,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, color: Colors.white),
          label: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: widget.screenWidth * 0.04,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    int total = _correctCount + _incorrectCount;
    double percentage = total > 0 ? (_correctCount / total * 100) : 0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(widget.screenWidth * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                percentage >= 70 ? Icons.emoji_events : Icons.refresh,
                size: 100,
                color: percentage >= 70
                    ? Colors.amber
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              SizedBox(height: 20),
              Text(
                percentage >= 70 ? "Harika İş!" : "İyi Deneme!",
                style: TextStyle(
                  fontSize: widget.screenWidth * 0.08,
                  fontWeight: FontWeight.w900,
                  fontFamily: "Cursive",
                ),
              ),
              SizedBox(height: 30),
              _buildStatRow("Doğru", _correctCount, Colors.green),
              SizedBox(height: 10),
              _buildStatRow("Yanlış", _incorrectCount, Colors.red),
              SizedBox(height: 10),
              _buildStatRow(
                  "Başarı Oranı", "${percentage.toStringAsFixed(1)}%", Colors.blue),
              SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _restartStudy,
                      icon: Icon(Icons.replay),
                      label: Text("Tekrar Çalış"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.home),
                      label: Text("Ana Sayfa"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, dynamic value, Color color) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: widget.screenWidth * 0.045,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: widget.screenWidth * 0.05,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
