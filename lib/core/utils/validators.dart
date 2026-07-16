/// Validasi input form Lecto
class Validators {
  Validators._();

  /// Nama wajib diisi (min. 2 karakter)
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Nama wajib diisi';
    if (value.trim().length < 2) return 'Nama minimal 2 karakter';
    return null;
  }

  /// Email opsional — jika diisi harus format valid
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Format email tidak valid';
    return null;
  }

  /// Nomor HP opsional — jika diisi hanya boleh angka
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final phoneRegex = RegExp(r'^[0-9]+$');
    if (!phoneRegex.hasMatch(value.trim())) return 'Nomor HP hanya boleh angka';
    return null;
  }

  /// Kode MK wajib diisi (min. 2 karakter)
  static String? courseCode(String? value) {
    if (value == null || value.trim().isEmpty) return 'Kode MK wajib diisi';
    if (value.trim().length < 2) return 'Kode minimal 2 karakter';
    return null;
  }

  /// Nama MK wajib diisi
  static String? courseName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Nama MK wajib diisi';
    return null;
  }

  /// SKS antara 1–6
  static String? credits(String? value) {
    if (value == null || value.trim().isEmpty) return 'SKS wajib diisi';
    final sks = int.tryParse(value.trim());
    if (sks == null) return 'SKS harus berupa angka';
    if (sks < 1) return 'SKS minimal 1';
    if (sks > 6) return 'SKS maksimal 6';
    return null;
  }

  /// Nama ruangan wajib diisi
  static String? roomName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Nama ruangan wajib diisi';
    return null;
  }

  /// Field wajib diisi (generic)
  static String? required(String? value, {String label = 'Field'}) {
    if (value == null || value.trim().isEmpty) return '$label wajib diisi';
    return null;
  }
}
