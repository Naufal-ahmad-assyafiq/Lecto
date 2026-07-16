import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/room.dart';
import '../services/storage_service.dart';

/// State notifier untuk manajemen data Ruangan
class RoomNotifier extends StateNotifier<List<Room>> {
  RoomNotifier() : super([]) {
    reload();
  }

  final _storage = StorageService.instance;
  final _uuid = const Uuid();

  /// Muat ulang data ruangan dari Hive ke state Riverpod.
  /// Dipanggil oleh SessionManager saat restore atau clear session.
  void reload() {
    state = _storage.getAllRooms();
  }

  /// Tambah ruangan baru
  Future<void> addRoom({
    required String roomName,
    required String category,
  }) async {
    final room = Room(
      id: _uuid.v4(),
      roomName: roomName,
      category: category,
    );
    await _storage.saveRoom(room);
    reload();
  }

  /// Update data ruangan
  Future<void> updateRoom(Room room) async {
    await _storage.saveRoom(room);
    reload();
  }

  /// Hapus ruangan
  Future<void> deleteRoom(String id) async {
    await _storage.deleteRoom(id);
    reload();
  }
}

/// Provider global untuk daftar ruangan
final roomProvider = StateNotifierProvider<RoomNotifier, List<Room>>(
  (ref) => RoomNotifier(),
);
