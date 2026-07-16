// Rule Base — kondisi IF/THEN Forward Chaining

import 'knowledge_base.dart';

/// Seluruh rule penjadwalan Forward Chaining.
class Rules {
  Rules._();

  // Rule 1: preferensi Pagi
  static bool rulePreferensiPagi(String preference) =>
      preference == KnowledgeBase.prefPagi;

  // Rule 2: preferensi Siang
  static bool rulePreferensiSiang(String preference) =>
      preference == KnowledgeBase.prefSiang;

  // Rule 3: kategori ruangan sesuai
  static bool ruleKategoriRuanganValid(String roomCategory, String required) =>
      roomCategory == required;

  // Rule 4: ruangan tersedia
  static bool ruleRuanganTersedia(bool isRoomFree) => isRoomFree;

  // Rule 5: dosen tidak bentrok
  static bool ruleDosenTersedia(bool isLecturerFree) => isLecturerFree;

  // Rule 6: tidak ada overlap Prodi+Semester
  static bool ruleSlotProdiSemesterValid(bool isNoOverlap) => isNoOverlap;

  // Rule 7: hari belum penuh
  static bool ruleHariTersedia(int currentCount) =>
      currentCount < KnowledgeBase.maxCoursesPerGroupPerDay;

  // Rule 8: jadwal valid — semua kondisi terpenuhi
  static bool ruleJadwalValid({
    required bool slotDalamPreferensi,
    required bool ruanganSesuaiKategori,
    required bool ruanganTersedia,
    required bool dosenTersedia,
    required bool tidakAdaOverlapProdiSem,
    required bool hariBelumPenuh,
  }) {
    return slotDalamPreferensi &&
        ruanganSesuaiKategori &&
        ruanganTersedia &&
        dosenTersedia &&
        tidakAdaOverlapProdiSem &&
        hariBelumPenuh;
  }

  // Business Rule Durasi SKS
  //   1 SKS = 45 menit, 2 SKS = 90 menit, 3 SKS = 120 menit

  /// Durasi menit berdasarkan SKS
  static int ruleDurasiSKS(int credits) =>
      KnowledgeBase.creditsToDuration(credits);

  /// Jumlah slot grid berdasarkan SKS
  static int ruleSlotGrid(int credits) =>
      KnowledgeBase.creditsToSlots(credits);
}
