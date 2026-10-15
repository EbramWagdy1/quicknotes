import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:quicknotes/core/localization/l10n_extension.dart';
import 'package:quicknotes/core/routing/app_routes.dart';
import 'package:quicknotes/core/services/location_service.dart';
import 'package:quicknotes/core/utils/app_colors.dart';
import 'package:quicknotes/core/utils/app_text_style.dart';
import 'package:quicknotes/features/home/model/note_model.dart';
import 'package:quicknotes/features/home/view/widgets/note_map_preview_card.dart';
import 'package:quicknotes/features/home/view_model/cubit/notes_cubit.dart';

class NotesMapView extends StatefulWidget {
  final LocationService? locationService;

  const NotesMapView({super.key, this.locationService});

  @override
  State<NotesMapView> createState() => _NotesMapViewState();
}

class _NotesMapViewState extends State<NotesMapView> {
  late final MapController _mapController;
  late final LocationService _locationService;

  Note? _selectedNote;
  bool _isLocatingUser = false;

  // Default coordinate (Cairo, Egypt center) if no notes or GPS
  static const LatLng _defaultCenter = LatLng(30.0444, 31.2357);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _locationService = widget.locationService ?? LocationService();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _onNoteTapped(Note note) {
    setState(() {
      _selectedNote = note;
    });

    if (note.latitude != null && note.longitude != null) {
      _mapController.move(
        LatLng(note.latitude!, note.longitude!),
        15.0,
      );
    }
  }

  Future<void> _centerOnUserLocation() {
    return _locateUser();
  }

  Future<void> _locateUser() async {
    setState(() {
      _isLocatingUser = true;
    });

    try {
      final position = await _locationService.getCurrentLocation();
      final userLatLng = LatLng(position.latitude, position.longitude);
      _mapController.move(userLatLng, 15.0);

      if (mounted) {
        final state = context.read<NotesCubit>().state;
        if (state is NotesLoaded) {
          final nearby = _locationService.getNearbyNotes(
            userLatitude: position.latitude,
            userLongitude: position.longitude,
            notes: state.notes,
            radiusInMeters: 500.0,
          );

          if (nearby.isNotEmpty && mounted) {
            final closest = nearby.first;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(
                      Icons.near_me_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        context.isArabic
                            ? 'ملاحظة قريبة: "${closest.note.title.isNotEmpty ? closest.note.title : 'بدون عنوان'}" (${closest.formattedDistance})'
                            : 'Nearby note: "${closest.note.title.isNotEmpty ? closest.note.title : 'Untitled'}" (${closest.formattedDistance})',
                        style: const TextStyle(
                          fontFamily: AppTextStyle.fontFamily,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.skyBlue,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: context.isArabic ? 'عرض' : 'View',
                  textColor: Colors.white,
                  onPressed: () => _onNoteTapped(closest.note),
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll('Exception: ', ''),
              style: const TextStyle(fontFamily: AppTextStyle.fontFamily),
            ),
            backgroundColor: AppColors.destructive,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLocatingUser = false;
        });
      }
    }
  }

  void _fitAllNotes(List<Note> notesWithLocation) {
    if (notesWithLocation.isEmpty) return;

    if (notesWithLocation.length == 1) {
      final single = notesWithLocation.first;
      _mapController.move(
        LatLng(single.latitude!, single.longitude!),
        15.0,
      );
      return;
    }

    final points = notesWithLocation
        .map((n) => LatLng(n.latitude!, n.longitude!))
        .toList();

    _mapController.fitCamera(
      CameraFit.coordinates(
        coordinates: points,
        padding: const EdgeInsets.all(50),
      ),
    );
  }

  void _showNotesListSheet(BuildContext context, List<Note> notesWithLocation) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.dragHandle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.place_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.isArabic
                          ? 'ملاحظات ذات موقع جغرافي (${notesWithLocation.length})'
                          : 'Notes with Location (${notesWithLocation.length})',
                      style: const TextStyle(
                        fontFamily: AppTextStyle.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate900,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.borderSubtle),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: notesWithLocation.length,
                  separatorBuilder: (_, _) => const Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: AppColors.borderSubtle,
                  ),
                  itemBuilder: (ctx, index) {
                    final note = notesWithLocation[index];
                    final isSelected = _selectedNote?.id == note.id;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: isSelected
                            ? AppColors.primary
                            : AppColors.skyBlueBackground,
                        child: Icon(
                          note.hasSubtasks
                              ? Icons.checklist_rounded
                              : Icons.note_alt_rounded,
                          size: 18,
                          color: isSelected ? Colors.white : AppColors.primary,
                        ),
                      ),
                      title: Text(
                        note.title.isEmpty
                            ? (context.isArabic ? 'ملاحظة بدون عنوان' : 'Untitled Note')
                            : note.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTextStyle.fontFamily,
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: AppColors.slate900,
                        ),
                      ),
                      subtitle: Text(
                        note.hasSubtasks
                            ? (context.isArabic
                                ? 'تم إنجاز ${note.completedSubtasksCount} من ${note.subtasks.length} مهمة'
                                : '${note.completedSubtasksCount}/${note.subtasks.length} tasks completed')
                            : (note.body.isNotEmpty
                                ? note.body
                                : (context.isArabic ? 'لا يوجد محتوى نصي' : 'No text content')),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AppTextStyle.fontFamily,
                          fontSize: 12,
                          color: AppColors.slate600,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.slate400,
                        size: 20,
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        _onNoteTapped(note);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: BlocBuilder<NotesCubit, NotesState>(
        builder: (context, state) {
          final allActiveNotes = state is NotesLoaded ? state.notes : <Note>[];
          final notesWithLocation =
              allActiveNotes.where((n) => n.hasLocation).toList();

          final initialCenter = notesWithLocation.isNotEmpty
              ? LatLng(
                  notesWithLocation.first.latitude!,
                  notesWithLocation.first.longitude!,
                )
              : _defaultCenter;

          return Stack(
            children: [
              // 1. OpenStreetMap Layer
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: initialCenter,
                  initialZoom: notesWithLocation.isNotEmpty ? 13.0 : 6.0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                  onTap: (_, _) {
                    if (_selectedNote != null) {
                      setState(() {
                        _selectedNote = null;
                      });
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.ebramwagdy.quicknotes',
                  ),
                  MarkerLayer(
                    markers: notesWithLocation.map((note) {
                      final isSelected = _selectedNote?.id == note.id;

                      return Marker(
                        point: LatLng(note.latitude!, note.longitude!),
                        width: isSelected ? 56 : 46,
                        height: isSelected ? 62 : 52,
                        child: GestureDetector(
                          onTap: () => _onNoteTapped(note),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutBack,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Outer Pin Shadow & Body
                                Icon(
                                  Icons.location_on_rounded,
                                  size: isSelected ? 56 : 46,
                                  color: isSelected
                                      ? AppColors.primaryActive
                                      : (note.isFavorite
                                          ? const Color(0xFFF59E0B)
                                          : AppColors.primary),
                                  shadows: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.25,
                                      ),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                // Inner Icon Indicator
                                PositionBarIcon(
                                  isSelected: isSelected,
                                  note: note,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              // 2. Top App Bar & Status Header
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      // Back Button
                      Material(
                        color: AppColors.cardWhite,
                        shape: const CircleBorder(),
                        elevation: 3,
                        shadowColor: Colors.black.withValues(alpha: 0.15),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: AppColors.slate800,
                          ),
                          tooltip: context.isArabic ? 'العودة للملاحظات' : 'Back to Notes',
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(AppRoutes.home);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Location count pill badge
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.cardWhite,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: AppColors.tier2Shadow,
                            border: Border.all(
                              color: AppColors.borderSubtle,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.map_rounded,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  context.isArabic
                                      ? '${notesWithLocation.length} ملاحظة على الخريطة'
                                      : '${notesWithLocation.length} ${notesWithLocation.length == 1 ? 'note on map' : 'notes on map'}',
                                  style: const TextStyle(
                                    fontFamily: AppTextStyle.fontFamily,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.slate900,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (notesWithLocation.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        // List sheet toggle button
                        Material(
                          color: AppColors.cardWhite,
                          shape: const CircleBorder(),
                          elevation: 3,
                          shadowColor: Colors.black.withValues(alpha: 0.15),
                          child: IconButton(
                            icon: const Icon(
                              Icons.format_list_bulleted_rounded,
                              color: AppColors.slate800,
                            ),
                            tooltip: context.isArabic
                                ? 'قائمة الملاحظات المحددة بالموقع'
                                : 'List of notes on map',
                            onPressed: () => _showNotesListSheet(
                              context,
                              notesWithLocation,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // 3. Floating Control Actions (GPS, Fit All, Zoom)
              Positioned(
                right: 16,
                bottom: _selectedNote != null ? 220 : 32,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Fit All Notes Button
                    if (notesWithLocation.isNotEmpty)
                      _buildFloatingAction(
                        icon: Icons.crop_free_rounded,
                        tooltip: context.isArabic ? 'إظهار جميع الملاحظات' : 'Fit all notes',
                        onPressed: () => _fitAllNotes(notesWithLocation),
                      ),

                    const SizedBox(height: 10),

                    // Locate My Position Button
                    _buildFloatingAction(
                      icon: _isLocatingUser
                          ? Icons.hourglass_top_rounded
                          : Icons.my_location_rounded,
                      tooltip: context.isArabic ? 'موقعي الحالي' : 'My current location',
                      isLoading: _isLocatingUser,
                      onPressed: _centerOnUserLocation,
                    ),

                    const SizedBox(height: 10),

                    // Zoom In
                    _buildFloatingAction(
                      icon: Icons.add_rounded,
                      tooltip: context.isArabic ? 'تكبير' : 'Zoom in',
                      onPressed: () {
                        _mapController.move(
                          _mapController.camera.center,
                          _mapController.camera.zoom + 1,
                        );
                      },
                    ),

                    const SizedBox(height: 8),

                    // Zoom Out
                    _buildFloatingAction(
                      icon: Icons.remove_rounded,
                      tooltip: context.isArabic ? 'تصغير' : 'Zoom out',
                      onPressed: () {
                        _mapController.move(
                          _mapController.camera.center,
                          _mapController.camera.zoom - 1,
                        );
                      },
                    ),
                  ],
                ),
              ),

              // 4. Empty State Banner (if no notes have coordinates)
              if (notesWithLocation.isEmpty)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 32,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppColors.tier3Shadow,
                      border: Border.all(
                        color: AppColors.borderSubtle,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_off_rounded,
                          size: 36,
                          color: AppColors.slate400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.isArabic
                              ? 'لا توجد ملاحظات ذات موقع جغرافي بعد'
                              : 'No Notes with Location Yet',
                          style: const TextStyle(
                            fontFamily: AppTextStyle.fontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.slate900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.isArabic
                              ? 'أنشئ أو عدّل ملاحظة مع تفعيل الموقع الجغرافي لتراها مثبتة هنا.'
                              : 'Create or edit a note with location enabled to see it pinned here.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: AppTextStyle.fontFamily,
                            fontSize: 13,
                            color: AppColors.slate600,
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.add_rounded, size: 20),
                            label: Text(
                              context.isArabic ? 'إنشاء ملاحظة' : 'Create Note',
                              style: const TextStyle(
                                fontFamily: AppTextStyle.fontFamily,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            onPressed: () {
                              context.push(AppRoutes.addNote);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // 5. Selected Note Bottom Preview Card
              if (_selectedNote != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 16,
                  child: NoteMapPreviewCard(
                    note: _selectedNote!,
                    onClose: () {
                      setState(() {
                        _selectedNote = null;
                      });
                    },
                    onCenterOnNote: () {
                      if (_selectedNote?.latitude != null &&
                          _selectedNote?.longitude != null) {
                        _mapController.move(
                          LatLng(
                            _selectedNote!.latitude!,
                            _selectedNote!.longitude!,
                          ),
                          15.0,
                        );
                      }
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFloatingAction({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return Material(
      color: AppColors.cardWhite,
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      child: IconButton(
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : Icon(icon, color: AppColors.slate800, size: 20),
        tooltip: tooltip,
        onPressed: isLoading ? null : onPressed,
      ),
    );
  }
}

class PositionBarIcon extends StatelessWidget {
  final bool isSelected;
  final Note note;

  const PositionBarIcon({
    super.key,
    required this.isSelected,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: isSelected ? 8 : 6,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(
          note.isPinned
              ? Icons.push_pin_rounded
              : (note.hasSubtasks
                  ? Icons.checklist_rounded
                  : Icons.edit_note_rounded),
          size: isSelected ? 16 : 13,
          color: isSelected ? AppColors.primaryActive : AppColors.primary,
        ),
      ),
    );
  }
}
