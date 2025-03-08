class Book {
  final String isbn13;
  final String? isbn10;
  final String title;
  final String? subtitle;
  final String? authors;
  final String? categories;
  final String? thumbnail;
  final String? description;
  final int? publishedYear;
  final double? averageRating;
  final int? numPages;
  final int? ratingsCount;

  Book({
    required this.isbn13,
    this.isbn10,
    required this.title,
    this.subtitle,
    this.authors,
    this.categories,
    this.thumbnail,
    this.description,
    this.publishedYear,
    this.averageRating,
    this.numPages,
    this.ratingsCount,
  });

  // Factory constructor to create a Book from Firestore
  factory Book.fromMap(Map<String, dynamic> data) {
    return Book(
      isbn13: data['isbn13'].toString(), // Convert to String
      isbn10: data['isbn10'],
      title: data['title'] ?? 'Unknown Title',
      subtitle: data['subtitle'],
      authors: data['authors'],
      categories: data['categories'],
      thumbnail: data['thumbnail'],
      description: data['description'],
      publishedYear:
          data['published_year'] != null
              ? int.tryParse(data['published_year'].toString())
              : null,
      averageRating:
          data['average_rating'] != null
              ? double.tryParse(data['average_rating'].toString())
              : null,
      numPages:
          data['num_pages'] != null
              ? int.tryParse(data['num_pages'].toString())
              : null,
      ratingsCount:
          data['ratings_count'] != null
              ? int.tryParse(data['ratings_count'].toString())
              : null,
    );
  }

  // Convert Book object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'isbn13': isbn13,
      'isbn10': isbn10,
      'title': title,
      'subtitle': subtitle,
      'authors': authors,
      'categories': categories,
      'thumbnail': thumbnail,
      'description': description,
      'published_year': publishedYear,
      'average_rating': averageRating,
      'num_pages': numPages,
      'ratings_count': ratingsCount,
    };
  }
}
