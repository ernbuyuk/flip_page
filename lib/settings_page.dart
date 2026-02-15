import 'package:flutter/material.dart';
import 'export_import_helper.dart';
import 'statistics_page.dart';
import 'search_page.dart';

class SettingsPage extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;

  SettingsPage({required this.screenWidth, required this.screenHeight});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F0EB),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: screenHeight * 0.04,
              left: screenWidth * 0.05,
              right: screenWidth * 0.05,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: screenWidth * 0.075),
                Text(
                  "Ayarlar",
                  style: TextStyle(
                    fontSize: screenWidth * 0.1125,
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
                    width: screenWidth * 0.09375,
                    height: screenHeight * 0.06,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.05),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              children: [
                _buildSettingsCard(
                  context,
                  "Not Ara",
                  "Notlarınızı hızlıca arayın",
                  Icons.search,
                  Colors.blue,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchPage(
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: screenHeight * 0.02),
                _buildSettingsCard(
                  context,
                  "İstatistikler",
                  "Not ve klasör istatistiklerinizi görün",
                  Icons.bar_chart,
                  Colors.purple,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StatisticsPage(
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: screenHeight * 0.02),
                _buildSettingsCard(
                  context,
                  "Notları Dışa Aktar",
                  "Notlarınızı yedekleyin",
                  Icons.upload_file,
                  Colors.green,
                  () async {
                    await ExportImportHelper.exportNotes(context);
                  },
                ),
                SizedBox(height: screenHeight * 0.02),
                _buildSettingsCard(
                  context,
                  "Notları İçe Aktar",
                  "Yedeklenmiş notları geri yükleyin",
                  Icons.download,
                  Colors.orange,
                  () async {
                    await ExportImportHelper.importNotes(context);
                  },
                ),
                SizedBox(height: screenHeight * 0.03),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.brown),
                            SizedBox(width: 8),
                            Text(
                              "Hakkında",
                              style: TextStyle(
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          "FlipPage v1.0.0",
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Flashcard tarzı not tutma uygulaması",
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: screenWidth * 0.08,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: screenWidth * 0.035,
            color: Colors.grey[600],
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: screenWidth * 0.04,
          color: Colors.grey,
        ),
      ),
    );
  }
}
