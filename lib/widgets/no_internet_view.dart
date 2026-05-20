import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../theme/app_theme.dart';

class NoInternetView extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoInternetView({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final textColor = AppTheme.text(context);
    final mutedColor = AppTheme.subtext(context);
    final cardColor = AppTheme.card(context);
    final lineColor = AppTheme.line(context);

    return Scaffold(
      backgroundColor: AppTheme.pageBg(context),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppTheme.pageGradientOf(context),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(22),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: lineColor),
                  boxShadow: isDark ? null : AppTheme.softShadow,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 230,
                      height: 230,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.primary.withOpacity(isDark ? .28 : .13),
                            AppTheme.secondary.withOpacity(isDark ? .20 : .10),
                          ],
                        ),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(.08)
                              : Colors.white.withOpacity(.85),
                        ),
                      ),
                      child: Lottie.asset(
                        'assets/lottie/no_internet.json',
                        fit: BoxFit.contain,
                        repeat: true,
                        animate: true,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Internet aloqasi yo‘q',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 24,
                        height: 1.15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Ulanishni tekshiring. Internet tiklangandan keyin ilova ma’lumotlarni avtomatik yangilaydi.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: mutedColor,
                        fontSize: 14.5,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Qayta urinish'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Wi‑Fi yoki mobil internetni yoqing',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: mutedColor.withOpacity(.86),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
