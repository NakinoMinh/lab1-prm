import 'dart:async';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import '../models/student.dart';
import '../models/attendance_session.dart';
import '../models/fap_class_slot.dart';
import '../services/otp_service.dart';
import '../services/google_sheets_service.dart';

class AttendanceProvider extends ChangeNotifier {
  late AttendanceSession _currentSession;
  List<Student> _students = [];
  Timer? _otpTimer;
  final GoogleSheetsService _sheetsService = GoogleSheetsService();

  String _searchQuery = '';
  AttendanceStatus? _filterStatus;
  String? _lastCheckinNotification;

  // --- Timetable & Class/Slot Management ---
  List<FapClassSlot> _classSlots = [];
  FapClassSlot? _selectedSlot;
  DateTime _currentWeekStart = _getWeekStart(DateTime.now());

  // Per-class student rosters: classCode -> List<Student>
  final Map<String, List<Student>> _classRosters = {};

  // Navigation callback (set by dashboard to switch tabs)
  VoidCallback? onNavigateToAttendance;

  AttendanceProvider() {
    _currentSession = AttendanceSession(
      classCode: 'SE1801',
      subjectCode: 'PRN231',
      slot: 1,
      date: DateTime.now(),
    );
    _loadSampleTimetable();
    _loadSampleRoster();
    _startOtpEngine();
  }

  // Getters
  AttendanceSession get currentSession => _currentSession;
  List<Student> get students => _students;
  GoogleSheetsService get sheetsService => _sheetsService;
  String get searchQuery => _searchQuery;
  AttendanceStatus? get filterStatus => _filterStatus;
  String? get lastCheckinNotification => _lastCheckinNotification;
  List<FapClassSlot> get classSlots => _classSlots;
  FapClassSlot? get selectedSlot => _selectedSlot;
  DateTime get currentWeekStart => _currentWeekStart;

  List<Student> get filteredStudents {
    return _students.where((s) {
      final matchesSearch = _searchQuery.isEmpty ||
          s.rollNo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.email.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter = _filterStatus == null || s.status == _filterStatus;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  int get countPresent => _students.where((s) => s.status == AttendanceStatus.present).length;
  int get countLate => _students.where((s) => s.status == AttendanceStatus.late).length;
  int get countAbsent => _students.where((s) => s.status == AttendanceStatus.absent).length;
  int get countNotChecked => _students.where((s) => s.status == AttendanceStatus.notChecked).length;
  int get countTotal => _students.length;
  double get attendancePercentage => countTotal == 0 ? 0 : (countPresent + countLate) / countTotal * 100;

  // Week navigation
  String get currentWeekLabel {
    final end = _currentWeekStart.add(const Duration(days: 6));
    return '${_formatDate(_currentWeekStart)} → ${_formatDate(end)}';
  }

  void previousWeek() {
    _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
    notifyListeners();
  }

  void nextWeek() {
    _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
    notifyListeners();
  }

  void goToCurrentWeek() {
    _currentWeekStart = _getWeekStart(DateTime.now());
    notifyListeners();
  }

  /// Get slots for a specific day column and slot row in the timetable
  List<FapClassSlot> getSlotsForCell(int dayOfWeek, int slotNumber) {
    return _classSlots.where((s) => s.dayOfWeek == dayOfWeek && s.slot == slotNumber).toList();
  }

  /// Get date for a specific day column in the current week
  DateTime getDateForDay(int dayOfWeek) {
    return _currentWeekStart.add(Duration(days: dayOfWeek - 1));
  }

  // --- OTP Engine ---
  void _startOtpEngine() {
    _updateOtp();
    _otpTimer?.cancel();
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _currentSession.otpRemainingSeconds = OtpService.getRemainingSeconds();
      if (_currentSession.otpRemainingSeconds == 10 || _currentSession.activeOtp.isEmpty) {
        _updateOtp();
      }
      notifyListeners();
    });
  }

  void _updateOtp() {
    _currentSession.activeOtp = OtpService.generateOtpForTimeWindow();
  }

  // --- Search & Filter ---
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterStatus(AttendanceStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }

  // --- Session Management ---
  void updateSessionInfo({String? classCode, String? subjectCode, int? slot}) {
    _currentSession = AttendanceSession(
      classCode: classCode ?? _currentSession.classCode,
      subjectCode: subjectCode ?? _currentSession.subjectCode,
      slot: slot ?? _currentSession.slot,
      date: _currentSession.date,
      activeOtp: _currentSession.activeOtp,
      otpRemainingSeconds: _currentSession.otpRemainingSeconds,
    );
    notifyListeners();
  }

  /// Select a timetable slot and switch to attendance mode
  void selectSlotAndStartAttendance(FapClassSlot slot) {
    _selectedSlot = slot;
    _currentSession = AttendanceSession(
      classCode: slot.classCode,
      subjectCode: slot.subjectCode,
      slot: slot.slot,
      date: DateTime.now(),
      activeOtp: _currentSession.activeOtp,
      otpRemainingSeconds: _currentSession.otpRemainingSeconds,
    );

    // Load class-specific roster
    if (_classRosters.containsKey(slot.classCode)) {
      _students = _classRosters[slot.classCode]!
          .map((s) => Student(
                rollNo: s.rollNo,
                fullName: s.fullName,
                email: s.email,
                group: s.group,
                status: AttendanceStatus.notChecked,
              ))
          .toList();
    } else {
      _students = [];
    }

    _lastCheckinNotification = 'Đã chọn ${slot.subjectCode} - ${slot.classCode} (Slot ${slot.slot})';
    notifyListeners();

    // Trigger navigation to attendance tab
    onNavigateToAttendance?.call();
  }

  /// Add a new class slot to the timetable
  void addClassSlot(FapClassSlot newSlot) {
    _classSlots.add(newSlot);
    notifyListeners();
  }

  /// Remove a class slot
  void removeClassSlot(String slotId) {
    _classSlots.removeWhere((s) => s.id == slotId);
    notifyListeners();
  }

  /// Import students for a specific class from CSV content
  void importStudentsForClass(String classCode, String rawCsv) {
    try {
      final List<List<dynamic>> rows = const CsvToListConverter().convert(rawCsv);
      if (rows.isEmpty) return;

      final newStudents = <Student>[];
      int startIdx = 0;
      if (rows.first.first.toString().toLowerCase().contains('roll') ||
          rows.first.first.toString().toLowerCase().contains('stt') ||
          rows.first.first.toString().toLowerCase().contains('no')) {
        startIdx = 1;
      }

      for (int i = startIdx; i < rows.length; i++) {
        final row = rows[i];
        if (row.length >= 2) {
          final rollNo = row[0].toString().trim();
          final fullName = row[1].toString().trim();
          final email = row.length > 2 ? row[2].toString().trim() : '';
          final group = row.length > 3 ? row[3].toString().trim() : classCode;

          if (rollNo.isNotEmpty && fullName.isNotEmpty) {
            newStudents.add(Student(
              rollNo: rollNo,
              fullName: fullName,
              email: email.isNotEmpty ? email : '${rollNo.toLowerCase()}@fpt.edu.vn',
              group: group.isNotEmpty ? group : classCode,
            ));
          }
        }
      }

      if (newStudents.isNotEmpty) {
        _classRosters[classCode] = newStudents;

        // If current session matches, update live student list
        if (_currentSession.classCode == classCode) {
          _students = newStudents;
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error parsing CSV for class $classCode: $e');
    }
  }

  /// Import students for a class directly from Google Sheets
  Future<int> importStudentsFromGoogleSheets(String classCode, String sheetUrl) async {
    final students = await _sheetsService.fetchStudentsFromSheet(sheetUrl, classCode);
    if (students.isNotEmpty) {
      _classRosters[classCode] = students;
      if (_currentSession.classCode == classCode) {
        _students = students;
      }
      notifyListeners();
      return students.length;
    }
    return 0;
  }

  /// Get student count for a specific class
  int getStudentCountForClass(String classCode) {
    return _classRosters[classCode]?.length ?? 0;
  }

  // --- Google Sheets ---
  void setGoogleSheetsUrl(String url) {
    _sheetsService.webAppUrl = url;
    notifyListeners();
  }

  void toggleStudentStatus(Student student, AttendanceStatus newStatus) {
    student.status = newStatus;
    student.checkinTime = (newStatus == AttendanceStatus.present || newStatus == AttendanceStatus.late)
        ? DateTime.now()
        : null;
    notifyListeners();
    _sheetsService.pushSingleCheckin(student, _currentSession.classCode, _currentSession.slot);
  }

  /// Student attendance submission via email and 10s OTP
  Map<String, dynamic> checkinStudent({required String email, required String otp}) {
    final cleanEmail = email.trim().toLowerCase();
    final cleanOtp = otp.trim();

    if (!cleanEmail.endsWith('@fpt.edu.vn') && !cleanEmail.endsWith('@fe.edu.vn')) {
      return {'success': false, 'message': 'Vui lòng sử dụng Email FPT hợp lệ (ví dụ: minhnbse182173@fpt.edu.vn)'};
    }

    final isValidOtp = OtpService.validateOtp(cleanOtp);
    if (!isValidOtp) {
      return {'success': false, 'message': 'Mã OTP không hợp lệ hoặc đã hết hạn (Mã OTP tự động thay đổi mỗi 10s).'};
    }

    final index = _students.indexWhere((s) => s.email.toLowerCase() == cleanEmail || cleanEmail.contains(s.rollNo.toLowerCase()));

    if (index != -1) {
      final student = _students[index];
      student.status = AttendanceStatus.present;
      student.checkinTime = DateTime.now();
      student.notes = 'Checked in via OTP QR';

      _lastCheckinNotification = '✅ ${student.fullName} (${student.rollNo}) đã điểm danh thành công!';
      notifyListeners();

      _sheetsService.pushSingleCheckin(student, _currentSession.classCode, _currentSession.slot);

      return {
        'success': true,
        'message': 'Điểm danh thành công cho sinh viên ${student.fullName} (${student.rollNo})!',
        'student': student,
      };
    } else {
      final newRollNo = cleanEmail.split('@').first.toUpperCase();
      final newStudent = Student(
        rollNo: newRollNo,
        fullName: newRollNo,
        email: cleanEmail,
        group: _currentSession.classCode,
        status: AttendanceStatus.present,
        checkinTime: DateTime.now(),
        notes: 'Auto-added via OTP Check-in',
      );
      _students.add(newStudent);
      _lastCheckinNotification = '✅ Thêm & điểm danh thành công cho $cleanEmail!';
      notifyListeners();

      _sheetsService.pushSingleCheckin(newStudent, _currentSession.classCode, _currentSession.slot);

      return {
        'success': true,
        'message': 'Thêm sinh viên mới & điểm danh thành công!',
        'student': newStudent,
      };
    }
  }

  void importCsvContent(String rawCsv) {
    try {
      final List<List<dynamic>> rows = const CsvToListConverter().convert(rawCsv);
      if (rows.isEmpty) return;

      final newStudents = <Student>[];
      int startIdx = 0;
      if (rows.first.first.toString().toLowerCase().contains('roll') ||
          rows.first.first.toString().toLowerCase().contains('stt')) {
        startIdx = 1;
      }

      for (int i = startIdx; i < rows.length; i++) {
        final row = rows[i];
        if (row.length >= 3) {
          final rollNo = row[0].toString().trim();
          final fullName = row[1].toString().trim();
          final email = row[2].toString().trim();
          final group = row.length > 3 ? row[3].toString().trim() : _currentSession.classCode;
          final statusStr = row.length > 4 ? row[4].toString().trim() : '';

          if (rollNo.isNotEmpty && fullName.isNotEmpty) {
            newStudents.add(Student(
              rollNo: rollNo,
              fullName: fullName,
              email: email.isNotEmpty ? email : '${rollNo.toLowerCase()}@fpt.edu.vn',
              group: group,
              status: AttendanceStatusExtension.fromString(statusStr),
            ));
          }
        }
      }

      if (newStudents.isNotEmpty) {
        _students = newStudents;
        _classRosters[_currentSession.classCode] = newStudents;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error parsing CSV: $e');
    }
  }

  String exportFapCsv() {
    final List<List<dynamic>> rows = [
      ['RollNo', 'FullName', 'Email', 'Group', 'Status', 'CheckinTime', 'Slot', 'Date']
    ];

    for (var s in _students) {
      rows.add([
        s.rollNo,
        s.fullName,
        s.email,
        s.group,
        s.status.toLabel(),
        s.checkinTime?.toIso8601String() ?? '',
        _currentSession.slot,
        _currentSession.date.toIso8601String().split('T').first,
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  void syncWithGoogleSheets() async {
    final success = await _sheetsService.pushAttendanceToSheet(
      _students,
      _currentSession.classCode,
      _currentSession.subjectCode,
      _currentSession.slot,
    );
    if (success) {
      _lastCheckinNotification = '☁️ Đã đồng bộ thành công dữ liệu với Google Sheets!';
      notifyListeners();
    }
  }

  // --- Sample Data ---
  void _loadSampleTimetable() {
    _classSlots = [
      FapClassSlot(
        id: 'prn232-mon-1',
        subjectCode: 'PRN232',
        subjectName: 'Building Cross-Platform Back-End Application With .NET',
        classCode: 'SE1917',
        slot: 1,
        dayOfWeek: 1,
        room: 'NVH 602',
        slotTime: '7:00 - 9:15',
        sessionNumber: 3,
        instructor: 'PhuongLHK',
        campus: 'FUHCM',
      ),
      FapClassSlot(
        id: 'prm393-mon-2',
        subjectCode: 'PRM393',
        subjectName: 'Mobile Development',
        classCode: 'SE1801',
        slot: 2,
        dayOfWeek: 1,
        room: 'NVH 602',
        slotTime: '9:30 - 11:45',
        instructor: 'PhuongLHK',
        campus: 'FUHCM',
      ),
      FapClassSlot(
        id: 'exe201-tue-1',
        subjectCode: 'EXE201',
        subjectName: 'Experiential Entrepreneurship 1',
        classCode: 'SE1917',
        slot: 1,
        dayOfWeek: 2,
        room: 'NVH 707',
        slotTime: '7:00 - 9:15',
        instructor: 'ThanhNV',
        campus: 'FUHCM',
        isOnline: true,
      ),
      FapClassSlot(
        id: 'swp391-tue-2',
        subjectCode: 'SWP391',
        subjectName: 'Application development project',
        classCode: 'SE1801',
        slot: 2,
        dayOfWeek: 2,
        room: 'NVH 612',
        slotTime: '9:30 - 11:45',
        instructor: 'TuanPM',
        campus: 'FUHCM',
      ),
      FapClassSlot(
        id: 'mln111-tue-3',
        subjectCode: 'MLN111',
        subjectName: 'Philosophy of Marxism-Leninism',
        classCode: 'SE1917',
        slot: 3,
        dayOfWeek: 2,
        room: 'NVH 404',
        slotTime: '12:30 - 14:45',
        instructor: 'HungNQ',
        campus: 'FUHCM',
      ),
      FapClassSlot(
        id: 'prn232-thu-1',
        subjectCode: 'PRN232',
        subjectName: 'Building Cross-Platform Back-End Application With .NET',
        classCode: 'SE1917',
        slot: 1,
        dayOfWeek: 4,
        room: 'NVH 602',
        slotTime: '7:00 - 9:15',
        sessionNumber: 4,
        instructor: 'PhuongLHK',
        campus: 'FUHCM',
      ),
      FapClassSlot(
        id: 'prm393-thu-2',
        subjectCode: 'PRM393',
        subjectName: 'Mobile Development',
        classCode: 'SE1801',
        slot: 2,
        dayOfWeek: 4,
        room: 'NVH 602',
        slotTime: '9:30 - 11:45',
        instructor: 'PhuongLHK',
        campus: 'FUHCM',
      ),
      FapClassSlot(
        id: 'mln111-fri-3',
        subjectCode: 'MLN111',
        subjectName: 'Philosophy of Marxism-Leninism',
        classCode: 'SE1917',
        slot: 3,
        dayOfWeek: 5,
        room: 'NVH 404',
        slotTime: '12:30 - 14:45',
        instructor: 'HungNQ',
        campus: 'FUHCM',
      ),
      FapClassSlot(
        id: 'swp391-fri-2',
        subjectCode: 'SWP391',
        subjectName: 'Application development project',
        classCode: 'SE1801',
        slot: 2,
        dayOfWeek: 5,
        room: 'NVH 612',
        slotTime: '9:30 - 11:45',
        instructor: 'TuanPM',
        campus: 'FUHCM',
      ),
      FapClassSlot(
        id: 'ite302c-fri-7',
        subjectCode: 'ITE302c',
        subjectName: 'Ethics in IT',
        classCode: 'SE1917',
        slot: 5,
        dayOfWeek: 5,
        room: 'Online',
        slotTime: '17:45 - 19:15',
        instructor: 'LongDT',
        campus: 'FUHCM',
        isOnline: true,
        meetUrl: 'https://meet.google.com/abc-defg-hij',
      ),
      FapClassSlot(
        id: 'mln111-sat-1',
        subjectCode: 'MLN111',
        subjectName: 'Philosophy of Marxism-Leninism',
        classCode: 'SE1917',
        slot: 1,
        dayOfWeek: 6,
        room: 'NVH 612',
        slotTime: '7:00 - 9:15',
        instructor: 'HungNQ',
        campus: 'FUHCM',
      ),
    ];

    // Pre-populate rosters
    _classRosters['SE1917'] = [
      Student(rollNo: 'SE182173', fullName: 'Bùi Nhật Minh', email: 'minhnbse182173@fpt.edu.vn', group: 'SE1917'),
      Student(rollNo: 'SE171234', fullName: 'Nguyen Van Nam', email: 'namnvse171234@fpt.edu.vn', group: 'SE1917'),
      Student(rollNo: 'SE180987', fullName: 'Tran Thi Mai', email: 'maittse180987@fpt.edu.vn', group: 'SE1917'),
      Student(rollNo: 'SE183456', fullName: 'Le Hoang Long', email: 'longlhse183456@fpt.edu.vn', group: 'SE1917'),
    ];
    _classRosters['SE1801'] = [
      Student(rollNo: 'SE182173', fullName: 'Bùi Nhật Minh', email: 'minhnbse182173@fpt.edu.vn', group: 'SE1801'),
      Student(rollNo: 'SE185111', fullName: 'Pham Thu Ha', email: 'haptse185111@fpt.edu.vn', group: 'SE1801'),
      Student(rollNo: 'SE186222', fullName: 'Dao Minh Tuan', email: 'tuandmse186222@fpt.edu.vn', group: 'SE1801'),
    ];
  }

  void _loadSampleRoster() {
    _students = _classRosters['SE1801'] ?? [];
  }

  // --- Helpers ---
  static DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday; // 1=Mon
    return DateTime(date.year, date.month, date.day).subtract(Duration(days: weekday - 1));
  }

  static String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _otpTimer?.cancel();
    super.dispose();
  }
}
