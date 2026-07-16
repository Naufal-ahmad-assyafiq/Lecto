import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/time_slots.dart';
import '../core/utils/validators.dart';
import '../models/room.dart';
import '../providers/room_provider.dart';
import '../services/storage_service.dart';
import '../widgets/neo_button.dart';
import '../widgets/room_card.dart';

/// Halaman manajemen Ruangan
class RoomScreen extends ConsumerStatefulWidget {
  const RoomScreen({super.key});

  @override
  ConsumerState<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends ConsumerState<RoomScreen> {
  @override
  Widget build(BuildContext context) {
    final rooms = ref.watch(roomProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Ruangan'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: () => _showRoomForm(context, ref),
              icon: const Icon(Icons.add, color: AppColors.neonLime, size: 20),
              label: const Text(
                'Tambah',
                style: TextStyle(
                    color: AppColors.neonLime, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
      body: rooms.isEmpty
          ? _buildEmpty()
          : Column(
              children: [
                // Summary bar
                _buildSummaryBar(rooms),
                // List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: rooms.length,
                    itemBuilder: (_, i) {
                      final r = rooms[i];
                      return RoomCard(
                        room: r,
                        onEdit: () => _showRoomForm(context, ref, room: r),
                        onDelete: () => _confirmDelete(context, ref, r),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRoomForm(context, ref),
        icon: const Icon(Icons.meeting_room_outlined),
        label: const Text('Tambah Ruangan',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildSummaryBar(List<Room> rooms) {
    final counts = <String, int>{
      for (final cat in TimeSlots.roomCategories)
        cat: rooms.where((r) => r.category == cat).length,
    };
    const catColors = <String, Color>{
      'Kelas': AppColors.neonLime,
      'Lab': AppColors.electricBlue,
      'Auditorium': AppColors.purple,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.bgSecondary,
        border: Border(
            bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: TimeSlots.roomCategories.map((cat) {
          final color = catColors[cat]!;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${counts[cat]} $cat',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.meeting_room_outlined,
              size: 64, color: AppColors.textMuted.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text('Belum ada ruangan',
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text('Tambah ruangan untuk mendukung penjadwalan',
              style:
                  TextStyle(color: AppColors.textMuted, fontSize: 13)),
          const SizedBox(height: 24),
          NeoButton(
            label: 'Tambah Ruangan',
            icon: Icons.meeting_room_outlined,
            onPressed: () => _showRoomForm(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, Room r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border, width: 2)),
        title: const Text('Hapus Ruangan?',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700)),
        content: Text('Hapus ruangan "${r.roomName}"?',
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(roomProvider.notifier).deleteRoom(r.id);
    }
  }

  Future<void> _showRoomForm(BuildContext context, WidgetRef ref,
      {Room? room}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RoomFormSheet(
        room: room,
        onSave: (name, category) async {
          if (room != null) {
            final updated = room.copyWith(roomName: name, category: category);
            await ref.read(roomProvider.notifier).updateRoom(updated);
          } else {
            await ref.read(roomProvider.notifier).addRoom(
                  roomName: name,
                  category: category,
                );
          }
        },
      ),
    );
  }
}

// ─── Room Form Bottom Sheet ───────────────────────────────────────────────────

class _RoomFormSheet extends StatefulWidget {
  const _RoomFormSheet({this.room, required this.onSave});

  final Room? room;
  final Future<void> Function(String name, String category) onSave;

  @override
  State<_RoomFormSheet> createState() => _RoomFormSheetState();
}

class _RoomFormSheetState extends State<_RoomFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  String _category = 'Kelas';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.room != null) {
      _nameCtrl.text = widget.room!.roomName;
      _category = widget.room!.category;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  static const _categoryIcons = <String, IconData>{
    'Kelas': Icons.class_outlined,
    'Lab': Icons.science_outlined,
    'Auditorium': Icons.theater_comedy_outlined,
  };

  static const _categoryColors = <String, Color>{
    'Kelas': AppColors.neonLime,
    'Lab': AppColors.electricBlue,
    'Auditorium': AppColors.purple,
  };

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.room != null;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(
              top: BorderSide(color: AppColors.border, width: 2)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.textMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Text(
              isEdit ? 'Edit Ruangan' : 'Tambah Ruangan',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 20),

            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    validator: (v) {
                      final err = Validators.roomName(v);
                      if (err != null) return err;
                      // Validasi nama unik
                      final storage = StorageService.instance;
                      if (storage.isRoomNameExists(v!.trim(),
                          excludeId: widget.room?.id)) {
                        return 'Nama ruangan sudah digunakan';
                      }
                      return null;
                    },
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Nama Ruangan',
                      prefixIcon: Icon(Icons.meeting_room_outlined,
                          color: AppColors.textMuted, size: 20),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'KATEGORI',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: TimeSlots.roomCategories.map((cat) {
                      final color = _categoryColors[cat]!;
                      final icon = _categoryIcons[cat]!;
                      final selected = _category == cat;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _category = cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 8),
                            decoration: BoxDecoration(
                              color: selected
                                  ? color.withOpacity(0.12)
                                  : AppColors.bgCard,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected ? color : AppColors.border,
                                width: selected ? 2 : 1.5,
                              ),
                              boxShadow: selected
                                  ? [
                                      BoxShadow(
                                        color: color.withOpacity(0.2),
                                        offset: const Offset(3, 3),
                                        blurRadius: 0,
                                      )
                                    ]
                                  : [],
                            ),
                            child: Column(
                              children: [
                                Icon(icon,
                                    color: selected
                                        ? color
                                        : AppColors.textMuted,
                                    size: 24),
                                const SizedBox(height: 6),
                                Text(
                                  cat,
                                  style: TextStyle(
                                    color: selected
                                        ? color
                                        : AppColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  NeoButton(
                    label: isEdit ? 'Simpan Perubahan' : 'Tambah Ruangan',
                    icon: Icons.save_outlined,
                    width: double.infinity,
                    height: 52,
                    isLoading: _saving,
                    onPressed: _saving ? null : _save,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await widget.onSave(_nameCtrl.text.trim(), _category);
    setState(() => _saving = false);
    if (mounted) Navigator.pop(context);
  }
}
