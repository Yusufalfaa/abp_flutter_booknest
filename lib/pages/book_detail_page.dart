import 'package:flutter/material.dart';

class BookDetailsPage extends StatefulWidget {
  final Map<String, dynamic> book;

  const BookDetailsPage({Key? key, required this.book}) : super(key: key);

  @override
  _BookDetailsPageState createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  bool isExpanded = false;
  bool isAdded = false; // Status untuk tombol Add/Remove

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Blurred Image
          Positioned.fill(
            child: Opacity(
              opacity: 0.4,
              child: Image.network(
                widget.book['thumbnail'] ?? '',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: Colors.black);
                },
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFFC76E6F),
                      ), // Warna disamakan
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      // Card putih untuk detail buku
                      Positioned(
                        top:
                            160, // Naikkan posisi kartu untuk memberi ruang pada cover
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          padding: const EdgeInsets.fromLTRB(
                            16,
                            100,
                            16,
                            16,
                          ), // Beri ruang lebih untuk cover
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Judul Buku
                                Text(
                                  widget.book['title'] ?? 'Unknown Title',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Penulis Buku
                                Text(
                                  'By ${widget.book['authors'] ?? 'Unknown'}'
                                      .toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Rate dan Review di atas garis
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Rating di kiri
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${widget.book['average_rating'] ?? 'N/A'}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Review di kanan
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.chat_bubble,
                                          color: Colors.orange,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${widget.book['reviews'] ?? 0} Reviews',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                // Garis horizontal di bawah rate & review
                                Divider(
                                  color: const Color(
                                    0xFFC76E6F,
                                  ), // Warna disamakan dengan tombol Add to List
                                  thickness: 2,
                                ),

                                const SizedBox(height: 16),

                                // Deskripsi Buku + Tombol Expand
                                IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Deskripsi
                                      Expanded(
                                        child: Text(
                                          widget.book['description'] ??
                                              'No description available.',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                          ),
                                          textAlign: TextAlign.justify,
                                          maxLines: isExpanded ? null : 3,
                                          overflow:
                                              isExpanded
                                                  ? TextOverflow.visible
                                                  : TextOverflow.ellipsis,
                                        ),
                                      ),
                                      // Tombol Expand "V"
                                      IconButton(
                                        icon: Icon(
                                          isExpanded
                                              ? Icons.keyboard_arrow_up
                                              : Icons.keyboard_arrow_down,
                                        ),
                                        color: Colors.black,
                                        onPressed: () {
                                          setState(() {
                                            isExpanded = !isExpanded;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Genre (Tags)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Categories",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        children:
                                            (widget.book['categories']
                                                    as String?)
                                                ?.split(',') // Split by comma
                                                .map(
                                                  (genre) => genre.trim(),
                                                ) // Trim whitespace
                                                .where(
                                                  (genre) => genre.isNotEmpty,
                                                ) // Remove empty values
                                                .map(
                                                  (genre) => Chip(
                                                    label: Text(
                                                      genre,
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    backgroundColor:
                                                        Colors.grey.shade300,
                                                  ),
                                                )
                                                .toList() ??
                                            [],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Tombol "Add to List" / "Remove from List"
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width *
                                      0.6, // Lebih pendek
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        isAdded = !isAdded;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          isAdded
                                              ? const Color(
                                                0xFFB0B0B0,
                                              ) // Abu-abu untuk Remove
                                              : const Color(
                                                0xFFC76E6F,
                                              ), // Merah untuk Add
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shadowColor: Colors.black.withOpacity(
                                        0.4,
                                      ),
                                      elevation: 6,
                                    ),
                                    child: Text(
                                      isAdded
                                          ? 'Remove from List'
                                          : 'Add to List',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Cover Buku diposisikan di atas card dan di atas judul
                      Positioned(
                        top: 10, // Naikkan posisi cover lebih tinggi
                        left:
                            MediaQuery.of(context).size.width * 0.5 -
                            75, // Agar cover berada di tengah
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            widget.book['thumbnail'] ?? '',
                            width: 150,
                            height: 220,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 150,
                                height: 220,
                                color: Colors.grey,
                                child: const Icon(Icons.broken_image, size: 50),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
