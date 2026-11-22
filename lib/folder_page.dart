import 'package:flutter/material.dart';
import 'my_notes_page.dart';
import 'navigation_helper.dart';
import 'note_storage.dart';
import 'theme_provider.dart';

class FolderPage extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;

  const FolderPage({super.key, required this.screenWidth, required this.screenHeight});

  @override
  State<FolderPage> createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {
  List<String> _folders = [];
  Map<String, int> _counts = {};

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    final folders = await NoteStorage.loadFolders();
    final notes = await NoteStorage.loadNotes();
    final counts = <String, int>{};
    for (final n in notes) {
      final f = (n['folder'] ?? '').toString();
      counts[f] = (counts[f] ?? 0) + 1;
    }
    if (!mounted) return;
    setState(() {
      _folders = folders;
      _counts = counts;
    });
  }

  String? _validateName(String name, {String? except}) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return "Klasör adı boş olamaz";
    if (trimmed == 'Karışık') return "Bu ad ayrılmış";
    final exists = _folders.any((f) => f != except && f.toLowerCase() == trimmed.toLowerCase());
    if (exists) return "Bu adda bir klasör zaten var";
    return null;
  }

  /// Ad soran ortak dialog. Geçerli bir ad girilirse döndürür.
  Future<String?> _askName({required String title, required String action, String initial = '', String? except}) {
    final controller = TextEditingController(text: initial);
    String? error;
    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void submit() {
              final e = _validateName(controller.text, except: except);
              if (e != null) {
                setDialogState(() => error = e);
                return;
              }
              Navigator.of(dialogContext).pop(controller.text.trim());
            }

            return AlertDialog(
              title: Text(title),
              content: TextField(
                controller: controller,
                autofocus: true,
                maxLength: 40,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(hintText: "Klasör Adı", errorText: error),
                onSubmitted: (_) => submit(),
              ),
              actions: [
                TextButton(
                  child: const Text("İptal"),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
                TextButton(onPressed: submit, child: Text(action)),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showAddFolderDialog() async {
    final name = await _askName(title: "Klasör Oluştur", action: "Oluştur");
    if (name == null) return;
    await NoteStorage.saveFolders([..._folders, name]);
    await _loadFolders();
  }

  Future<void> _renameFolder(String oldName) async {
    final name = await _askName(title: "Yeniden Adlandır", action: "Kaydet", initial: oldName, except: oldName);
    if (name == null || name == oldName) return;
    await NoteStorage.renameFolder(oldName, name);
    await _loadFolders();
  }

  Future<void> _deleteFolder(String name) async {
    final count = _counts[name] ?? 0;
    // null: iptal, false: notları taşı, true: notları da sil
    final deleteNotes = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Klasörü Sil"),
          content: Text(
            count == 0
                ? "\"$name\" klasörünü silmek istediğinizden emin misiniz?"
                : "\"$name\" klasöründe $count not var. Notlar ne olsun?",
          ),
          actions: [
            TextButton(
              child: const Text("İptal"),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            if (count > 0)
              TextButton(
                child: const Text("Varsayılana taşı"),
                onPressed: () => Navigator.of(dialogContext).pop(false),
              ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(count > 0 ? "Notlarla sil" : "Sil"),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );
    if (deleteNotes == null) return;
    await NoteStorage.deleteFolder(name, deleteNotes: deleteNotes);
    await _loadFolders();
  }

  void _showFolderActions(String name) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text("Yeniden adlandır"),
              onTap: () {
                Navigator.pop(sheetContext);
                _renameFolder(name);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text("Sil", style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(sheetContext);
                _deleteFolder(name);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardColor = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 12, left: screenWidth * 0.05, right: screenWidth * 0.05),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Image.asset(
                    'assets/backpage.png',
                    width: screenWidth * 0.09375,
                    height: screenWidth * 0.09375,
                  ),
                ),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "Klasörler",
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
          Expanded(
            child: _folders.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        "Henüz klasör yok.\nAşağıdan yeni bir klasör oluşturun.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: EdgeInsets.all(screenWidth * 0.05),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 220,
                      crossAxisSpacing: screenWidth * 0.05,
                      mainAxisSpacing: screenWidth * 0.05,
                      childAspectRatio: 1.15,
                    ),
                    itemCount: _folders.length,
                    itemBuilder: (context, index) {
                      final name = _folders[index];
                      final count = _counts[name] ?? 0;
                      return Material(
                        color: cardColor,
                        elevation: 4,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MyNotesPage(folderName: name)),
                            );
                            _loadFolders();
                          },
                          onLongPress: () => _showFolderActions(name),
                          child: Stack(
                            children: [
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 160),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.folder, color: Colors.brown, size: 36),
                                          const SizedBox(height: 6),
                                          Text(
                                            name,
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            "$count not",
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: IconButton(
                                  icon: const Icon(Icons.more_vert, size: 20),
                                  tooltip: "Seçenekler",
                                  onPressed: () => _showFolderActions(name),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: _showAddFolderDialog,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 2),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/file_yellow.png', width: screenWidth * 0.14, height: screenWidth * 0.12),
                      SizedBox(width: screenWidth * 0.02),
                      Text(
                        "Klasör Oluştur",
                        style: TextStyle(
                          fontSize: screenWidth * 0.08,
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
          ),
        ],
      ),
    );
  }
}
