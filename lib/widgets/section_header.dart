import 'package:flutter/material.dart';
import '../app_theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              const Expanded(child: Divider(color: AppTheme.divider, thickness: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.5,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              const Expanded(child: Divider(color: AppTheme.divider, thickness: 1)),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 10,
                letterSpacing: 2,
              ),
            ),
          ],
          if (actionLabel != null) ...[
            const SizedBox(height: 4),
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
