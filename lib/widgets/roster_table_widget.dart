import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import '../providers/attendance_provider.dart';
import '../models/student.dart';

class RosterTableWidget extends StatelessWidget {
  const RosterTableWidget({super.key});

  void _handlePickCsvFile(BuildContext context, AttendanceProvider provider) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'txt'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        String content = '';
        if (file.bytes != null) {
          content = utf8.decode(file.bytes!);
        }
        if (content.isNotEmpty && context.mounted) {
          provider.importCsvContent(content);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã nạp danh sách sinh viên từ file CSV thành công!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi mở file CSV: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AttendanceProvider>(context);
    final students = provider.filteredStudents;

    return Column(
      children: [
        // Controls Row: Search & Filters & Buttons
        Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Search Field
                Expanded(
                  child: TextField(
                    onChanged: (val) => provider.setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm MSSV, Họ tên hoặc Email...',
                      prefixIcon: const Icon(Icons.search),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Status Filter Chips
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Tất cả'),
                      selected: provider.filterStatus == null,
                      onSelected: (_) => provider.setFilterStatus(null),
                    ),
                    FilterChip(
                      label: const Text('Có mặt'),
                      selected: provider.filterStatus == AttendanceStatus.present,
                      selectedColor: Colors.green[100],
                      onSelected: (_) => provider.setFilterStatus(AttendanceStatus.present),
                    ),
                    FilterChip(
                      label: const Text('Trễ'),
                      selected: provider.filterStatus == AttendanceStatus.late,
                      selectedColor: Colors.orange[100],
                      onSelected: (_) => provider.setFilterStatus(AttendanceStatus.late),
                    ),
                    FilterChip(
                      label: const Text('Vắng'),
                      selected: provider.filterStatus == AttendanceStatus.absent,
                      selectedColor: Colors.red[100],
                      onSelected: (_) => provider.setFilterStatus(AttendanceStatus.absent),
                    ),
                  ],
                ),
                const SizedBox(width: 16),

                // Import CSV File Button
                ElevatedButton.icon(
                  onPressed: () => _handlePickCsvFile(context, provider),
                  icon: const Icon(Icons.file_upload_outlined),
                  label: const Text('Import CSV'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B2A4A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Student Data Table View
        Expanded(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: students.isEmpty
                ? const Center(
                    child: Text(
                      'Không tìm thấy sinh viên phù hợp.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: students.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(student.status).withValues(alpha: 0.15),
                          child: Icon(
                            _getStatusIcon(student.status),
                            color: _getStatusColor(student.status),
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              student.rollNo,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 12),
                            Text(student.fullName),
                            const SizedBox(width: 8),
                            Chip(
                              label: Text(student.group, style: const TextStyle(fontSize: 10)),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                            )
                          ],
                        ),
                        subtitle: Text('${student.email} ${student.checkinTime != null ? "• Check-in: ${_formatTime(student.checkinTime!)}" : ""}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Status Dropdown selector for Teacher Override
                            DropdownButton<AttendanceStatus>(
                              value: student.status,
                              underline: const SizedBox(),
                              items: AttendanceStatus.values.map((st) {
                                return DropdownMenuItem(
                                  value: st,
                                  child: Text(
                                    st.toLabel(),
                                    style: TextStyle(
                                      color: _getStatusColor(st),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (newStatus) {
                                if (newStatus != null) {
                                  provider.toggleStudentStatus(student, newStatus);
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.late:
        return Colors.orange;
      case AttendanceStatus.absent:
        return Colors.red;
      case AttendanceStatus.notChecked:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Icons.check_circle;
      case AttendanceStatus.late:
        return Icons.access_time_filled;
      case AttendanceStatus.absent:
        return Icons.cancel;
      case AttendanceStatus.notChecked:
        return Icons.radio_button_unchecked;
    }
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final second = dt.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }
}
