import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/attendance_provider.dart';
import 'screens/teacher_dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FapAttendanceApp());
}

class FapAttendanceApp extends StatelessWidget {
  const FapAttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AttendanceProvider(),
      child: MaterialApp(
        title: 'FAP Smart Attendance Assistant',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFF36F21),
            primary: const Color(0xFFF36F21),
            secondary: const Color(0xFF1B2A4A),
          ),
          scaffoldBackgroundColor: const Color(0xFFF4F6F9),
        ),
        home: const TeacherDashboardScreen(),
      ),
    );
  }
}
