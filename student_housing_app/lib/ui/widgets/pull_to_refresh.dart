import 'package:flutter/material.dart';

class PullToRefresh extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const PullToRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      // توحيد الألوان في التطبيق كله من هنا
      color: const Color(0xFF001F3F),
      backgroundColor: Colors.white,
      onRefresh: onRefresh,
      // هنا السر: بنحط SingleChildScrollView عشان نضمن إن الصفحة بتقبل السحب
      // حتى لو المحتوى صغير ومش مكمل الشاشة
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: child,
      ),
    );
  }
}