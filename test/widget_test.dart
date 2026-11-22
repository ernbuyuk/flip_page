import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flip_page/folder_page.dart';
import 'package:flip_page/main.dart';
import 'package:flip_page/my_notes_main_page.dart';
import 'package:flip_page/my_notes_page.dart';
import 'package:flip_page/new_note_page.dart';
import 'package:flip_page/note_storage.dart';
import 'package:flip_page/search_page.dart';
import 'package:flip_page/settings_page.dart';
import 'package:flip_page/statistics_page.dart';
import 'package:flip_page/study_mode_page.dart';

/// Gerçek telefonlara yakın ekran profilleri (mantıksal dp + sistem çubukları).
class DeviceProfile {
  final String name;
  final Size size;
  final double top;
  final double bottom;
  final double textScale;
  final double keyboard;

  const DeviceProfile(this.name, this.size, {this.top = 24, this.bottom = 48, this.textScale = 1.0, this.keyboard = 0});
}

const profiles = [
  DeviceProfile('kucuk-320x568', Size(320, 568)),
  DeviceProfile('orta-360x640-3tus', Size(360, 640), top: 24, bottom: 48),
  DeviceProfile('pixel-393x851-centik', Size(393, 851), top: 52, bottom: 24),
  DeviceProfile('samsung-384x854-buyukyazi', Size(384, 854), top: 36, bottom: 48, textScale: 1.3),
  DeviceProfile('kisa-360x600-buyukyazi', Size(360, 600), top: 24, bottom: 48, textScale: 1.5),
  DeviceProfile('genis-412x915', Size(412, 915), top: 32, bottom: 16),
  DeviceProfile('tablet-yatay-1280x800', Size(1280, 800), top: 24, bottom: 48),
];

Future<void> seedData() async {
  final notes = [
    {'frontText': 'Merhaba', 'backText': 'Hello', 'folder': 'İngilizce', 'color': 'yellow'},
    {'frontText': 'Kedi', 'backText': 'Cat', 'folder': 'İngilizce', 'color': 'blue'},
    {
      'frontText': 'Uzun bir soru metni ' * 20,
      'backText': 'Uzun bir cevap metni ' * 30,
      'folder': '',
      'color': 'default',
    },
    {'frontText': 'H2O', 'backText': 'Su', 'folder': 'Kimya', 'color': 'green', 'wrongCount': 3, 'correctCount': 1},
  ];
  SharedPreferences.setMockInitialValues({
    'notes': notes.map(jsonEncode).toList(),
    'folders': ['İngilizce', 'Kimya', 'Çok uzun bir klasör adı burada'],
  });
}

Future<void> pumpPage(WidgetTester tester, DeviceProfile p, Widget page) async {
  const dpr = 3.0;
  tester.view.devicePixelRatio = dpr;
  tester.view.physicalSize = p.size * dpr;
  tester.view.padding = FakeViewPadding(top: p.top * dpr, bottom: p.bottom * dpr);
  tester.view.viewPadding = FakeViewPadding(top: p.top * dpr, bottom: p.bottom * dpr);
  tester.view.viewInsets = FakeViewPadding(bottom: p.keyboard * dpr);
  tester.platformDispatcher.textScaleFactorTestValue = p.textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  await tester.pumpWidget(MaterialApp(
    builder: (context, child) => SafeLayout(child: child),
    home: page,
  ));
  await tester.pumpAndSettle();
}

/// Butonun ekranın görünür (güvenli) alanında olduğunu doğrular.
void expectVisible(WidgetTester tester, Finder finder, DeviceProfile p) {
  expect(finder, findsWidgets);
  final rect = tester.getRect(finder.first);
  final safeBottom = p.size.height - (p.keyboard > 0 ? p.keyboard : p.bottom);
  expect(rect.bottom, lessThanOrEqualTo(safeBottom + 0.5),
      reason: '${p.name}: buton alt sınırın dışına taşıyor ($rect)');
  expect(rect.top, greaterThanOrEqualTo(p.top - 0.5), reason: '${p.name}: buton üst sınırın dışına taşıyor ($rect)');
}

void main() {
  testWidgets('App acilisinda ana ekran gorunur', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(FlipPageApp());
    await tester.pumpAndSettle();

    expect(find.text('FlipPage'), findsOneWidget);
    expect(find.text('Yeni Not'), findsOneWidget);
    expect(find.text('Notlarım'), findsOneWidget);
  });

  for (final p in profiles) {
    group('Ekran sigma: ${p.name}', () {
      setUp(seedData);

      testWidgets('Ana sayfa', (tester) async {
        await pumpPage(tester, p, const HomePage());
        expect(find.text('Notlarım'), findsOneWidget);
      });

      testWidgets('Yeni not: butonlar kaydırmadan görünür', (tester) async {
        await pumpPage(tester, p, NewNotePage(screenWidth: p.size.width, screenHeight: p.size.height));
        expectVisible(tester, find.textContaining('Kaydet'), p);
        expectVisible(tester, find.textContaining('Çevir'), p);
      });

      testWidgets('Yeni not: klavye açıkken butonlar görünür', (tester) async {
        final withKeyboard = DeviceProfile(p.name, p.size,
            top: p.top, bottom: p.bottom, textScale: p.textScale, keyboard: p.size.height * 0.42);
        await pumpPage(tester, withKeyboard, NewNotePage(screenWidth: p.size.width, screenHeight: p.size.height));
        expectVisible(tester, find.text('Kaydet'), withKeyboard);
        expectVisible(tester, find.text('Çevir'), withKeyboard);
      });

      testWidgets('Notlarım menüsü', (tester) async {
        await pumpPage(tester, p, NewNotesMainPage(screenWidth: p.size.width, screenHeight: p.size.height));
        expect(find.text('Düzenle'), findsOneWidget);
      });

      testWidgets('Karışık notlar: çalışma modu butonu görünür', (tester) async {
        await pumpPage(tester, p, const MyNotesPage());
        expectVisible(tester, find.text('Çalışma Modu'), p);
      });

      testWidgets('Düzenle: sil/paylaş/düzenle görünür', (tester) async {
        await pumpPage(tester, p, const MyNotesPage(isEditMode: true));
        expectVisible(tester, find.text('Sil'), p);
        expectVisible(tester, find.text('Paylaş'), p);
        expectVisible(tester, find.text('Düzenle'), p);
      });

      testWidgets('Klasörler', (tester) async {
        await pumpPage(tester, p, FolderPage(screenWidth: p.size.width, screenHeight: p.size.height));
        expectVisible(tester, find.text('Klasör Oluştur'), p);
      });

      testWidgets('Çalışma modu: ön ve arka yüz', (tester) async {
        await pumpPage(tester, p, StudyModePage(screenWidth: p.size.width, screenHeight: p.size.height));
        expectVisible(tester, find.text('Cevabı Göster'), p);
        await tester.tap(find.text('Cevabı Göster'));
        await tester.pumpAndSettle();
        expectVisible(tester, find.text('Biliyorum'), p);
        expectVisible(tester, find.text('Bilmiyorum'), p);
      });

      testWidgets('Ayarlar', (tester) async {
        await pumpPage(tester, p, SettingsPage(screenWidth: p.size.width, screenHeight: p.size.height));
        expect(find.text('Ayarlar'), findsOneWidget);
      });

      testWidgets('İstatistikler', (tester) async {
        await pumpPage(tester, p, StatisticsPage(screenWidth: p.size.width, screenHeight: p.size.height));
        expect(find.text('İstatistikler'), findsOneWidget);
      });

      testWidgets('Arama', (tester) async {
        await pumpPage(tester, p, SearchPage(screenWidth: p.size.width, screenHeight: p.size.height));
        expect(find.text('Not Ara'), findsOneWidget);
      });
    });
  }

  group('Çalışma modu akışı', () {
    setUp(seedData);

    Future<int> answerUntilResult(WidgetTester tester, String button) async {
      for (var i = 0; i < 20; i++) {
        if (find.text('Tekrar Çalış').evaluate().isNotEmpty) return i;
        await tester.tap(find.text('Cevabı Göster'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(button));
        await tester.pumpAndSettle();
      }
      return -1;
    }

    testWidgets('Hep "Bilmiyorum" denince oturum biter (her kart en fazla 1 kez tekrar)', (tester) async {
      final p = profiles[2];
      await pumpPage(tester, p, StudyModePage(screenWidth: p.size.width, screenHeight: p.size.height));
      final answers = await answerUntilResult(tester, 'Bilmiyorum');
      expect(answers, 8, reason: '4 kart + 4 tekrar sonrası sonuç ekranı gelmeli');
      expect(find.text('Tekrarda Öğrenilen'), findsOneWidget);
    });

    testWidgets('Hep "Biliyorum" denince tekrar turu olmaz', (tester) async {
      final p = profiles[2];
      await pumpPage(tester, p, StudyModePage(screenWidth: p.size.width, screenHeight: p.size.height));
      final answers = await answerUntilResult(tester, 'Biliyorum');
      expect(answers, 4);
      expect(find.text('Tekrarda Öğrenilen'), findsNothing);
    });
  });

  group('Aralıklı tekrar', () {
    setUp(seedData);

    test('Bilinen kartın aralığı büyür, bilinmeyen sıfırlanır', () {
      final now = DateTime(2026, 11, 15, 14, 30);
      final note = <String, dynamic>{'id': 'x'};
      final intervals = <int>[];
      for (var i = 0; i < 3; i++) {
        SpacedRepetition.schedule(note, correct: true, now: now);
        intervals.add(note['interval'] as int);
      }
      expect(intervals, [1, 3, 8]);
      expect(SpacedRepetition.dueOf(note), DateTime(2026, 11, 23));
      expect(SpacedRepetition.isDue(note, now: now), isFalse);

      SpacedRepetition.schedule(note, correct: false, now: now);
      expect(note['interval'], 0);
      expect(SpacedRepetition.isDue(note, now: now), isTrue);
      expect(SpacedRepetition.easeOf(note), lessThan(2.65));
    });

    test('Çalışma sonucu tekrar gününü kaydeder', () async {
      final notes = await NoteStorage.loadNotes();
      final id = notes[0]['id'] as String;
      await NoteStorage.recordReview(id, correct: true);
      final after = await NoteStorage.loadNotes();
      final note = after.firstWhere((n) => n['id'] == id);
      expect(note['interval'], 1);
      expect(SpacedRepetition.isDue(note), isFalse);
      expect(SpacedRepetition.dueCount(after), notes.length - 1);
    });

    testWidgets('Tekrarı gelmeyen kartlar çalışmaya gelmez; bitince "Bugünlük bu kadar"', (tester) async {
      final notes = await NoteStorage.loadNotes();
      for (final n in notes) {
        await NoteStorage.recordReview(n['id'] as String, correct: true);
      }
      final p = profiles[1];
      await pumpPage(tester, p, StudyModePage(screenWidth: p.size.width, screenHeight: p.size.height));
      expect(find.text('Bugünlük bu kadar!'), findsOneWidget);
      expect(find.textContaining('yarın: 4 kart'), findsOneWidget);
      await tester.tap(find.text('Yine de tüm kartları çalış'));
      await tester.pumpAndSettle();
      expect(find.text('Cevabı Göster'), findsOneWidget);
      expect(find.text('1 / 4'), findsOneWidget);
    });

    testWidgets('Ana sayfada bugünkü tekrar sayısı görünür', (tester) async {
      final p = profiles[0];
      await pumpPage(tester, p, const HomePage());
      expect(find.text('Bugün 4 tekrar'), findsOneWidget);
    });
  });

  group('Sesli okuma', () {
    setUp(seedData);

    testWidgets('Hoparlör butonu kartın yazısını seçilen dilde okur', (tester) async {
      final calls = <MethodCall>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(const MethodChannel('flutter_tts'), (call) async {
        calls.add(call);
        return 1;
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('flutter_tts'), null));

      final p = profiles[2];
      await pumpPage(tester, p, StudyModePage(screenWidth: p.size.width, screenHeight: p.size.height));
      await tester.tap(find.byTooltip('Sesli oku'));
      await tester.pumpAndSettle();

      final speak = calls.where((c) => c.method == 'speak').toList();
      expect(speak, hasLength(1));
      expect((speak.single.arguments as String).isNotEmpty, isTrue);
      expect(calls.any((c) => c.method == 'setLanguage' && c.arguments == 'tr-TR'), isTrue);
    });

    testWidgets('TTS yoksa uygulama çökmez, uyarı gösterir', (tester) async {
      final p = profiles[2];
      await pumpPage(tester, p, StudyModePage(screenWidth: p.size.width, screenHeight: p.size.height));
      await tester.tap(find.byTooltip('Sesli oku'));
      // Eklenti yokken kanal cevabı gerçek zamanlı gelir.
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
      await tester.pumpAndSettle();
      expect(find.textContaining('Sesli okuma'), findsOneWidget);
    });
  });

  group('Veri doğruluğu', () {
    setUp(seedData);

    test('Eski notlara id atanır ve kalıcı olur', () async {
      final first = await NoteStorage.loadNotes();
      final second = await NoteStorage.loadNotes();
      expect(first.every((n) => (n['id'] as String).isNotEmpty), isTrue);
      expect(first.map((n) => n['id']).toSet().length, first.length);
      expect(second.map((n) => n['id']).toList(), first.map((n) => n['id']).toList());
    });

    test('Düzenleme sadece hedef notu değiştirir', () async {
      final notes = await NoteStorage.loadNotes();
      final target = notes[1];
      await NoteStorage.upsertNote(
        id: target['id'] as String,
        frontText: 'Köpek',
        backText: 'Dog',
        folder: target['folder'] as String,
        color: 'pink',
      );
      final after = await NoteStorage.loadNotes();
      expect(after.length, notes.length);
      expect(after[1]['frontText'], 'Köpek');
      expect(after[0]['frontText'], 'Merhaba');
      expect(after[3]['frontText'], 'H2O');
    });

    test('Not silmek diğer klasörlerdeki notlara dokunmaz', () async {
      final notes = await NoteStorage.loadNotes();
      await NoteStorage.deleteNote(notes[0]['id'] as String);
      final after = await NoteStorage.loadNotes();
      expect(after.length, notes.length - 1);
      expect(after.any((n) => n['folder'] == 'Kimya'), isTrue);
    });

    test('Klasör silinince notlar varsayılana taşınabilir', () async {
      await NoteStorage.deleteFolder('İngilizce', deleteNotes: false);
      final notes = await NoteStorage.loadNotes();
      expect(notes.length, 4);
      expect(notes.where((n) => n['folder'] == 'İngilizce'), isEmpty);
      expect(await NoteStorage.loadFolders(), isNot(contains('İngilizce')));
    });

    test('Klasör yeniden adlandırılınca notlar da taşınır', () async {
      await NoteStorage.renameFolder('Kimya', 'Fen');
      final notes = await NoteStorage.loadNotes();
      expect(notes.where((n) => n['folder'] == 'Fen').length, 1);
      expect(await NoteStorage.loadFolders(), contains('Fen'));
    });

    test('Çalışma sonucu nota işlenir', () async {
      final notes = await NoteStorage.loadNotes();
      await NoteStorage.recordReview(notes[0]['id'] as String, correct: false);
      await NoteStorage.recordReview(notes[0]['id'] as String, correct: true);
      final after = await NoteStorage.loadNotes();
      expect(after[0]['wrongCount'], 1);
      expect(after[0]['correctCount'], 1);
    });
  });
}
