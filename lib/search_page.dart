import 'package:flutter/material.dart';
import 'new_note_page.dart';
import 'navigation_helper.dart';
import 'note_storage.dart';
import 'theme_provider.dart';

class SearchPage extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;

  SearchPage({required this.screenWidth, required this.screenHeight});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Map<String, dynamic>> _allNotes = [];
  List<Map<String, dynamic>> _filteredNotes = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _searchController.addListener(_filterNotes);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    final notes = await NoteStorage.loadNotes();
    if (!mounted) return;
    _allNotes = notes.reversed.toList(); // en yeni üstte
    _filterNotes();
  }

  void _filterNotes() {
    String query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredNotes = _allNotes;
      } else {
        _filteredNotes = _allNotes.where((note) {
          String frontText = note['frontText']?.toLowerCase() ?? '';
          String backText = note['backText']?.toLowerCase() ?? '';
          String folder = note['folder']?.toLowerCase() ?? '';
          return frontText.contains(query) || backText.contains(query) || folder.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _openNote(int index) async {
    Map<String, dynamic> note = _filteredNotes[index];
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewNotePage(
          screenWidth: widget.screenWidth,
          screenHeight: widget.screenHeight,
          frontText: note['frontText'],
          backText: note['backText'],
          isEditMode: true,
          noteId: note['id'] as String,
          folderName: note['folder'],
          color: note['color'],
        ),
      ),
    );
    await _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: 12,
              left: widget.screenWidth * 0.05,
              right: widget.screenWidth * 0.05,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: widget.screenWidth * 0.09375),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "Not Ara",
                      style: TextStyle(
                        fontSize: widget.screenWidth * 0.1,
                        fontWeight: FontWeight.w800,
                        fontFamily: AppFontSettings.labelFontFamily,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    closeOrGoHome(context);
                  },
                  child: Image.asset(
                    'assets/exit.png',
                    width: widget.screenWidth * 0.09375,
                    height: widget.screenWidth * 0.09375,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: widget.screenWidth * 0.05,
              vertical: widget.screenHeight * 0.02,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Notlarda ara...",
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.brown),
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
              style: TextStyle(fontSize: widget.screenWidth * 0.045),
            ),
          ),
          Expanded(
            child: _filteredNotes.isEmpty
                ? Center(
                    child: Text(
                      _searchController.text.isEmpty ? "Not bulunamadı" : "Arama sonucu bulunamadı",
                      style: TextStyle(
                        fontSize: widget.screenWidth * 0.05,
                        fontFamily: AppFontSettings.labelFontFamily,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.screenWidth * 0.05,
                    ),
                    itemCount: _filteredNotes.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> note = _filteredNotes[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: widget.screenHeight * 0.02),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                          onTap: () => _openNote(index),
                          leading: Builder(builder: (context) {
                            final style = NoteColor.style((note['color'] ?? 'default').toString());
                            return Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: style.paper,
                                shape: BoxShape.circle,
                                border: Border.all(color: style.ink.withValues(alpha: 0.5)),
                              ),
                              child: Icon(style.icon, size: 18, color: style.ink),
                            );
                          }),
                          title: Text(
                            note['frontText'] ?? '',
                            style: TextStyle(
                              fontSize: widget.screenWidth * 0.045,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 5),
                              Text(
                                note['backText'] ?? '',
                                style: TextStyle(fontSize: widget.screenWidth * 0.04),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (note['folder']?.isNotEmpty ?? false)
                                Padding(
                                  padding: EdgeInsets.only(top: 5),
                                  child: Text(
                                    "Klasör: ${note['folder']}",
                                    style: TextStyle(
                                      fontSize: widget.screenWidth * 0.035,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.brown,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
