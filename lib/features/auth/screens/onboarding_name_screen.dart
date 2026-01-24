import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/router/page_transitions.dart';
import 'onboarding_birthdate_screen.dart';

class OnboardingNameScreen extends StatefulWidget {
  final String email;
  final String? initialFirstName;
  final String? initialLastName;
  
  const OnboardingNameScreen({
    super.key,
    required this.email,
    this.initialFirstName,
    this.initialLastName,
  });

  @override
  State<OnboardingNameScreen> createState() => _OnboardingNameScreenState();
}

class _OnboardingNameScreenState extends State<OnboardingNameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _prenomController = TextEditingController();
  final _nomController = TextEditingController();
  String? _selectedGender;
  
  final List<Map<String, String>> _genderOptions = [
    {'value': 'M', 'label': 'Homme'},
    {'value': 'F', 'label': 'Femme'},
  ];

  @override
  void initState() {
    super.initState();
    // Pré-remplir avec les données OAuth si disponibles
    if (widget.initialFirstName != null && widget.initialFirstName!.isNotEmpty) {
      _prenomController.text = widget.initialFirstName!;
    }
    if (widget.initialLastName != null && widget.initialLastName!.isNotEmpty) {
      _nomController.text = widget.initialLastName!;
    }
  }

  @override
  void dispose() {
    _prenomController.dispose();
    _nomController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedGender == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Veuillez sélectionner votre genre'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      context.navigateSlide(
        OnboardingBirthdateScreen(
          email: widget.email,
          prenom: _prenomController.text,
          nom: _nomController.text,
          gender: _selectedGender!,
        ),
        routeName: '/auth/onboarding/birthdate',
      );
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ce champ est requis';
    }
    return null;
  }

  void _showGenderPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceDefault,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
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
                      'Sélectionnez votre genre',
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 60), // Balance
                  ],
                ),
              ),
              // Options
              ..._genderOptions.map((option) {
                final isSelected = _selectedGender == option['value'];
                return InkWell(
                  onTap: () {
                    setState(() => _selectedGender = option['value']);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppColors.brandPrimary.withValues(alpha: 0.05)
                          : Colors.transparent,
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.borderDefault.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            option['label']!,
                            style: AppTypography.bodyLarge.copyWith(
                              color: isSelected 
                                  ? AppColors.brandPrimary 
                                  : AppColors.textPrimary,
                              fontWeight: isSelected 
                                  ? FontWeight.w600 
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: AppColors.brandPrimary,
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFormValid = _prenomController.text.isNotEmpty && 
                        _nomController.text.isNotEmpty &&
                        _selectedGender != null;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            // Header fixe avec back button et logo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(AppIcons.arrowBack),
                    onPressed: () => Navigator.of(context).pop(),
                    color: AppColors.iconPrimary,
                  ),
                  const Expanded(
                    child: Center(
                      child: AppLogo(size: AppLogoSize.small),
                    ),
                  ),
                  const SizedBox(width: 48), // Balance pour centrer le logo
                ],
              ),
            ),
            
            // Contenu scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  bottom: bottomPadding > 0 ? bottomPadding + 80 : AppSpacing.lg,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      AppSpacing.vGapLg,
                      
                      // Title
                      Text(
                        'Vos informations',
                        style: AppTypography.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      
                      AppSpacing.vGapXs,
                      
                      // Subtitle
                      Text(
                        'Commençons par votre nom',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      AppSpacing.vGapXxl,
                      
                      // Nom field
                      AppTextField(
                        controller: _nomController,
                        label: 'Nom',
                        hint: 'Entrez votre nom',
                        prefixIcon: Icons.person_outline,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        validator: _validateName,
                        onChanged: (value) => setState(() {}),
                      ),
                      
                      AppSpacing.vGapMd,
                      
                      // Prénom field
                      AppTextField(
                        controller: _prenomController,
                        label: 'Prénom',
                        hint: 'Entrez votre prénom',
                        prefixIcon: Icons.person_outline,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        validator: _validateName,
                        onChanged: (value) => setState(() {}),
                      ),
                      
                      AppSpacing.vGapMd,
                      
                      // Genre field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Genre',
                            style: AppTypography.inputLabel,
                          ),
                          AppSpacing.vGapXs,
                          GestureDetector(
                            onTap: _showGenderPicker,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.md,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.inputBackground,
                                borderRadius: AppRadius.inputBorderRadius,
                                border: Border.all(
                                  color: _selectedGender != null 
                                      ? AppColors.brandPrimary 
                                      : AppColors.inputBorder,
                                  width: _selectedGender != null ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.wc_outlined,
                                    color: _selectedGender != null 
                                        ? AppColors.brandPrimary 
                                        : AppColors.iconSecondary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      _selectedGender != null
                                          ? _genderOptions.firstWhere((o) => o['value'] == _selectedGender)['label']!
                                          : 'Sélectionnez votre genre',
                                      style: _selectedGender != null
                                          ? AppTypography.bodyMedium.copyWith(
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.w500,
                                            )
                                          : AppTypography.inputHint,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: AppColors.iconSecondary,
                                  ),
                                ],
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
            
            // Bouton fixe en bas
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom: bottomPadding > 0 ? AppSpacing.sm : AppSpacing.lg,
                top: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: AppColors.backgroundPrimary,
                boxShadow: bottomPadding > 0 ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ] : null,
              ),
              child: AppButton(
                label: 'Suivant',
                onPressed: isFormValid ? _onContinue : null,
                variant: AppButtonVariant.primary,
                size: AppButtonSize.large,
                isFullWidth: true,
                isDisabled: !isFormValid,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
