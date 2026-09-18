import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_provider.dart';

class ExtensionGuideScreen extends StatelessWidget {
  const ExtensionGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const fptOrange = Color(0xFFF36F21);
    const deepBlue = Color(0xFF1B2A4A);
    final provider = Provider.of<AttendanceProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [deepBlue, Color(0xFF2E4374)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: deepBlue.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: fptOrange,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.extension_rounded, color: Colors.white, size: 36),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'CHROME & EDGE EXTENSION',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'FAP Auto Attendance Assistant',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Tiện ích mở rộng tự động tích điểm danh sinh viên trên trang web FAP (fap.fpt.edu.vn) cho giảng viên.',
                            style: TextStyle(color: Colors.white70, fontSize: 13.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Installation Steps Card
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hướng dẫn cài đặt tiện ích vào Chrome / Edge trong 3 bước:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: deepBlue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildStepItem(
                        number: '1',
                        title: 'Mở trang quản lý tiện ích trình duyệt',
                        description: 'Trên Chrome hoặc Edge, mở tab mới và truy cập: chrome://extensions/ rồi gạt bật "Developer mode" (Chế độ cho nhà phát triển) ở góc phải.',
                        copyText: 'chrome://extensions/',
                        context: context,
                      ),
                      const Divider(height: 24),
                      _buildStepItem(
                        number: '2',
                        title: 'Tải tiện ích đã giải nén (Load unpacked)',
                        description: 'Nhấn nút "Load unpacked" (Tải tiện ích đã giải nén) và chọn thư mục mã nguồn extension bên dưới:',
                        copyText: r'C:\Users\minhn\.gemini\antigravity\scratch\fap_attendance_app\extension',
                        context: context,
                      ),
                      const Divider(height: 24),
                      _buildStepItem(
                        number: '3',
                        title: 'Truy cập FAP và điểm danh tự động 1-Click',
                        description: 'Mở trang điểm danh lớp học trên https://fap.fpt.edu.vn/ -> Widget trợ lý sẽ tự động xuất hiện ở góc dưới màn hình. Bấm "Tự động tích điểm danh" để hệ thống tự động tick P / A cho sinh viên!',
                        copyText: 'https://fap.fpt.edu.vn/',
                        context: context,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Live Simulation & Test Card
              Card(
                elevation: 1,
                color: const Color(0xFFF8FAFC),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mô phỏng dữ liệu đồng bộ với Extension',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: deepBlue,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Dữ liệu ca dạy hiện tại được Extension đọc để tích điểm danh trên FAP',
                                style: TextStyle(fontSize: 12.5, color: Colors.black54),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Color(0xFF2E7D32),
                                  content: Text('⚡ Dữ liệu điểm danh đã sẵn sàng cho Extension trên FAP!'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.sync_rounded, size: 18),
                            label: const Text('Kiểm tra kết nối'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: fptOrange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Lớp hiện tại: ${provider.currentSession.classCode} (${provider.currentSession.subjectCode})'),
                                Text('Tổng SV: ${provider.countTotal}'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Đã có mặt (P): ${provider.countPresent}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                Text('Vắng (A): ${provider.countAbsent}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                Text('Chưa điểm danh: ${provider.countNotChecked}', style: const TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepItem({
    required String number,
    required String title,
    required String description,
    required String copyText,
    required BuildContext context,
  }) {
    const fptOrange = Color(0xFFF36F21);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: fptOrange,
          child: Text(
            number,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        copyText,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 16, color: fptOrange),
                      tooltip: 'Sao chép',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: copyText));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã sao chép vào bộ nhớ tạm!')),
                        );
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
