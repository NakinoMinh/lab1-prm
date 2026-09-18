import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import '../models/student.dart';

class GoogleSheetsService {
  String? webAppUrl;

  GoogleSheetsService({this.webAppUrl});

  bool get isConfigured => webAppUrl != null && webAppUrl!.trim().isNotEmpty;

  /// Fetch students list from a Google Sheets URL or Apps Script URL
  Future<List<Student>> fetchStudentsFromSheet(String inputUrl, String defaultClassCode) async {
    final cleanUrl = inputUrl.trim();
    if (cleanUrl.isEmpty) return [];

    try {
      String csvContent = '';

      // Case 1: Standard Google Sheets link (e.g., https://docs.google.com/spreadsheets/d/SHEET_ID/edit...)
      if (cleanUrl.contains('docs.google.com/spreadsheets/d/')) {
        final regExp = RegExp(r'/spreadsheets/d/([a-zA-Z0-9-_]+)');
        final match = regExp.firstMatch(cleanUrl);
        if (match != null && match.groupCount >= 1) {
          final sheetId = match.group(1);
          final exportUrl = 'https://docs.google.com/spreadsheets/d/$sheetId/export?format=csv';
          final response = await http.get(Uri.parse(exportUrl));
          if (response.statusCode == 200) {
            csvContent = utf8.decode(response.bodyBytes);
          }
        }
      } 
      // Case 2: Apps Script Web App URL or direct CSV endpoint
      else {
        final uri = Uri.parse(cleanUrl.contains('?') ? '$cleanUrl&action=getStudents' : '$cleanUrl?action=getStudents');
        final response = await http.get(uri);
        if (response.statusCode == 200) {
          final body = utf8.decode(response.bodyBytes).trim();
          if (body.startsWith('{') || body.startsWith('[')) {
            final json = jsonDecode(body);
            final List<dynamic> list = (json is Map && json['students'] != null) ? json['students'] : (json is List ? json : []);
            return list.map((item) => Student.fromMap(Map<String, dynamic>.from(item))).toList();
          } else {
            csvContent = body;
          }
        }
      }

      if (csvContent.isNotEmpty) {
        final List<List<dynamic>> rows = const CsvToListConverter().convert(csvContent);
        if (rows.isEmpty) return [];

        final students = <Student>[];
        int startIdx = 0;
        if (rows.first.first.toString().toLowerCase().contains('roll') ||
            rows.first.first.toString().toLowerCase().contains('stt') ||
            rows.first.first.toString().toLowerCase().contains('mssv')) {
          startIdx = 1;
        }

        for (int i = startIdx; i < rows.length; i++) {
          final row = rows[i];
          if (row.length >= 2) {
            final rollNo = row[0].toString().trim();
            final fullName = row[1].toString().trim();
            final email = row.length > 2 ? row[2].toString().trim() : '';
            final group = row.length > 3 ? row[3].toString().trim() : defaultClassCode;

            if (rollNo.isNotEmpty && fullName.isNotEmpty) {
              students.add(Student(
                rollNo: rollNo,
                fullName: fullName,
                email: email.isNotEmpty ? email : '${rollNo.toLowerCase()}@fpt.edu.vn',
                group: group.isNotEmpty ? group : defaultClassCode,
              ));
            }
          }
        }
        return students;
      }
    } catch (e) {
      debugPrint('Error fetching students from sheet: $e');
    }
    return [];
  }

  /// Sync student list and attendance statuses to Google Sheets
  Future<bool> pushAttendanceToSheet(List<Student> roster, String classCode, String subjectCode, int slot) async {
    if (!isConfigured) return false;

    try {
      final payload = {
        'action': 'syncAttendance',
        'classCode': classCode,
        'subjectCode': subjectCode,
        'slot': slot,
        'date': DateTime.now().toIso8601String(),
        'students': roster.map((s) => s.toMap()).toList(),
      };

      final response = await http.post(
        Uri.parse(webAppUrl!),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 302) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Google Sheets Sync Error: $e');
      return false;
    }
  }

  /// Single student check-in event push to Google Sheets
  Future<bool> pushSingleCheckin(Student student, String classCode, int slot) async {
    if (!isConfigured) return false;

    try {
      final payload = {
        'action': 'studentCheckin',
        'classCode': classCode,
        'slot': slot,
        'email': student.email,
        'rollNo': student.rollNo,
        'fullName': student.fullName,
        'status': student.status.toLabel(),
        'checkinTime': student.checkinTime?.toIso8601String() ?? DateTime.now().toIso8601String(),
      };

      final response = await http.post(
        Uri.parse(webAppUrl!),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      return response.statusCode == 200 || response.statusCode == 302;
    } catch (e) {
      debugPrint('Single Checkin Push Error: $e');
      return false;
    }
  }

  /// Google Apps Script code template that user can copy & paste into Google Sheets
  static String get sampleAppsScriptCode => '''
/**
 * FAP Attendance System - Google Apps Script Backend
 * Paste this into Google Sheets -> Extensions -> Apps Script
 * Deploy as Web App (Execute as: Me, Who has access: Anyone)
 */
function doGet(e) {
  var sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
  var data = sheet.getDataRange().getValues();
  var students = [];
  
  for (var i = 1; i < data.length; i++) {
    var row = data[i];
    if (row[0]) {
      students.push({
        rollNo: row[0],
        fullName: row[1] || "",
        email: row[2] || "",
        group: row[3] || "",
        status: row[4] || "NOT CHECKED",
        checkinTime: row[5] || ""
      });
    }
  }

  return ContentService.createTextOutput(JSON.stringify({
    status: "success",
    count: students.length,
    students: students
  })).setMimeType(ContentService.MimeType.JSON);
}

function doPost(e) {
  try {
    var data = JSON.parse(e.postData.contents);
    var sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
    
    if (data.action === "syncAttendance") {
      sheet.clear();
      sheet.appendRow(["RollNo", "FullName", "Email", "Group", "Status", "CheckinTime", "Notes"]);
      
      var students = data.students || [];
      for (var i = 0; i < students.length; i++) {
        var s = students[i];
        sheet.appendRow([s.rollNo, s.fullName, s.email, s.group, s.status, s.checkinTime, s.notes]);
      }
      return ContentService.createTextOutput(JSON.stringify({status: "success", count: students.length}))
        .setMimeType(ContentService.MimeType.JSON);
    } 
    else if (data.action === "studentCheckin") {
      sheet.appendRow([data.rollNo, data.fullName, data.email, data.classCode || "SE1801", data.status, data.checkinTime, "OTP Check-in"]);
      return ContentService.createTextOutput(JSON.stringify({status: "success"}))
        .setMimeType(ContentService.MimeType.JSON);
    }
  } catch (err) {
    return ContentService.createTextOutput(JSON.stringify({status: "error", error: err.toString()}))
      .setMimeType(ContentService.MimeType.JSON);
  }
}
''';
}
