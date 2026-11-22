import 'package:flutter/material.dart';
import 'theme_provider.dart';
import 'note_card.dart';
import 'navigation_helper.dart';
import 'note_storage.dart';

class NewNotePage extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final String? frontText;
  final String? backText;
  final bool isEditMode;

  /// Düzenlenen notun id'si (düzenleme modunda zorunlu).
  final String? noteId;
  final String? folderName;
  final String? color;

  const NewNotePage({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    this.frontText,
    this.backText,
    this.isEditMode = false,
    this.noteId,
    this.folderName,
    this.color,
  });

  @override
  State<NewNotePage> createState() => _NewNotePageState();
}

class _NewNotePageState extends State<NewNotePage> with SingleTickerProviderStateMixin {
  bool _isFront = true;
  bool _isTextVisible = true;
  bool _isSaving = false;
  final TextEditingController _frontController = TextEditingController();
  final TextEditingController _backController = TextEditingController();
  late AnimationController _animationController;
  List<String> _folders = [];
  String _selectedColor = 'default';
  String _selectedFolder = '';
  bool _folderChosen = false;

  String _initialFront = '';
  String _initialBack = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
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

    _selectedFolder = widget.folderName ?? '';
    _folderChosen = widget.isEditMode || widget.folderName != null;

    if (widget.isEditMode) {
      _frontController.text = widget.frontText ?? '';
      _backController.text = widget.backText ?? '';
      _selectedColor = widget.color ?? 'default';
    }
    _initialFront = _frontController.text;
    _initialBack = _backController.text;

    _loadFolders();
  }

  Future<void> _loadFolders() async {
    final folders = await NoteStorage.loadFolders();
    if (!mounted) return;
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

  bool _isNoteEmpty() {
    return _frontController.text.trim().isEmpty && _backController.text.trim().isEmpty;
  }

  bool get _hasUnsavedChanges {
    if (widget.isEditMode) {
      return _frontController.text != _initialFront || _backController.text != _initialBack;
    }
    return !_isNoteEmpty();
  }

  void _flip() {
    if (_animationController.isAnimating) return;
    FocusScope.of(context).unfocus();
    _animationController.forward();
  }

  Future<void> _onSavePressed() async {
    if (_isSaving) return;
    if (_isNoteEmpty()) {
      _showSnack("Lütfen bir metin girin!");
      return;
    }
    if (!_folderChosen && _folders.isNotEmpty) {
      final folder = await _pickFolder();
      if (folder == null) return; // iptal
      _selectedFolder = folder;
      _folderChosen = true;
    }
    await _save();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    await NoteStorage.upsertNote(
      id: widget.isEditMode ? widget.noteId : null,
      frontText: _frontController.text,
      backText: _backController.text,
      folder: _selectedFolder,
      color: _selectedColor,
    );
    if (!mounted) return;
    setState(() => _isSaving = false);

    _showSnack("Not Kaydedildi!");

    if (widget.isEditMode) {
      Navigator.pop(context, true);
      return;
    }

    // Yeni not: alanları temizle, ön yüze dön. Renk ve klasör seri giriş için korunur.
    _frontController.clear();
    _backController.clear();
    _initialFront = '';
    _initialBack = '';
    setState(() {
      _isFront = true;
      // Kullanıcı klasörü dialogdan seçtiyse bir sonraki notta tekrar sorulsun.
      _folderChosen = widget.folderName != null;
    });
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text), duration: const Duration(seconds: 2)));
  }

  Future<String?> _pickFolder() {
    return showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        final options = ['', ..._folders];
        return AlertDialog(
          title: const Text("Klasör Seç"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (context, index) {
                final name = options[index];
                return ListTile(
                  leading: Icon(name.isEmpty ? Icons.inbox_outlined : Icons.folder_outlined),
                  title: Text(name.isEmpty ? "Varsayılan" : name),
                  trailing: name == _selectedFolder ? const Icon(Icons.check) : null,
                  onTap: () => Navigator.of(dialogContext).pop(name),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text("İptal"),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _confirmDiscard() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Emin misiniz?"),
          content: const Text("Son yazdığınız not kaydedilmedi. Geri gitmek istediğinize emin misiniz?"),
          actions: [
            TextButton(
              child: const Text("Hayır"),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            TextButton(
              child: const Text("Evet"),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<void> _onExitPressed() async {
    if (!_hasUnsavedChanges || await _confirmDiscard()) {
      if (mounted) closeOrGoHome(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return PopScope(
      // Sistem geri tuşu / geri hareketi de kaydedilmemiş notu korur.
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmDiscard() && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final h = constraints.maxHeight;
            final compact = keyboardOpen || h < 520;
            return Column(
              children: [
                _buildHeader(screenWidth, h),
                if (!keyboardOpen) _buildOptionsRow(screenWidth),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.025,
                      vertical: 6,
                    ),
                    child: GestureDetector(
                      onHorizontalDragEnd: (details) {
                        if ((details.primaryVelocity ?? 0).abs() > 200) _flip();
                      },
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(_animationController.value * 3.1416),
                            alignment: Alignment.center,
                            child: _buildCard(screenWidth),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                compact ? _buildCompactButtons(screenWidth) : _buildLargeButtons(screenWidth, h),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(double screenWidth, double h) {
    return Padding(
      padding: EdgeInsets.only(top: h * 0.015, left: screenWidth * 0.05, right: screenWidth * 0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: screenWidth * 0.09375),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                widget.isEditMode ? "Notu Düzenle" : "Yeni Not",
                style: TextStyle(
                  fontSize: screenWidth * 0.1,
                  fontWeight: FontWeight.w800,
                  fontFamily: AppFontSettings.labelFontFamily,
                ),
              ),
            ),
          ),
          Semantics(
            button: true,
            label: 'Kapat',
            child: GestureDetector(
              onTap: _onExitPressed,
              child: Image.asset(
                'assets/exit.png',
                width: screenWidth * 0.09375,
                height: screenWidth * 0.09375,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Renk ve klasör seçimi.
  Widget _buildOptionsRow(double screenWidth) {
    return Padding(
      padding: EdgeInsets.fromLTRB(screenWidth * 0.04, 8, screenWidth * 0.04, 0),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: NoteColor.colorNames.map((name) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: NoteColorSwatch(
                      colorName: name,
                      selected: name == _selectedColor,
                      size: 34,
                      onTap: () => setState(() => _selectedColor = name),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          if (_folders.isNotEmpty)
            ActionChip(
              avatar: const Icon(Icons.folder_outlined, size: 18),
              label: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: screenWidth * 0.25),
                child: Text(
                  _selectedFolder.isEmpty ? "Varsayılan" : _selectedFolder,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              onPressed: () async {
                final folder = await _pickFolder();
                if (folder != null) {
                  setState(() {
                    _selectedFolder = folder;
                    _folderChosen = true;
                  });
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCard(double screenWidth) {
    final controller = _isFront ? _frontController : _backController;
    final style = NoteColor.style(_selectedColor);
    return NoteCard(
      colorName: _selectedColor,
      width: double.infinity,
      child: _isTextVisible
          ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: NoteCardLabel(
                    colorName: _selectedColor,
                    text: _isFront ? "ÖN YÜZ · SORU" : "ARKA YÜZ · CEVAP",
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08, vertical: 8),
                    child: TextField(
                      key: ValueKey(_isFront),
                      controller: controller,
                      expands: true,
                      maxLines: null,
                      textAlign: TextAlign.center,
                      textAlignVertical: TextAlignVertical.center,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: _isFront ? "Ön yüz yazısını buraya yazın..." : "Arka yüz yazısını buraya yazın...",
                        hintStyle: TextStyle(color: style.text.withValues(alpha: 0.45)),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(fontSize: screenWidth * 0.055, color: style.text),
                      cursorColor: style.ink,
                    ),
                  ),
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildLargeButtons(double screenWidth, double h) {
    return Padding(
      padding: EdgeInsets.only(bottom: h * 0.01),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _largeButton("Sayfayı Çevir", 'assets/flip.png', _flip, screenWidth, h),
          _largeButton(
              _isSaving ? "Kaydediliyor..." : "Notu Kaydet", 'assets/file_yellow.png', _onSavePressed, screenWidth, h),
        ],
      ),
    );
  }

  Widget _largeButton(String text, String asset, VoidCallback onTap, double screenWidth, double h) {
    final iconHeight = (h * 0.065).clamp(32.0, 64.0);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(asset, width: iconHeight * 2, height: iconHeight),
            SizedBox(width: screenWidth * 0.02),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: screenWidth * 0.085,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                    fontFamily: AppFontSettings.labelFontFamily,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Klavye açıkken / kısa ekranlarda tek satırlık butonlar.
  Widget _buildCompactButtons(double screenWidth) {
    return Padding(
      padding: EdgeInsets.fromLTRB(screenWidth * 0.04, 2, screenWidth * 0.04, 6),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _flip,
              icon: const Icon(Icons.flip),
              label: const FittedBox(child: Text("Çevir")),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.brown),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FilledButton.icon(
              onPressed: _onSavePressed,
              icon: const Icon(Icons.save_outlined),
              label: const FittedBox(child: Text("Kaydet")),
              style: FilledButton.styleFrom(backgroundColor: Colors.brown),
            ),
          ),
        ],
      ),
    );
  }
}
