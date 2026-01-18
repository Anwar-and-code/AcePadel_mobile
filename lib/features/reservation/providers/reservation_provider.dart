import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/reservation_service.dart';
import '../../../core/services/auth_service.dart';
import '../../gamification/services/gamification_service_v2.dart';

enum ReservationLoadingState {
  initial,
  loading,
  loaded,
  error,
}

class ReservationProvider extends ChangeNotifier {
  ReservationLoadingState _terrainsState = ReservationLoadingState.initial;
  ReservationLoadingState _slotsState = ReservationLoadingState.initial;
  ReservationLoadingState _reservationsState = ReservationLoadingState.initial;
  ReservationLoadingState _bookingState = ReservationLoadingState.initial;

  List<Terrain> _terrains = [];
  List<AvailableSlot> _availableSlots = [];
  List<Reservation> _userReservations = [];
  Map<int, int> _availableSlotCounts = {};
  
  DateTime? _selectedDate;
  Terrain? _selectedTerrain;
  AvailableSlot? _selectedSlot;
  
  String? _errorMessage;

  ReservationLoadingState get terrainsState => _terrainsState;
  ReservationLoadingState get slotsState => _slotsState;
  ReservationLoadingState get reservationsState => _reservationsState;
  ReservationLoadingState get bookingState => _bookingState;

  List<Terrain> get terrains => _terrains;
  List<AvailableSlot> get availableSlots => _availableSlots;
  List<Reservation> get userReservations => _userReservations;
  
  DateTime? get selectedDate => _selectedDate;
  Terrain? get selectedTerrain => _selectedTerrain;
  AvailableSlot? get selectedSlot => _selectedSlot;
  
  String? get errorMessage => _errorMessage;

  List<AvailableSlot> get slotsForSelectedTerrain {
    if (_selectedTerrain == null) return [];
    return _availableSlots.where((s) => s.terrainId == _selectedTerrain!.id).toList();
  }

  List<AvailableSlot> get availableSlotsForSelectedTerrain {
    return slotsForSelectedTerrain.where((s) => !s.isReserved).toList();
  }

  Map<int, int> get availableSlotCountByTerrain => _availableSlotCounts;

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

  bool get canBook => _selectedDate != null && _selectedTerrain != null && _selectedSlot != null;

  Future<void> loadTerrains() async {
    _terrainsState = ReservationLoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _terrains = await ReservationService.getTerrains();
      _terrainsState = ReservationLoadingState.loaded;
    } catch (e) {
      _terrainsState = ReservationLoadingState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> loadSlotsForDate(DateTime date) async {
    _slotsState = ReservationLoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _availableSlots = await ReservationService.getAvailableSlotsForDate(date);
      
      _availableSlotCounts = {};
      for (final terrain in _terrains) {
        _availableSlotCounts[terrain.id] = _availableSlots
            .where((s) => s.terrainId == terrain.id && !s.isReserved)
            .length;
      }
      
      _slotsState = ReservationLoadingState.loaded;
    } catch (e) {
      _slotsState = ReservationLoadingState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
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

  void selectDate(DateTime date) {
    _selectedDate = date;
    _selectedTerrain = null;
    _selectedSlot = null;
    notifyListeners();
    loadSlotsForDate(date);
  }

  void selectTerrain(Terrain terrain) {
    if (_selectedSlot != null) {
      final slotForTerrain = _availableSlots.firstWhere(
        (s) => s.timeSlotId == _selectedSlot!.timeSlotId && s.terrainId == terrain.id,
        orElse: () => _selectedSlot!,
      );
      _selectedSlot = slotForTerrain;
    }
    _selectedTerrain = terrain;
    notifyListeners();
  }

  void selectSlot(AvailableSlot slot) {
    if (slot.isReserved) return;
    _selectedSlot = slot;
    _selectedTerrain = null;
    notifyListeners();
  }

  void selectSlotByTimeSlotId(int timeSlotId) {
    final slot = _availableSlots.firstWhere(
      (s) => s.timeSlotId == timeSlotId && !s.isReserved,
      orElse: () => _availableSlots.firstWhere((s) => s.timeSlotId == timeSlotId),
    );
    _selectedSlot = slot;
    _selectedTerrain = null;
    notifyListeners();
  }

  void clearSelection() {
    _selectedDate = null;
    _selectedTerrain = null;
    _selectedSlot = null;
    _availableSlots = [];
    _availableSlotCounts = {};
    notifyListeners();
  }

  void resetSlotSelection() {
    _selectedSlot = null;
    notifyListeners();
  }

  void resetTerrainSelection() {
    _selectedTerrain = null;
    _selectedSlot = null;
    notifyListeners();
  }

  Future<Reservation?> createReservation() async {
    if (!canBook) {
      _errorMessage = 'Veuillez sélectionner une date, un terrain et un créneau';
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
        terrainId: _selectedTerrain!.id,
        timeSlotId: _selectedSlot!.timeSlotId,
        date: _selectedDate!,
        userId: user.id,
      );

      _bookingState = ReservationLoadingState.loaded;
      
      _userReservations.insert(0, reservation);
      
      // Gamification: Award XP for reservation
      final hour = _selectedSlot!.startTime != null 
          ? int.tryParse(_selectedSlot!.startTime!.split(':')[0]) 
          : null;
      await GamificationServiceV2.instance.onReservationMade(hour: hour);
      
      final slotIndex = _availableSlots.indexWhere(
        (s) => s.terrainId == _selectedTerrain!.id && s.timeSlotId == _selectedSlot!.timeSlotId
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
      
      if (_availableSlotCounts.containsKey(_selectedTerrain!.id)) {
        _availableSlotCounts[_selectedTerrain!.id] = 
            (_availableSlotCounts[_selectedTerrain!.id] ?? 1) - 1;
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
      loadTerrains(),
      loadUserReservations(),
      if (_selectedDate != null) loadSlotsForDate(_selectedDate!),
    ]);
  }
}
