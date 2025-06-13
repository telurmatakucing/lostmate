class LostItem {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String location;
  final DateTime date;
  final String reporterName;
  final String? reporterPhotoUrl;

  LostItem({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.location,
    required this.date,
    required this.reporterName,
    this.reporterPhotoUrl,
  });
}
