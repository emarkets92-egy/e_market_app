import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';

class ContactUsSection extends StatelessWidget {
  const ContactUsSection({super.key});

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    // Remove + and spaces from phone number
    final cleanPhone = phone.replaceAll(RegExp(r'[\s+]'), '');
    final uri = Uri.parse('https://wa.me/$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.lightBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.contact_mail_outlined,
                  color: AppTheme.primaryBlue,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'contact_us'.tr(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _ContactItem(
            icon: Icons.language,
            label: 'website'.tr(),
            value: 'e-markets.org',
            onTap: () => _launchURL('https://e-markets.org'),
          ),
          const SizedBox(height: 12),
          _ContactItem(
            icon: Icons.phone,
            label: 'phone'.tr(),
            value: '+201211766667',
            onTap: () => _launchPhone('+201211766667'),
          ),
          const SizedBox(height: 12),
          _ContactItem(
            icon: Icons.chat,
            label: 'whatsapp'.tr(),
            value: '+201211766667',
            onTap: () => _launchWhatsApp('+201211766667'),
          ),
          const SizedBox(height: 12),
          _ContactItem(
            icon: Icons.email,
            label: 'email'.tr(),
            value: 'info@e-markets.org',
            onTap: () => _launchEmail('info@e-markets.org'),
          ),
          const SizedBox(height: 12),
          _ContactItem(
            icon: Icons.location_on,
            label: 'address'.tr(),
            value: '45 Qambiz st, infront of shooting club gate -Dokki- Giza, Egypt',
            onTap: null,
          ),
          const SizedBox(height: 24),
          Text(
            'follow_us'.tr(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _SocialMediaButton(
                icon: Icons.facebook,
                label: 'facebook'.tr(),
                onTap: () => _launchURL('https://www.facebook.com/EMarkets'),
              ),
              const SizedBox(width: 12),
              _SocialMediaButton(
                icon: Icons.business,
                label: 'linkedin'.tr(),
                onTap: () => _launchURL('https://www.linkedin.com/company/emarkets-eg'),
              ),
              const SizedBox(width: 12),
              _SocialMediaButton(
                icon: Icons.alternate_email,
                label: 'twitter'.tr(),
                onTap: () => _launchURL('https://twitter.com/emarkets_eg'),
              ),
              const SizedBox(width: 12),
              _SocialMediaButton(
                icon: Icons.camera_alt,
                label: 'instagram'.tr(),
                onTap: () => _launchURL('https://www.instagram.com/emarkets_eg'),
              ),
              const SizedBox(width: 12),
              _SocialMediaButton(
                icon: Icons.play_circle_outline,
                label: 'youtube'.tr(),
                onTap: () => _launchURL('https://www.youtube.com/@EMarkets-eg'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _ContactItem({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFDBEAFE)),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryBlue,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
          ],
        ),
      ),
    );
  }
}

class _SocialMediaButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SocialMediaButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFDBEAFE)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppTheme.primaryBlue,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
