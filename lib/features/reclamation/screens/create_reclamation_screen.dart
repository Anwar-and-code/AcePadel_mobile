import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/design_system/design_system.dart';
import '../models/reclamation.dart';
import '../services/reclamation_service.dart';

/// Écran de création d'une réclamation
class CreateReclamationScreen extends StatefulWidget {
  const CreateReclamationScreen({super.key});

  @override
  State<CreateReclamationScreen> createState() => _CreateReclamationScreenState();
}

class _CreateReclamationScreenState extends State<CreateReclamationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  ReclamationCategory _selectedCategory = ReclamationCategory.general;
  final List<Uint8List> _selectedPhotoBytes = [];
  bool _isSubmitting = false;

  static const int _maxPhotos = 2;

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _subjectController.text.trim().isNotEmpty &&
           _descriptionController.text.trim().isNotEmpty;
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_selectedPhotoBytes.length >= _maxPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum $_maxPhotos photos autorisées'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedPhotoBytes.add(bytes);
      });
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _selectedPhotoBytes.removeAt(index);
    });
  }

  void _showImageSourceDialog() {
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
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  'Ajouter une photo',
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.camera_alt, color: AppColors.brandPrimary),
                ),
                title: const Text('Prendre une photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.photo_library, color: AppColors.info),
                ),
                title: const Text('Choisir depuis la galerie'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              AppSpacing.vGapMd,
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitReclamation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final result = await ReclamationService.instance.createReclamation(
      subject: _subjectController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      photoBytes: _selectedPhotoBytes.isNotEmpty ? _selectedPhotoBytes : null,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Réclamation envoyée avec succès'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Erreur lors de l\'envoi'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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
          'Nouvelle réclamation',
          style: AppTypography.titleLarge,
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Catégorie
              Text(
                'Catégorie',
                style: AppTypography.inputLabel,
              ),
              AppSpacing.vGapXs,
              _buildCategorySelector(),
              
              AppSpacing.vGapXl,

              // Sujet
              AppTextField(
                controller: _subjectController,
                label: 'Sujet',
                hint: 'Décrivez brièvement le problème',
                prefixIcon: Icons.subject,
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le sujet est requis';
                  }
                  if (value.trim().length < 5) {
                    return 'Le sujet doit contenir au moins 5 caractères';
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),

              AppSpacing.vGapXl,

              // Description
              Text(
                'Description',
                style: AppTypography.inputLabel,
              ),
              AppSpacing.vGapXs,
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Décrivez votre problème en détail...',
                  hintStyle: AppTypography.inputHint,
                  filled: true,
                  fillColor: AppColors.inputBackground,
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.inputBorderRadius,
                    borderSide: BorderSide(color: AppColors.inputBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.inputBorderRadius,
                    borderSide: BorderSide(color: AppColors.inputBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.inputBorderRadius,
                    borderSide: BorderSide(color: AppColors.brandPrimary, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: AppRadius.inputBorderRadius,
                    borderSide: BorderSide(color: AppColors.error),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La description est requise';
                  }
                  if (value.trim().length < 20) {
                    return 'La description doit contenir au moins 20 caractères';
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),

              AppSpacing.vGapXl,

              // Photos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Photos (optionnel)',
                    style: AppTypography.inputLabel,
                  ),
                  Text(
                    '${_selectedPhotoBytes.length}/$_maxPhotos',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              AppSpacing.vGapXs,
              Text(
                'Ajoutez des photos pour illustrer votre réclamation',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              AppSpacing.vGapMd,
              _buildPhotoSection(),

              AppSpacing.vGapXxl,

              // Submit button
              AppButton(
                label: 'Envoyer la réclamation',
                onPressed: _isFormValid && !_isSubmitting ? _submitReclamation : null,
                variant: AppButtonVariant.primary,
                size: AppButtonSize.large,
                isFullWidth: true,
                isLoading: _isSubmitting,
                isDisabled: !_isFormValid,
              ),

              AppSpacing.vGapLg,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: AppRadius.inputBorderRadius,
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ReclamationCategory>(
          value: _selectedCategory,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          borderRadius: AppRadius.inputBorderRadius,
          dropdownColor: AppColors.surfaceDefault,
          items: ReclamationCategory.values.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Row(
                children: [
                  Icon(
                    _getCategoryIcon(category),
                    size: 20,
                    color: AppColors.brandPrimary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    category.label,
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedCategory = value);
            }
          },
        ),
      ),
    );
  }

  IconData _getCategoryIcon(ReclamationCategory category) {
    switch (category) {
      case ReclamationCategory.general:
        return Icons.help_outline;
      case ReclamationCategory.reservation:
        return Icons.calendar_today;
      case ReclamationCategory.terrain:
        return Icons.sports_tennis;
      case ReclamationCategory.paiement:
        return Icons.payment;
      case ReclamationCategory.autre:
        return Icons.more_horiz;
    }
  }

  Widget _buildPhotoSection() {
    return Row(
      children: [
        // Photos sélectionnées
        ..._selectedPhotoBytes.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: _PhotoThumbnail(
              bytes: entry.value,
              onRemove: () => _removePhoto(entry.key),
            ),
          );
        }),
        // Bouton ajouter
        if (_selectedPhotoBytes.length < _maxPhotos)
          _AddPhotoButton(onTap: _showImageSourceDialog),
      ],
    );
  }
}

/// Miniature d'une photo sélectionnée
class _PhotoThumbnail extends StatelessWidget {
  final Uint8List bytes;
  final VoidCallback onRemove;

  const _PhotoThumbnail({
    required this.bytes,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderDefault),
            image: DecorationImage(
              image: MemoryImage(bytes),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Bouton pour ajouter une photo
class _AddPhotoButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddPhotoButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.brandPrimary.withValues(alpha: 0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 32,
              color: AppColors.brandPrimary,
            ),
            AppSpacing.vGapXxs,
            Text(
              'Ajouter',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.brandPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
