import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_provider.dart';

class QrGeneratorWidget extends StatefulWidget {
  const QrGeneratorWidget({super.key});

  static const String studentPortalUrl = 'https://nakinominh.github.io/lab1-prm/';

  @override
  State<QrGeneratorWidget> createState() => _QrGeneratorWidgetState();
}

class _QrGeneratorWidgetState extends State<QrGeneratorWidget> {
  bool _isPaused = false;
  String? _frozenQrData;
  String? _frozenOtp;
  int? _frozenSecondsLeft;

  void _togglePause(String currentQrData, String currentOtp, int currentSecondsLeft) {
    setState(() {
      if (_isPaused) {
        // Resume - clear frozen data
        _isPaused = false;
        _frozenQrData = null;
        _frozenOtp = null;
        _frozenSecondsLeft = null;
      } else {
        // Pause - freeze current QR data so students can scan
        _isPaused = true;
        _frozenQrData = currentQrData;
        _frozenOtp = currentOtp;
        _frozenSecondsLeft = currentSecondsLeft;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);
    final session = provider.currentSession;
    final liveOtp = session.activeOtp;
    final liveSecondsLeft = session.otpRemainingSeconds;
    final liveProgress = liveSecondsLeft / 10.0;

    // Live QR Data
    final liveQrData = '${QrGeneratorWidget.studentPortalUrl}?subject=${session.subjectCode}&class=${session.classCode}&slot=${session.slot}&otp=$liveOtp';

    // Use frozen or live data
    final displayQrData = _isPaused ? (_frozenQrData ?? liveQrData) : liveQrData;
    final displayOtp = _isPaused ? (_frozenOtp ?? liveOtp) : liveOtp;
    final displaySecondsLeft = _isPaused ? (_frozenSecondsLeft ?? liveSecondsLeft) : liveSecondsLeft;
    final displayProgress = _isPaused ? 1.0 : liveProgress;

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
                  Flexible(
                    child: Text(
                      '${session.subjectCode} - Class ${session.classCode} (Slot ${session.slot})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B2A4A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Pause/Resume Button
            SizedBox(
              width: double.infinity,
              child: _isPaused
                  ? FilledButton.icon(
                      onPressed: () => _togglePause(liveQrData, liveOtp, liveSecondsLeft),
                      icon: const Icon(Icons.play_arrow_rounded, size: 20),
                      label: const Text('Tiếp tục xoay OTP'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    )
                  : OutlinedButton.icon(
                      onPressed: () => _togglePause(liveQrData, liveOtp, liveSecondsLeft),
                      icon: const Icon(Icons.pause_rounded, size: 20),
                      label: const Text('Giữ mã QR để sinh viên quét'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFF36F21),
                        side: const BorderSide(color: Color(0xFFF36F21)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
            ),

            // Paused indicator
            if (_isPaused)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.amber.shade800),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'QR đang giữ cố định — sinh viên có thể quét ngay',
                        style: TextStyle(fontSize: 11.5, color: Colors.amber.shade900, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Dynamic QR Code Display — LARGER for better phone scanning
            Container(
              padding: const EdgeInsets.all(20),
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
                data: displayQrData,
                version: QrVersions.auto,
                size: 280.0,
                errorCorrectionLevel: QrErrorCorrectLevel.H,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Color(0xFF1B2A4A),
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Color(0xFF1B2A4A),
                ),
                padding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 18),

            // OTP Display
            Text(
              _isPaused ? 'MÃ OTP (ĐÃ GIỮ CỐ ĐỊNH):' : 'MÃ OTP XÁC THỰC (10s):',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _isPaused ? Colors.amber.shade800 : Colors.grey[600],
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: _isPaused ? Colors.amber.shade800 : const Color(0xFF1B2A4A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                displayOtp.length == 6 ? '${displayOtp.substring(0, 3)} ${displayOtp.substring(3)}' : displayOtp,
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
                    Row(
                      children: [
                        Icon(
                          _isPaused ? Icons.pause_circle_filled : Icons.timer_outlined,
                          size: 18,
                          color: _isPaused ? Colors.amber.shade800 : const Color(0xFFF36F21),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isPaused ? 'Đang giữ cố định' : 'Reset sau 10s',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _isPaused ? Colors.amber.shade800 : null,
                          ),
                        ),
                      ],
                    ),
                    if (!_isPaused)
                      Text(
                        '${displaySecondsLeft}s',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: displaySecondsLeft <= 3 ? Colors.red : const Color(0xFFF36F21),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: displayProgress,
                    minHeight: 10,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _isPaused
                          ? Colors.amber.shade700
                          : (displaySecondsLeft <= 3 ? Colors.red : const Color(0xFFF36F21)),
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
                          Flexible(
                            child: Text(
                              'Cổng Điểm Danh Sinh Viên (Deployed Web):',
                              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const SelectableText(
                        QrGeneratorWidget.studentPortalUrl,
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: Color(0xFFF36F21),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Huong dan:',
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '1. Bam "Giu ma QR" de chua QR co dinh\n'
                              '2. Sinh vien dung dien thoai quet ma QR\n'
                              '3. Trang diem danh tu dong mo tren trinh duyet',
                              style: TextStyle(fontSize: 10, color: Colors.blue.shade700, height: 1.4),
                            ),
                          ],
                        ),
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
