import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_theme.dart';
import '../core/constants/time_slots.dart';
import '../core/utils/validators.dart';
import '../models/course.dart';
import '../models/lecturer.dart';
import '../providers/lecturer_provider.dart';
import '../services/storage_service.dart';
import '../widgets/lecturer_card.dart';
import '../widgets/neo_button.dart';

/// Halaman manajemen Dosen
class LecturerScreen extends ConsumerStatefulWidget {
  const LecturerScreen({super.key});

  @override
  ConsumerState<LecturerScreen> createState() => _LecturerScreenState();
}

class _LecturerScreenState extends ConsumerState<LecturerScreen> {
  @override
  Widget build(BuildContext context) {
    final lecturers = ref.watch(lecturerProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Dosen'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: () => _showLecturerForm(context, ref),
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
      body: lecturers.isEmpty
          ? _buildEmpty()
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: lecturers.length,
              itemBuilder: (_, i) {
                final l = lecturers[i];
                return LecturerCard(
                  lecturer: l,
                  onEdit: () => _showLecturerForm(context, ref, lecturer: l),
                  onDelete: () => _confirmDelete(context, ref, l),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showLecturerForm(context, ref),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Tambah Dosen',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_outline,
              size: 64, color: AppColors.textMuted.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text('Belum ada dosen',
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text('Tambah dosen untuk mulai menjadwalkan',
              style:
                  TextStyle(color: AppColors.textMuted, fontSize: 13)),
          const SizedBox(height: 24),
          NeoButton(
            label: 'Tambah Dosen',
            icon: Icons.person_add_outlined,
            onPressed: () => _showLecturerForm(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, Lecturer l) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border, width: 2)),
        title: const Text('Hapus Dosen?',
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        content: Text(
          'Hapus dosen "${l.name}" dan seluruh mata kuliahnya?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
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
      await ref.read(lecturerProvider.notifier).deleteLecturer(l.id);
    }
  }

  Future<void> _showLecturerForm(BuildContext context, WidgetRef ref,
      {Lecturer? lecturer}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LecturerFormSheet(
        lecturer: lecturer,
        onSave: (name, phone, email, pref, courses) async {
          if (lecturer != null) {
            final updated = lecturer.copyWith(
              name: name,
              phone: phone,
              email: email,
              preference: pref,
              courses: courses,
            );
            await ref.read(lecturerProvider.notifier).updateLecturer(updated);
          } else {
            await ref.read(lecturerProvider.notifier).addLecturer(
                  name: name,
                  phone: phone,
                  email: email,
                  preference: pref,
                  courses: courses,
                );
          }
        },
      ),
    );
  }
}

// ─── Lecturer Form Bottom Sheet ──────────────────────────────────────────────

class _LecturerFormSheet extends StatefulWidget {
  const _LecturerFormSheet({this.lecturer, required this.onSave});

  final Lecturer? lecturer;
  final Future<void> Function(
    String name,
    String phone,
    String email,
    String preference,
    List<Course> courses,
  ) onSave;

  @override
  State<_LecturerFormSheet> createState() => _LecturerFormSheetState();
}

class _LecturerFormSheetState extends State<_LecturerFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  String _preference = TimeSlots.prefPagi;
  List<_CourseFormData> _courseData = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.lecturer != null) {
      _nameCtrl.text = widget.lecturer!.name;
      _phoneCtrl.text = widget.lecturer!.phone;
      _emailCtrl.text = widget.lecturer!.email;
      _preference = widget.lecturer!.preference;
      _courseData = widget.lecturer!.courses
          .map((c) => _CourseFormData.fromCourse(c))
          .toList();
    }
    if (_courseData.isEmpty) _courseData.add(_CourseFormData());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    for (final d in _courseData) {
      d.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.lecturer != null;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      maxChildSize: 0.97,
      minChildSize: 0.5,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(
              top: BorderSide(color: AppColors.border, width: 2)),
        ),
        child: Column(
          children: [
            // Drag handle
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.textMuted,
                  borderRadius: BorderRadius.circular(2)),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Text(
                    isEdit ? 'Edit Dosen' : 'Tambah Dosen',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.border),
            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  controller: ctrl,
                  padding: const EdgeInsets.all(20),
                  children: [
                    _sectionLabel('Biodata Dosen'),
                    const SizedBox(height: 12),
                    _textField(
                      controller: _nameCtrl,
                      label: 'Nama Dosen',
                      icon: Icons.person_outline,
                      validator: Validators.name,
                    ),
                    const SizedBox(height: 12),
                    _textField(
                      controller: _phoneCtrl,
                      label: 'Nomor HP (opsional)',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      validator: Validators.phone,
                    ),
                    const SizedBox(height: 12),
                    _textField(
                      controller: _emailCtrl,
                      label: 'Email (opsional)',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 24),

                    // Preferensi
                    _sectionLabel('Preferensi Mengajar'),
                    const SizedBox(height: 12),
                    _preferenceSelector(),
                    const SizedBox(height: 24),

                    // Mata Kuliah
                    Row(
                      children: [
                        _sectionLabel('Mata Kuliah'),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: _addCourse,
                          icon: const Icon(Icons.add,
                              color: AppColors.neonLime, size: 18),
                          label: const Text('Tambah MK',
                              style: TextStyle(
                                  color: AppColors.neonLime,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._courseData.asMap().entries.map((e) {
                      final index = e.key;
                      final data = e.value;
                      return _CourseFormCard(
                        data: data,
                        index: index,
                        onRemove: _courseData.length > 1
                            ? () => setState(
                                () => _courseData.removeAt(index))
                            : null,
                      );
                    }),
                    const SizedBox(height: 32),

                    // Save button
                    NeoButton(
                      label: isEdit ? 'Simpan Perubahan' : 'Tambah Dosen',
                      icon: Icons.save_outlined,
                      width: double.infinity,
                      height: 56,
                      isLoading: _saving,
                      onPressed: _saving ? null : _save,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
      ),
    );
  }

  Widget _preferenceSelector() {
    return Row(
      children: [
        Expanded(
          child: _prefOption(
            label: 'Pagi',
            subtitle: '07:30 – 12:00',
            icon: Icons.wb_sunny_outlined,
            value: TimeSlots.prefPagi,
            color: AppColors.neonLime,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _prefOption(
            label: 'Siang',
            subtitle: '12:30 – 16:30',
            icon: Icons.wb_twilight_outlined,
            value: TimeSlots.prefSiang,
            color: AppColors.electricBlue,
          ),
        ),
      ],
    );
  }

  Widget _prefOption({
    required String label,
    required String subtitle,
    required IconData icon,
    required String value,
    required Color color,
  }) {
    final selected = _preference == value;
    return GestureDetector(
      onTap: () => setState(() => _preference = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.12) : AppColors.bgCard,
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
        child: Row(
          children: [
            Icon(icon,
                color: selected ? color : AppColors.textMuted, size: 22),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                      color: selected ? color : AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    )),
                Text(subtitle,
                    style: TextStyle(
                      color: selected
                          ? color.withOpacity(0.7)
                          : AppColors.textMuted,
                      fontSize: 11,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addCourse() {
    setState(() => _courseData.add(_CourseFormData()));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Validasi semua form MK
    bool mkValid = true;
    for (final d in _courseData) {
      if (!d.formKey.currentState!.validate()) {
        mkValid = false;
      }
    }
    if (!mkValid) return;

    // Validasi kode MK unik
    final storage = StorageService.instance;
    for (final d in _courseData) {
      final code = d.codeCtrl.text.trim();
      if (storage.isCourseCodeExists(code,
          excludeLecturerId: widget.lecturer?.id)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Kode MK "$code" sudah digunakan!'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }
    }

    setState(() => _saving = true);

    const uuid = Uuid();
    final courses = _courseData.map((d) {
      return Course(
        id: d.id ?? uuid.v4(),
        courseName: d.nameCtrl.text.trim(),
        courseCode: d.codeCtrl.text.trim(),
        credits: int.tryParse(d.creditsCtrl.text.trim()) ?? 2,
        semester: d.semester,
        programStudi: d.programStudi,
        roomCategory: d.roomCategory,
      );
    }).toList();

    await widget.onSave(
      _nameCtrl.text.trim(),
      _phoneCtrl.text.trim(),
      _emailCtrl.text.trim(),
      _preference,
      courses,
    );

    setState(() => _saving = false);
    if (mounted) Navigator.pop(context);
  }
}

// ─── Course Form Data ─────────────────────────────────────────────────────────

class _CourseFormData {
  final String? id;
  final nameCtrl = TextEditingController();
  final codeCtrl = TextEditingController();
  final creditsCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  int semester = 1;
  String programStudi = 'Teknik Informatika';
  String roomCategory = 'Kelas';

  _CourseFormData({this.id});

  factory _CourseFormData.fromCourse(Course c) {
    final d = _CourseFormData(id: c.id);
    d.nameCtrl.text = c.courseName;
    d.codeCtrl.text = c.courseCode;
    d.creditsCtrl.text = c.credits.toString();
    d.semester = c.semester;
    d.programStudi = c.programStudi;
    d.roomCategory = c.roomCategory;
    return d;
  }

  void dispose() {
    nameCtrl.dispose();
    codeCtrl.dispose();
    creditsCtrl.dispose();
  }
}

// ─── Course Form Card ─────────────────────────────────────────────────────────

class _CourseFormCard extends StatefulWidget {
  const _CourseFormCard({
    required this.data,
    required this.index,
    this.onRemove,
  });

  final _CourseFormData data;
  final int index;
  final VoidCallback? onRemove;

  @override
  State<_CourseFormCard> createState() => _CourseFormCardState();
}

class _CourseFormCardState extends State<_CourseFormCard> {
  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.neoBrutalCard(
        borderColor: AppColors.neonLime.withOpacity(0.3),
        shadowOffset: 3,
      ),
      child: Form(
        key: data.formKey,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card MK
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.neonLime.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: AppColors.neonLime.withOpacity(0.4),
                          width: 1),
                    ),
                    child: Text(
                      'MK ${widget.index + 1}',
                      style: const TextStyle(
                        color: AppColors.neonLime,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (widget.onRemove != null)
                    IconButton(
                      onPressed: widget.onRemove,
                      icon: const Icon(Icons.remove_circle_outline,
                          color: AppColors.error, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Nama MK
              TextFormField(
                controller: data.nameCtrl,
                validator: Validators.courseName,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Nama Mata Kuliah',
                  prefixIcon: Icon(Icons.book_outlined,
                      color: AppColors.textMuted, size: 18),
                ),
              ),
              const SizedBox(height: 10),

              // Kode MK + SKS
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: data.codeCtrl,
                      validator: Validators.courseCode,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Kode MK',
                        prefixIcon: Icon(Icons.tag,
                            color: AppColors.textMuted, size: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: data.creditsCtrl,
                      validator: Validators.credits,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'SKS',
                        prefixIcon: Icon(Icons.timer_outlined,
                            color: AppColors.textMuted, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Program Studi (NEW)
              _dropdownLabel('Program Studi'),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: TimeSlots.programStudiList.contains(data.programStudi)
                    ? data.programStudi
                    : TimeSlots.programStudiList.first,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Program Studi wajib dipilih' : null,
                decoration: const InputDecoration(
                  labelText: 'Program Studi',
                  prefixIcon: Icon(
                    Icons.account_balance_outlined,
                    color: AppColors.textMuted,
                    size: 18,
                  ),
                ),
                dropdownColor: AppColors.bgCard,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 13),
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: AppColors.textMuted),
                items: TimeSlots.programStudiList.map((prodi) {
                  return DropdownMenuItem<String>(
                    value: prodi,
                    child: Text(prodi,
                        style:
                            const TextStyle(color: AppColors.textPrimary)),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => data.programStudi = v);
                },
              ),
              const SizedBox(height: 10),

              // Semester
              _dropdownLabel('Semester'),
              const SizedBox(height: 6),
              _chipSelector(
                items: TimeSlots.semesters.map((s) => s.toString()).toList(),
                selected: data.semester.toString(),
                onSelect: (v) =>
                    setState(() => data.semester = int.parse(v)),
                color: AppColors.electricBlue,
              ),
              const SizedBox(height: 10),

              // Jenis Ruangan
              _dropdownLabel('Jenis Ruangan'),
              const SizedBox(height: 6),
              _chipSelector(
                items: TimeSlots.roomCategories,
                selected: data.roomCategory,
                onSelect: (v) => setState(() => data.roomCategory = v),
                color: AppColors.neonOrange,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dropdownLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _chipSelector({
    required List<String> items,
    required String selected,
    required void Function(String) onSelect,
    required Color color,
  }) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: items.map((item) {
        final isSelected = item == selected;
        return GestureDetector(
          onTap: () => onSelect(item),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.15) : AppColors.bgCardAlt,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? color : AppColors.border,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Text(
              item,
              style: TextStyle(
                color: isSelected ? color : AppColors.textSecondary,
                fontSize: 12,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
