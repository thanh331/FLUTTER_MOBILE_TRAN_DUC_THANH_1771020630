class NewsModel {
  final String title;
  final String image;
  final String date;

  NewsModel({required this.title, required this.image, required this.date});

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      title: json['title'] ?? '',
      image: json['imageUrl'] ?? '',
      date: json['createdDate']?.toString() ?? '',
    );
  }
}