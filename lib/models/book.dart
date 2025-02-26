class Book {
  final String bid;
  final String title;
  final String author;
  final String dateReleased;
  final int totalPage;
  final String genre;
  final String description;


  Book(
    {
      required this.bid,
      required this.title,
      required this.author,
      required this.dateReleased,
      required this.totalPage,
      required this.genre,
      required this.description,
    }
  );

  Map<String, dynamic> toMap() {
    return {
      'bid' : bid,
      'title' : title,
      'author' : author,
      'dateReleased' : dateReleased,
      'totalPage' : totalPage,
      'genre' : genre,
      'description' : description,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map){
    return Book(
      bid: map['bid'],
      title: map['title'],
      author: map['author'],
      dateReleased: map['dateReleased'],
      totalPage: map['totalPage'],
      genre: map['genre'],
      description: map['description'],
    );
  }

}