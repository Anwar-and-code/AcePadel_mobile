import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../../core/design_system/design_system.dart';
import '../../gamification/gamification.dart';
import '../../product_tour/product_tour.dart';
import '../models/models.dart';
import '../providers/reservation_provider.dart';

class ReservationScreenV2 extends StatefulWidget {
  const ReservationScreenV2({
    super.key,
    this.tourDateSelectorKey,
    this.tourCourtSelectorKey,
  });

  final GlobalKey? tourDateSelectorKey;
  final GlobalKey? tourCourtSelectorKey;

  @override
  State<ReservationScreenV2> createState() => _ReservationScreenV2State();
}

class _ReservationScreenV2State extends State<ReservationScreenV2> {
  int _currentTab = 0;
  bool _isDateExpanded = true;
  bool _isSlotExpanded = true;
  bool _isCourtExpanded = true;

  late ReservationProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = ReservationProvider();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _provider.loadTerrains();
    await _provider.loadUserReservations();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  List<DateTime> _getWeekDates() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return List.generate(7, (i) => today.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundPrimary,
          elevation: 0,
          title: Text('Réservation', style: AppTypography.titleLarge),
          centerTitle: true,
        ),
        body: Column(
          children: [
            _buildTabSelector(),
            Expanded(
              child: _currentTab == 0 ? _buildBookingTab() : _buildHistoryTab(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Consumer<ReservationProvider>(
      builder: (context, provider, _) {
        final upcomingCount = provider.upcomingReservations.length;
        return Container(
          margin: AppSpacing.screenPaddingHorizontalOnly,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.surfaceSubtle,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.brandPrimary, width: 1),
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                alignment: _currentTab == 0 ? Alignment.centerLeft : Alignment.centerRight,
                duration: AppAnimations.durationNormal,
                curve: Curves.easeInOutCubic,
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.brandPrimary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.brandPrimary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (_currentTab != 0) {
                          setState(() => _currentTab = 0);
                          HapticFeedback.selectionClick();
                        }
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: AppAnimations.durationNormal,
                          style: AppTypography.labelMedium.copyWith(
                            color: _currentTab == 0 ? AppColors.white : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                          child: const Text('Réserver'),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (_currentTab != 1) {
                          setState(() => _currentTab = 1);
                          HapticFeedback.selectionClick();
                        }
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedDefaultTextStyle(
                              duration: AppAnimations.durationNormal,
                              style: AppTypography.labelMedium.copyWith(
                                color: _currentTab == 1 ? AppColors.white : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                              child: const Text('Historique'),
                            ),
                            if (upcomingCount > 0) ...[
                              const SizedBox(width: 8),
                              AnimatedContainer(
                                duration: AppAnimations.durationNormal,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _currentTab == 1 ? AppColors.white : AppColors.brandSecondary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  upcomingCount.toString(),
                                  style: AppTypography.caption.copyWith(
                                    color: _currentTab == 1 ? AppColors.brandPrimary : AppColors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBookingTab() {
    return Consumer<ReservationProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSpacing.vGapLg,
              
              // Step 1: Date
              Padding(
                padding: AppSpacing.screenPaddingHorizontalOnly,
                child: GestureDetector(
                  onTap: () => setState(() => _isDateExpanded = true),
                  child: _buildStepHeader(
                    step: 1,
                    title: 'Choisir une date',
                    isCompleted: provider.selectedDate != null,
                    showEditAction: !_isDateExpanded && provider.selectedDate != null,
                  ),
                ),
              ),
              AppSpacing.vGapMd,
              _wrapWithShowcase(
                key: widget.tourDateSelectorKey,
                step: TourSteps.dateSelector,
                child: AnimatedCrossFade(
                  firstChild: _buildDateSelector(provider),
                  secondChild: provider.selectedDate != null
                      ? _buildSelectedDateSummary(provider.selectedDate!)
                      : const SizedBox.shrink(),
                  crossFadeState: _isDateExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                  duration: AppAnimations.durationNormal,
                ),
              ),

              // Step 2: Créneau (après date)
              if (provider.selectedDate != null) ...[
                AppSpacing.vGapXl,
                Padding(
                  padding: AppSpacing.screenPaddingHorizontalOnly,
                  child: GestureDetector(
                    onTap: () => setState(() => _isSlotExpanded = true),
                    child: _buildStepHeader(
                      step: 2,
                      title: 'Choisir un créneau',
                      isCompleted: provider.selectedSlot != null,
                      showEditAction: !_isSlotExpanded && provider.selectedSlot != null,
                    ),
                  ),
                ),
                AppSpacing.vGapMd,
                AnimatedCrossFade(
                  firstChild: _buildTimeSlotSelector(provider),
                  secondChild: provider.selectedSlot != null
                      ? _buildSelectedSlotSummary(provider.selectedSlot!)
                      : const SizedBox.shrink(),
                  crossFadeState: _isSlotExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                  duration: AppAnimations.durationNormal,
                ),
              ],

              // Step 3: Terrain (après créneau)
              if (provider.selectedSlot != null) ...[
                AppSpacing.vGapXl,
                Padding(
                  padding: AppSpacing.screenPaddingHorizontalOnly,
                  child: GestureDetector(
                    onTap: () => setState(() => _isCourtExpanded = true),
                    child: _buildStepHeader(
                      step: 3,
                      title: 'Choisir un terrain',
                      isCompleted: provider.selectedTerrain != null,
                      showEditAction: !_isCourtExpanded && provider.selectedTerrain != null,
                    ),
                  ),
                ),
                AppSpacing.vGapMd,
                _wrapWithShowcase(
                  key: widget.tourCourtSelectorKey,
                  step: TourSteps.courtSelector,
                  child: AnimatedCrossFade(
                    firstChild: _buildCourtSelector(provider),
                    secondChild: provider.selectedTerrain != null
                        ? _buildSelectedCourtSummary(provider.selectedTerrain!)
                        : const SizedBox.shrink(),
                    crossFadeState: _isCourtExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                    duration: AppAnimations.durationNormal,
                  ),
                ),
              ],

              // Bouton réserver
              if (provider.canBook) ...[
                AppSpacing.vGapXxl,
                Padding(
                  padding: AppSpacing.screenPaddingHorizontalOnly,
                  child: AppButton(
                    label: 'Réserver maintenant',
                    onPressed: () => _onBookPressed(provider),
                    variant: AppButtonVariant.primary,
                    size: AppButtonSize.large,
                    isFullWidth: true,
                  ),
                ),
              ],
              AppSpacing.vGapXxl,
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepHeader({
    required int step,
    required String title,
    required bool isCompleted,
    bool showEditAction = false,
  }) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isCompleted ? AppColors.success : AppColors.brandPrimary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: AppColors.white, size: 16)
                : Text(step.toString(), style: AppTypography.labelMedium.copyWith(color: AppColors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        AppSpacing.hGapSm,
        Expanded(child: Text(title, style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold))),
        if (showEditAction)
          Text('Modifier', style: AppTypography.labelSmall.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildDateSelector(ReservationProvider provider) {
    final dates = _getWeekDates();
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.screenPaddingHorizontalOnly,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = provider.selectedDate != null &&
              provider.selectedDate!.day == date.day &&
              provider.selectedDate!.month == date.month &&
              provider.selectedDate!.year == date.year;
          return Padding(
            padding: EdgeInsets.only(right: AppSpacing.sm),
            child: _DateCard(
              date: date,
              isSelected: isSelected,
              onTap: () {
                provider.selectDate(date);
                setState(() {
                  _isDateExpanded = false;
                  _isSlotExpanded = true;
                  _isCourtExpanded = true;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedDateSummary(DateTime date) {
    final dayNames = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    final monthNames = ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'];
    final dateStr = '${dayNames[date.weekday - 1]} ${date.day} ${monthNames[date.month - 1]}';
    return _buildSummaryCard(icon: Icons.calendar_month, text: dateStr, onTap: () => setState(() => _isDateExpanded = true));
  }

  Widget _buildTimeSlotSelector(ReservationProvider provider) {
    if (provider.slotsState == ReservationLoadingState.loading) {
      return const Padding(padding: AppSpacing.screenPaddingHorizontalOnly, child: Center(child: CircularProgressIndicator()));
    }
    final uniqueSlots = <int, AvailableSlot>{};
    for (final slot in provider.availableSlots) {
      if (!uniqueSlots.containsKey(slot.timeSlotId)) {
        uniqueSlots[slot.timeSlotId] = slot;
      }
    }
    var slots = uniqueSlots.values.toList()..sort((a, b) => a.startTime.compareTo(b.startTime));
    
    // Filtrer les créneaux passés si c'est aujourd'hui
    if (provider.selectedDate != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final selectedDate = DateTime(provider.selectedDate!.year, provider.selectedDate!.month, provider.selectedDate!.day);
      
      if (selectedDate.isAtSameMomentAs(today)) {
        final currentHour = now.hour;
        final currentMinute = now.minute;
        slots = slots.where((slot) {
          final timeParts = slot.startTime.split(':');
          final slotHour = int.tryParse(timeParts[0]) ?? 0;
          final slotMinute = int.tryParse(timeParts[1]) ?? 0;
          return slotHour > currentHour || (slotHour == currentHour && slotMinute > currentMinute);
        }).toList();
      }
    }
    if (slots.isEmpty) {
      return _buildEmptyState('Aucun créneau disponible', 'Essayez une autre date');
    }
    return Container(
      margin: AppSpacing.screenPaddingHorizontalOnly,
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        color: AppColors.surfaceDefault,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: ClipRRect(
        borderRadius: AppRadius.borderRadiusMd,
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: slots.length,
          separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.borderDefault),
          itemBuilder: (context, index) {
            final slot = slots[index];
            final isSelected = provider.selectedSlot?.timeSlotId == slot.timeSlotId;
            final availableTerrains = provider.availableSlots.where((s) => s.timeSlotId == slot.timeSlotId && !s.isReserved).length;
            return _TimeSlotRow(
              slot: slot,
              isSelected: isSelected,
              availableTerrains: availableTerrains,
              onTap: availableTerrains > 0 ? () {
                provider.selectSlotByTimeSlotId(slot.timeSlotId);
                setState(() {
                  _isSlotExpanded = false;
                  _isCourtExpanded = true;
                });
              } : null,
            );
          },
        ),
      ),
    );
  }

  Widget _buildSelectedSlotSummary(AvailableSlot slot) {
    return _buildSummaryCard(icon: Icons.access_time, text: slot.timeRange, onTap: () => setState(() => _isSlotExpanded = true));
  }

  Widget _buildCourtSelector(ReservationProvider provider) {
    if (provider.selectedSlot == null) return const SizedBox.shrink();
    final terrainsForSlot = provider.availableSlots
        .where((s) => s.timeSlotId == provider.selectedSlot!.timeSlotId)
        .toList()
      ..sort((a, b) => a.terrainCode.compareTo(b.terrainCode));
    if (terrainsForSlot.isEmpty) {
      return _buildEmptyState('Aucun terrain disponible', 'Essayez un autre créneau');
    }
    
    final firstRow = terrainsForSlot.take(2).toList();
    final secondRow = terrainsForSlot.skip(2).take(2).toList();
    
    return Padding(
      padding: AppSpacing.screenPaddingHorizontalOnly,
      child: Column(
        children: [
          Row(
            children: firstRow.map((slot) {
              final terrain = provider.terrains.firstWhere((t) => t.id == slot.terrainId, orElse: () => Terrain(id: slot.terrainId, code: slot.terrainCode, isActive: true, createdAt: DateTime.now()));
              final isSelected = provider.selectedTerrain?.id == terrain.id;
              final isAvailable = !slot.isReserved;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _CourtCard(
                    terrain: terrain,
                    isSelected: isSelected,
                    isAvailable: isAvailable,
                    onTap: isAvailable ? () {
                      provider.selectTerrain(terrain);
                      setState(() => _isCourtExpanded = false);
                    } : null,
                  ),
                ),
              );
            }).toList(),
          ),
          if (secondRow.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: secondRow.map((slot) {
                final terrain = provider.terrains.firstWhere((t) => t.id == slot.terrainId, orElse: () => Terrain(id: slot.terrainId, code: slot.terrainCode, isActive: true, createdAt: DateTime.now()));
                final isSelected = provider.selectedTerrain?.id == terrain.id;
                final isAvailable = !slot.isReserved;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _CourtCard(
                      terrain: terrain,
                      isSelected: isSelected,
                      isAvailable: isAvailable,
                      onTap: isAvailable ? () {
                        provider.selectTerrain(terrain);
                        setState(() => _isCourtExpanded = false);
                      } : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectedCourtSummary(Terrain terrain) {
    return _buildSummaryCard(icon: Icons.sports_tennis, text: 'Terrain ${terrain.code}', onTap: () => setState(() => _isCourtExpanded = true));
  }

  Widget _buildSummaryCard({required IconData icon, required String text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: AppSpacing.screenPaddingHorizontalOnly,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.brandPrimary.withValues(alpha: 0.05),
          borderRadius: AppRadius.borderRadiusMd,
          border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.brandPrimary, size: 20),
            AppSpacing.hGapMd,
            Text(text, style: AppTypography.titleSmall.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
            const Spacer(),
            Icon(Icons.edit_outlined, color: AppColors.brandPrimary, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Container(
      margin: AppSpacing.screenPaddingHorizontalOnly,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(color: AppColors.surfaceSubtle, borderRadius: AppRadius.borderRadiusMd),
      child: Column(
        children: [
          Icon(Icons.event_busy, color: AppColors.iconSecondary, size: 48),
          AppSpacing.vGapMd,
          Text(title, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
          AppSpacing.vGapSm,
          Text(subtitle, style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Consumer<ReservationProvider>(
      builder: (context, provider, _) {
        if (provider.reservationsState == ReservationLoadingState.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        final upcomingReservations = provider.upcomingReservations;
        final pastReservations = provider.pastReservations;
        return RefreshIndicator(
          onRefresh: () => provider.loadUserReservations(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSpacing.vGapLg,
                if (upcomingReservations.isNotEmpty) ...[
                  Padding(
                    padding: AppSpacing.screenPaddingHorizontalOnly,
                    child: Row(
                      children: [
                        Text('À venir', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.brandSecondary, borderRadius: BorderRadius.circular(10)),
                          child: Text('${upcomingReservations.length}', style: AppTypography.caption.copyWith(color: AppColors.white, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.vGapMd,
                  ...upcomingReservations.map((reservation) => Padding(
                    padding: AppSpacing.screenPaddingHorizontalOnly,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _ReservationCard(
                        reservation: reservation,
                        onTap: () => _showReservationDetails(reservation),
                      ),
                    ),
                  )),
                  AppSpacing.vGapLg,
                ] else ...[
                  Padding(
                    padding: AppSpacing.screenPaddingHorizontalOnly,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(color: AppColors.surfaceSubtle, borderRadius: AppRadius.borderRadiusMd),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: AppColors.iconSecondary, size: 32),
                          AppSpacing.hGapMd,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Aucune réservation à venir', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w600)),
                                AppSpacing.vGapXxs,
                                Text('Réservez un terrain pour votre prochaine partie !', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AppSpacing.vGapLg,
                ],
                Padding(
                  padding: AppSpacing.screenPaddingHorizontalOnly,
                  child: Text('Historique', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                ),
                AppSpacing.vGapMd,
                if (pastReservations.isEmpty)
                  Padding(
                    padding: AppSpacing.screenPaddingHorizontalOnly,
                    child: Text('Aucune réservation passée', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
                  )
                else
                  ...pastReservations.map((reservation) => Padding(
                    padding: AppSpacing.screenPaddingHorizontalOnly,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _ReservationCard(
                        reservation: reservation,
                        onTap: () => _showReservationDetails(reservation),
                      ),
                    ),
                  )),
                AppSpacing.vGapXxl,
              ],
            ),
          ),
        );
      },
    );
  }

  void _onBookPressed(ReservationProvider provider) {
    if (!provider.canBook) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BookingConfirmationSheet(
        terrain: provider.selectedTerrain!,
        slot: provider.selectedSlot!,
        date: provider.selectedDate!,
        onConfirm: () async {
          Navigator.pop(context);
          final reservation = await provider.createReservation();
          if (reservation != null) {
            final slotHour = int.tryParse(provider.selectedSlot?.startTime.split(':').first ?? '12') ?? 12;
            GamificationServiceV2.instance.onReservationMade(hour: slotHour);
            await provider.loadUserReservations();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Réservation confirmée ! Référence: ${reservation.reference}'), backgroundColor: AppColors.success),
              );
              setState(() => _currentTab = 1);
            }
          } else if (provider.errorMessage != null && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(provider.errorMessage!), backgroundColor: AppColors.error),
            );
          }
        },
      ),
    );
  }

  void _showReservationDetails(Reservation reservation) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReservationDetailsSheet(
        reservation: reservation,
        onCancel: reservation.canCancel ? () async {
          Navigator.pop(context);
          final success = await _provider.cancelReservation(reservation.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(success ? 'Réservation annulée' : 'Erreur lors de l\'annulation'),
                backgroundColor: success ? AppColors.success : AppColors.error,
              ),
            );
          }
        } : null,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final monthNames = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
    return '${date.day} ${monthNames[date.month - 1]} ${date.year}';
  }

  Widget _wrapWithShowcase({required GlobalKey? key, required TourStep step, required Widget child}) {
    if (key == null) return child;
    return Showcase(
      key: key,
      title: step.title,
      description: step.description,
      tooltipBackgroundColor: AppColors.cardBackground,
      textColor: AppColors.textPrimary,
      descTextStyle: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
      titleTextStyle: AppTypography.titleSmall.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
      tooltipPadding: const EdgeInsets.all(AppSpacing.lg),
      targetBorderRadius: AppRadius.borderRadiusMd,
      targetPadding: const EdgeInsets.all(AppSpacing.sm),
      child: child,
    );
  }
}

// ============================================================================
// WIDGETS PRIVÉS
// ============================================================================

class _DateCard extends StatelessWidget {
  const _DateCard({required this.date, required this.isSelected, this.onTap});
  final DateTime date;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dayNames = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    final monthNames = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppAnimations.durationNormal,
        width: 85,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandPrimary : AppColors.surfaceSubtle,
          borderRadius: AppRadius.borderRadiusMd,
          border: isSelected ? null : Border.all(color: AppColors.brandPrimary),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(dayNames[date.weekday - 1], style: AppTypography.labelMedium.copyWith(color: isSelected ? AppColors.white : AppColors.textSecondary, fontWeight: FontWeight.bold)),
            AppSpacing.vGapXxs,
            Text(date.day.toString(), style: AppTypography.headlineSmall.copyWith(color: isSelected ? AppColors.white : AppColors.textPrimary, fontWeight: FontWeight.bold)),
            AppSpacing.vGapXxs,
            Text(monthNames[date.month - 1], style: AppTypography.labelMedium.copyWith(color: isSelected ? AppColors.white : AppColors.textSecondary, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _TimeSlotRow extends StatelessWidget {
  const _TimeSlotRow({required this.slot, required this.isSelected, required this.availableTerrains, this.onTap});
  final AvailableSlot slot;
  final bool isSelected;
  final int availableTerrains;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDisabled = availableTerrains == 0;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppAnimations.durationFast,
        color: isSelected ? AppColors.brandPrimary.withValues(alpha: 0.08) : isDisabled ? AppColors.neutral50 : Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(slot.timeRange, style: AppTypography.bodyMedium.copyWith(color: isDisabled ? AppColors.textDisabled : AppColors.textPrimary, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
                    if (isDisabled) ...[
                      AppSpacing.hGapSm,
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text('Complet', style: AppTypography.caption.copyWith(color: AppColors.error, fontSize: 10)),
                      ),
                    ] else ...[
                      AppSpacing.hGapSm,
                      Text('$availableTerrains terrains', style: AppTypography.caption.copyWith(color: AppColors.success)),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: isDisabled ? AppColors.neutral300 : isSelected ? AppColors.brandPrimary : AppColors.neutral900,
                  borderRadius: AppRadius.borderRadiusSm,
                ),
                child: Text(slot.formattedPrice, style: AppTypography.labelMedium.copyWith(color: AppColors.white, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourtCard extends StatelessWidget {
  const _CourtCard({required this.terrain, required this.isSelected, required this.isAvailable, this.onTap});
  final Terrain terrain;
  final bool isSelected;
  final bool isAvailable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppAnimations.durationNormal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          color: !isAvailable ? AppColors.neutral100 : isSelected ? AppColors.brandPrimary : AppColors.surfaceDefault,
          borderRadius: AppRadius.borderRadiusMd,
          border: isSelected || !isAvailable ? null : Border.all(color: AppColors.borderDefault),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(terrain.code, style: AppTypography.displaySmall.copyWith(color: !isAvailable ? AppColors.neutral400 : isSelected ? AppColors.white : AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 36), textAlign: TextAlign.center),
            AppSpacing.vGapXs,
            Text(!isAvailable ? 'Réservé' : 'Disponible', style: AppTypography.caption.copyWith(color: !isAvailable ? AppColors.error : isSelected ? AppColors.white.withValues(alpha: 0.8) : AppColors.success, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({required this.reservation, this.onTap});
  final Reservation reservation;
  final VoidCallback? onTap;

  String _formatDate(DateTime date) {
    final monthNames = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
    return '${date.day} ${monthNames[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadius.cardBorderRadius,
        border: Border.all(color: AppColors.reservationCardBorder),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.cardBorderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.cardBorderRadius,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
                decoration: BoxDecoration(
                  color: reservation.status.color.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(AppRadius.card - 1), bottomLeft: Radius.circular(AppRadius.card - 1)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(reservation.formattedStartTime, style: AppTypography.titleMedium.copyWith(color: AppColors.white, fontWeight: FontWeight.bold)),
                    Text(reservation.formattedEndTime, style: AppTypography.bodySmall.copyWith(color: AppColors.white.withValues(alpha: 0.8))),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(_formatDate(reservation.reservationDate), style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold))),
                          AppBadge(label: reservation.status.label, variant: reservation.status.badgeVariant),
                        ],
                      ),
                      AppSpacing.vGapXxs,
                      Text('Terrain ${reservation.terrainCode ?? '--'}', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: Icon(AppIcons.chevronRight, color: AppColors.iconTertiary, size: AppIcons.sizeMd),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingConfirmationSheet extends StatelessWidget {
  const _BookingConfirmationSheet({required this.terrain, required this.slot, required this.date, required this.onConfirm});
  final Terrain terrain;
  final AvailableSlot slot;
  final DateTime date;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final dayNames = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    final monthNames = ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'];
    final dateStr = '${dayNames[date.weekday - 1]} ${date.day} ${monthNames[date.month - 1]} ${date.year}';
    
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceDefault.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(top: BorderSide(color: AppColors.white.withValues(alpha: 0.5), width: 1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.neutral300, borderRadius: BorderRadius.circular(2)))),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text('Récapitulatif', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.neutral200),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.calendar_month_outlined, 'Date', dateStr, AppColors.brandSecondary),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: AppColors.neutral200)),
                    _buildInfoRow(Icons.access_time_filled_outlined, 'Créneau', '${slot.startTime.substring(0, 5)} - ${slot.endTime.substring(0, 5)}', AppColors.brandPrimary),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: AppColors.neutral200)),
                    _buildInfoRow(Icons.sports_tennis_outlined, 'Terrain', 'Terrain ${terrain.code}', AppColors.success),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total à payer', style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                    Text(slot.formattedPrice, style: AppTypography.headlineMedium.copyWith(color: AppColors.brandPrimary, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Message d'avertissement
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'Veuillez noter que toute annulation de réservation doit être effectuée au moins 4 heures avant le créneau afin de permettre à d\'autres clients de profiter de cette opportunité. De plus, toute réservation non annulée sera facturée.\n\nMerci de votre compréhension et de votre coopération.',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.neutral300)),
                          backgroundColor: Colors.transparent,
                        ),
                        child: Text('Annuler', style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: AppColors.brandPrimary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
                        ),
                        child: ElevatedButton(
                          onPressed: onConfirm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Confirmer', style: AppTypography.labelLarge.copyWith(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, color: AppColors.white, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color iconColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(value, style: AppTypography.titleSmall.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}

class _ReservationDetailsSheet extends StatelessWidget {
  const _ReservationDetailsSheet({required this.reservation, this.onCancel});
  final Reservation reservation;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final dayNames = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    final monthNames = ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'];
    final date = reservation.reservationDate;
    final dateStr = '${dayNames[date.weekday - 1]} ${date.day} ${monthNames[date.month - 1]} ${date.year}';
    
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceDefault.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(top: BorderSide(color: AppColors.white.withValues(alpha: 0.5), width: 1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.neutral300, borderRadius: BorderRadius.circular(2)))),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Détails de la réservation', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
                    AppBadge(label: reservation.status.label, variant: reservation.status.badgeVariant),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.neutral200),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.confirmation_number_outlined, 'Référence', reservation.reference, AppColors.brandPrimary),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: AppColors.neutral200)),
                    _buildInfoRow(Icons.calendar_month_outlined, 'Date', dateStr, AppColors.brandSecondary),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: AppColors.neutral200)),
                    _buildInfoRow(Icons.access_time_filled_outlined, 'Créneau', '${reservation.formattedStartTime} - ${reservation.formattedEndTime}', AppColors.info),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: AppColors.neutral200)),
                    _buildInfoRow(Icons.sports_tennis_outlined, 'Terrain', 'Terrain ${reservation.terrainCode ?? '--'}', AppColors.success),
                    if (reservation.price != null) ...[
                      const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: AppColors.neutral200)),
                      _buildInfoRow(Icons.payments_outlined, 'Prix', '${reservation.price} FCFA', AppColors.warning),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: Row(
                  children: [
                    if (onCancel != null) ...[
                      Expanded(
                        child: TextButton(
                          onPressed: onCancel,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: AppColors.error.withValues(alpha: 0.5))),
                            backgroundColor: AppColors.error.withValues(alpha: 0.05),
                          ),
                          child: Text('Annuler la réservation', style: AppTypography.labelLarge.copyWith(color: AppColors.error, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text('Fermer', style: AppTypography.labelLarge.copyWith(color: AppColors.white, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color iconColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(value, style: AppTypography.titleSmall.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}
