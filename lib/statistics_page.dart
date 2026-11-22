import 'package:flutter/material.dart';
import 'export_import_helper.dart';
import 'navigation_helper.dart';
import 'theme_provider.dart';

class StatisticsPage extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;

  const StatisticsPage({super.key, required this.screenWidth, required this.screenHeight});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  Map<String, dynamic>? _statistics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    Map<String, dynamic> stats = await ExportImportHelper.getStatistics();
    if (!mounted) return;
    setState(() {
      _statistics = stats;
      _isLoading = false;
    });
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: screenWidth * 0.09375),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "İstatistikler",
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
          const SizedBox(height: 16),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(screenWidth * 0.05, 0, screenWidth * 0.05, 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard("Not", _statistics!['totalNotes'].toString(), Icons.note, Colors.blue),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildStatCard(
                              "Klasör", _statistics!['totalFolders'].toString(), Icons.folder, Colors.orange),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            "Çalışılan",
                            _statistics!['reviewedNotes'].toString(),
                            Icons.school,
                            Colors.teal,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildStatCard(
                            "Başarı",
                            _statistics!['successRate'] == null
                                ? "-"
                                : "%${(_statistics!['successRate'] as double).toStringAsFixed(0)}",
                            Icons.emoji_events,
                            Colors.purple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            "Bugün Tekrar",
                            _statistics!['dueToday'].toString(),
                            Icons.replay_circle_filled,
                            Colors.deepOrange,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildStatCard(
                            "Öğrenildi",
                            _statistics!['learnedNotes'].toString(),
                            Icons.verified,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _sectionTitle("Klasörlere Göre Dağılım", screenWidth),
                    const SizedBox(height: 10),
                    ...(_statistics!['folderCounts'] as Map<String, int>)
                        .entries
                        .map((entry) => _buildFolderCard(entry.key, entry.value, screenWidth)),
                    if ((_statistics!['hardestNotes'] as List).isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _sectionTitle("En Çok Zorlandığın Kartlar", screenWidth),
                      const SizedBox(height: 10),
                      ...(_statistics!['hardestNotes'] as List<Map<String, dynamic>>).map(
                        (note) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(Icons.warning_amber_rounded, color: Colors.red),
                            title: Text(
                              (note['frontText'] ?? '').toString(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Text(
                              "${note['wrongCount'] ?? 0} yanlış",
                              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text, double screenWidth) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: screenWidth * 0.055,
          fontWeight: FontWeight.w700,
          fontFamily: AppFontSettings.labelFontFamily,
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.7), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, size: 36, color: Colors.white.withValues(alpha: 0.8)),
        ],
      ),
    );
  }

  Widget _buildFolderCard(String folderName, int count, double screenWidth) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: const Icon(Icons.folder_outlined, color: Colors.brown, size: 30),
        title: Text(
          folderName.isEmpty ? "Varsayılan" : folderName,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: Colors.brown, borderRadius: BorderRadius.circular(20)),
          child: Text(
            count.toString(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      ),
    );
  }
}
