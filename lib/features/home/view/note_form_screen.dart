import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quicknotes/core/di/injection.dart';
import 'package:quicknotes/core/localization/l10n_extension.dart';
import 'package:quicknotes/core/services/audio_record_service.dart';
import 'package:quicknotes/core/services/biometric_service.dart';
import 'package:quicknotes/core/services/gemini_service.dart';
import 'package:quicknotes/core/services/location_service.dart';
import 'package:quicknotes/core/services/notification_service.dart';
import 'package:quicknotes/core/theme/app_theme.dart';
import 'package:quicknotes/core/utils/app_colors.dart';
import 'package:quicknotes/core/utils/app_text_style.dart';
import 'package:quicknotes/core/utils/note_export_helper.dart';
import 'package:quicknotes/core/utils/snackbar_helper.dart';
import 'package:quicknotes/core/utils/validators.dart';
import 'package:quicknotes/features/home/model/note_model.dart';
import 'package:quicknotes/features/home/model/subtask_model.dart';
import 'package:quicknotes/features/home/view/widgets/ai_summary_sheet.dart';
import 'package:quicknotes/features/home/view/widgets/note_metadata.dart';
import 'package:quicknotes/features/home/view/widgets/note_text_field.dart';
import 'package:quicknotes/features/home/view/widgets/subtasks_editor.dart';
import 'package:quicknotes/features/home/view/widgets/tags_selector.dart';
import 'package:quicknotes/features/home/view/widgets/voice_note_widget.dart';
import 'package:quicknotes/features/home/view_model/cubit/notes_cubit.dart';

enum NoteType { text, checklist }

class NoteFormScreen extends StatefulWidget {
  final Note? note;

  const NoteFormScreen({super.key, this.note});

  bool get isEditMode => note != null;

  @override
  State<NoteFormScreen> createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;

  final LocationService _locationService = LocationService();
  late final BiometricService _biometricService;
  late final AudioRecordService _audioRecordService;
  final ImagePicker _imagePicker = ImagePicker();

  late bool _attachLocation;
  late bool _isLocked;
  late bool _isPinned;
  late bool _isFavorite;
  late List<String> _tags;
  late List<Subtask> _subtasks;
  late NoteType _noteType;
  DateTime? _reminderAt;

  double? _latitude;
  double? _longitude;

  bool _isSaving = false;
  bool _isRecordingAudio = false;
  int _recordDurationSeconds = 0;
  Timer? _recordTimer;
  String? _audioPath;
  bool _isScanningOcr = false;

  @override
  void initState() {
    super.initState();

    _biometricService = sl.isRegistered<BiometricService>()
        ? sl<BiometricService>()
        : BiometricService();

    _audioRecordService = sl.isRegistered<AudioRecordService>()
        ? sl<AudioRecordService>()
        : AudioRecordService();

    _audioPath = widget.note?.audioPath;

    _titleController = TextEditingController(text: widget.note?.title ?? '');

    _bodyController = TextEditingController(text: widget.note?.body ?? '');

    _attachLocation = widget.note?.hasLocation ?? false;
    _isLocked = widget.note?.isLocked ?? false;
    _isPinned = widget.note?.isPinned ?? false;
    _isFavorite = widget.note?.isFavorite ?? false;
    _tags = List<String>.from(widget.note?.tags ?? const []);
    _subtasks = List<Subtask>.from(widget.note?.subtasks ?? const []);
    _reminderAt = widget.note?.reminderAt;

    // Automatically select Checklist mode if note has subtasks, else Text Note
    if (widget.note != null && widget.note!.hasSubtasks) {
      _noteType = NoteType.checklist;
    } else {
      _noteType = NoteType.text;
    }

    _latitude = widget.note?.latitude;
    _longitude = widget.note?.longitude;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _recordTimer?.cancel();
    if (_isRecordingAudio) {
      _audioRecordService.cancelRecording();
    }
    super.dispose();
  }

  void _handleLocationToggle(bool enable) {
    setState(() {
      _attachLocation = enable;
      if (!enable) {
        _latitude = null;
        _longitude = null;
      }
    });

    if (enable && (_latitude == null || _longitude == null)) {
      _locationService
          .getCurrentLocation()
          .then((position) {
            if (mounted && _attachLocation) {
              setState(() {
                _latitude = position.latitude;
                _longitude = position.longitude;
              });
            }
          })
          .catchError((_) {
            // Silently ignore; Cubit will handle in background if saved
          });
    }
  }

  Future<void> _handleLockToggle(bool enable) async {
    final isAr = context.isArabic;
    if (enable) {
      final canAuth = await _biometricService.canAuthenticate();
      if (!canAuth) {
        if (mounted) {
          _showError(
            isAr
                ? 'لم يتم إعداد المصادقة البيومترية / رمز المرور على هذا الجهاز.'
                : 'Biometrics / Passcode is not set up on this device.',
          );
        }
        return;
      }

      final authenticated = await _biometricService.authenticate(
        localizedReason: isAr
            ? 'تأكيد البصمة أو رمز المرور لقفل هذه الملاحظة'
            : 'Confirm fingerprint or passcode to lock this note',
      );

      if (authenticated && mounted) {
        setState(() {
          _isLocked = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.slate900,
            duration: const Duration(seconds: 2),
            content: Row(
              children: [
                const Icon(Icons.lock_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  isAr
                      ? 'تم قفل الملاحظة بأمان الهاتف'
                      : 'Note locked with phone security',
                ),
              ],
            ),
          ),
        );
      } else if (mounted) {
        _showError(
          isAr
              ? 'تم إلغاء المصادقة. تظل الملاحظة غير مقفلة.'
              : 'Authentication cancelled. Note remains unlocked.',
        );
      }
    } else {
      final authenticated = await _biometricService.authenticate(
        localizedReason: isAr
            ? 'تأكيد البصمة أو رمز المرور لإلغاء قفل هذه الملاحظة'
            : 'Confirm fingerprint or passcode to unlock this note',
      );

      if (authenticated && mounted) {
        setState(() {
          _isLocked = false;
        });
      } else if (mounted) {
        _showError(
          isAr ? 'تم إلغاء المصادقة.' : 'Authentication cancelled.',
        );
      }
    }
  }

  Future<void> _pickReminderDateTime() async {
    if (sl.isRegistered<NotificationService>()) {
      await sl<NotificationService>().requestPermissions();
    }
    if (!mounted) return;

    final now = DateTime.now();
    final initialDate = _reminderAt != null && _reminderAt!.isAfter(now)
        ? _reminderAt!
        : now.add(const Duration(hours: 1));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.skyBlue,
              onPrimary: Colors.white,
              onSurface: AppColors.slate900,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null || !mounted) return;

    final initialTime = TimeOfDay.fromDateTime(initialDate);
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.skyBlue,
              onPrimary: Colors.white,
              onSurface: AppColors.slate900,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null || !mounted) return;

    final scheduledDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (scheduledDateTime.isBefore(DateTime.now().subtract(const Duration(minutes: 1)))) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.isArabic
                  ? 'يرجى اختيار وقت في المستقبل للتذكير'
                  : 'Please select a future time for the reminder',
              style: const TextStyle(fontFamily: AppTextStyle.fontFamily),
            ),
            backgroundColor: AppColors.destructive,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    setState(() {
      _reminderAt = scheduledDateTime;
    });
  }

  Note _buildCurrentNote() {
    final bodyText = _noteType == NoteType.text ? _bodyController.text.trim() : '';
    final taskList = _noteType == NoteType.checklist ? _subtasks : const <Subtask>[];
    return Note(
      id: widget.note?.id ?? 0,
      title: _titleController.text.trim(),
      body: bodyText,
      latitude: _attachLocation ? _latitude : null,
      longitude: _attachLocation ? _longitude : null,
      createdAt: widget.note?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      isLocked: _isLocked,
      isPinned: _isPinned,
      isFavorite: _isFavorite,
      tags: _tags,
      subtasks: taskList,
      reminderAt: _reminderAt,
      audioPath: _audioPath,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_noteType == NoteType.checklist && _subtasks.isEmpty) {
      _showError(
        context.isArabic
            ? 'يرجى إضافة مهمة واحدة على الأقل إلى قائمة المهام.'
            : 'Please add at least one task to your checklist.',
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final cubit = context.read<NotesCubit>();
      final shouldFetchInBackground =
          _attachLocation && (_latitude == null || _longitude == null);

      bool success;

      final bodyText = _noteType == NoteType.text
          ? _bodyController.text.trim()
          : '';
      final taskList = _noteType == NoteType.checklist
          ? _subtasks
          : const <Subtask>[];

      if (widget.isEditMode) {
        final oldNote = widget.note!;

        final updatedNote = Note(
          id: oldNote.id,
          title: _titleController.text.trim(),
          body: bodyText,
          latitude: _attachLocation ? _latitude : null,
          longitude: _attachLocation ? _longitude : null,
          createdAt: oldNote.createdAt,
          updatedAt: DateTime.now(),
          isLocked: _isLocked,
          isPinned: _isPinned,
          isFavorite: _isFavorite,
          isDeleted: false,
          tags: _tags,
          subtasks: taskList,
          reminderAt: _reminderAt,
          audioPath: _audioPath,
        );

        success = await cubit.updateNote(
          updatedNote,
          fetchLocationInBackground: shouldFetchInBackground,
        );
      } else {
        success = await cubit.addNote(
          title: _titleController.text.trim(),
          body: bodyText,
          latitude: _attachLocation ? _latitude : null,
          longitude: _attachLocation ? _longitude : null,
          isLocked: _isLocked,
          isPinned: _isPinned,
          isFavorite: _isFavorite,
          tags: _tags,
          subtasks: taskList,
          reminderAt: _reminderAt,
          audioPath: _audioPath,
          fetchLocationInBackground: shouldFetchInBackground,
        );
      }

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _handleAiSummarize() {
    final title = _titleController.text.trim();
    String content = '';
    if (_noteType == NoteType.text) {
      content = _bodyController.text.trim();
    } else {
      content = _subtasks
          .map((s) => '- ${s.title} (${s.isCompleted ? "Done" : "Todo"})')
          .join('\n');
    }

    if (content.length < 15) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.slate900,
          content: Text(
            context.isArabic
                ? 'يرجى كتابة المزيد من النص قبل التلخيص بالذكاء الاصطناعي'
                : 'Please add more text before summarizing with AI',
          ),
        ),
      );
      return;
    }

    AiSummarySheet.show(
      context: context,
      noteTitle: title,
      noteContent: content,
      onAppendToNote: (summary) {
        setState(() {
          if (_noteType == NoteType.checklist) {
            _noteType = NoteType.text;
          }
          final current = _bodyController.text.trim();
          final header = context.isArabic ? '📌 ملخص الذكاء الاصطناعي:' : '📌 AI Summary:';
          if (current.isEmpty) {
            _bodyController.text = '$header\n$summary';
          } else {
            _bodyController.text = '$current\n\n$header\n$summary';
          }
        });
      },
      onReplaceNote: (summary) {
        setState(() {
          if (_noteType == NoteType.checklist) {
            _noteType = NoteType.text;
          }
          _bodyController.text = summary;
        });
      },
    );
  }

  Future<void> _handleExtractTasks() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    if (body.isEmpty) return;

    try {
      final gemini = sl<GeminiService>();
      final tasks = await gemini.extractTasks(title: title, body: body);

      if (mounted) {
        if (tasks.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.slate900,
              content: Text(
                context.isArabic
                    ? 'لم يتم العثور على مهام أو مواعيد تنفيذية في الملاحظة'
                    : 'No actionable tasks or deadlines detected in note',
              ),
            ),
          );
        } else {
          final newSubtasks = tasks.map((t) {
            final uniqueId = '${DateTime.now().microsecondsSinceEpoch}_${t.hashCode.abs()}';
            return Subtask(
              id: uniqueId,
              title: t,
              isCompleted: false,
            );
          }).toList();

          setState(() {
            _noteType = NoteType.checklist;
            _subtasks = [..._subtasks, ...newSubtasks];
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.slate900,
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.isArabic
                          ? 'تم تحويل الملاحظة إلى ${tasks.length} مهام بنجاح!'
                          : 'Converted note into ${tasks.length} tasks!',
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final friendlyMsg = GeminiService.getUserFriendlyError(e, isArabic: context.isArabic);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
            content: Text(friendlyMsg),
          ),
        );
      }
    }
  }

  void _showAiAssistantMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: AppColors.dragHandle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded, color: AppColors.skyBlue, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        context.isArabic ? 'المساعد الذكي Gemini' : 'Gemini AI Assistant',
                        style: const TextStyle(
                          fontFamily: AppTextStyle.fontFamily,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.slate900,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: AppColors.borderSubtle, height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.skyBlueBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.summarize_rounded, color: AppColors.skyBlue, size: 20),
                  ),
                  title: Text(
                    context.isArabic ? 'تلخيص الملاحظة' : 'Summarize Note',
                    style: AppTextStyle.bodyLarge,
                  ),
                  subtitle: Text(
                    context.isArabic
                        ? 'ملخص تنفيذي موجز لمحتواك'
                        : 'Concise executive summary of your content',
                    style: AppTextStyle.bodySmall,
                  ),
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    _handleAiSummarize();
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.skyBlueBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.checklist_rounded, color: AppColors.skyBlue, size: 20),
                  ),
                  title: Text(
                    context.isArabic
                        ? 'تحويل الملاحظة ← مهام ومواعيد'
                        : 'Convert Note → Tasks & Deadlines',
                    style: AppTextStyle.bodyLarge,
                  ),
                  subtitle: Text(
                    context.isArabic
                        ? 'استخراج المهام والمواعيد وتحويلها إلى قائمة مهام'
                        : 'Extract actionable tasks and scheduled deadlines into a checklist',
                    style: AppTextStyle.bodySmall,
                  ),
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    _handleExtractTasks();
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.tag_rounded, color: Color(0xFF16A34A), size: 20),
                  ),
                  title: Text(
                    context.isArabic ? 'اقتراح وسوم ذكية تلقائياً' : 'Auto-Suggest Smart Tags',
                    style: AppTextStyle.bodyLarge,
                  ),
                  subtitle: Text(
                    context.isArabic
                        ? 'تصنيف المحتوى واقتراح وسوم تصنيفية مناسبة'
                        : 'Classify content and suggest relevant category tags',
                    style: AppTextStyle.bodySmall,
                  ),
                  onTap: () async {
                    Navigator.of(bottomSheetContext).pop();
                    final title = _titleController.text.trim();
                    final body = _bodyController.text.trim();
                    if (title.isEmpty && body.isEmpty) {
                      _showError(
                        context.isArabic
                            ? 'أضف عنواناً أو محتوى للملاحظة أولاً'
                            : 'Add a title or note content first',
                      );
                      return;
                    }
                    try {
                      final gemini = sl<GeminiService>();
                      final tags = await gemini.suggestTags(title: title, body: body);
                      if (tags.isNotEmpty && mounted) {
                        setState(() {
                          for (final t in tags) {
                            if (!_tags.contains(t)) _tags.add(t);
                          }
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppColors.slate900,
                            content: Text(
                              context.isArabic
                                  ? 'تمت إضافة وسوم الذكاء الاصطناعي: ${tags.join('، ')}'
                                  : 'Added AI tags: ${tags.join(', ')}',
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        final friendlyMsg = GeminiService.getUserFriendlyError(e, isArabic: context.isArabic);
                        _showError(friendlyMsg);
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggleAudioRecording() async {
    if (_isRecordingAudio) {
      await _stopAudioRecording();
    } else {
      await _startAudioRecording();
    }
  }

  Future<void> _startAudioRecording() async {
    try {
      final permitted = await _audioRecordService.hasPermission();
      if (!permitted) {
        if (mounted) {
          _showError(
            context.isArabic
                ? 'يرجى إعطاء صلاحية الميكروفون لتسجيل الملاحظة الصوتية'
                : 'Microphone permission denied. Please grant microphone access.',
          );
        }
        return;
      }

      final path = await _audioRecordService.startRecording();
      if (path != null && mounted) {
        setState(() {
          _isRecordingAudio = true;
          _recordDurationSeconds = 0;
        });

        _recordTimer?.cancel();
        _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (!mounted) {
            timer.cancel();
            return;
          }
          setState(() {
            _recordDurationSeconds++;
          });
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isRecordingAudio = false);
        _showError(
          context.isArabic
              ? 'خطأ في التسجيل الصوتي: $e'
              : 'Voice recording error: $e',
        );
      }
    }
  }

  Future<void> _stopAudioRecording() async {
    _recordTimer?.cancel();
    try {
      final path = await _audioRecordService.stopRecording();
      if (mounted) {
        setState(() {
          _isRecordingAudio = false;
          _recordDurationSeconds = 0;
          if (path != null && path.isNotEmpty) {
            _audioPath = path;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.isArabic
                  ? 'تم حفظ الملاحظة الصوتية بنجاح 🎙️'
                  : 'Voice note recorded successfully 🎙️',
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRecordingAudio = false;
          _recordDurationSeconds = 0;
        });
        _showError(
          context.isArabic
              ? 'فشل إيقاف التسجيل: $e'
              : 'Failed to stop recording: $e',
        );
      }
    }
  }

  Future<void> _cancelAudioRecording() async {
    _recordTimer?.cancel();
    try {
      await _audioRecordService.cancelRecording();
    } catch (_) {}
    if (mounted) {
      setState(() {
        _isRecordingAudio = false;
        _recordDurationSeconds = 0;
      });
    }
  }

  String _formatTimerSeconds(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _handleOcrScan() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.dragHandle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  context.isArabic
                      ? 'مسح الملاحظة بالذكاء الاصطناعي (OCR)'
                      : 'Scan Note with AI (OCR)',
                  style: AppTextStyle.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  context.isArabic
                      ? 'التقط صورة لملاحظاتك المكتوبة بخط اليد أو المستندات لاستخراج النصوص والمهام تلقائياً.'
                      : 'Take a picture of handwritten notes, documents, or whiteboards to extract text and tasks automatically.',
                  style: AppTextStyle.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                  ),
                  title: Text(
                    context.isArabic ? 'التقاط صورة بالكاميرا' : 'Take Photo with Camera',
                    style: AppTextStyle.bodyLarge,
                  ),
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.skyBlueBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.photo_library_rounded, color: AppColors.skyBlue),
                  ),
                  title: Text(
                    context.isArabic ? 'اختيار من المعرض' : 'Choose from Gallery',
                    style: AppTextStyle.bodyLarge,
                  ),
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) return;

    try {
      final picked = await _imagePicker.pickImage(source: source);
      if (picked == null) return;

      setState(() => _isScanningOcr = true);

      final bytes = await picked.readAsBytes();
      final mime = picked.mimeType ?? 'image/jpeg';
      final gemini = sl<GeminiService>();
      final result = await gemini.extractNoteFromImage(imageBytes: bytes, mimeType: mime);

      if (!mounted) return;

      final extractedTitle = (result['title'] as String?)?.trim() ?? '';
      final extractedBody = (result['body'] as String?)?.trim() ?? '';
      final extractedTasks = (result['tasks'] as List<dynamic>?)
              ?.map((e) => e.toString().trim())
              .where((e) => e.isNotEmpty)
              .toList() ??
          [];

      setState(() {
        if (_titleController.text.trim().isEmpty && extractedTitle.isNotEmpty) {
          _titleController.text = extractedTitle;
        }

        if (_noteType == NoteType.checklist || extractedTasks.isNotEmpty) {
          for (final task in extractedTasks) {
            _subtasks.add(
              Subtask(
                 id: '${DateTime.now().microsecondsSinceEpoch}_${task.hashCode.abs()}',
                 title: task,
                 isCompleted: false,
               ),
            );
          }
        }

        if (extractedBody.isNotEmpty) {
          final cur = _bodyController.text.trim();
          _bodyController.text = cur.isEmpty ? extractedBody : '$cur\n\n$extractedBody';
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.slate900,
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.isArabic
                      ? 'تم استخراج الملاحظة من الصورة بنجاح!${extractedTasks.isNotEmpty ? ' (تمت إضافة ${extractedTasks.length} مهام)' : ''}'
                      : 'Extracted note from image successfully!${extractedTasks.isNotEmpty ? ' (${extractedTasks.length} tasks added)' : ''}',
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        final friendlyMsg = GeminiService.getUserFriendlyError(e, isArabic: context.isArabic);
        _showError(friendlyMsg);
      }
    } finally {
      if (mounted) setState(() => _isScanningOcr = false);
    }
  }

  Future<void> _delete() async {
    if (widget.note == null) return;

    if (_isLocked) {
      final authenticated = await _biometricService.authenticate(
        localizedReason: context.isArabic
            ? 'المصادقة لحذف هذه الملاحظة المقفلة'
            : 'Authenticate to delete this locked note',
      );
      if (!authenticated) {
        if (mounted) {
          _showError(
            context.isArabic
                ? 'فشلت المصادقة. لم يتم حذف الملاحظة.'
                : 'Authentication failed. Note was not deleted.',
          );
        }
        return;
      }
    }

    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(context.l10n.deleteNote, style: AppTextStyle.headlineSmall),
          content: Text(
            context.l10n.deleteAllNotesMessage,
            style: AppTextStyle.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                context.l10n.cancel,
                style: const TextStyle(
                  color: AppColors.slate600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.destructive,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(context.l10n.delete),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      final cubit = context.read<NotesCubit>();
      final noteToDelete = widget.note!;

      SnackbarHelper.showDeleteUndoSnackBar(
        note: noteToDelete,
        cubit: cubit,
      );

      Navigator.of(context).pop();
      await cubit.deleteNote(noteToDelete);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.error,
        content: Text(message, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildToolbarIconButton({
    required String tooltip,
    required IconData icon,
    required VoidCallback? onPressed,
    bool isLoading = false,
    Color? color,
    Color? backgroundColor,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : Icon(
                    icon,
                    size: 20,
                    color: color ?? AppColors.slate700,
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.isEditMode;
    final viewInsetsBottom = MediaQuery.viewInsetsOf(context).bottom;
    final paddingBottom = MediaQuery.paddingOf(context).bottom;

    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: context.surfaceColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 19,
            color: context.textPrimary,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          isEdit ? context.l10n.editNote : context.l10n.addNote,
          style: TextStyle(
            fontFamily: AppTextStyle.fontFamily,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: context.textPrimary,
          ),
        ),
        centerTitle: false,
        actions: [
          // AI Assistant Pill
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _showAiAssistantMenu,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0C4A6E) : AppColors.skyBlueBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppTheme.darkSkyBlue : AppColors.skyBlue.withValues(alpha: 0.35),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: isDark ? AppTheme.darkSkyBlue : AppColors.skyBlue,
                      size: 14,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'AI',
                      style: TextStyle(
                        fontFamily: AppTextStyle.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppTheme.darkSkyBlue : AppColors.skyBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Discreet Context Menu for meta actions (Share, Favorite, Pin, Lock, Delete)
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_horiz_rounded,
              color: context.iconColor,
              size: 22,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: context.borderColor, width: 1),
            ),
            color: context.surfaceColor,
            elevation: 4,
            onSelected: (value) async {
              switch (value) {
                case 'share':
                  final currentNote = _buildCurrentNote();
                  NoteExportHelper.shareNote(currentNote);
                  break;
                case 'favorite':
                  setState(() => _isFavorite = !_isFavorite);
                  break;
                case 'pin':
                  setState(() => _isPinned = !_isPinned);
                  break;
                case 'lock':
                  _handleLockToggle(!_isLocked);
                  break;
                case 'delete':
                  _delete();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    const Icon(
                      Icons.share_outlined,
                      color: AppColors.skyBlue,
                      size: 19,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      context.l10n.shareNote,
                      style: AppTextStyle.bodyMedium.copyWith(
                        color: context.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'favorite',
                child: Row(
                  children: [
                    Icon(
                      _isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: _isFavorite ? const Color(0xFFF59E0B) : context.iconColor,
                      size: 19,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _isFavorite
                          ? context.l10n.removeFromFavorites
                          : context.l10n.addToFavorites,
                      style: AppTextStyle.bodyMedium.copyWith(
                        color: context.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'pin',
                child: Row(
                  children: [
                    Icon(
                      _isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                      color: _isPinned ? AppColors.primary : context.iconColor,
                      size: 19,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _isPinned
                          ? context.l10n.unpinNote
                          : context.l10n.pinNote,
                      style: AppTextStyle.bodyMedium.copyWith(
                        color: context.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'lock',
                child: Row(
                  children: [
                    Icon(
                      _isLocked ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                      color: _isLocked ? AppColors.primary : context.iconColor,
                      size: 19,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _isLocked
                          ? context.l10n.unlockNote
                          : context.l10n.lockNote,
                      style: AppTextStyle.bodyMedium.copyWith(
                        color: context.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isEdit) ...[
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete_outline_rounded, color: AppColors.destructive, size: 19),
                      const SizedBox(width: 10),
                      Text(
                        context.l10n.deleteNote,
                        style: const TextStyle(
                          fontFamily: AppTextStyle.fontFamily,
                          color: AppColors.destructive,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              children: [
                // Title Field
                NoteTextField(
                  controller: _titleController,
                  text: context.l10n.noteTitleHint,
                  maxLines: null,
                  maxLength: Validators.maxTitleLength,
                  validator: (val) => Validators.validateTitle(
                    val,
                    isArabic: context.isArabic,
                  ),
                ),

                const SizedBox(height: 8),

                // Note timestamp metadata & Status chips row
                Row(
                  children: [
                    Expanded(
                      child: NoteMetadata(isEdit: isEdit, note: widget.note),
                    ),
                    if (_isPinned)
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTheme.darkSkyBlue.withValues(alpha: 0.16)
                              : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: (isDark ? AppTheme.darkSkyBlue : AppColors.primary)
                                .withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.push_pin_rounded,
                              size: 11,
                              color: isDark ? AppTheme.darkSkyBlue : AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              context.isArabic ? 'مثبت' : 'Pinned',
                              style: TextStyle(
                                fontFamily: AppTextStyle.fontFamily,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppTheme.darkSkyBlue : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_isFavorite)
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFFF59E0B).withValues(alpha: 0.18)
                              : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, size: 12, color: Color(0xFFF59E0B)),
                            const SizedBox(width: 4),
                            Text(
                              context.isArabic ? 'مفضلة' : 'Favorite',
                              style: const TextStyle(
                                fontFamily: AppTextStyle.fontFamily,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFD97706),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_isLocked)
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTheme.darkSkyBlue.withValues(alpha: 0.16)
                              : AppColors.primaryFixed.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: (isDark ? AppTheme.darkSkyBlue : AppColors.primary)
                                .withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock_rounded,
                              size: 11,
                              color: isDark ? AppTheme.darkSkyBlue : AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              context.l10n.locked,
                              style: TextStyle(
                                fontFamily: AppTextStyle.fontFamily,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppTheme.darkSkyBlue : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_attachLocation)
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF0C4A6E).withValues(alpha: 0.6)
                              : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: (isDark ? AppTheme.darkSkyBlue : AppColors.primary)
                                .withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 11,
                              color: isDark ? AppTheme.darkSkyBlue : AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              context.l10n.location,
                              style: TextStyle(
                                fontFamily: AppTextStyle.fontFamily,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppTheme.darkSkyBlue : AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            InkWell(
                              onTap: () => _handleLocationToggle(false),
                              child: Icon(
                                Icons.close_rounded,
                                size: 12,
                                color: isDark ? AppTheme.darkSkyBlue : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_reminderAt != null)
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _reminderAt!.isBefore(DateTime.now())
                              ? (isDark
                                  ? const Color(0xFF7F1D1D).withValues(alpha: 0.45)
                                  : const Color(0xFFFEF2F2))
                              : (isDark
                                  ? const Color(0xFF0C4A6E).withValues(alpha: 0.5)
                                  : AppColors.skyBlueBackground),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _reminderAt!.isBefore(DateTime.now())
                                ? (isDark
                                    ? const Color(0xFFEF4444).withValues(alpha: 0.4)
                                    : const Color(0xFFFCA5A5))
                                : (isDark
                                    ? AppTheme.darkSkyBlue.withValues(alpha: 0.35)
                                    : AppColors.skyBlue.withValues(alpha: 0.3)),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _reminderAt!.isBefore(DateTime.now())
                                  ? Icons.alarm_off_rounded
                                  : Icons.alarm_rounded,
                              size: 11,
                              color: _reminderAt!.isBefore(DateTime.now())
                                  ? AppColors.destructive
                                  : (isDark ? AppTheme.darkSkyBlue : AppColors.skyBlue),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: _pickReminderDateTime,
                              child: Text(
                                context.formatReminder(_reminderAt!),
                                style: TextStyle(
                                  fontFamily: AppTextStyle.fontFamily,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _reminderAt!.isBefore(DateTime.now())
                                      ? AppColors.destructive
                                      : (isDark ? AppTheme.darkSkyBlue : AppColors.skyBlue),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _reminderAt = null;
                                });
                              },
                              child: Icon(
                                Icons.close_rounded,
                                size: 12,
                                color: _reminderAt!.isBefore(DateTime.now())
                                    ? AppColors.destructive
                                    : (isDark ? AppTheme.darkSkyBlue : AppColors.skyBlue),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 10),

                // Tags Selector
                TagsSelector(
                  tags: _tags,
                  noteTitle: _titleController.text,
                  noteContent: _bodyController.text,
                  onChanged: (newTags) {
                    setState(() {
                      _tags = newTags;
                    });
                  },
                ),

                const SizedBox(height: 12),

                // Modern Glass Note Type Switcher (Text Note vs Tasks Checklist)
                Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: context.glassSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: context.glassBorder, width: 1),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _noteType = NoteType.text;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            decoration: BoxDecoration(
                              color: _noteType == NoteType.text
                                  ? (isDark ? const Color(0xFF1E293B) : Colors.white)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: _noteType == NoteType.text
                                  ? Border.all(
                                      color: isDark
                                          ? const Color(0xFF334155)
                                          : AppColors.borderSubtle,
                                      width: 0.8,
                                    )
                                  : null,
                              boxShadow: (_noteType == NoteType.text)
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: isDark ? 0.35 : 0.06,
                                        ),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.edit_note_rounded,
                                    size: 16,
                                    color: _noteType == NoteType.text
                                        ? AppColors.primary
                                        : context.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    context.l10n.textNote,
                                    style: TextStyle(
                                      fontFamily: AppTextStyle.fontFamily,
                                      fontSize: 12,
                                      fontWeight: _noteType == NoteType.text
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: _noteType == NoteType.text
                                          ? AppColors.primary
                                          : context.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _noteType = NoteType.checklist;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            decoration: BoxDecoration(
                              color: _noteType == NoteType.checklist
                                  ? (isDark ? const Color(0xFF1E293B) : Colors.white)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: _noteType == NoteType.checklist
                                  ? Border.all(
                                      color: isDark
                                          ? const Color(0xFF334155)
                                          : AppColors.borderSubtle,
                                      width: 0.8,
                                    )
                                  : null,
                              boxShadow: (_noteType == NoteType.checklist)
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: isDark ? 0.35 : 0.06,
                                        ),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.checklist_rounded,
                                    size: 16,
                                    color: _noteType == NoteType.checklist
                                        ? AppColors.primary
                                        : context.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    context.l10n.checklist,
                                    style: TextStyle(
                                      fontFamily: AppTextStyle.fontFamily,
                                      fontSize: 12,
                                      fontWeight: _noteType == NoteType.checklist
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: _noteType == NoteType.checklist
                                          ? AppColors.primary
                                          : context.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Voice Note Player if recorded or exists
                if (_audioPath != null) ...[
                  VoiceNotePlayerWidget(
                    audioPath: _audioPath!,
                    isEditable: true,
                    onDelete: () {
                      setState(() {
                        _audioPath = null;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                ],

                // Editor Canvas (Text Body OR Subtasks Checklist)
                if (_noteType == NoteType.text) ...[
                  NoteTextField(
                    controller: _bodyController,
                    text: context.l10n.noteBodyHint,
                    maxLines: null,
                    minLines: 8,
                    maxLength: Validators.maxBodyLength,
                    textInputAction: TextInputAction.newline,
                    style: AppTextStyle.bodyLarge.copyWith(
                      color: context.textPrimary,
                    ),
                    hintStyle: AppTextStyle.bodyLarge.copyWith(
                      color: context.textMuted,
                    ),
                    validator: (val) => Validators.validateBody(
                      val,
                      isChecklist: false,
                      hasAudio: _audioPath != null && _audioPath!.isNotEmpty,
                      isArabic: context.isArabic,
                    ),
                  ),
                ] else ...[
                  SubtasksEditor(
                    subtasks: _subtasks,
                    onChanged: (updated) {
                      setState(() {
                        _subtasks = updated;
                      });
                    },
                  ),
                ],

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),

      // Unified Modern Glassmorphic Accessory Bottom Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.35)
                  : const Color(0xFF0F172A).withValues(alpha: 0.05),
              offset: const Offset(0, -2),
              blurRadius: 12,
            ),
          ],
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: EdgeInsets.fromLTRB(
                14,
                8,
                14,
                viewInsetsBottom > 0
                    ? 8
                    : (paddingBottom > 0 ? paddingBottom + 4 : 12),
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F172A).withValues(alpha: 0.85)
                    : Colors.white.withValues(alpha: 0.88),
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? const Color(0xFF334155).withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.85),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Voice Recording Live Status Banner
                  if (_isRecordingAudio)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF450A0A).withValues(alpha: 0.7)
                            : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.destructive.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: AppColors.destructive,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatTimerSeconds(_recordDurationSeconds),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.destructive,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              context.isArabic
                                  ? 'جارٍ تسجيل الصوت...'
                                  : 'Recording audio note...',
                              style: TextStyle(
                                fontFamily: AppTextStyle.fontFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: context.textPrimary,
                              ),
                            ),
                          ),
                          // Discard / Cancel button
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            color: context.textSecondary,
                            tooltip: context.isArabic ? 'إلغاء' : 'Cancel',
                            visualDensity: VisualDensity.compact,
                            onPressed: _cancelAudioRecording,
                          ),
                          const SizedBox(width: 4),
                          // Stop & Save button
                          InkWell(
                            onTap: _stopAudioRecording,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.destructive,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    context.isArabic ? 'حفظ' : 'Done',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Accessory Bar Row
                  Row(
                    children: [
                      // OCR Scanner Tool Icon
                      _buildToolbarIconButton(
                        tooltip: context.isArabic
                            ? 'مسح ضوئي (صورة إلى ملاحظة)'
                            : 'OCR Scan (Photo → Note)',
                        isLoading: _isScanningOcr,
                        icon: Icons.document_scanner_outlined,
                        color: context.iconColor,
                        onPressed: _isScanningOcr ? null : _handleOcrScan,
                      ),
                      const SizedBox(width: 4),

                      // Voice Note Record Tool Icon
                      _buildToolbarIconButton(
                        tooltip: _isRecordingAudio
                            ? (context.isArabic ? 'إيقاف وحفظ التسجيل' : 'Stop Recording')
                            : (context.isArabic ? 'تسجيل ملاحظة صوتية' : 'Record Voice Note'),
                        icon: _isRecordingAudio
                            ? Icons.stop_circle_rounded
                            : (_audioPath != null ? Icons.mic_rounded : Icons.mic_none_rounded),
                        color: _isRecordingAudio
                            ? AppColors.destructive
                            : (_audioPath != null ? context.accentColor : context.iconColor),
                        backgroundColor: _isRecordingAudio
                            ? (isDark
                                ? const Color(0xFF7F1D1D).withValues(alpha: 0.5)
                                : const Color(0xFFFEE2E2))
                            : (_audioPath != null
                                ? (isDark
                                    ? const Color(0xFF0C4A6E).withValues(alpha: 0.4)
                                    : AppColors.skyBlueBackground)
                                : null),
                        onPressed: _toggleAudioRecording,
                      ),
                      const SizedBox(width: 4),

                      // Location Attachment Tool Icon
                      _buildToolbarIconButton(
                        tooltip: _attachLocation
                            ? (context.isArabic ? 'الموقع مرفق (اضغط للإلغاء)' : 'Location attached (Tap to detach)')
                            : (context.isArabic ? 'إرفاق الموقع الحالي' : 'Attach current location'),
                        icon: _attachLocation ? Icons.location_on_rounded : Icons.location_on_outlined,
                        color: _attachLocation ? context.accentColor : context.iconColor,
                        backgroundColor: _attachLocation
                            ? (isDark
                                ? const Color(0xFF0C4A6E).withValues(alpha: 0.5)
                                : const Color(0xFFEFF6FF))
                            : null,
                        onPressed: () => _handleLocationToggle(!_attachLocation),
                      ),
                      const SizedBox(width: 4),

                      // Reminder Tool Icon
                      _buildToolbarIconButton(
                        tooltip: _reminderAt != null
                            ? (context.isArabic
                                ? 'تذكير: ${context.formatReminder(_reminderAt!)} (اضغط للتعديل)'
                                : 'Reminder: ${context.formatReminder(_reminderAt!)} (Tap to edit)')
                            : (context.isArabic ? 'ضبط تذكير' : 'Set Reminder'),
                        icon: _reminderAt != null
                            ? Icons.alarm_rounded
                            : Icons.alarm_add_rounded,
                        color: _reminderAt != null ? context.accentColor : context.iconColor,
                        backgroundColor: _reminderAt != null
                            ? (isDark
                                ? const Color(0xFF0C4A6E).withValues(alpha: 0.5)
                                : AppColors.skyBlueBackground)
                            : null,
                        onPressed: _pickReminderDateTime,
                      ),
                      const SizedBox(width: 4),

                      // AI Assistant Tool Icon
                      _buildToolbarIconButton(
                        tooltip: context.isArabic ? 'المساعد الذكي Gemini' : 'Gemini AI Assistant',
                        icon: Icons.auto_awesome_rounded,
                        color: isDark ? AppTheme.darkSkyBlue : AppColors.skyBlue,
                        backgroundColor: isDark
                            ? const Color(0xFF0C4A6E).withValues(alpha: 0.35)
                            : AppColors.skyBlueBackground,
                        onPressed: _showAiAssistantMenu,
                      ),

                      const Spacer(),

                      // Compact Modern Save/Update Pill Button
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: context.accentColor,
                          foregroundColor: isDark ? AppTheme.darkCanvas : Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _isSaving ? null : _save,
                        icon: _isSaving
                            ? SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: isDark ? AppTheme.darkCanvas : Colors.white,
                                ),
                              )
                            : Icon(
                                isEdit ? Icons.check_rounded : Icons.save_rounded,
                                size: 16,
                              ),
                        label: Text(
                          context.l10n.save,
                          style: const TextStyle(
                            fontFamily: AppTextStyle.fontFamily,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
