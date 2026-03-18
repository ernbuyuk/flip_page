import 'package:flutter/material.dart';
import 'export_import_helper.dart';
import 'navigation_helper.dart';

class StatisticsPage extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;

  StatisticsPage({required this.screenWidth, required this.screenHeight});

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
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
    setState(() {
      _statistics = stats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                  "İstatistikler",
                  style: TextStyle(
                    fontSize: widget.screenWidth * 0.1125,
                    fontWeight: FontWeight.w800,
                    fontFamily: "Cursive",
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    closeOrGoHome(context);
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
          SizedBox(height: widget.screenHeight * 0.05),
          if (_isLoading)
            Center(child: CircularProgressIndicator())
          else
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.screenWidth * 0.05,
                ),
                child: Column(
                  children: [
                    _buildStatCard(
                      "Toplam Not Sayısı",
                      _statistics!['totalNotes'].toString(),
                      Icons.note,
                      Colors.blue,
                    ),
                    SizedBox(height: widget.screenHeight * 0.02),
                    _buildStatCard(
                      "Klasör Sayısı",
                      _statistics!['totalFolders'].toString(),
                      Icons.folder,
                      Colors.orange,
                    ),
                    SizedBox(height: widget.screenHeight * 0.03),
                    Text(
                      "Klasörlere Göre Dağılım",
                      style: TextStyle(
                        fontSize: widget.screenWidth * 0.06,
                        fontWeight: FontWeight.w700,
                        fontFamily: "Cursive",
                      ),
                    ),
                    SizedBox(height: widget.screenHeight * 0.02),
                    ...(_statistics!['folderCounts'] as Map<String, int>)
                        .entries
                        .map((entry) => _buildFolderCard(entry.key, entry.value))
                        .toList(),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: EdgeInsets.all(widget.screenWidth * 0.05),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.7), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: widget.screenWidth * 0.045,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: widget.screenWidth * 0.1,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Icon(
              icon,
              size: widget.screenWidth * 0.15,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFolderCard(String folderName, int count) {
    return Card(
      margin: EdgeInsets.only(bottom: widget.screenHeight * 0.015),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          Icons.folder_outlined,
          color: Colors.brown,
          size: widget.screenWidth * 0.08,
        ),
        title: Text(
          folderName.isEmpty ? "Default" : folderName,
          style: TextStyle(
            fontSize: widget.screenWidth * 0.045,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.screenWidth * 0.03,
            vertical: widget.screenHeight * 0.01,
          ),
          decoration: BoxDecoration(
            color: Colors.brown,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: widget.screenWidth * 0.04,
            ),
          ),
        ),
      ),
    );
  }
}
