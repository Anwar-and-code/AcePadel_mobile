import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/design_system/design_system.dart';
import '../../coaching/models/coach.dart';
import '../../coaching/services/coaching_service.dart';

class CoachingScreen extends StatefulWidget {
  const CoachingScreen({super.key});

  @override
  State<CoachingScreen> createState() => _CoachingScreenState();
}

class _CoachingScreenState extends State<CoachingScreen> {
  List<Coach> _coaches = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCoaches();
  }

  Future<void> _loadCoaches() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final coaches = await CoachingService.getCoaches();
      setState(() {
        _coaches = coaches;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
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
          'Nos Coaches',
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.brandPrimary),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
            AppSpacing.vGapMd,
            Text(
              'Erreur de chargement',
              style: AppTypography.titleSmall,
            ),
            AppSpacing.vGapSm,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text(
                _error!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            AppSpacing.vGapLg,
            TextButton.icon(
              onPressed: _loadCoaches,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_coaches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_tennis,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            AppSpacing.vGapMd,
            Text(
              'Aucun coach disponible',
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            AppSpacing.vGapSm,
            Text(
              'Revenez plus tard',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCoaches,
      color: AppColors.brandPrimary,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: _coaches.length,
        itemBuilder: (context, index) {
          final coach = _coaches[index];
          return _CoachCard(
            coach: coach,
            onTap: () => _showCoachDetails(context, coach),
          );
        },
      ),
    );
  }

  void _showCoachDetails(BuildContext context, Coach coach) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _CoachDetailsSheet(
          coach: coach,
          scrollController: scrollController,
        ),
      ),
    );
  }
}

class _CoachCard extends StatelessWidget {
  final Coach coach;
  final VoidCallback onTap;

  const _CoachCard({
    required this.coach,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                _buildAvatar(),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coach.fullName,
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (coach.bio != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          coach.bio!,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.brandPrimary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'À partir de ${coach.formatPrice(coach.price1hTrio)}',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.brandPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.brandPrimary.withValues(alpha: 0.1),
      ),
      child: coach.imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: coach.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.brandPrimary,
                  ),
                ),
                errorWidget: (context, url, error) => Center(
                  child: Text(
                    coach.initials,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.brandPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
          : Center(
              child: Text(
                coach.initials,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.brandPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }
}

class _CoachDetailsSheet extends StatelessWidget {
  final Coach coach;
  final ScrollController scrollController;

  const _CoachDetailsSheet({
    required this.coach,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: AppSpacing.sm),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.borderDefault,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Expanded(
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              _buildHeader(),
              AppSpacing.vGapXl,
              _buildPricingSection(),
              AppSpacing.vGapXl,
              _buildContactButtons(context),
              AppSpacing.vGapLg,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.brandPrimary.withValues(alpha: 0.1),
          ),
          child: coach.imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: coach.imageUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Center(
                      child: Text(
                        coach.initials,
                        style: AppTypography.headlineSmall.copyWith(
                          color: AppColors.brandPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    coach.initials,
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.brandPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                coach.fullName,
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (coach.bio != null) ...[
                AppSpacing.vGapSm,
                Text(
                  coach.bio!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
              AppSpacing.vGapMd,
              Row(
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    coach.phone,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPricingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tarifs des séances',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSpacing.vGapMd,
        _buildPricingCategory(
          title: 'Solo',
          icon: Icons.person,
          color: AppColors.brandPrimary,
          prices: [
            ('1 heure', coach.formattedPrice1hSolo),
            ('1h 30', coach.formattedPrice1h30Solo),
          ],
        ),
        AppSpacing.vGapMd,
        _buildPricingCategory(
          title: 'Duo',
          icon: Icons.people,
          color: const Color(0xFF4CAF50),
          prices: [
            ('1 heure', coach.formattedPrice1hDuo),
            ('1h 30', coach.formattedPrice1h30Duo),
          ],
        ),
        AppSpacing.vGapMd,
        _buildPricingCategory(
          title: 'Trio',
          icon: Icons.groups,
          color: const Color(0xFF2196F3),
          prices: [
            ('1 heure', coach.formattedPrice1hTrio),
            ('1h 30', coach.formattedPrice1h30Trio),
          ],
        ),
      ],
    );
  }

  Widget _buildPricingCategory({
    required String title,
    required IconData icon,
    required Color color,
    required List<(String, String)> prices,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          AppSpacing.vGapMd,
          ...prices.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.$1,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      item.$2,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildContactButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _callCoach(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.phone),
            label: Text(
              'Appeler ${coach.firstName}',
              style: AppTypography.labelLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        AppSpacing.vGapMd,
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _whatsappCoach(),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF25D366),
              side: const BorderSide(color: Color(0xFF25D366)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.chat),
            label: Text(
              'WhatsApp',
              style: AppTypography.labelLarge.copyWith(
                color: const Color(0xFF25D366),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _callCoach() {
    final phoneNumber = coach.phone.replaceAll(RegExp(r'[^\d+]'), '');
    launchUrl(Uri.parse('tel:$phoneNumber'));
  }

  void _whatsappCoach() {
    final phoneNumber = coach.phone.replaceAll(RegExp(r'[^\d]'), '');
    launchUrl(Uri.parse('https://wa.me/$phoneNumber'));
  }
}
