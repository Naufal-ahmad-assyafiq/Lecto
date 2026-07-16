// ============================================================
// DEPRECATED — File ini telah dipindahkan
// ============================================================
//
// Seluruh logika Forward Chaining telah direfaktor ke:
//   lib/core/forward_chaining/
//
// File baru:
//   knowledge_base.dart      ← Fakta & konstanta sistem
//   rules.dart               ← Rule IF/THEN (8 rule)
//   fact_manager.dart        ← Pengambil fakta dari Hive
//   conflict_checker.dart    ← Validasi semua bentrok
//   schedule_engine.dart     ← Least Loaded Day strategy
//   inference_engine.dart    ← Inti algoritma Forward Chaining
//   forward_chaining_engine.dart ← Façade (entry point)
//
// File ini dipertahankan sebagai barrel export
// untuk menghindari breaking imports yang mungkin ada.
// ============================================================

export '../core/forward_chaining/forward_chaining_engine.dart';
