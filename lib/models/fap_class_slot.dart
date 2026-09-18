/// Represents a single class slot in the lecturer's weekly timetable.
/// Models the FAP (FPT Academic Portal) schedule structure.
class FapClassSlot {
  final String id;
  final String subjectCode;    // e.g. PRN232, PRM393, SWP391
  final String subjectName;    // e.g. Building Cross-Platform Back-End Application With .NET
  final String classCode;      // Student group e.g. SE1917, SE1801
  final int slot;              // 1-8
  final int dayOfWeek;         // 1=Mon, 2=Tue, ..., 7=Sun
  final String room;           // e.g. NVH 602, Online
  final String slotTime;       // e.g. 7:00-9:15
  final int sessionNumber;     // Course session number e.g. 3
  final String instructor;     // e.g. PhuongLHK
  final String campus;         // e.g. FUHCM
  final String? meetUrl;       // Google Meet / Zoom URL
  final bool isOnline;

  FapClassSlot({
    required this.id,
    required this.subjectCode,
    required this.subjectName,
    required this.classCode,
    required this.slot,
    required this.dayOfWeek,
    this.room = '',
    this.slotTime = '',
    this.sessionNumber = 1,
    this.instructor = '',
    this.campus = 'FUHCM',
    this.meetUrl,
    this.isOnline = false,
  });

  /// Returns the slot time range based on slot number (FAP standard)
  static String getSlotTimeRange(int slot) {
    switch (slot) {
      case 1: return '7:00 - 9:15';
      case 2: return '9:30 - 11:45';
      case 3: return '12:30 - 14:45';
      case 4: return '15:00 - 17:15';
      case 5: return '17:30 - 19:45';
      case 6: return '20:00 - 22:15';
      case 7: return '17:45 - 19:15';
      case 8: return '19:30 - 21:00';
      default: return '';
    }
  }

  static String getDayName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1: return 'Thứ 2';
      case 2: return 'Thứ 3';
      case 3: return 'Thứ 4';
      case 4: return 'Thứ 5';
      case 5: return 'Thứ 6';
      case 6: return 'Thứ 7';
      case 7: return 'CN';
      default: return '';
    }
  }

  static String getDayShortName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1: return 'MON';
      case 2: return 'TUE';
      case 3: return 'WED';
      case 4: return 'THU';
      case 5: return 'FRI';
      case 6: return 'SAT';
      case 7: return 'SUN';
      default: return '';
    }
  }
}
