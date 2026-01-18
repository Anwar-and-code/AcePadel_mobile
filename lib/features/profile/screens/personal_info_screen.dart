import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/services/user_profile_service.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  bool _isEditing = false;
  bool _isSaving = false;

  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _phone = '';
  DateTime? _birthDate;
  String _selectedGender = 'Aucun';

  final List<String> _genderOptions = ['Aucun', 'Homme', 'Femme', 'Autre'];

  @override
  void initState() {
    super.initState();
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
    });
  }

  String _mapGenderFromDb(String? gender) {
    switch (gender?.toUpperCase()) {
      case 'MALE':
      case 'HOMME':
        return 'Homme';
      case 'FEMALE':
      case 'FEMME':
        return 'Femme';
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
        return 'MALE';
      case 'Femme':
        return 'FEMALE';
      case 'Autre':
        return 'OTHER';
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
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _isEditing ? _handleSave : () => setState(() => _isEditing = true),
              child: Text(
                _isEditing ? 'Enregistrer' : 'Modifier',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.brandPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
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
                isEditing: _isEditing,
                onTap: _isEditing ? () => _showEditDialog('Prénom', _firstName, (v) => setState(() => _firstName = v)) : null,
              ),
              _InfoTile(
                icon: Icons.badge_outlined,
                title: 'Nom',
                value: _lastName.isEmpty ? 'Non renseigné' : _lastName,
                isEditing: _isEditing,
                onTap: _isEditing ? () => _showEditDialog('Nom', _lastName, (v) => setState(() => _lastName = v)) : null,
              ),
              _InfoTile(
                icon: Icons.cake_outlined,
                title: 'Date de naissance',
                value: _formatDate(_birthDate),
                isEditing: _isEditing,
                onTap: _isEditing ? _selectDate : null,
              ),
              _InfoTile(
                icon: Icons.wc_outlined,
                title: 'Genre',
                value: _selectedGender,
                isEditing: _isEditing,
                onTap: _isEditing ? _showGenderSelector : null,
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
                isEditing: _isEditing,
                onTap: _isEditing ? () => _showEditDialog('Téléphone', _phone, (v) => setState(() => _phone = v), keyboardType: TextInputType.phone) : null,
              ),
            ]),

            AppSpacing.vGapXxl,
          ],
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
      if (success) _isEditing = false;
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

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.brandPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
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
