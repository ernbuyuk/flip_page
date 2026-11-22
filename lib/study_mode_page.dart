import 'dart:math';

import 'package:flutter/material.dart';
import 'note_storage.dart';
import 'theme_provider.dart';
import 'note_card.dart';
import 'speech_service.dart';

class StudyModePage extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final String? folderName;

  /// true: sadece tekrar zamanı gelmiş kartlar (aralıklı tekrar).
  final bool dueOnly;

  const StudyModePage({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    this.folderName,
    this.dueOnly = true,
  });

  @override
  State<StudyModePage> createState() => _StudyModePageState();
}

class _StudyModePageState extends State<StudyModePage> {
  static const String _mixedFolderName = 'Karışık';

  List<Map<String, dynamic>> _notes = [];
  List<Map<String, dynamic>> _studyQueue = [];
  bool _loading = true;
  int currentIndex = 0;
  bool _isFront = true;
  int _correctCount = 0;
  int _incorrectCount = 0;
  bool _showResult = false;

  /// İlk turdaki kart sayısı; bundan sonraki kartlar tekrar turudur.
  int _firstRoundSize = 0;

  /// Tekrar turunda bilinen kart sayısı.
  int _relearnedCount = 0;

  /// Çift dokunmada iki kart birden geçilmesin diye.
  bool _answering = false;

  bool get _isRetry => currentIndex >= _firstRoundSize;

  /// Daha çok yanlış bilinen kartları öne alır.
  bool _hardFirst = false;

  /// Kartları arka yüzden (cevaptan) başlatır.
  bool _reverse = false;

  /// Sadece bugün tekrar zamanı gelen kartlar.
  late bool _dueOnly = widget.dueOnly;

  @override
  void initState() {
    super.initState();
    SpeechService.load().then((_) {
      if (mounted) setState(() {});
    });
    _loadNotes();
  }

  @override
  void dispose() {
    SpeechService.stop();
    super.dispose();
  }

  /// Ekranda görünen yüz (ters modda önce cevap gösterilir).
  bool get _showingFront => _isFront != _reverse;

  /// "Otomatik oku" açıksa ekrandaki yüzü sesli okur.
  void _autoSpeak() {
    if (!SpeechService.autoRead || _showResult || currentIndex >= _studyQueue.length) return;
    final note = _studyQueue[currentIndex];
    final text = (_showingFront ? note['frontText'] : note['backText'])?.toString() ?? '';
    SpeechService.speak(text, front: _showingFront, key: '$currentIndex-$_isFront');
  }

  Future<void> _loadNotes() async {
    List<Map<String, dynamic>> allNotes = await NoteStorage.loadNotes();

    if (widget.folderName != null && widget.folderName != _mixedFolderName) {
      allNotes = allNotes.where((note) => note['folder'] == widget.folderName).toList();
    }

    if (!mounted) return;
    setState(() {
      _notes = allNotes;
      _loading = false;
      _studyQueue = _buildQueue();
      _firstRoundSize = _studyQueue.length;
    });
    _autoSpeak();
  }

  static double _difficulty(Map<String, dynamic> note) {
    final c = ((note['correctCount'] as num?) ?? 0).toDouble();
    final w = ((note['wrongCount'] as num?) ?? 0).toDouble();
    // Hiç çalışılmamış kartlar orta zorlukta sayılır.
    return (w + 1) / (c + w + 2);
  }

  List<Map<String, dynamic>> _buildQueue() {
    final source = _dueOnly ? _notes.where((n) => SpacedRepetition.isDue(n)) : _notes;
    final queue = List<Map<String, dynamic>>.from(source)..shuffle(Random());
    if (_hardFirst) {
      queue.sort((a, b) => _difficulty(b).compareTo(_difficulty(a)));
    }
    return queue;
  }

  void _flipCard() {
    setState(() {
      _isFront = !_isFront;
    });
    _autoSpeak();
  }

  void _markCorrect() => _answer(correct: true);

  void _markIncorrect() => _answer(correct: false);

  /// Puan sadece kartın ilk cevabıyla hesaplanır. Bilinmeyen kart tur sonunda
  /// yalnızca bir kez tekrar gösterilir; böylece oturum her zaman biter.
  void _answer({required bool correct}) {
    if (_answering || _showResult || currentIndex >= _studyQueue.length) return;
    _answering = true;
    final note = _studyQueue[currentIndex];
    NoteStorage.recordReview(note['id'] as String, correct: correct);
    setState(() {
      if (_isRetry) {
        if (correct) _relearnedCount++;
      } else if (correct) {
        _correctCount++;
      } else {
        _incorrectCount++;
        _studyQueue.add(note);
      }
      if (currentIndex < _studyQueue.length - 1) {
        currentIndex++;
        _isFront = true;
      } else {
        _showResult = true;
      }
    });
    _answering = false;
    if (_showResult) {
      SpeechService.stop();
    } else {
      _autoSpeak();
    }
  }

  void _restartStudy() {
    setState(() {
      currentIndex = 0;
      _correctCount = 0;
      _incorrectCount = 0;
      _showResult = false;
      _isFront = true;
      _relearnedCount = 0;
      _studyQueue = _buildQueue();
      _firstRoundSize = _studyQueue.length;
    });
    _autoSpeak();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_showResult) {
      return _buildResultScreen();
    }

    final screenWidth = MediaQuery.of(context).size.width;

    if (_studyQueue.isEmpty && _dueOnly && _notes.isNotEmpty) {
      return _buildAllDoneScreen(screenWidth);
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
              const SizedBox(height: 20),
              Text(
                "Çalışılacak not bulunamadı",
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontFamily: AppFontSettings.labelFontFamily,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Geri Dön"),
              ),
            ],
          ),
        ),
      );
    }

    final currentNote = _studyQueue[currentIndex];
    final cardColor = (currentNote['color'] ?? 'default').toString();
    final showingFront = _showingFront;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.only(top: 8, left: screenWidth * 0.03, right: screenWidth * 0.03),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  tooltip: "Geri",
                  icon: const Icon(Icons.arrow_back),
                ),
                Expanded(
                  child: Column(
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "Çalışma Modu",
                          style: TextStyle(
                            fontSize: screenWidth * 0.08,
                            fontWeight: FontWeight.w800,
                            fontFamily: AppFontSettings.labelFontFamily,
                          ),
                        ),
                      ),
                      Text(
                        _isRetry
                            ? "Tekrar: ${currentIndex - _firstRoundSize + 1} / ${_studyQueue.length - _firstRoundSize}"
                            : "${currentIndex + 1} / $_firstRoundSize",
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                _scoreChip(_incorrectCount, Colors.red),
                const SizedBox(width: 4),
                _scoreChip(_correctCount, Colors.green),
                PopupMenuButton<String>(
                  tooltip: "Seçenekler",
                  onSelected: (value) {
                    if (value == 'auto') {
                      SpeechService.save(auto: !SpeechService.autoRead);
                      setState(() {});
                      if (SpeechService.autoRead) {
                        _autoSpeak();
                      } else {
                        SpeechService.stop();
                      }
                      return;
                    }
                    setState(() {
                      if (value == 'hard') _hardFirst = !_hardFirst;
                      if (value == 'reverse') _reverse = !_reverse;
                      if (value == 'due') _dueOnly = !_dueOnly;
                    });
                    _restartStudy();
                  },
                  itemBuilder: (context) => [
                    CheckedPopupMenuItem(
                      value: 'due',
                      checked: _dueOnly,
                      child: const Text("Sadece bugünkü tekrarlar"),
                    ),
                    CheckedPopupMenuItem(
                      value: 'auto',
                      checked: SpeechService.autoRead,
                      child: const Text("Kartları otomatik oku"),
                    ),
                    CheckedPopupMenuItem(
                      value: 'hard',
                      checked: _hardFirst,
                      child: const Text("Önce zor kartlar"),
                    ),
                    CheckedPopupMenuItem(
                      value: 'reverse',
                      checked: _reverse,
                      child: const Text("Cevaptan başla"),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Progress bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (currentIndex + 1) / _studyQueue.length,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.brown),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Card: kalan tüm alanı kullanır, butonlar her zaman görünür kalır.
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: GestureDetector(
                onTap: _flipCard,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: Tween<double>(begin: 0.92, end: 1).animate(animation),
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: _buildCardContent(
                    key: ValueKey('$currentIndex-$_isFront'),
                    text: showingFront ? (currentNote['frontText'] ?? '') : (currentNote['backText'] ?? ''),
                    cardColor: cardColor,
                    label: (showingFront ? "SORU" : "CEVAP") + (_isRetry ? " · TEKRAR" : ""),
                    hint: _isFront ? "Dokunarak çevir" : "Cevabı biliyor musun?",
                    speakFront: showingFront,
                    speakKey: '$currentIndex-$_isFront',
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          Padding(
            padding: EdgeInsets.fromLTRB(screenWidth * 0.05, 0, screenWidth * 0.05, 12),
            child: _isFront
                ? SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _flipCard,
                      icon: const Icon(Icons.flip, color: Colors.white),
                      label: const Text("Cevabı Göster",
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  )
                : Row(
                    children: [
                      _buildActionButton("Bilmiyorum", Icons.close, Colors.red, _markIncorrect),
                      _buildActionButton("Biliyorum", Icons.check, Colors.green, _markCorrect),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _scoreChip(int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        "$value",
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildCardContent({
    required Key key,
    required String text,
    required String cardColor,
    required String label,
    required String hint,
    required bool speakFront,
    required String speakKey,
  }) {
    final style = NoteColor.style(cardColor);
    return NoteCard(
      key: key,
      colorName: cardColor,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
              child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 22),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(child: NoteCardLabel(colorName: cardColor, text: label)),
                    SpeakButton(text: text, front: speakFront, speakKey: speakKey, color: style.ink),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                    child: Text(
                      text.isEmpty ? "(boş)" : text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: widget.screenWidth * 0.055,
                        fontWeight: FontWeight.w600,
                        color: style.text,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 34),
                child: Text(
                  hint,
                  style: TextStyle(
                    fontSize: 13,
                    color: style.ink.withValues(alpha: 0.75),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }

  /// Bugün tekrar edilecek kart kalmadığında gösterilir.
  Widget _buildAllDoneScreen(double screenWidth) {
    final next = SpacedRepetition.nextDue(_notes);
    String nextText = "";
    if (next != null) {
      final today = DateTime.now();
      final days =
          DateTime(next.year, next.month, next.day).difference(DateTime(today.year, today.month, today.day)).inDays;
      final count = _notes.where((n) {
        final d = SpacedRepetition.dueOf(n);
        return d != null && d.year == next.year && d.month == next.month && d.day == next.day;
      }).length;
      nextText = "Sıradaki tekrar ${SpacedRepetition.describeDays(days)}: $count kart";
    }
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.06),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.task_alt, size: 96, color: Colors.green),
              const SizedBox(height: 16),
              Text(
                "Bugünlük bu kadar!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.07,
                  fontWeight: FontWeight.w900,
                  fontFamily: AppFontSettings.labelFontFamily,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Tekrar zamanı gelen kartların hepsini çalıştın.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              if (nextText.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  nextText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() => _dueOnly = false);
                    _restartStudy();
                  },
                  icon: const Icon(Icons.style),
                  label: const Text("Yine de tüm kartları çalış"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: const Text("Geri Dön"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, color: Colors.white),
          label: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    final screenWidth = MediaQuery.of(context).size.width;
    int total = _correctCount + _incorrectCount;
    double percentage = total > 0 ? (_correctCount / total * 100) : 0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                percentage >= 70 ? Icons.emoji_events : Icons.refresh,
                size: 100,
                color: percentage >= 70 ? Colors.amber : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 20),
              Text(
                percentage >= 70 ? "Harika İş!" : "İyi Deneme!",
                style: TextStyle(
                  fontSize: screenWidth * 0.08,
                  fontWeight: FontWeight.w900,
                  fontFamily: AppFontSettings.labelFontFamily,
                ),
              ),
              const SizedBox(height: 30),
              _buildStatRow("Doğru", _correctCount, Colors.green),
              const SizedBox(height: 10),
              _buildStatRow("Yanlış", _incorrectCount, Colors.red),
              const SizedBox(height: 10),
              _buildStatRow("Başarı Oranı", "%${percentage.toStringAsFixed(1)}", Colors.blue),
              const SizedBox(height: 14),
              Text(
                "Bildiğin kartlar birkaç gün sonra, bilmediklerin daha erken tekrar karşına çıkacak.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              if (_incorrectCount > 0) ...[
                const SizedBox(height: 10),
                _buildStatRow("Tekrarda Öğrenilen", "$_relearnedCount / $_incorrectCount", Colors.orange),
              ],
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _restartStudy,
                      icon: const Icon(Icons.replay),
                      label: const FittedBox(child: Text("Tekrar Çalış")),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const FittedBox(child: Text("Notlara Dön")),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
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
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value.toString(),
            style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.w900, color: color),
          ),
        ],
      ),
    );
  }
}
