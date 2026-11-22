import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'dart:io';

import 'note_storage.dart';

class ExportImportHelper {
  static void _snack(BuildContext context, String text) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  // Export notes to a JSON file
  static Future<void> exportNotes(BuildContext context) async {
    try {
      final notes = await NoteStorage.loadNotes();
      final folders = await NoteStorage.loadFolders();

      if (notes.isEmpty && folders.isEmpty) {
        _snack(context, "Dışa aktarılacak not bulunamadı.");
        return;
      }

      Map<String, dynamic> exportData = {
        "app": "FlipPage",
        "formatVersion": 2,
        // Eski sürümlerle uyumluluk için notlar JSON metni olarak saklanır.
        "notes": notes.map(jsonEncode).toList(),
        "folders": folders,
        "exportDate": DateTime.now().toIso8601String(),
      };

      String jsonString = jsonEncode(exportData);

      final directory = await getTemporaryDirectory();
      final date = DateTime.now().toIso8601String().split('T').first;
      final file = File('${directory.path}/flippage_yedek_$date.json');
      await file.writeAsString(jsonString);

      final result = await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/json')],
        text: 'FlipPage Notlarım - $date',
      );

      if (result.status == ShareResultStatus.success) {
        _snack(context, "${notes.length} not dışa aktarıldı!");
      }
    } catch (e) {
      _snack(context, "Dışa aktarma hatası: $e");
    }
  }

  static String _contentKey(Map<String, dynamic> n) =>
      '${n['frontText'] ?? ''}\u0000${n['backText'] ?? ''}\u0000${n['folder'] ?? ''}';

  // Import notes from a JSON file
  static Future<void> importNotes(BuildContext context) async {
    try {
      // Bazı Android dosya yöneticileri .json dosyalarını "application/json"
      // olarak işaretlemediği için uzantı filtresi dosyaları gri gösterebiliyor.
      // Bu yüzden her dosya seçilebilir, içerik aşağıda doğrulanır.
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: true,
      );

      if (result == null) return;
      final picked = result.files.single;
      String contents;
      if (picked.bytes != null) {
        contents = utf8.decode(picked.bytes!);
      } else if (picked.path != null) {
        contents = await File(picked.path!).readAsString();
      } else {
        _snack(context, "Dosya okunamadı.");
        return;
      }

      final decoded = jsonDecode(contents);
      if (decoded is! Map || decoded['notes'] is! List) {
        _snack(context, "Bu dosya bir FlipPage yedeği değil.");
        return;
      }

      final importedNotes = <Map<String, dynamic>>[];
      for (final item in decoded['notes'] as List) {
        final value = item is String ? jsonDecode(item) : item;
        if (value is Map) importedNotes.add(Map<String, dynamic>.from(value));
      }
      final importedFolders = ((decoded['folders'] as List?) ?? []).map((f) => f.toString()).toList();

      final existingNotes = await NoteStorage.loadNotes();
      final existingFolders = await NoteStorage.loadFolders();
      final existingIds = existingNotes.map((n) => n['id']).toSet();
      final existingContent = existingNotes.map(_contentKey).toSet();

      final toAdd = <Map<String, dynamic>>[];
      for (final note in importedNotes) {
        final key = _contentKey(note);
        if (existingContent.contains(key)) continue; // aynı not zaten var
        if (note['id'] == null || existingIds.contains(note['id'])) {
          note['id'] = NoteStorage.newId();
        }
        existingIds.add(note['id']);
        existingContent.add(key);
        toAdd.add(note);
      }
      final skipped = importedNotes.length - toAdd.length;

      if (!context.mounted) return;
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text("İçe Aktarmayı Onayla"),
            content: Text(
              "${toAdd.length} yeni not mevcut notlarınıza eklenecek."
              "${skipped > 0 ? "\n\n$skipped not zaten kayıtlı olduğu için atlanacak." : ""}"
              "\n\nDevam etmek istiyor musunuz?",
            ),
            actions: [
              TextButton(
                child: const Text("İptal"),
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

      if (confirm != true) return;

      final folders = [...existingFolders];
      for (final f in importedFolders) {
        if (f.trim().isNotEmpty && !folders.contains(f)) folders.add(f);
      }
      // Notlarda geçen ama klasör listesinde olmayan klasörleri de ekle.
      for (final n in toAdd) {
        final f = (n['folder'] ?? '').toString();
        if (f.isNotEmpty && !folders.contains(f)) folders.add(f);
      }

      await NoteStorage.saveNotes([...existingNotes, ...toAdd]);
      await NoteStorage.saveFolders(folders);

      _snack(context, "${toAdd.length} not başarıyla içe aktarıldı!");
    } on FormatException {
      _snack(context, "Dosya geçerli bir JSON değil.");
    } catch (e) {
      _snack(context, "İçe aktarma hatası: $e");
    }
  }

  // Get statistics about notes
  static Future<Map<String, dynamic>> getStatistics() async {
    final notes = await NoteStorage.loadNotes();
    final folders = await NoteStorage.loadFolders();

    Map<String, int> folderCounts = {};
    int correct = 0;
    int wrong = 0;
    int reviewed = 0;
    for (var note in notes) {
      String folder = (note['folder'] ?? '').toString();
      folderCounts[folder] = (folderCounts[folder] ?? 0) + 1;
      final c = ((note['correctCount'] as num?) ?? 0).toInt();
      final w = ((note['wrongCount'] as num?) ?? 0).toInt();
      correct += c;
      wrong += w;
      if (c + w > 0) reviewed++;
    }

    final hardest = notes.where((n) => ((n['wrongCount'] as num?) ?? 0) > 0).toList()
      ..sort((a, b) => ((b['wrongCount'] as num?) ?? 0).compareTo((a['wrongCount'] as num?) ?? 0));

    return {
      'totalNotes': notes.length,
      'totalFolders': folders.length,
      'folderCounts': folderCounts,
      'reviewedNotes': reviewed,
      'successRate': correct + wrong == 0 ? null : correct / (correct + wrong) * 100,
      'hardestNotes': hardest.take(5).toList(),
      'dueToday': SpacedRepetition.dueCount(notes),
      'learnedNotes': notes.where((n) => SpacedRepetition.intervalOf(n) >= SpacedRepetition.learnedInterval).length,
    };
  }
}
