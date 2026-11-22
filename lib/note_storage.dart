import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Notlar ve klasörler için tek erişim noktası.
///
/// Her nota benzersiz bir `id` atanır. Önceki sürümlerde notlar liste
/// sırasına (index) göre düzenleniyor/siliniyordu; karıştırılmış veya
/// filtrelenmiş listelerde bu, yanlış notun değişmesine ya da diğer
/// klasörlerdeki notların silinmesine yol açıyordu.
class NoteStorage {
  static const String notesKey = 'notes';
  static const String foldersKey = 'folders';

  static final Random _random = Random();

  /// Notlar her kaydedildiğinde artar; ana sayfadaki "bugünkü tekrar" sayacı
  /// gibi yerler bunu dinleyip yenilenir.
  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  static String newId() {
    final time = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final rand = _random.nextInt(1 << 32).toRadixString(36);
    return '$time$rand';
  }

  /// Tüm notları yükler; id'si olmayan eski notlara id atayıp kaydeder.
  static Future<List<Map<String, dynamic>>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(notesKey) ?? [];
    final notes = <Map<String, dynamic>>[];
    var migrated = false;

    for (final item in raw) {
      try {
        final decoded = jsonDecode(item);
        if (decoded is! Map) continue;
        final note = Map<String, dynamic>.from(decoded);
        if (note['id'] == null || note['id'].toString().isEmpty) {
          note['id'] = newId();
          migrated = true;
        }
        note['frontText'] = (note['frontText'] ?? '').toString();
        note['backText'] = (note['backText'] ?? '').toString();
        note['folder'] = (note['folder'] ?? '').toString();
        note['color'] = (note['color'] ?? 'default').toString();
        notes.add(note);
      } catch (_) {
        migrated = true; // bozuk kaydı at
      }
    }

    if (migrated) {
      await saveNotes(notes);
    }
    return notes;
  }

  static Future<void> saveNotes(List<Map<String, dynamic>> notes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(notesKey, notes.map(jsonEncode).toList());
    changes.value++;
  }

  /// Notu ekler veya aynı id'ye sahip notu günceller.
  static Future<Map<String, dynamic>> upsertNote({
    String? id,
    required String frontText,
    required String backText,
    required String folder,
    required String color,
  }) async {
    final notes = await loadNotes();
    final now = DateTime.now().toIso8601String();
    final index = id == null ? -1 : notes.indexWhere((n) => n['id'] == id);

    Map<String, dynamic> note;
    if (index >= 0) {
      note = Map<String, dynamic>.from(notes[index]);
      note['frontText'] = frontText;
      note['backText'] = backText;
      note['folder'] = folder;
      note['color'] = color;
      note['updatedAt'] = now;
      notes[index] = note;
    } else {
      note = {
        'id': id ?? newId(),
        'frontText': frontText,
        'backText': backText,
        'folder': folder,
        'color': color,
        'createdAt': now,
        'updatedAt': now,
      };
      notes.add(note);
    }
    await saveNotes(notes);
    return note;
  }

  static Future<void> deleteNote(String id) async {
    final notes = await loadNotes();
    notes.removeWhere((n) => n['id'] == id);
    await saveNotes(notes);
  }

  /// Çalışma modundaki sonucu nota işler ve bir sonraki tekrar gününü planlar.
  static Future<void> recordReview(String id, {required bool correct, DateTime? now}) async {
    final notes = await loadNotes();
    final index = notes.indexWhere((n) => n['id'] == id);
    if (index < 0) return;
    final note = notes[index];
    final at = now ?? DateTime.now();
    note['correctCount'] = ((note['correctCount'] as num?) ?? 0).toInt() + (correct ? 1 : 0);
    note['wrongCount'] = ((note['wrongCount'] as num?) ?? 0).toInt() + (correct ? 0 : 1);
    note['lastReviewedAt'] = at.toIso8601String();
    SpacedRepetition.schedule(note, correct: correct, now: at);
    await saveNotes(notes);
  }

  static Future<List<String>> loadFolders() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(foldersKey) ?? [];
  }

  static Future<void> saveFolders(List<String> folders) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(foldersKey, folders);
  }

  /// Klasörü yeniden adlandırır ve içindeki notları taşır.
  static Future<void> renameFolder(String oldName, String newName) async {
    final folders = await loadFolders();
    final i = folders.indexOf(oldName);
    if (i >= 0) folders[i] = newName;
    await saveFolders(folders);

    final notes = await loadNotes();
    for (final note in notes) {
      if (note['folder'] == oldName) note['folder'] = newName;
    }
    await saveNotes(notes);
  }

  /// Klasörü siler. [deleteNotes] false ise notlar varsayılan klasöre taşınır.
  static Future<void> deleteFolder(String name, {required bool deleteNotes}) async {
    final folders = await loadFolders();
    folders.remove(name);
    await saveFolders(folders);

    final notes = await loadNotes();
    if (deleteNotes) {
      notes.removeWhere((n) => n['folder'] == name);
    } else {
      for (final note in notes) {
        if (note['folder'] == name) note['folder'] = '';
      }
    }
    await saveNotes(notes);
  }

  static Future<int> countNotesInFolder(String name) async {
    final notes = await loadNotes();
    return notes.where((n) => n['folder'] == name).length;
  }
}

/// Basit aralıklı tekrar (SM-2'nin iki butonlu sadeleştirilmiş hali).
///
/// Her not şu alanları taşır:
/// - `interval`: bir sonraki tekrara kadar gün sayısı (0 = henüz öğrenilmedi)
/// - `ease`: kolaylık katsayısı (1.3 – 3.0); bildikçe artar, unuttukça azalır
/// - `dueAt`: tekrar zamanı (ISO tarih). Yoksa kart hemen çalışılabilir.
class SpacedRepetition {
  static const double defaultEase = 2.5;
  static const double minEase = 1.3;
  static const double maxEase = 3.0;

  /// Bu kadar gün aralığa ulaşan kart "öğrenildi" sayılır.
  static const int learnedInterval = 21;

  static int intervalOf(Map<String, dynamic> note) => ((note['interval'] as num?) ?? 0).toInt();

  static double easeOf(Map<String, dynamic> note) => ((note['ease'] as num?) ?? defaultEase).toDouble();

  static DateTime? dueOf(Map<String, dynamic> note) {
    final raw = note['dueAt'];
    if (raw is! String || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  static DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Kartın bugün (veya daha önce) tekrar zamanı geldiyse true.
  static bool isDue(Map<String, dynamic> note, {DateTime? now}) {
    final due = dueOf(note);
    if (due == null) return true;
    return !due.isAfter(now ?? DateTime.now());
  }

  /// Cevaba göre `interval`, `ease` ve `dueAt` alanlarını günceller.
  static void schedule(Map<String, dynamic> note, {required bool correct, required DateTime now}) {
    var interval = intervalOf(note);
    var ease = easeOf(note);

    if (correct) {
      if (interval <= 0) {
        interval = 1;
      } else if (interval == 1) {
        interval = 3;
      } else {
        interval = (interval * ease).round();
      }
      ease = min(maxEase, ease + 0.05);
    } else {
      interval = 0;
      ease = max(minEase, ease - 0.2);
    }
    interval = min(interval, 365);

    note['interval'] = interval;
    note['ease'] = double.parse(ease.toStringAsFixed(2));
    // Bilinmeyen kart bugün tekrar çalışılabilir; bilinen kart ilgili günün başında açılır.
    note['dueAt'] = (interval == 0 ? now : _startOfDay(now).add(Duration(days: interval))).toIso8601String();
  }

  /// Bugün tekrar edilecek kart sayısı.
  static int dueCount(Iterable<Map<String, dynamic>> notes, {DateTime? now}) =>
      notes.where((n) => isDue(n, now: now)).length;

  /// Bugün hiç kart yoksa sıradaki tekrar günü.
  static DateTime? nextDue(Iterable<Map<String, dynamic>> notes, {DateTime? now}) {
    DateTime? best;
    for (final n in notes) {
      final d = dueOf(n);
      if (d == null || !d.isAfter(now ?? DateTime.now())) continue;
      if (best == null || d.isBefore(best)) best = d;
    }
    return best;
  }

  /// "yarın", "3 gün sonra" gibi okunur ifade.
  static String describeDays(int days) {
    if (days <= 0) return "bugün";
    if (days == 1) return "yarın";
    if (days < 30) return "$days gün sonra";
    if (days < 365) return "${(days / 30).round()} ay sonra";
    return "1 yıl sonra";
  }
}
