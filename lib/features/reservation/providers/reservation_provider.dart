import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/reservation_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/points_service.dart';

enum ReservationLoadingState {
  initial,
  loading,
  loaded,
  error,
}

class ReservationProvider extends ChangeNotifier {
  ReservationLoadingState _courtsState = ReservationLoadingState.initial;
  ReservationLoadingState _slotsState = ReservationLoadingState.initial;
  ReservationLoadingState _reservationsState = ReservationLoadingState.initial;
  ReservationLoadingState _bookingState = ReservationLoadingState.initial;

  List<Court> _courts = [];
  List<AvailableSlot> _availableSlots = [];
  List<Reservation> _userReservations = [];
  Map<int, int> _availableSlotCounts = {};
  
  DateTime? _selectedDate;
  Court? _selectedCourt;
  AvailableSlot? _selectedSlot;
  
  String? _errorMessage;

  ReservationLoadingState get courtsState => _courtsState;
  ReservationLoadingState get slotsState => _slotsState;
  ReservationLoadingState get reservationsState => _reservationsState;
  ReservationLoadingState get bookingState => _bookingState;

  List<Court> get courts => _courts;
  List<AvailableSlot> get availableSlots => _availableSlots;
  List<Reservation> get userReservations => _userReservations;
  
  DateTime? get selectedDate => _selectedDate;
  Court? get selectedCourt => _selectedCourt;
  AvailableSlot? get selectedSlot => _selectedSlot;
  
  String? get errorMessage => _errorMessage;

  List<AvailableSlot> get slotsForSelectedCourt {
    if (_selectedCourt == null) return [];
    return _availableSlots.where((s) => s.terrainId == _selectedCourt!.id).toList();
  }

  List<AvailableSlot> get availableSlotsForSelectedCourt {
    return slotsForSelectedCourt.where((s) => !s.isReserved).toList();
  }

  Map<int, int> get availableSlotCountByCourt => _availableSlotCounts;

  List<Reservation> get upcomingReservations {
    return _userReservations.where((r) => r.isUpcoming).toList()
      ..sort((a, b) {
        final dateCompare = a.reservationDate.compareTo(b.reservationDate);
        if (dateCompare != 0) return dateCompare;
        if (a.startTime == null || b.startTime == null) return 0;
        return a.startTime!.compareTo(b.startTime!);
      });
  }

  List<Reservation> get pastReservations {
    return _userReservations.where((r) => !r.isUpcoming).toList()
      ..sort((a, b) => b.reservationDate.compareTo(a.reservationDate));
  }

  bool get canBook => _selectedDate != null && _selectedCourt != null && _selectedSlot != null;

  Future<void> loadCourts() async {
    _courtsState = ReservationLoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _courts = await ReservationService.getCourts();
      _courtsState = ReservationLoadingState.loaded;
    } catch (e) {
      _courtsState = ReservationLoadingState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> loadSlotsForDate(DateTime date, {bool autoAdvance = true}) async {
    _slotsState = ReservationLoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _availableSlots = await ReservationService.getAvailableSlotsForDate(date);
      
      _availableSlotCounts = {};
      for (final court in _courts) {
        _availableSlotCounts[court.id] = _availableSlots
            .where((s) => s.terrainId == court.id && !s.isReserved)
            .length;
      }
      
      _slotsState = ReservationLoadingState.loaded;
      notifyListeners();
      
      // Auto-advance to next day if no available slots
      if (autoAdvance && !_hasAvailableSlotsForDate(date)) {
        final nextDate = date.add(const Duration(days: 1));
        final maxDate = DateTime.now().add(const Duration(days: 6));
        if (nextDate.isBefore(maxDate) || _isSameDay(nextDate, maxDate)) {
          _selectedDate = nextDate;
          await loadSlotsForDate(nextDate, autoAdvance: true);
          return;
        }
      }
    } catch (e) {
      _slotsState = ReservationLoadingState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  bool _hasAvailableSlotsForDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(date.year, date.month, date.day);
    
    // Filter slots that are not reserved
    var availableSlots = _availableSlots.where((s) => !s.isReserved).toList();
    
    // If today, also filter out past time slots
    if (_isSameDay(selectedDate, today)) {
      final currentHour = now.hour;
      final currentMinute = now.minute;
      availableSlots = availableSlots.where((slot) {
        final timeParts = slot.startTime.split(':');
        final slotHour = int.tryParse(timeParts[0]) ?? 0;
        final slotMinute = int.tryParse(timeParts[1]) ?? 0;
        return slotHour > currentHour || (slotHour == currentHour && slotMinute > currentMinute);
      }).toList();
    }
    
    return availableSlots.isNotEmpty;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> loadUserReservations() async {
    final user = AuthService.currentUser;
    if (user == null) {
      _reservationsState = ReservationLoadingState.error;
      _errorMessage = 'Utilisateur non connecté';
      notifyListeners();
      return;
    }

    _reservationsState = ReservationLoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _userReservations = await ReservationService.getUserReservations(user.id);
      _reservationsState = ReservationLoadingState.loaded;
    } catch (e) {
      _reservationsState = ReservationLoadingState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  void selectDate(DateTime date, {bool autoAdvance = true}) {
    _selectedDate = date;
    _selectedCourt = null;
    _selectedSlot = null;
    notifyListeners();
    loadSlotsForDate(date, autoAdvance: autoAdvance);
  }

  void selectCourt(Court court) {
    if (_selectedSlot != null) {
      final slotForCourt = _availableSlots.firstWhere(
        (s) => s.timeSlotId == _selectedSlot!.timeSlotId && s.terrainId == court.id,
        orElse: () => _selectedSlot!,
      );
      _selectedSlot = slotForCourt;
    }
    _selectedCourt = court;
    notifyListeners();
  }

  void selectSlot(AvailableSlot slot) {
    if (slot.isReserved) return;
    _selectedSlot = slot;
    _selectedCourt = null;
    notifyListeners();
  }

  void selectSlotByTimeSlotId(int timeSlotId) {
    final slot = _availableSlots.firstWhere(
      (s) => s.timeSlotId == timeSlotId && !s.isReserved,
      orElse: () => _availableSlots.firstWhere((s) => s.timeSlotId == timeSlotId),
    );
    _selectedSlot = slot;
    _selectedCourt = null;
    notifyListeners();
  }

  void clearSelection() {
    _selectedDate = null;
    _selectedCourt = null;
    _selectedSlot = null;
    _availableSlots = [];
    _availableSlotCounts = {};
    notifyListeners();
  }

  void resetSlotSelection() {
    _selectedSlot = null;
    notifyListeners();
  }

  void resetCourtSelection() {
    _selectedCourt = null;
    _selectedSlot = null;
    notifyListeners();
  }

  Future<Reservation?> createReservation() async {
    if (!canBook) {
      _errorMessage = 'Veuillez sélectionner une date, un court et un créneau';
      notifyListeners();
      return null;
    }

    final user = AuthService.currentUser;
    if (user == null) {
      _errorMessage = 'Utilisateur non connecté';
      notifyListeners();
      return null;
    }

    _bookingState = ReservationLoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final reservation = await ReservationService.createReservation(
        terrainId: _selectedCourt!.id,
        timeSlotId: _selectedSlot!.timeSlotId,
        date: _selectedDate!,
        userId: user.id,
      );

      _bookingState = ReservationLoadingState.loaded;
      
      _userReservations.insert(0, reservation);
      
      // Ajouter des points pour la réservation
      await PointsService.instance.addPointsForReservation(reservation.id);
      
      final slotIndex = _availableSlots.indexWhere(
        (s) => s.terrainId == _selectedCourt!.id && s.timeSlotId == _selectedSlot!.timeSlotId
      );
      if (slotIndex != -1) {
        _availableSlots[slotIndex] = AvailableSlot(
          terrainId: _availableSlots[slotIndex].terrainId,
          terrainCode: _availableSlots[slotIndex].terrainCode,
          timeSlotId: _availableSlots[slotIndex].timeSlotId,
          startTime: _availableSlots[slotIndex].startTime,
          endTime: _availableSlots[slotIndex].endTime,
          price: _availableSlots[slotIndex].price,
          isReserved: true,
        );
      }
      
      if (_availableSlotCounts.containsKey(_selectedCourt!.id)) {
        _availableSlotCounts[_selectedCourt!.id] = 
            (_availableSlotCounts[_selectedCourt!.id] ?? 1) - 1;
      }
      
      clearSelection();
      notifyListeners();
      
      return reservation;
    } catch (e) {
      _bookingState = ReservationLoadingState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> cancelReservation(int reservationId) async {
    try {
      final updatedReservation = await ReservationService.cancelReservation(reservationId);
      
      final index = _userReservations.indexWhere((r) => r.id == reservationId);
      if (index != -1) {
        _userReservations[index] = updatedReservation;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshAll() async {
    await Future.wait([
      loadCourts(),
      loadUserReservations(),
      if (_selectedDate != null) loadSlotsForDate(_selectedDate!),
    ]);
  }
}
