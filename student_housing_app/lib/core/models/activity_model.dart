class Activity {
  final String id;
  final String title;
  final String category;
  final String date; // e.g., "2026-01-25"
  final String time; // e.g., "03:00 PM"
  final String location;
  final String imagePath; // Can be URL or asset path
  final String description;

  Activity({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.time,
    required this.location,
    required this.imagePath,
    required this.description,
  });
}
