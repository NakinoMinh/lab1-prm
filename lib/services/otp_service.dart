class OtpService {
  static const int otpDurationSeconds = 10;
  static const String _seedKey = 'FAP_ATTENDANCE_SECRET_2026';

  /// Generates a deterministic 6-digit OTP code based on the current 10-second time window.
  static String generateOtpForTimeWindow([DateTime? customTime]) {
    final now = customTime ?? DateTime.now();
    final epochSeconds = now.millisecondsSinceEpoch ~/ 1000;
    final timeWindow = epochSeconds ~/ otpDurationSeconds;
    
    return _calculateOtp(timeWindow);
  }

  /// Validates if an entered 6-digit OTP matches either the current 10s window or the previous 10s window.
  static bool validateOtp(String inputOtp) {
    final cleanInput = inputOtp.trim();
    if (cleanInput.length != 6) return false;

    final now = DateTime.now();
    final epochSeconds = now.millisecondsSinceEpoch ~/ 1000;
    final currentWindow = epochSeconds ~/ otpDurationSeconds;
    final previousWindow = currentWindow - 1; // 10s grace period for network latency

    final validCurrent = _calculateOtp(currentWindow);
    final validPrevious = _calculateOtp(previousWindow);

    return cleanInput == validCurrent || cleanInput == validPrevious;
  }

  /// Calculates remaining seconds in the current 10s window (10 -> 1)
  static int getRemainingSeconds() {
    final now = DateTime.now();
    final epochSeconds = now.millisecondsSinceEpoch ~/ 1000;
    final elapsedInWindow = epochSeconds % otpDurationSeconds;
    return otpDurationSeconds - elapsedInWindow;
  }

  static String _calculateOtp(int windowIndex) {
    // Hash-like deterministic computation using windowIndex and secret seed
    int hash = 5381;
    final combinedStr = '$_seedKey:$windowIndex';
    for (int i = 0; i < combinedStr.length; i++) {
      hash = ((hash << 5) + hash) + combinedStr.codeUnitAt(i);
    }
    
    // Ensure positive integer and convert to 6 digits
    final code = (hash.abs() % 900000) + 100000;
    return code.toString();
  }
}
