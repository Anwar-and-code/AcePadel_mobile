import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  int _currentTab = 0;
  DateTime? _selectedDate;
  String? _selectedCourt;
  String? _selectedSlot;

  final List<Booking> _bookingHistory = [
    Booking(
      reference: 'WP-X0125',
      courtName: 'A',
      date: DateTime.now().subtract(const Duration(days: 2)),
      startTime: '13:00',
      endTime: '14:00',
      price: 15000,
      status: BookingStatus.completed,
    ),
    Booking(
      reference: 'WP-X0124',
      courtName: 'B',
      date: DateTime.now().subtract(const Duration(days: 5)),
      startTime: '16:00',
      endTime: '17:30',
      price: 20000,
      status: BookingStatus.completed,
    ),
    Booking(
      reference: 'WP-X0123',
      courtName: 'A',
      date: DateTime.now().add(const Duration(days: 3)),
      startTime: '19:00',
      endTime: '20:30',
      price: 25000,
      status: BookingStatus.upcoming,
    ),
    Booking(
      reference: 'WP-X0122',
      courtName: 'D',
      date: DateTime.now().subtract(const Duration(days: 10)),
      startTime: '10:00',
      endTime: '11:00',
      price: 15000,
      status: BookingStatus.completed,
    ),
    Booking(
      reference: 'WP-X0121',
      courtName: 'C',
      date: DateTime.now().subtract(const Duration(days: 15)),
      startTime: '14:00',
      endTime: '15:00',
      price: 15000,
      status: BookingStatus.cancelled,
    ),
  ];

  int get _upcomingCount => _bookingHistory
      .where((b) => b.status == BookingStatus.upcoming)
      .length;

  final List<Court> _courts = [
    Court(id: 'A', name: 'A', isAvailable: true),
    Court(id: 'B', name: 'B', isAvailable: true),
    Court(id: 'C', name: 'C', isAvailable: false),
    Court(id: 'D', name: 'D', isAvailable: true),
  ];

  final List<TimeSlot> _morningSlots = [
    TimeSlot(id: '1', time: '08:00 - 09:00', price: 15000, isAvailable: true),
    TimeSlot(id: '2', time: '09:00 - 10:00', price: 15000, isAvailable: false),
    TimeSlot(id: '3', time: '10:00 - 11:00', price: 15000, isAvailable: true),
    TimeSlot(id: '4', time: '11:00 - 12:00', price: 15000, isAvailable: true),
    TimeSlot(id: '5', time: '12:00 - 13:00', price: 15000, isAvailable: false),
    TimeSlot(id: '6', time: '13:00 - 14:00', price: 15000, isAvailable: true),
    TimeSlot(id: '7', time: '14:00 - 15:00', price: 15000, isAvailable: true),
    TimeSlot(id: '8', time: '15:00 - 16:00', price: 15000, isAvailable: true),
  ];

  final List<TimeSlot> _eveningSlots = [
    TimeSlot(id: '9', time: '16:00 - 17:30', price: 20000, isAvailable: true),
    TimeSlot(id: '10', time: '17:30 - 19:00', price: 20000, isAvailable: false),
    TimeSlot(id: '11', time: '19:00 - 20:30', price: 25000, isAvailable: true),
    TimeSlot(id: '12', time: '20:30 - 22:00', price: 25000, isAvailable: true),
    TimeSlot(id: '13', time: '22:00 - 23:30', price: 20000, isAvailable: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundPrimary,
        elevation: 0,
        title: Text(
          'Réservation',
          style: AppTypography.titleLarge,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Tab selector
          _buildTabSelector(),
          
          // Tab content
          Expanded(
            child: _currentTab == 0 ? _buildBookingTab() : _buildHistoryTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      margin: AppSpacing.screenPaddingHorizontalOnly,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: AppRadius.borderRadiusMd,
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: 'Nouvelle réservation',
              isSelected: _currentTab == 0,
              onTap: () => setState(() => _currentTab = 0),
            ),
          ),
          Expanded(
            child: _TabButton(
              label: 'Historique',
              isSelected: _currentTab == 1,
              onTap: () => setState(() => _currentTab = 1),
              badgeCount: _upcomingCount,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSpacing.vGapLg,
          
          // Step 1: Date selector (always visible)
          Padding(
            padding: AppSpacing.screenPaddingHorizontalOnly,
            child: _buildStepHeader(
              step: 1,
              title: 'Choisir une date',
              isCompleted: _selectedDate != null,
            ),
          ),
          AppSpacing.vGapMd,
          _buildDateSelector(),

          // Step 2: Time slots (visible after date selection)
          if (_selectedDate != null) ...[
            AppSpacing.vGapXl,
            Padding(
              padding: AppSpacing.screenPaddingHorizontalOnly,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStepHeader(
                    step: 2,
                    title: 'Choisir un créneau',
                    isCompleted: _selectedSlot != null,
                  ),
                  AppSpacing.vGapMd,

                  // Morning slots (1h)
                  Text(
                    'Matinée (1h)',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  AppSpacing.vGapSm,
                  _buildTimeSlotGrid(_morningSlots),

                  AppSpacing.vGapLg,

                  // Evening slots (1h30)
                  Text(
                    'Soirée (1h30)',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  AppSpacing.vGapSm,
                  _buildTimeSlotGrid(_eveningSlots),
                ],
              ),
            ),
          ],

          // Step 3: Court selector (visible after slot selection)
          if (_selectedSlot != null) ...[
            AppSpacing.vGapXl,
            Padding(
              padding: AppSpacing.screenPaddingHorizontalOnly,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStepHeader(
                    step: 3,
                    title: 'Choisir un terrain',
                    isCompleted: _selectedCourt != null,
                  ),
                  AppSpacing.vGapMd,
                  _buildCourtSelector(),
                ],
              ),
            ),
          ],

          // Book button (visible when all selections made)
          if (_selectedDate != null && _selectedSlot != null && _selectedCourt != null) ...[
            AppSpacing.vGapXxl,
            Padding(
              padding: AppSpacing.screenPaddingHorizontalOnly,
              child: AppButton(
                label: 'Réserver maintenant',
                onPressed: _onBookPressed,
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
  }

  Widget _buildStepHeader({
    required int step,
    required String title,
    required bool isCompleted,
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
                ? Icon(Icons.check, color: AppColors.white, size: 16)
                : Text(
                    step.toString(),
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        AppSpacing.hGapSm,
        Text(
          title,
          style: AppTypography.titleSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    final upcomingBookings = _bookingHistory
        .where((b) => b.status == BookingStatus.upcoming)
        .toList();
    final pastBookings = _bookingHistory
        .where((b) => b.status != BookingStatus.upcoming)
        .toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSpacing.vGapLg,
          
          // Upcoming reservations section with highlight
          if (upcomingBookings.isNotEmpty) ...[
            Padding(
              padding: AppSpacing.screenPaddingHorizontalOnly,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.brandSecondary.withValues(alpha: 0.1),
                  borderRadius: AppRadius.borderRadiusMd,
                  border: Border.all(
                    color: AppColors.brandSecondary.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.brandSecondary,
                            borderRadius: AppRadius.borderRadiusFull,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.event_available,
                                color: AppColors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${upcomingBookings.length} réservation${upcomingBookings.length > 1 ? 's' : ''} à venir',
                                style: AppTypography.labelMedium.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.vGapMd,
                    ...upcomingBookings.map((booking) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _BookingHistoryCard(
                        booking: booking,
                        isHighlighted: true,
                      ),
                    )),
                  ],
                ),
              ),
            ),
            AppSpacing.vGapXl,
          ] else ...[
            // Empty state for no upcoming reservations
            Padding(
              padding: AppSpacing.screenPaddingHorizontalOnly,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: AppRadius.borderRadiusMd,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: AppColors.iconSecondary,
                      size: 32,
                    ),
                    AppSpacing.hGapMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Aucune réservation à venir',
                            style: AppTypography.labelLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          AppSpacing.vGapXxs,
                          Text(
                            'Réservez un terrain pour votre prochaine partie !',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AppSpacing.vGapXl,
          ],

          // Past reservations
          Padding(
            padding: AppSpacing.screenPaddingHorizontalOnly,
            child: Text(
              'Historique',
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          AppSpacing.vGapMd,
          if (pastBookings.isEmpty)
            Padding(
              padding: AppSpacing.screenPaddingHorizontalOnly,
              child: Text(
                'Aucune réservation passée',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            ...pastBookings.map((booking) => Padding(
              padding: AppSpacing.screenPaddingHorizontalOnly,
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _BookingHistoryCard(booking: booking),
              ),
            )),
          
          AppSpacing.vGapXxl,
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    final now = DateTime.now();
    final dates = List.generate(14, (i) => now.add(Duration(days: i)));

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.screenPaddingHorizontalOnly,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = _selectedDate != null &&
              _selectedDate!.day == date.day &&
              _selectedDate!.month == date.month;

          return Padding(
            padding: EdgeInsets.only(right: AppSpacing.sm),
            child: _DateCard(
              date: date,
              isSelected: isSelected,
              onTap: () => setState(() {
                _selectedDate = date;
                // Reset downstream selections when date changes
                _selectedSlot = null;
                _selectedCourt = null;
              }),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCourtSelector() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.2,
      ),
      itemCount: _courts.length,
      itemBuilder: (context, index) {
        final court = _courts[index];
        final isSelected = _selectedCourt == court.id;
        return _CourtCard(
          court: court,
          isSelected: isSelected,
          onTap: court.isAvailable
              ? () => setState(() => _selectedCourt = court.id)
              : null,
        );
      },
    );
  }

  Widget _buildTimeSlotGrid(List<TimeSlot> slots) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: slots.map((slot) {
        final isSelected = _selectedSlot == slot.id;
        return _TimeSlotChip(
          slot: slot,
          isSelected: isSelected,
          onTap: slot.isAvailable
              ? () => setState(() => _selectedSlot = slot.id)
              : null,
        );
      }).toList(),
    );
  }

  void _onBookPressed() {
    if (_selectedDate == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BookingConfirmationSheet(
        court: _courts.firstWhere((c) => c.id == _selectedCourt),
        slot: [..._morningSlots, ..._eveningSlots]
            .firstWhere((s) => s.id == _selectedSlot),
        date: _selectedDate!,
      ),
    );
  }
}

class _DateCard extends StatelessWidget {
  const _DateCard({
    required this.date,
    required this.isSelected,
    this.onTap,
  });

  final DateTime date;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dayNames = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    final monthNames = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'
    ];

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppAnimations.durationNormal,
        width: 85,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandPrimary : AppColors.surfaceSubtle,
          borderRadius: AppRadius.borderRadiusMd,
          border: isSelected
              ? null
              : Border.all(color: AppColors.borderDefault),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayNames[date.weekday - 1],
              style: AppTypography.labelMedium.copyWith(
                color: isSelected ? AppColors.white : AppColors.textSecondary,
              ),
            ),
            AppSpacing.vGapXxs,
            Text(
              date.day.toString(),
              style: AppTypography.headlineSmall.copyWith(
                color: isSelected ? AppColors.white : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.vGapXxs,
            Text(
              monthNames[date.month - 1],
              style: AppTypography.labelMedium.copyWith(
                color: isSelected ? AppColors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourtCard extends StatelessWidget {
  const _CourtCard({
    required this.court,
    required this.isSelected,
    this.onTap,
  });

  final Court court;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDisabled = !court.isAvailable;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppAnimations.durationNormal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: isDisabled
              ? AppColors.neutral100
              : isSelected
                  ? AppColors.brandPrimary
                  : AppColors.surfaceDefault,
          borderRadius: AppRadius.borderRadiusMd,
          border: isSelected || isDisabled
              ? null
              : Border.all(color: AppColors.borderDefault),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              court.name,
              style: AppTypography.displaySmall.copyWith(
                color: isDisabled
                    ? AppColors.neutral400
                    : isSelected
                        ? AppColors.white
                        : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 36,
              ),
              textAlign: TextAlign.center,
            ),
            if (isDisabled) ...[
              AppSpacing.vGapXs,
              Text(
                'Indisponible',
                style: AppTypography.caption.copyWith(
                  color: AppColors.error,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TimeSlotChip extends StatelessWidget {
  const _TimeSlotChip({
    required this.slot,
    required this.isSelected,
    this.onTap,
  });

  final TimeSlot slot;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDisabled = !slot.isAvailable;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppAnimations.durationNormal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isDisabled
              ? AppColors.neutral100
              : isSelected
                  ? AppColors.brandPrimary
                  : AppColors.surfaceDefault,
          borderRadius: AppRadius.borderRadiusSm,
          border: isSelected || isDisabled
              ? null
              : Border.all(color: AppColors.borderDefault),
        ),
        child: Column(
          children: [
            Text(
              slot.time,
              style: AppTypography.labelSmall.copyWith(
                color: isDisabled
                    ? AppColors.neutral400
                    : isSelected
                        ? AppColors.white
                        : AppColors.textPrimary,
              ),
            ),
            AppSpacing.vGapXxs,
            Text(
              '${slot.price.toStringAsFixed(0)} F',
              style: AppTypography.caption.copyWith(
                color: isDisabled
                    ? AppColors.neutral400
                    : isSelected
                        ? AppColors.white.withValues(alpha: 0.8)
                        : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingConfirmationSheet extends StatelessWidget {
  const _BookingConfirmationSheet({
    required this.court,
    required this.slot,
    required this.date,
  });

  final Court court;
  final TimeSlot slot;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.screenPadding,
      decoration: BoxDecoration(
        color: AppColors.surfaceDefault,
        borderRadius: AppRadius.topXxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.neutral300,
              borderRadius: AppRadius.borderRadiusFull,
            ),
          ),
          AppSpacing.vGapLg,

          // Title
          Text(
            'Confirmer la réservation',
            style: AppTypography.titleLarge,
          ),
          AppSpacing.vGapXl,

          // Details
          _buildDetailRow('Terrain', court.name),
          AppSpacing.vGapMd,
          _buildDetailRow('Date', '${date.day}/${date.month}/${date.year}'),
          AppSpacing.vGapMd,
          _buildDetailRow('Créneau', slot.time),
          AppSpacing.vGapMd,
          _buildDetailRow('Prix', '${slot.price.toStringAsFixed(0)} FCFA'),

          AppSpacing.vGapXl,

          // Buttons
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Annuler',
                  onPressed: () => Navigator.pop(context),
                  variant: AppButtonVariant.outline,
                ),
              ),
              AppSpacing.hGapMd,
              Expanded(
                child: AppButton(
                  label: 'Confirmer',
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Réservation confirmée !'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  variant: AppButtonVariant.primary,
                ),
              ),
            ],
          ),

          AppSpacing.vGapLg,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class Court {
  final String id;
  final String name;
  final bool isAvailable;

  Court({required this.id, required this.name, required this.isAvailable});
}

class TimeSlot {
  final String id;
  final String time;
  final double price;
  final bool isAvailable;

  TimeSlot({
    required this.id,
    required this.time,
    required this.price,
    required this.isAvailable,
  });
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isSelected,
    this.onTap,
    this.badgeCount = 0,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppAnimations.durationNormal,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandPrimary : Colors.transparent,
          borderRadius: AppRadius.borderRadiusSm,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected ? AppColors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (badgeCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.white 
                      : AppColors.brandSecondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeCount.toString(),
                  style: AppTypography.caption.copyWith(
                    color: isSelected 
                        ? AppColors.brandPrimary 
                        : AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BookingHistoryCard extends StatelessWidget {
  const _BookingHistoryCard({
    required this.booking,
    this.isHighlighted = false,
  });

  final Booking booking;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final monthNames = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    final dayNames = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

    return Container(
      decoration: BoxDecoration(
        color: isHighlighted ? AppColors.white : AppColors.cardBackground,
        borderRadius: AppRadius.cardBorderRadius,
        border: Border.all(
          color: isHighlighted 
              ? AppColors.brandSecondary 
              : AppColors.reservationCardBorder,
          width: isHighlighted ? 2 : 1,
        ),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: AppColors.brandSecondary.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.cardBorderRadius,
        child: InkWell(
          onTap: () {
            // Show booking details
          },
          borderRadius: AppRadius.cardBorderRadius,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Date badge
                Container(
                  width: 60,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: booking.status == BookingStatus.upcoming
                        ? AppColors.brandSecondary
                        : booking.status == BookingStatus.cancelled
                            ? AppColors.neutral400
                            : AppColors.brandPrimary,
                    borderRadius: AppRadius.borderRadiusSm,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        dayNames[booking.date.weekday - 1],
                        style: AppTypography.caption.copyWith(
                          color: AppColors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      Text(
                        booking.date.day.toString(),
                        style: AppTypography.titleLarge.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        monthNames[booking.date.month - 1],
                        style: AppTypography.caption.copyWith(
                          color: AppColors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.hGapMd,

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.brandPrimary.withValues(alpha: 0.1),
                              borderRadius: AppRadius.borderRadiusSm,
                            ),
                            child: Text(
                              'Terrain ${booking.courtName}',
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.brandPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          AppBadge(
                            label: booking.status.label,
                            variant: booking.status.badgeVariant,
                          ),
                        ],
                      ),
                      AppSpacing.vGapSm,
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${booking.startTime} - ${booking.endTime}',
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.vGapXxs,
                      Row(
                        children: [
                          Text(
                            '${booking.price.toStringAsFixed(0)} FCFA',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '  •  ',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                          Text(
                            'Réf: ${booking.reference}',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow
                Icon(
                  AppIcons.chevronRight,
                  color: AppColors.iconTertiary,
                  size: AppIcons.sizeMd,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum BookingStatus {
  upcoming,
  completed,
  cancelled;

  String get label {
    switch (this) {
      case BookingStatus.upcoming:
        return 'À venir';
      case BookingStatus.completed:
        return 'Terminée';
      case BookingStatus.cancelled:
        return 'Annulée';
    }
  }

  AppBadgeVariant get badgeVariant {
    switch (this) {
      case BookingStatus.upcoming:
        return AppBadgeVariant.warning;
      case BookingStatus.completed:
        return AppBadgeVariant.success;
      case BookingStatus.cancelled:
        return AppBadgeVariant.error;
    }
  }
}

class Booking {
  final String reference;
  final String courtName;
  final DateTime date;
  final String startTime;
  final String endTime;
  final double price;
  final BookingStatus status;

  Booking({
    required this.reference,
    required this.courtName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.price,
    required this.status,
  });
}
