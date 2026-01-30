class DailyAttendance {
  final String date;
  final bool isPresent; // true = تمام / حاضر، false = غياب
  final String? note;   // ملاحظات لو فيه (اختياري)

  DailyAttendance({
    required this.date,
    required this.isPresent,
    this.note,
  });

  factory DailyAttendance.fromJson(Map<String, dynamic> json) {
    return DailyAttendance(
      date: json['date'],
      // هنا بنحول الـ Boolean اللي جاي من الداتا بيز مباشرة
      isPresent: json['isPresent'] ?? false,
      note: json['note'],
    );
  }
}