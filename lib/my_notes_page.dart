import 'dart:math';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'new_note_page.dart';
import 'study_mode_page.dart';
import 'navigation_helper.dart';
import 'note_storage.dart';
import 'theme_provider.dart';
import 'note_card.dart';
import 'speech_service.dart';

class MyNotesPage extends StatefulWidget {
  final bool isEditMode;
  final String? folderName;

  const MyNotesPage({super.key, this.isEditMode = false, this.folderName});

  @override
  State<MyNotesPage> createState() => _MyNotesPageState();
}

class _MyNotesPageState extends State<MyNotesPage> with SingleTickerProviderStateMixin {
  static const String _mixedFolderName = 'Karışık';

  List<Map<String, dynamic>> _notes = [];
  bool _loading = true;
  int currentIndex = 0;
  double _dragDx = 0;
  late AnimationController _animationController;
  bool _isFront = true;
  bool _isTextVisible = true;

  bool get _filtersByFolder => widget.folderName != null && widget.folderName != _mixedFolderName;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _isFront = !_isFront;
            _animationController.reset();
            _isTextVisible = true;
          });
        }
      })
      ..addListener(() {
        final visible = _animationController.value <= 0.5;
        if (visible != _isTextVisible) {
          setState(() => _isTextVisible = visible);
        }
      });

    _loadNotes();
  }

  /// Notları yükler. [keepId] verilirse o not tekrar öne getirilir
  /// (düzenleme sonrası kullanıcının yeri kaybolmasın diye).
  Future<void> _loadNotes({String? keepId}) async {
    final all = await NoteStorage.loadNotes();
    var notes = _filtersByFolder ? all.where((n) => n['folder'] == widget.folderName).toList() : all;

    if (keepId != null && _notes.isNotEmpty) {
      // Mevcut sırayı koru, sadece içerikleri güncelle.
      final byId = {for (final n in notes) n['id']: n};
      final ordered = <Map<String, dynamic>>[];
      for (final old in _notes) {
        final updated = byId.remove(old['id']);
        if (updated != null) ordered.add(updated);
      }
      ordered.addAll(byId.values);
      notes = ordered;
    } else {
      notes.shuffle(Random());
    }

    if (!mounted) return;
    setState(() {
      _notes = notes;
      _loading = false;
      if (keepId != null) {
        final i = _notes.indexWhere((n) => n['id'] == keepId);
        currentIndex = i >= 0 ? i : 0;
      }
      if (currentIndex >= _notes.length) currentIndex = 0;
    });
  }

  void _goTo(int delta) {
    if (_notes.isEmpty) return;
    setState(() {
      currentIndex = (currentIndex + delta + _notes.length) % _notes.length;
      _isFront = true;
      _animationController.reset();
      _isTextVisible = true;
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() => _dragDx += details.delta.dx);
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (_dragDx.abs() > 80 || velocity.abs() > 600) {
      final isNext = (_dragDx != 0 ? _dragDx : velocity) < 0;
      _goTo(isNext ? 1 : -1);
    }
    setState(() => _dragDx = 0);
  }

  void _flipCard() {
    if (!_animationController.isAnimating) {
      _animationController.forward();
    }
  }

  void _resetFlip() {
    if (!_isFront && !_animationController.isAnimating) {
      _animationController.forward();
    }
  }

  Future<void> _deleteNote() async {
    if (_notes.isEmpty) return;
    final note = _notes[currentIndex];
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Notu Sil"),
        content: Text(
          "\"${_preview(note['frontText'])}\" notu silinsin mi? Bu işlem geri alınamaz.",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text("İptal")),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Sil"),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    // Önceden sadece ekrandaki (filtrelenmiş) liste kaydediliyordu ve bu,
    // diğer klasörlerdeki notların silinmesine yol açabiliyordu.
    await NoteStorage.deleteNote(note['id'] as String);
    if (!mounted) return;
    setState(() {
      _notes.removeAt(currentIndex);
      if (_notes.isEmpty) {
        currentIndex = 0;
      } else {
        currentIndex = currentIndex % _notes.length;
      }
      _isFront = true;
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text("Not silindi.")));
  }

  String _preview(dynamic text) {
    final s = (text ?? '').toString().replaceAll('\n', ' ').trim();
    if (s.isEmpty) return '(boş)';
    return s.length > 40 ? '${s.substring(0, 40)}…' : s;
  }

  Future<void> _editNote() async {
    if (_notes.isEmpty) return;
    final note = _notes[currentIndex];
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => NewNotePage(
          screenWidth: MediaQuery.of(context).size.width,
          screenHeight: MediaQuery.of(context).size.height,
          frontText: note['frontText'],
          backText: note['backText'],
          isEditMode: true,
          noteId: note['id'] as String,
          folderName: note['folder'] as String? ?? '',
          color: note['color'],
        ),
      ),
    );
    if (changed == true) {
      await _loadNotes(keepId: note['id'] as String);
    }
  }

  void _shareNote() {
    if (_notes.isNotEmpty) {
      Map<String, dynamic> note = _notes[currentIndex];
      final folder = (note['folder'] ?? '').toString();
      String shareText = '''
FlipPage Notu

Ön Yüz: ${note['frontText'] ?? ''}

Arka Yüz: ${note['backText'] ?? ''}
${folder.isNotEmpty ? '\nKlasör: $folder' : ''}''';
      Share.share(shareText.trim(), subject: 'FlipPage Notu');
    }
  }

  void _openStudyMode() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudyModePage(
          screenWidth: MediaQuery.of(context).size.width,
          screenHeight: MediaQuery.of(context).size.height,
          folderName: widget.folderName ?? _mixedFolderName,
        ),
      ),
    ).then((_) => _loadNotes(keepId: _notes.isEmpty ? null : _notes[currentIndex]['id'] as String));
  }

  @override
  void dispose() {
    SpeechService.stop();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 12, left: screenWidth * 0.05, right: screenWidth * 0.05),
            child: Row(
              children: [
                Semantics(
                  button: true,
                  label: 'Geri',
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Image.asset('assets/backpage.png', width: screenWidth * 0.11),
                  ),
                ),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        widget.isEditMode ? "Düzenle" : (widget.folderName ?? "Notlarım"),
                        style: TextStyle(
                          fontSize: screenWidth * 0.1,
                          fontWeight: FontWeight.w800,
                          fontFamily: AppFontSettings.labelFontFamily,
                        ),
                      ),
                    ),
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Ana sayfa',
                  child: GestureDetector(
                    onTap: () => closeOrGoHome(context),
                    child: Image.asset(
                      'assets/exit.png',
                      width: screenWidth * 0.09375,
                      height: screenWidth * 0.09375,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_notes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                "${currentIndex + 1} / ${_notes.length}  •  Kaydır: sonraki  •  Dokun: çevir",
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _notes.isEmpty
                    ? const Center(
                        child: Text(
                          "Kayıtlı not bulunamadı.",
                          style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onHorizontalDragUpdate: _onDragUpdate,
                            onHorizontalDragEnd: _onDragEnd,
                            onTap: _flipCard,
                            onLongPress: _flipCard,
                            onLongPressEnd: (details) => _resetFlip(),
                            child: Stack(
                              alignment: Alignment.center,
                              children: _buildCardStack(constraints),
                            ),
                          );
                        },
                      ),
          ),
          if (widget.isEditMode && _notes.isNotEmpty)
            _buildEditButtons(screenWidth)
          else if (_notes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: _openStudyMode,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 4),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/flip.png', width: screenWidth * 0.12, height: screenWidth * 0.12),
                        SizedBox(width: screenWidth * 0.02),
                        Text(
                          "Çalışma Modu",
                          style: TextStyle(
                            fontSize: screenWidth * 0.07,
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w800,
                            fontFamily: AppFontSettings.labelFontFamily,
                          ),
                        ),
                        Builder(builder: (context) {
                          final due = SpacedRepetition.dueCount(_notes);
                          return Container(
                            margin: EdgeInsets.only(left: screenWidth * 0.02),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: due > 0 ? Colors.deepOrange : Colors.green,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              due > 0 ? "$due tekrar" : "✓ tamam",
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEditButtons(double screenWidth) {
    Widget button(String label, Widget icon, VoidCallback onTap) {
      return Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  icon,
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: screenWidth * 0.065,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                      fontFamily: AppFontSettings.labelFontFamily,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final iconSize = screenWidth * 0.1;
    return Padding(
      padding: EdgeInsets.fromLTRB(screenWidth * 0.02, 0, screenWidth * 0.02, 10),
      child: Row(
        children: [
          button("Sil", Image.asset('assets/delete.png', width: iconSize, height: iconSize), _deleteNote),
          button("Paylaş", Icon(Icons.share, size: iconSize, color: Colors.brown), _shareNote),
          button("Düzenle", Image.asset('assets/edit.png', width: iconSize, height: iconSize), _editNote),
        ],
      ),
    );
  }

  List<Widget> _buildCardStack(BoxConstraints constraints) {
    final displayCount = min(_notes.length, 5);
    const stepOffset = 12.0;
    final stackSpace = stepOffset * (displayCount - 1);
    final cardWidth = constraints.maxWidth * 0.9;
    // Kart, mevcut alana sığacak şekilde boyutlanır (eski hali ekran yüksekliğinin
    // %60'ı + 190px ofset kullanıyordu ve kısa ekranlarda başlığın üstüne taşıyordu).
    final cardHeight = max(120.0, min(constraints.maxHeight - stackSpace - 32, cardWidth * 1.45));

    final stack = <Widget>[];
    for (int i = 0; i < displayCount; i++) {
      final noteIndex = (currentIndex + i) % _notes.length;
      final isTop = i == 0;
      stack.add(Transform.translate(
        offset: Offset(isTop ? _dragDx : 0, -stepOffset * i + stackSpace / 2),
        child: Transform.rotate(
          angle: isTop ? _dragDx / 2000 : 0,
          child: Transform.scale(
            scale: isTop ? 1.0 : 1.0 - 0.03 * i,
            child: _buildNoteCard(_notes[noteIndex], isTop, cardWidth, cardHeight),
          ),
        ),
      ));
    }
    return stack.reversed.toList();
  }

  Widget _buildNoteCard(Map<String, dynamic> note, bool isTopCard, double width, double height) {
    final folderName = (note["folder"] ?? "").toString();
    if (!isTopCard) {
      return _buildCard(note, "", false, folderName, width, height);
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(_animationController.value * 3.1416),
          alignment: Alignment.center,
          child: _buildCard(
            note,
            _isFront ? (note["frontText"] ?? "") : (note["backText"] ?? ""),
            true,
            folderName,
            width,
            height,
          ),
        );
      },
    );
  }

  Widget _buildCard(
      Map<String, dynamic> note, String text, bool isTopCard, String folderName, double width, double height) {
    final screenWidth = MediaQuery.of(context).size.width;
    final colorName = (note['color'] ?? 'default').toString();
    final style = NoteColor.style(colorName);
    final showText = isTopCard && _isTextVisible;

    return NoteCard(
      colorName: colorName,
      width: width,
      height: height,
      child: showText
          ? Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 60, 28, 32),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Text(
                          text.isEmpty ? (_isFront ? "(Ön yüz boş)" : "(Arka yüz boş)") : text,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenWidth * 0.055,
                            fontWeight: FontWeight.bold,
                            color: style.text,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 32,
                  left: 30,
                  right: 30,
                  child: Row(
                    children: [
                      NoteCardLabel(colorName: colorName, text: _isFront ? "SORU" : "CEVAP", fontSize: 11),
                      SpeakButton(
                        text: text,
                        front: _isFront,
                        speakKey: 'list-${note['id']}-$_isFront',
                        color: style.ink,
                        size: 22,
                      ),
                      const Spacer(),
                      Flexible(
                        child: Text(
                          folderName.isEmpty ? "(varsayılan)" : "($folderName)",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: style.ink.withValues(alpha: 0.75),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : null,
    );
  }

}
