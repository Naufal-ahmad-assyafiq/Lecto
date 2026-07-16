/// Konstanta slot waktu dan data domain Lecto
class TimeSlots {
  TimeSlots._();

  // Slot waktu sesi Pagi (07:30–12:00)
  static const List<String> pagi = [
    '07:30', '08:00', '08:30', '09:00', '09:30',
    '10:00', '10:30', '11:00', '11:30', '12:00',
  ];

  // Slot waktu sesi Siang (12:30–16:30)
  static const List<String> siang = [
    '12:30', '13:00', '13:30', '14:00', '14:30',
    '15:00', '15:30', '16:00', '16:30',
  ];

  static List<String> get all => [...pagi, ...siang];

  static const List<String> activeDays = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu',
  ];

  // Daftar Program Studi
  static const List<String> programStudiList = [
    'Teknik Informatika',
    'Komputerisasi Akuntansi',
    'Sistem Informasi',
    'Manajemen Informatika',
    'Desain Komunikasi Visual',
    'Manajemen Bisnis',
    'Manajemen',
    'Akuntansi',
    'Pendidikan Kepelatihan Olahraga',
  ];

  static const List<int> semesters = [1, 2, 3, 4, 5, 6, 7, 8];
  static const List<String> classes = ['A', 'B', 'C', 'D', 'E'];
  static const List<String> roomCategories = ['Kelas', 'Lab', 'Auditorium'];

  static const String prefPagi = 'Pagi';
  static const String prefSiang = 'Siang';

  // Business Rule Durasi SKS: 1=45mnt, 2=90mnt, 3=120mnt
  static const Map<int, int> durationRules = {1: 45, 2: 90, 3: 120};

  static int creditsToDuration(int credits) =>
      durationRules[credits] ?? (credits * 45);

  static int creditsToSlots(int credits) =>
      (creditsToDuration(credits) / 30).ceil();

  /// Hitung waktu selesai berdasarkan business rule durasi
  static String? calculateEndTime(String startTime, int credits) {
    if (all.indexOf(startTime) == -1) return null;
    return _addMinutes(startTime, creditsToDuration(credits));
  }

  static String _addMinutes(String time, int minutes) {
    final parts = time.split(':');
    final total = int.parse(parts[0]) * 60 + int.parse(parts[1]) + minutes;
    return '${(total ~/ 60).toString().padLeft(2, '0')}:${(total % 60).toString().padLeft(2, '0')}';
  }

  static List<String> getOccupiedSlots(String startSlot, int credits) {
    final allS = all;
    final startIndex = allS.indexOf(startSlot);
    if (startIndex == -1) return [];
    final end = (startIndex + creditsToSlots(credits)).clamp(0, allS.length);
    return allS.sublist(startIndex, end);
  }

  static List<String> slotsForPreference(String preference) =>
      preference == prefPagi ? pagi : siang;

  /// Format durasi untuk tampilan: '45 menit', '1 jam 30 menit', '2 jam'
  static String formatDuration(int credits) {
    final minutes = creditsToDuration(credits);
    if (minutes < 60) return '$minutes menit';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '$h jam' : '$h jam $m menit';
  }
}
