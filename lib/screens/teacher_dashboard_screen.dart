import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_provider.dart';
import '../widgets/qr_generator_widget.dart';
import '../widgets/roster_table_widget.dart';
import '../widgets/sheets_config_widget.dart';
import 'fap_timetable_screen.dart';
import 'student_qr_checkin_screen.dart';
import 'extension_guide_screen.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    // Register navigation callback so timetable slot click can navigate to QR tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AttendanceProvider>(context, listen: false);
      provider.onNavigateToAttendance = () {
        if (mounted) {
          setState(() {
            _selectedTabIndex = 1; // Switch to Điểm danh QR & OTP tab
          });
        }
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = Provider.of<AttendanceProvider>(context);
    final notification = provider.lastCheckinNotification;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: Row(
        children: [
          // Sidebar Navigation
          _buildSidebar(context),

          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Top Header Bar
                _buildHeader(context, provider),

                // Live Notification Banner
                if (notification != null)
                  Container(
                    width: double.infinity,
                    color: Colors.green.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            notification,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Active View Body
                Expanded(
                  child: _buildActiveTabContent(provider),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 260,
      color: const Color(0xFF1B2A4A),
      child: Column(
        children: [
          // App Title Logo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white12)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF36F21),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.school_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FAP ATTENDANCE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15.5,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      'Smart Desktop Assistant',
                      style: TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                _buildNavItem(0, 'Lịch dạy FAP (Timetable)', Icons.calendar_month_rounded),
                _buildNavItem(1, 'Điểm danh QR & OTP 10s', Icons.qr_code_scanner_rounded),
                _buildNavItem(2, 'SV Quét Mã Điểm Danh', Icons.how_to_reg_rounded),
                _buildNavItem(3, 'Danh sách sinh viên', Icons.people_alt_outlined),
                _buildNavItem(4, 'Cấu hình Google Sheets', Icons.cloud_outlined),
                _buildNavItem(5, 'Tiện ích FAP (Extension)', Icons.extension_rounded),
              ],
            ),
          ),

          // Active Slot Quick Tag in Sidebar
          Consumer<AttendanceProvider>(
            builder: (context, prov, _) {
              return Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF22C55E),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Ca dạy đang chọn:',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${prov.currentSession.subjectCode} - ${prov.currentSession.classCode}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'Slot ${prov.currentSession.slot} • ${prov.countTotal} sinh viên',
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ),
              );
            },
          ),

          // Footer info
          Container(
            padding: const EdgeInsets.all(14),
            color: Colors.black12,
            child: const Row(
              children: [
                Icon(Icons.verified_rounded, color: Color(0xFFF36F21), size: 16),
                SizedBox(width: 8),
                Text(
                  'FPT University • Lab 1',
                  style: TextStyle(color: Colors.white60, fontSize: 11.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon) {
    final isSelected = _selectedTabIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF36F21) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          leading: Icon(icon, color: isSelected ? Colors.white : Colors.grey[400], size: 20),
          title: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[300],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13.5,
            ),
          ),
          dense: true,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          onTap: () {
            setState(() {
              _selectedTabIndex = index;
            });
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AttendanceProvider provider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Class / Subject active badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2A4A).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.class_outlined, color: Color(0xFF1B2A4A), size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                '${provider.currentSession.subjectCode} - Lớp ${provider.currentSession.classCode}',
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B2A4A),
                ),
              ),
              const SizedBox(width: 10),
              Chip(
                label: Text('Slot ${provider.currentSession.slot}'),
                backgroundColor: const Color(0xFFF36F21).withValues(alpha: 0.1),
                side: const BorderSide(color: Color(0xFFF36F21)),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                visualDensity: VisualDensity.compact,
              )
            ],
          ),

          // Action Buttons
          Row(
            children: [
              if (_selectedTabIndex != 1)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedTabIndex = 1;
                      });
                    },
                    icon: const Icon(Icons.qr_code_2, size: 18),
                    label: const Text('Mở trang QR'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFF36F21),
                      side: const BorderSide(color: Color(0xFFF36F21)),
                    ),
                  ),
                ),

              // Export FAP Report Button
              ElevatedButton.icon(
                onPressed: () {
                  final csv = provider.exportFapCsv();
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Xuất Báo Cáo Điểm Danh (FAP Format)'),
                      content: SizedBox(
                        width: 500,
                        height: 300,
                        child: SingleChildScrollView(
                          child: SelectableText(csv),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Đóng'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.file_download, size: 18),
                label: const Text('Xuất báo cáo FAP'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  elevation: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTabContent(AttendanceProvider provider) {
    switch (_selectedTabIndex) {
      case 0:
        return const FapTimetableScreen();
      case 1:
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Pane: Dynamic QR & OTP Widget
              const SizedBox(
                width: 360,
                child: QrGeneratorWidget(),
              ),
              const SizedBox(width: 20),

              // Right Pane: Summary Statistics & Quick Roster Overview
              Expanded(
                child: Column(
                  children: [
                    // Stat Cards Grid
                    Row(
                      children: [
                        _buildStatCard('Tổng sinh viên', '${provider.countTotal}', Colors.blue),
                        const SizedBox(width: 12),
                        _buildStatCard('Có mặt', '${provider.countPresent}', Colors.green),
                        const SizedBox(width: 12),
                        _buildStatCard('Trễ', '${provider.countLate}', Colors.orange),
                        const SizedBox(width: 12),
                        _buildStatCard('Vắng', '${provider.countAbsent}', Colors.red),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Quick Roster Table
                    const Expanded(child: RosterTableWidget()),
                  ],
                ),
              ),
            ],
          ),
        );
      case 2:
        return const StudentQrCheckinScreen();
      case 3:
        return const Padding(
          padding: EdgeInsets.all(20.0),
          child: RosterTableWidget(),
        );
      case 4:
        return const SheetsConfigWidget();
      case 5:
      default:
        return const ExtensionGuideScreen();
    }
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
