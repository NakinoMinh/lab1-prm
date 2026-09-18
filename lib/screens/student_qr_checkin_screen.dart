import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_provider.dart';
import '../models/student.dart';

/// Modern Material 3 Student QR Scan Result & Attendance Check-in Screen.
/// Displays scanned class data, extracted 10s OTP, email input, and verified digital ticket.
class StudentQrCheckinScreen extends StatefulWidget {
  const StudentQrCheckinScreen({super.key});

  @override
  State<StudentQrCheckinScreen> createState() => _StudentQrCheckinScreenState();
}

class _StudentQrCheckinScreenState extends State<StudentQrCheckinScreen> {
  final _emailController = TextEditingController(text: 'minhnbse182173@fpt.edu.vn');
  final _otpController = TextEditingController();

  final bool _isAutoFilledFromQr = true;
  Map<String, dynamic>? _checkinResult;
  String? _digitalTicketHash;

  @override
  void initState() {
    super.initState();
    // Auto-fill active OTP from QR code
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AttendanceProvider>(context, listen: false);
      _otpController.text = provider.currentSession.activeOtp;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _submitAttendance() {
    final provider = Provider.of<AttendanceProvider>(context, listen: false);
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();

    if (email.isEmpty || otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập Email FPT và mã OTP!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final res = provider.checkinStudent(email: email, otp: otp);
    setState(() {
      _checkinResult = res;
      if (res['success'] == true) {
        // Generate pseudo-cryptographic anti-fraud ticket hash
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        _digitalTicketHash = 'FAP-${email.split('@').first.toUpperCase()}-${timestamp.toRadixString(16).toUpperCase()}';
      }
    });
  }

  void _resetForNewScan() {
    final provider = Provider.of<AttendanceProvider>(context, listen: false);
    setState(() {
      _checkinResult = null;
      _digitalTicketHash = null;
      _otpController.text = provider.currentSession.activeOtp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = Provider.of<AttendanceProvider>(context);
    final session = provider.currentSession;
    final secondsLeft = session.otpRemainingSeconds;

    // Keep OTP synced if auto-filled
    if (_isAutoFilledFromQr && _checkinResult == null) {
      if (_otpController.text != session.activeOtp) {
        _otpController.text = session.activeOtp;
      }
    }

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: _checkinResult != null && _checkinResult!['success'] == true
                ? _buildSuccessTicket(context, provider)
                : _buildCheckinForm(context, provider, secondsLeft),
          ),
        ),
      ),
    );
  }

  /// Form displayed after scanning QR code
  Widget _buildCheckinForm(BuildContext context, AttendanceProvider provider, int secondsLeft) {
    final session = provider.currentSession;
    const fptOrange = Color(0xFFF36F21);
    const deepBlue = Color(0xFF1B2A4A);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Banner: Scanned QR Info
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: deepBlue,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: fptOrange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'QUÉT MÃ QR THÀNH CÔNG',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const Row(
                      children: [
                        Icon(Icons.qr_code_scanner, color: Colors.white70, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'FAP Verified',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '${session.subjectCode} - Lớp ${session.classCode}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Slot ${session.slot} • Ngày: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Main Form Body
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // OTP Extracted Status Box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: fptOrange.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.vpn_key_rounded, color: fptOrange, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Mã OTP tự động trích xuất từ QR:',
                              style: TextStyle(fontSize: 11.5, color: Colors.black54),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _otpController.text.length == 6
                                  ? '${_otpController.text.substring(0, 3)} ${_otpController.text.substring(3)}'
                                  : _otpController.text,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                                color: deepBlue,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Countdown Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: secondsLeft <= 3 ? Colors.red.shade100 : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 14,
                              color: secondsLeft <= 3 ? Colors.red : Colors.orange.shade900,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${secondsLeft}s',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: secondsLeft <= 3 ? Colors.red : Colors.orange.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Email Input Field
                const Text(
                  'Email FPT của sinh viên:',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: deepBlue),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'ví dụ: minhnbse182173@fpt.edu.vn',
                    prefixIcon: const Icon(Icons.email_outlined, color: fptOrange),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: fptOrange, width: 1.8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Quick Email Selectors for Class Demo
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildEmailChip('minhnbse182173@fpt.edu.vn', 'Bùi Nhật Minh'),
                    _buildEmailChip('namnvse171234@fpt.edu.vn', 'Nguyễn Văn Nam'),
                    _buildEmailChip('maittse180987@fpt.edu.vn', 'Trần Thị Mai'),
                  ],
                ),
                const SizedBox(height: 24),

                // Confirm Check-in Button
                FilledButton.icon(
                  onPressed: _submitAttendance,
                  icon: const Icon(Icons.how_to_reg_rounded, size: 22),
                  label: const Text(
                    'XÁC NHẬN ĐIỂM DANH NGAY',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: fptOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 2,
                  ),
                ),

                // Error alert if failed
                if (_checkinResult != null && _checkinResult!['success'] == false) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _checkinResult!['message'] ?? 'Điểm danh thất bại.',
                            style: TextStyle(color: Colors.red.shade900, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailChip(String email, String name) {
    final isSelected = _emailController.text.trim() == email;
    return InkWell(
      onTap: () {
        setState(() {
          _emailController.text = email;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF36F21).withValues(alpha: 0.15) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFF36F21) : Colors.transparent,
          ),
        ),
        child: Text(
          '$name ($email)',
          style: TextStyle(
            fontSize: 11,
            color: isSelected ? const Color(0xFFF36F21) : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  /// Digital Attendance Ticket (Thẻ Điểm Danh Điện Tử)
  Widget _buildSuccessTicket(BuildContext context, AttendanceProvider provider) {
    final student = _checkinResult!['student'] as Student?;
    final session = provider.currentSession;
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')} ${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF22C55E), width: 1.8),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.12),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Verified Banner
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: const BoxDecoration(
              color: Color(0xFF059669),
              borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, color: Color(0xFF059669), size: 36),
                ),
                const SizedBox(height: 12),
                const Text(
                  'ĐIỂM DANH THÀNH CÔNG',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'FPT University • Thẻ Điểm Danh Điện Tử Hợp Lệ',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          // Ticket Body Details
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildTicketRow('Sinh viên:', student?.fullName ?? 'Sinh viên FPT', isBold: true),
                const Divider(height: 20),
                _buildTicketRow('Mã số sinh viên (MSSV):', student?.rollNo ?? 'SE182173', isBold: true),
                const Divider(height: 20),
                _buildTicketRow('Email:', student?.email ?? _emailController.text),
                const Divider(height: 20),
                _buildTicketRow('Môn học & Lớp:', '${session.subjectCode} • ${session.classCode}'),
                const Divider(height: 20),
                _buildTicketRow('Ca học / Slot:', 'Slot ${session.slot}'),
                const Divider(height: 20),
                _buildTicketRow('Thời gian ghi nhận:', timeStr),
                const Divider(height: 20),
                _buildTicketRow('Mã chống gian lận:', _digitalTicketHash ?? 'FAP-VERIFIED-2026', isMonospace: true),
                const SizedBox(height: 24),

                // Sync Status Confirmation
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.cloud_done_rounded, color: Color(0xFF059669), size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Trạng thái: Đã cập nhật CÓ MẶT trên app giảng viên & Google Sheets DB.',
                          style: TextStyle(
                            color: Color(0xFF065F46),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Action to Scan Another or Go Back
                OutlinedButton.icon(
                  onPressed: _resetForNewScan,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Quét mã lượt mới / Đổi sinh viên'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketRow(String label, String value, {bool isBold = false, bool isMonospace = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[700], fontSize: 13),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontFamily: isMonospace ? 'monospace' : null,
              color: isMonospace ? const Color(0xFF0F766E) : const Color(0xFF1B2A4A),
            ),
          ),
        ),
      ],
    );
  }
}
