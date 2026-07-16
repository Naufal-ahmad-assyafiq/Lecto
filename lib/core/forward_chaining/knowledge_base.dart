// Knowledge Base — fakta domain sistem pakar Lecto

/// Konstanta dan fakta domain penjadwalan.
class KnowledgeBase {
  KnowledgeBase._();

  // Hari aktif perkuliahan
  static const List<String> workingDays = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu',
  ];

  // Slot waktu sesi Pagi (07:30–12:00)
  static const List<String> timeSlotsPagi = [
    '07:30', '08:00', '08:30', '09:00', '09:30',
    '10:00', '10:30', '11:00', '11:30', '12:00',
  ];

  // Slot waktu sesi Siang (12:30–16:30)
  static const List<String> timeSlotsSiang = [
    '12:30', '13:00', '13:30', '14:00', '14:30',
    '15:00', '15:30', '16:00', '16:30',
  ];

  // Gabungan semua slot
  static List<String> get allTimeSlots => [...timeSlotsPagi, ...timeSlotsSiang];

  // Kategori ruangan
  static const List<String> roomCategories = ['Kelas', 'Lab', 'Auditorium'];

  // Preferensi mengajar
  static const String prefPagi = 'Pagi';
  static const String prefSiang = 'Siang';

  // Batas MK per kelompok per hari
  static const int maxCoursesPerGroupPerDay = 3;

  // Durasi satu slot grid (30 menit)
  static const int minutesPerSlot = 30;

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

  // Business Rule Durasi SKS:
  //   1 SKS = 45 menit
  //   2 SKS = 90 menit
  //   3 SKS = 120 menit
  static const Map<int, int> durationRules = {
    1: 45,
    2: 90,
    3: 120,
  };

  /// Durasi menit berdasarkan SKS (business rule)
  static int creditsToDuration(int credits) {
    return durationRules[credits] ?? (credits * 45);
  }

  /// Jumlah slot grid yang diblokir berdasarkan SKS
  static int creditsToSlots(int credits) {
    return (creditsToDuration(credits) / minutesPerSlot).ceil();
  }

  /// Slot sesuai preferensi dosen
  static List<String> slotsForPreference(String preference) {
    return preference == prefPagi ? timeSlotsPagi : timeSlotsSiang;
  }

  /// Hitung waktu selesai berdasarkan business rule durasi
  static String? calculateEndTime(String startSlot, int credits) {
    final all = allTimeSlots;
    if (all.indexOf(startSlot) == -1) return null;
    return _addMinutes(startSlot, creditsToDuration(credits));
  }

  /// Konversi waktu HH:mm ke menit
  static int timeToMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  static String _addMinutes(String time, int minutes) {
    final parts = time.split(':');
    final total = int.parse(parts[0]) * 60 + int.parse(parts[1]) + minutes;
    return '${(total ~/ 60).toString().padLeft(2, '0')}:${(total % 60).toString().padLeft(2, '0')}';
  }
}

/// Exception saat data tidak cukup untuk generate jadwal
class SchedulingException implements Exception {
  final String message;
  const SchedulingException(this.message);

  @override
  String toString() => 'SchedulingException: $message';
}
