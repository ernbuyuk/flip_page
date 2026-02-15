import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'new_note_page.dart';

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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? notesJson = prefs.getStringList("notes") ?? [];
    setState(() {
      _allNotes = notesJson.map((note) => jsonDecode(note) as Map<String, dynamic>).toList();
      _filteredNotes = _allNotes;
    });
  }

  void _filterNotes() {
    String query = _searchController.text.toLowerCase();
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

  void _openNote(int index) {
    Map<String, dynamic> note = _filteredNotes[index];
    // Find the original index in _allNotes
    int originalIndex = _allNotes.indexWhere((n) => 
      n['frontText'] == note['frontText'] && 
      n['backText'] == note['backText'] && 
      n['folder'] == note['folder']
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewNotePage(
          screenWidth: widget.screenWidth,
          screenHeight: widget.screenHeight,
          frontText: note['frontText'],
          backText: note['backText'],
          isEditMode: true,
          noteIndex: originalIndex,
          folderName: note['folder'],
        ),
      ),
    ).then((_) => _loadNotes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F0EB),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: widget.screenHeight * 0.04,
              left: widget.screenWidth * 0.05,
              right: widget.screenWidth * 0.05,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: widget.screenWidth * 0.075),
                Text(
                  "Not Ara",
                  style: TextStyle(
                    fontSize: widget.screenWidth * 0.1125,
                    fontWeight: FontWeight.w800,
                    fontFamily: "Cursive",
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Image.asset(
                    'assets/exit.png',
                    width: widget.screenWidth * 0.09375,
                    height: widget.screenHeight * 0.06,
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.brown),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              style: TextStyle(fontSize: widget.screenWidth * 0.045),
            ),
          ),
          Expanded(
            child: _filteredNotes.isEmpty
                ? Center(
                    child: Text(
                      _searchController.text.isEmpty
                          ? "Not bulunamadı"
                          : "Arama sonucu bulunamadı",
                      style: TextStyle(
                        fontSize: widget.screenWidth * 0.05,
                        fontFamily: "Cursive",
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
                        child: ListTile(
                          onTap: () => _openNote(index),
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
