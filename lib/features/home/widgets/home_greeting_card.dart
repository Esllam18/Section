// lib/features/home/widgets/home_greeting_card.dart
import 'package:flutter/material.dart';
import 'package:section/core/constants/app_colors.dart';

class HomeGreetingCard extends StatelessWidget {
  final String name;
  final String faculty;
  final bool isAr;

  const HomeGreetingCard({
    super.key,
    required this.name,
    required this.faculty,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isAr
                ? 'أهلاً${name.isNotEmpty ? "، $name" : ""}! 👋'
                : 'Hello${name.isNotEmpty ? ", $name" : ""}! 👋',
            style: const TextStyle(
              fontFamily: 'Lora',
              fontWeight: FontWeight.w700,
              fontSize: 22,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            isAr ? 'ماذا تريد اليوم؟' : 'What would you like to do today?',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: Colors.white.withOpacity(0.82),
            ),
          ),
          if (faculty.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                faculty,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
