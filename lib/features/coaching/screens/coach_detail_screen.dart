import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/design_system/design_system.dart';
import '../models/coach.dart';

class CoachDetailScreen extends StatelessWidget {
  final Coach coach;

  const CoachDetailScreen({
    super.key,
    required this.coach,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCoachInfo(),
                  AppSpacing.vGapXl,
                  _buildPricingSection(),
                  AppSpacing.vGapXl,
                  _buildContactButton(context),
                  AppSpacing.vGapLg,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.backgroundPrimary,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: coach.imageUrl != null
            ? CachedNetworkImage(
                imageUrl: coach.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.brandPrimary.withValues(alpha: 0.1),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.brandPrimary),
                  ),
                ),
                errorWidget: (context, url, error) => _buildPlaceholderImage(),
              )
            : _buildPlaceholderImage(),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.brandPrimary.withValues(alpha: 0.1),
      child: Center(
        child: Text(
          coach.initials,
          style: AppTypography.displayLarge.copyWith(
            color: AppColors.brandPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCoachInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          coach.fullName,
          style: AppTypography.headlineMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (coach.bio != null) ...[
          AppSpacing.vGapMd,
          Text(
            coach.bio!,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
        AppSpacing.vGapMd,
        Row(
          children: [
            Icon(
              Icons.phone_outlined,
              size: 18,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              coach.phone,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
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
            _PriceItem(duration: '1 heure', price: coach.formattedPrice1hSolo),
            _PriceItem(duration: '1h 30', price: coach.formattedPrice1h30Solo),
          ],
        ),
        AppSpacing.vGapMd,
        _buildPricingCategory(
          title: 'Duo',
          icon: Icons.people,
          color: const Color(0xFF4CAF50),
          prices: [
            _PriceItem(duration: '1 heure', price: coach.formattedPrice1hDuo),
            _PriceItem(duration: '1h 30', price: coach.formattedPrice1h30Duo),
          ],
        ),
        AppSpacing.vGapMd,
        _buildPricingCategory(
          title: 'Trio',
          icon: Icons.groups,
          color: const Color(0xFF2196F3),
          prices: [
            _PriceItem(duration: '1 heure', price: coach.formattedPrice1hTrio),
            _PriceItem(duration: '1h 30', price: coach.formattedPrice1h30Trio),
          ],
        ),
      ],
    );
  }

  Widget _buildPricingCategory({
    required String title,
    required IconData icon,
    required Color color,
    required List<_PriceItem> prices,
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
                      item.duration,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      item.price,
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

  Widget _buildContactButton(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _callCoach(context),
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
            onPressed: () => _whatsappCoach(context),
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

  void _callCoach(BuildContext context) {
    final phoneNumber = coach.phone.replaceAll(RegExp(r'[^\d+]'), '');
    launchUrl(Uri.parse('tel:$phoneNumber'));
  }

  void _whatsappCoach(BuildContext context) {
    final phoneNumber = coach.phone.replaceAll(RegExp(r'[^\d]'), '');
    launchUrl(Uri.parse('https://wa.me/$phoneNumber'));
  }
}

class _PriceItem {
  final String duration;
  final String price;

  _PriceItem({required this.duration, required this.price});
}
