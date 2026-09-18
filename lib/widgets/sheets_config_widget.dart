import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_provider.dart';
import '../services/google_sheets_service.dart';

class SheetsConfigWidget extends StatefulWidget {
  const SheetsConfigWidget({super.key});

  @override
  State<SheetsConfigWidget> createState() => _SheetsConfigWidgetState();
}

class _SheetsConfigWidgetState extends State<SheetsConfigWidget> {
  final _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AttendanceProvider>(context, listen: false);
    _urlController.text = provider.sheetsService.webAppUrl ?? '';
  }

  @override

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);
    final isConfigured = provider.sheetsService.isConfigured;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Connection Status Header Card
          Card(
            color: isConfigured ? Colors.green[50] : Colors.amber[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isConfigured ? Colors.green : Colors.amber.shade700,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    isConfigured ? Icons.cloud_done : Icons.cloud_off,
                    color: isConfigured ? Colors.green[700] : Colors.amber[800],
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isConfigured
                              ? 'Đã kết nối với Google Sheets Web App!'
                              : 'Đang chạy ở chế độ Chế độ Nội bộ (Local DB Mode)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isConfigured ? Colors.green[900] : Colors.amber[900],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isConfigured
                              ? 'Mọi lượt điểm danh và trạng thái sinh viên sẽ được đồng bộ trực tiếp lên Google Sheet của bạn.'
                              : 'Dữ liệu được lưu trực tiếp trong bộ nhớ ứng dụng. Bạn có thể nhập URL Google Apps Script bên dưới để kết nối Database thực.',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  if (isConfigured)
                    ElevatedButton.icon(
                      onPressed: () => provider.syncWithGoogleSheets(),
                      icon: const Icon(Icons.sync),
                      label: const Text('Đồng bộ ngay'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], foregroundColor: Colors.white),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Google Apps Script Web App URL Input
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cấu hình Web App URL của Google Sheets',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Dán đường dẫn Web App URL sau khi deploy Google Apps Script:',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _urlController,
                          decoration: const InputDecoration(
                            hintText: 'https://script.google.com/macros/s/.../exec',
                            prefixIcon: Icon(Icons.link),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          provider.setGoogleSheetsUrl(_urlController.text.trim());
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã cập nhật Google Sheets Web App URL!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF36F21),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        ),
                        child: const Text('Lưu cấu hình'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Instructions & Code Snippet
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Mã nguồn Google Apps Script (GAS Backend Code)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: GoogleSheetsService.sampleAppsScriptCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã sao chép mã Apps Script vào bộ nhớ tạm!'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy, size: 16),
                        label: const Text('Sao chép Code'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Hướng dẫn thiết lập 3 bước:\n'
                    '1. Mở file Google Sheets -> chọn Extensions -> Apps Script.\n'
                    '2. Xóa toàn bộ code cũ, dán đoạn mã bên dưới vào và lưu lại.\n'
                    '3. Bấm Deploy -> New deployment -> Select type: Web app -> Execute as: Me -> Who has access: Anyone -> Deploy & Copy Web App URL.',
                    style: TextStyle(fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        GoogleSheetsService.sampleAppsScriptCode,
                        style: const TextStyle(
                          color: Color(0xFFD4D4D4),
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
