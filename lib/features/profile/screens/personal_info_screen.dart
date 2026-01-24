import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/services/user_profile_service.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  bool _isSaving = false;

  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _phone = '';
  DateTime? _birthDate;
  String _selectedGender = 'Aucun';

  // Original values to detect changes
  String _originalFirstName = '';
  String _originalLastName = '';
  String _originalPhone = '';
  DateTime? _originalBirthDate;
  String _originalGender = 'Aucun';

  final List<String> _genderOptions = ['Aucun', 'Homme', 'Femme', 'Autre'];
  
  final List<String> _monthNames = [
    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
  ];

  @override
  void initState() {
    super.initState();
    _refreshAndLoadProfile();
  }

  Future<void> _refreshAndLoadProfile() async {
    // Recharger le profil depuis Supabase
    await UserProfileService.instance.loadProfile();
    _loadProfileData();
  }

  void _loadProfileData() {
    final profile = UserProfileService.instance.profile;
    setState(() {
      _firstName = profile?.firstName ?? '';
      _lastName = profile?.lastName ?? '';
      _email = profile?.email ?? '';
      _phone = profile?.phone ?? '';
      _birthDate = profile?.birthDate;
      _selectedGender = _mapGenderFromDb(profile?.gender);
      
      // Store original values
      _originalFirstName = _firstName;
      _originalLastName = _lastName;
      _originalPhone = _phone;
      _originalBirthDate = _birthDate;
      _originalGender = _selectedGender;
    });
  }

  bool get _hasChanges {
    return _firstName != _originalFirstName ||
           _lastName != _originalLastName ||
           _phone != _originalPhone ||
           _birthDate != _originalBirthDate ||
           _selectedGender != _originalGender;
  }

  String _mapGenderFromDb(String? gender) {
    switch (gender?.toUpperCase()) {
      case 'M':
      case 'MALE':
      case 'HOMME':
        return 'Homme';
      case 'F':
      case 'FEMALE':
      case 'FEMME':
        return 'Femme';
      case 'O':
      case 'OTHER':
      case 'AUTRE':
        return 'Autre';
      default:
        return 'Aucun';
    }
  }

  String _mapGenderToDb(String gender) {
    switch (gender) {
      case 'Homme':
        return 'M';
      case 'Femme':
        return 'F';
      case 'Autre':
        return 'O';
      default:
        return '';
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Non renseigné';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundPrimary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(AppIcons.arrowBack, color: AppColors.iconPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Informations personnelles',
          style: AppTypography.titleLarge,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.vGapMd,

            // Identité Section
            _buildSectionHeader('Identité'),
            AppSpacing.vGapSm,
            _buildSettingsCard([
              _InfoTile(
                icon: Icons.person_outline,
                title: 'Prénom',
                value: _firstName.isEmpty ? 'Non renseigné' : _firstName,
                isEditing: true,
                onTap: () => _showEditDialog('Prénom', _firstName, (v) => setState(() => _firstName = v)),
              ),
              _InfoTile(
                icon: Icons.badge_outlined,
                title: 'Nom',
                value: _lastName.isEmpty ? 'Non renseigné' : _lastName,
                isEditing: true,
                onTap: () => _showEditDialog('Nom', _lastName, (v) => setState(() => _lastName = v)),
              ),
              _InfoTile(
                icon: Icons.cake_outlined,
                title: 'Date de naissance',
                value: _formatDate(_birthDate),
                isEditing: true,
                onTap: _selectDate,
              ),
              _InfoTile(
                icon: Icons.wc_outlined,
                title: 'Genre',
                value: _selectedGender,
                isEditing: true,
                onTap: _showGenderSelector,
              ),
            ]),

            AppSpacing.vGapXl,

            // Contact Section
            _buildSectionHeader('Contact'),
            AppSpacing.vGapSm,
            _buildSettingsCard([
              _InfoTile(
                icon: Icons.email_outlined,
                title: 'Email',
                value: _email.isEmpty ? 'Non renseigné' : _email,
                isEditing: false, // Email jamais modifiable
                isLocked: true,
              ),
              _InfoTile(
                icon: Icons.phone_outlined,
                title: 'Téléphone',
                value: _phone.isEmpty ? 'Non renseigné' : _phone,
                isEditing: true,
                onTap: () => _showEditDialog('Téléphone', _phone, (v) => setState(() => _phone = v), keyboardType: TextInputType.phone),
              ),
            ]),

            AppSpacing.vGapXxl,
            
            // Bottom padding for button
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: FilledButton(
            onPressed: _hasChanges && !_isSaving ? _handleSave : null,
            style: FilledButton.styleFrom(
              backgroundColor: _hasChanges ? AppColors.success : AppColors.neutral300,
              disabledBackgroundColor: AppColors.neutral300,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSaving
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : Text(
                    'Enregistrer les modifications',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: AppSpacing.screenPaddingHorizontalOnly,
      child: Text(
        title,
        style: AppTypography.labelLarge.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      margin: AppSpacing.screenPaddingHorizontalOnly,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadius.cardBorderRadius,
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(
                height: 1,
                indent: AppSpacing.md + 40 + AppSpacing.md,
                color: AppColors.borderDefault,
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    
    final success = await UserProfileService.instance.updateProfile(
      firstName: _firstName.trim(),
      lastName: _lastName.trim(),
      phone: _phone.trim(),
      gender: _mapGenderToDb(_selectedGender),
      birthDate: _birthDate,
    );
    
    setState(() {
      _isSaving = false;
      if (success) {
        // Update original values after successful save
        _originalFirstName = _firstName;
        _originalLastName = _lastName;
        _originalPhone = _phone;
        _originalBirthDate = _birthDate;
        _originalGender = _selectedGender;
      }
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Informations mises à jour' : 'Erreur lors de la mise à jour'),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  void _showEditDialog(String title, String currentValue, Function(String) onSave, {TextInputType? keyboardType}) {
    final controller = TextEditingController(text: currentValue);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier $title'),
        content: TextField(
          controller: controller,
          keyboardType: keyboardType,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Entrez votre $title',
            border: OutlineInputBorder(
              borderRadius: AppRadius.borderRadiusMd,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderRadiusMd,
              borderSide: BorderSide(color: AppColors.brandPrimary, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
            child: Text('Confirmer', style: TextStyle(color: AppColors.brandPrimary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showGenderSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sélectionner le genre',
              style: AppTypography.headlineSmall,
            ),
            AppSpacing.vGapLg,
            ..._genderOptions.map((gender) => ListTile(
              leading: Icon(
                _getGenderIcon(gender),
                color: _selectedGender == gender ? AppColors.brandPrimary : AppColors.iconSecondary,
              ),
              title: Text(gender),
              trailing: _selectedGender == gender
                  ? Icon(Icons.check, color: AppColors.brandPrimary)
                  : null,
              onTap: () {
                setState(() => _selectedGender = gender);
                Navigator.pop(context);
              },
            )),
            AppSpacing.vGapLg,
          ],
        ),
      ),
    );
  }

  IconData _getGenderIcon(String gender) {
    switch (gender) {
      case 'Homme':
        return Icons.male;
      case 'Femme':
        return Icons.female;
      case 'Autre':
        return Icons.transgender;
      default:
        return Icons.person_outline;
    }
  }

  void _selectDate() {
    int? selectedDay = _birthDate?.day;
    int? selectedMonth = _birthDate?.month;
    int? selectedYear = _birthDate?.year;
    
    final currentYear = DateTime.now().year;
    final years = List.generate(81, (i) => currentYear - 10 - i); // 10 à 90 ans
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundPrimary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          int getDaysInMonth(int month, int? year) {
            if (month == 2) {
              if (year != null && ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0))) {
                return 29;
              }
              return 28;
            }
            if ([4, 6, 9, 11].contains(month)) return 30;
            return 31;
          }
          
          List<int> availableDays = selectedMonth != null 
              ? List.generate(getDaysInMonth(selectedMonth!, selectedYear), (i) => i + 1)
              : List.generate(31, (i) => i + 1);
          
          return Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderDefault,
                    borderRadius: AppRadius.borderRadiusFull,
                  ),
                ),
                AppSpacing.vGapLg,
                
                // Title
                Text(
                  'Date de naissance',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppSpacing.vGapXl,
                
                // Date pickers row
                Row(
                  children: [
                    // Jour
                    Expanded(
                      flex: 2,
                      child: _buildDatePickerField(
                        label: 'Jour',
                        displayValue: selectedDay?.toString().padLeft(2, '0'),
                        hint: 'Jour',
                        onTap: () => _showPicker(
                          title: 'Jour',
                          items: availableDays.map((d) => d.toString().padLeft(2, '0')).toList(),
                          initialIndex: selectedDay != null ? selectedDay! - 1 : 0,
                          onSelected: (index) {
                            setModalState(() => selectedDay = availableDays[index]);
                          },
                        ),
                      ),
                    ),
                    AppSpacing.hGapSm,
                    // Mois
                    Expanded(
                      flex: 3,
                      child: _buildDatePickerField(
                        label: 'Mois',
                        displayValue: selectedMonth != null ? _monthNames[selectedMonth! - 1] : null,
                        hint: 'Mois',
                        onTap: () => _showPicker(
                          title: 'Mois',
                          items: _monthNames,
                          initialIndex: selectedMonth != null ? selectedMonth! - 1 : 0,
                          onSelected: (index) {
                            setModalState(() {
                              selectedMonth = index + 1;
                              // Valider le jour pour ce mois
                              if (selectedDay != null) {
                                final maxDays = getDaysInMonth(selectedMonth!, selectedYear);
                                if (selectedDay! > maxDays) selectedDay = maxDays;
                              }
                            });
                          },
                        ),
                      ),
                    ),
                    AppSpacing.hGapSm,
                    // Année
                    Expanded(
                      flex: 2,
                      child: _buildDatePickerField(
                        label: 'Année',
                        displayValue: selectedYear?.toString(),
                        hint: 'Année',
                        onTap: () => _showPicker(
                          title: 'Année',
                          items: years.map((y) => y.toString()).toList(),
                          initialIndex: selectedYear != null ? years.indexOf(selectedYear!) : 20,
                          onSelected: (index) {
                            setModalState(() => selectedYear = years[index]);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                
                AppSpacing.vGapXl,
                
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Annuler',
                        variant: AppButtonVariant.outline,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    AppSpacing.hGapMd,
                    Expanded(
                      child: AppButton(
                        label: 'Confirmer',
                        variant: AppButtonVariant.primary,
                        onPressed: (selectedDay != null && selectedMonth != null && selectedYear != null)
                            ? () {
                                setState(() {
                                  _birthDate = DateTime(selectedYear!, selectedMonth!, selectedDay!);
                                });
                                Navigator.pop(context);
                              }
                            : null,
                        isDisabled: selectedDay == null || selectedMonth == null || selectedYear == null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDatePickerField({
    required String label,
    required String? displayValue,
    required String hint,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        AppSpacing.vGapXs,
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: AppRadius.inputBorderRadius,
              border: Border.all(
                color: displayValue != null ? AppColors.brandPrimary : AppColors.inputBorder,
                width: displayValue != null ? 1.5 : 1,
              ),
            ),
            child: Center(
              child: Text(
                displayValue ?? hint,
                style: displayValue != null
                    ? AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      )
                    : AppTypography.bodyMedium.copyWith(
                        color: AppColors.textTertiary,
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showPicker({
    required String title,
    required List<String> items,
    required int initialIndex,
    required ValueChanged<int> onSelected,
  }) {
    int tempIndex = initialIndex >= 0 && initialIndex < items.length ? initialIndex : 0;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 300,
        decoration: BoxDecoration(
          color: AppColors.surfaceDefault,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.borderDefault),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Annuler',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Text(
                    title,
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      onSelected(tempIndex);
                      Navigator.pop(context);
                    },
                    child: Text(
                      'OK',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.brandPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Picker
            Expanded(
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(
                  initialItem: tempIndex,
                ),
                itemExtent: 44,
                onSelectedItemChanged: (index) => tempIndex = index,
                selectionOverlay: Container(
                  decoration: BoxDecoration(
                    border: Border.symmetric(
                      horizontal: BorderSide(
                        color: AppColors.brandPrimary.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                ),
                children: items.map((item) => Center(
                  child: Text(
                    item,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
    this.isEditing = false,
    this.isLocked = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final bool isEditing;
  final bool isLocked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isPlaceholder = value == 'Non renseigné';
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary.withValues(alpha: 0.1),
                  borderRadius: AppRadius.borderRadiusMd,
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: AppColors.brandPrimary,
                ),
              ),
              AppSpacing.hGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    AppSpacing.vGapXxs,
                    Text(
                      value,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isPlaceholder ? AppColors.textTertiary : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isLocked)
                Icon(
                  Icons.lock_outline,
                  size: 18,
                  color: AppColors.textTertiary,
                )
              else if (isEditing)
                Icon(
                  AppIcons.chevronRight,
                  color: AppColors.iconTertiary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
