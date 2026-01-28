import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// SecretModeSwitch: Reusable widget for toggling secret/anonymous complaint mode
/// 
/// Features:
/// - Animated tab toggle UI
/// - Clear visual indication of mode
/// - Warning banner when secret mode is enabled
class SecretModeSwitch extends StatelessWidget {
  final bool isSecret;
  final ValueChanged<bool> onChanged;

  const SecretModeSwitch({
    super.key,
    required this.isSecret,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tab Toggle
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
              ),
            ],
          ),
          child: Row(
            children: [
              // Normal Complaint Tab
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !isSecret ? const Color(0xFF001F3F) : Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'شكوى عادية',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: !isSecret ? Colors.white : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
              // Secret Complaint Tab
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSecret ? const Color(0xFFFF6B6B) : Colors.white,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'شكوى سرية',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSecret ? Colors.white : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Secret Mode Warning Banner
        if (isSecret) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3CD),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFFFE69C),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lock,
                  color: Color(0xFFFF8C00),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'هذه الشكوى مشفرة ولن يظهر اسمك أو بياناتك للمستلم',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF856404),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
