import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_provider.dart';

class QrGeneratorWidget extends StatelessWidget {
  const QrGeneratorWidget({super.key});

  static const String studentPortalUrl = 'https://nakinominh.github.io/lab1-prm/';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);
    final session = provider.currentSession;
    final otp = session.activeOtp;
    final secondsLeft = session.otpRemainingSeconds;
    final progress = secondsLeft / 10.0;

    // Encoded QR Data payload - direct link with parameters so scanning opens student portal
    final qrData = '$studentPortalUrl?subject=${session.subjectCode}&class=${session.classCode}&slot=${session.slot}&otp=$otp';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF36F21).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFF36F21)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.qr_code_2, color: Color(0xFFF36F21), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${session.subjectCode} - Class ${session.classCode} (Slot ${session.slot})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B2A4A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Dynamic QR Code Display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 220.0,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Color(0xFF1B2A4A),
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Color(0xFF1B2A4A),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // OTP Display
            Text(
              'MÃ OTP XÁC THỰC (10s):',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2A4A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                otp.length == 6 ? '${otp.substring(0, 3)} ${otp.substring(3)}' : otp,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                  color: Colors.white,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 18),

            // 10s Timer Progress Bar
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.timer_outlined, size: 18, color: Color(0xFFF36F21)),
                        SizedBox(width: 6),
                        Text(
                          'Reset sau 10s',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    Text(
                      '${secondsLeft}s',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: secondsLeft <= 3 ? Colors.red : const Color(0xFFF36F21),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      secondsLeft <= 3 ? Colors.red : const Color(0xFFF36F21),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Deployed Student Portal Info Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.public_rounded, size: 15, color: Color(0xFF0284C7)),
                          SizedBox(width: 6),
                          Text(
                            'Cổng Điểm Danh Sinh Viên (Deployed Web):',
                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const SelectableText(
                        studentPortalUrl,
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: Color(0xFFF36F21),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sinh viên dùng điện thoại quét mã QR hoặc truy cập link trên để đăng nhập Google FPT và điểm danh.',
                        style: TextStyle(fontSize: 10.5, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
