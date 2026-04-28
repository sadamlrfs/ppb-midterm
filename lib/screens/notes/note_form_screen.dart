import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../models/note_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/app_button.dart';

class NoteFormScreen extends StatefulWidget {
  final String thesisId;
  final String? bimbinganId;
  final NoteModel? existing;

  const NoteFormScreen({
    super.key,
    required this.thesisId,
    this.bimbinganId,
    this.existing,
  });

  @override
  State<NoteFormScreen> createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> {
  final _bodyCtrl = TextEditingController();
  bool _loading = false;
  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) _bodyCtrl.text = widget.existing!.body;
  }

  @override
  void dispose() {
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_bodyCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note cannot be empty')),
      );
      return;
    }
    setState(() => _loading = true);
    final uid = context.read<AuthProvider>().user!.uid;
    final fs = FirestoreService();
    try {
      if (_isEdit) {
        final updated = NoteModel(
          id: widget.existing!.id,
          thesisId: widget.thesisId,
          bimbinganId: widget.bimbinganId,
          authorId: uid,
          body: _bodyCtrl.text.trim(),
          createdAt: widget.existing!.createdAt,
        );
        await fs.updateNote(updated);
      } else {
        await fs.createNote(NoteModel(
          id: const Uuid().v4(),
          thesisId: widget.thesisId,
          bimbinganId: widget.bimbinganId,
          authorId: uid,
          body: _bodyCtrl.text.trim(),
          createdAt: DateTime.now(),
        ));
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Note' : 'New Note'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.error),
              onPressed: () async {
                await FirestoreService().deleteNote(widget.existing!.id);
                if (context.mounted) Navigator.pop(context);
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _bodyCtrl,
                  maxLines: null,
                  expands: true,
                  keyboardType: TextInputType.multiline,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Write your note here…',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: AppColors.textLight),
                    filled: false,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: _isEdit ? 'Save Changes' : 'Save Note',
              loading: _loading,
              onPressed: _submit,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
