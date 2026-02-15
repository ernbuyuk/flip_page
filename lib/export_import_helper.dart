import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'dart:io';

class ExportImportHelper {
  // Export notes to a JSON file
  static Future<void> exportNotes(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? notes = prefs.getStringList("notes") ?? [];
      List<String>? folders = prefs.getStringList("folders") ?? [];

      Map<String, dynamic> exportData = {
        "notes": notes,
        "folders": folders,
        "export_date": DateTime.now().toIso8601String(),
      };

      String jsonString = jsonEncode(exportData);

      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/flippage_notlar_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonString);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'FlipPage Notlarım - ${DateTime.now().toString().split(' ')[0]}',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Notlar başarıyla dışa aktarıldı!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Dışa aktarma hatası: $e")),
      );
    }
  }

  // Import notes from a JSON file
  static Future<void> importNotes(BuildContext context) async {
    try {
      // Pick a file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        String contents = await file.readAsString();
        Map<String, dynamic> importData = jsonDecode(contents);

        // Show confirmation dialog
        bool? confirm = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("İçe Aktarmayı Onayla"),
              content: Text(
                "Bu işlem mevcut notlarınızı ekleyecek. Devam etmek istiyor musunuz?",
              ),
              actions: [
                TextButton(
                  child: Text("İptal"),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: Text("Evet"),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        );

        if (confirm == true) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          
          // Get existing data
          List<String> existingNotes = prefs.getStringList("notes") ?? [];
          List<String> existingFolders = prefs.getStringList("folders") ?? [];

          // Add imported data
          List<String> importedNotes = (importData['notes'] as List).cast<String>();
          List<String> importedFolders = (importData['folders'] as List?)?.cast<String>() ?? [];

          existingNotes.addAll(importedNotes);
          existingFolders.addAll(importedFolders.where((f) => !existingFolders.contains(f)));

          // Save combined data
          await prefs.setStringList("notes", existingNotes);
          await prefs.setStringList("folders", existingFolders);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${importedNotes.length} not başarıyla içe aktarıldı!"),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("İçe aktarma hatası: $e")),
      );
    }
  }

  // Get statistics about notes
  static Future<Map<String, dynamic>> getStatistics() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? notesJson = prefs.getStringList("notes") ?? [];
    List<String>? folders = prefs.getStringList("folders") ?? [];

    List<Map<String, dynamic>> notes = notesJson.map((note) => jsonDecode(note) as Map<String, dynamic>).toList();

    Map<String, int> folderCounts = {};
    for (var note in notes) {
      String folder = note['folder'] ?? 'Default';
      if (folder.isEmpty) folder = 'Default';
      folderCounts[folder] = (folderCounts[folder] ?? 0) + 1;
    }

    return {
      'totalNotes': notes.length,
      'totalFolders': folders.length,
      'folderCounts': folderCounts,
    };
  }
}
