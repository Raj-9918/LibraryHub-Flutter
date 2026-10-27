
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const LibraryHubApp());
}

class LibraryHubApp extends StatelessWidget {
  const LibraryHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LibraryHub',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF355C7D),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
      ),
      home: const LibraryHome(),
    );
  }
}

class Book {
  final String title;
  final String author;
  final String category;
  final String description;
  final IconData icon;

  const Book({
    required this.title,
    required this.author,
    required this.category,
    required this.description,
    required this.icon,
  });
}

const books = [
  Book(
    title: 'The Alchemist',
    author: 'Paulo Coelho',
    category: 'Fiction',
    description:
        'A story about dreams, courage, and discovering your personal journey.',
    icon: Icons.auto_stories,
  ),
  Book(
    title: 'Wings of Fire',
    author: 'A. P. J. Abdul Kalam',
    category: 'Biography',
    description:
        'An inspiring autobiography about education, hard work, and achievement.',
    icon: Icons.rocket_launch,
  ),
  Book(
    title: 'Clean Code',
    author: 'Robert C. Martin',
    category: 'Technology',
    description:
        'A guide to writing readable, maintainable, and well-organized code.',
    icon: Icons.code,
  ),
  Book(
    title: 'Atomic Habits',
    author: 'James Clear',
    category: 'Self Help',
    description:
        'Learn how small daily habits can help you improve over time.',
    icon: Icons.auto_graph,
  ),
  Book(
    title: 'Rich Dad Poor Dad',
    author: 'Robert T. Kiyosaki',
    category: 'Finance',
    description:
        'An introduction to financial thinking, saving, and money management.',
    icon: Icons.account_balance_wallet,
  ),
  Book(
    title: 'The Psychology of Money',
    author: 'Morgan Housel',
    category: 'Finance',
    description:
        'Stories about how people think about money and make financial decisions.',
    icon: Icons.psychology,
  ),
];

class LibraryHome extends StatefulWidget {
  const LibraryHome({super.key});

  @override
  State<LibraryHome> createState() => _LibraryHomeState();
}

class _LibraryHomeState extends State<LibraryHome> {
  int selectedTab = 0;
  String searchText = '';
  String userName = 'Library Member';
  List<String> borrowed = [];
  List<String> favorites = [];

  @override
  void initState() {
    super.initState();
    loadSavedData();
  }

  Future<void> loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      borrowed = prefs.getStringList('borrowedBooks') ?? [];
      favorites = prefs.getStringList('favoriteBooks') ?? [];
      userName = prefs.getString('userName') ?? 'Library Member';
    });
  }

  Future<void> saveList(String key, List<String> values) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, values);
  }

  void toggleFavorite(Book book) {
    setState(() {
      if (favorites.contains(book.title)) {
        favorites.remove(book.title);
      } else {
        favorites.add(book.title);
      }
    });
    saveList('favoriteBooks', favorites);
  }

  void borrowBook(Book book) {
    if (borrowed.contains(book.title)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have already borrowed this book.')),
      );
      return;
    }

    setState(() => borrowed.add(book.title));
    saveList('borrowedBooks', borrowed);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${book.title} borrowed successfully!')),
    );
  }

  void returnBook(String title) {
    setState(() => borrowed.remove(title));
    saveList('borrowedBooks', borrowed);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title returned successfully!')),
    );
  }

  Future<void> editProfile() async {
    final controller = TextEditingController(text: userName);

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Profile'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Your name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', result);

      if (!mounted) return;
      setState(() => userName = result);
    }

    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titles = [
      'LibraryHub',
      'Explore Books',
      'My Books',
      'Favorites',
      'My Profile',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[selectedTab]),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Favorites',
            onPressed: () => setState(() => selectedTab = 3),
            icon: const Icon(Icons.favorite_border),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: selectedTab,
        children: [
          homeScreen(),
          exploreScreen(),
          borrowedScreen(),
          favoritesScreen(),
          profileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTab,
        onDestinationSelected: (index) {
          setState(() => selectedTab = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Books',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline),
            selectedIcon: Icon(Icons.bookmark),
            label: 'My Books',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget homeScreen() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF355C7D), Color(0xFF6C8EAD)],
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'YOUR NEXT CHAPTER STARTS HERE',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Hello, $userName!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Discover books. Learn something new every day.',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF355C7D),
                ),
                onPressed: () => setState(() => selectedTab = 1),
                child: const Text('Explore Library'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: statCard('All Books', '${books.length}', Icons.menu_book)),
            const SizedBox(width: 12),
            Expanded(child: statCard('Borrowed', '${borrowed.length}', Icons.bookmark)),
            const SizedBox(width: 12),
            Expanded(child: statCard('Favorites', '${favorites.length}', Icons.favorite)),
          ],
        ),
        const SizedBox(height: 28),
        sectionTitle('Popular Books', 'View all', () {
          setState(() => selectedTab = 1);
        }),
        const SizedBox(height: 12),
        ...books.take(3).map((book) => bookCard(book)),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget statCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF355C7D)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  Widget sectionTitle(String title, String action, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        TextButton(onPressed: onTap, child: Text(action)),
      ],
    );
  }

  Widget exploreScreen() {
    final filtered = books.where((book) {
      final query = searchText.toLowerCase();
      return book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query) ||
          book.category.toLowerCase().contains(query);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: (value) => setState(() => searchText = value),
            decoration: InputDecoration(
              hintText: 'Search title, author or category...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('No books found. Try another search.'))
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: filtered.map((book) => bookCard(book)).toList(),
                ),
        ),
      ],
    );
  }

  Widget bookCard(Book book) {
    final isFavorite = favorites.contains(book.title);
    final isBorrowed = borrowed.contains(book.title);

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 54,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFFE5EDF5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(book.icon, color: const Color(0xFF355C7D), size: 30),
        ),
        title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text('${book.author}\n${book.category}'),
        ),
        isThreeLine: true,
        trailing: IconButton(
          tooltip: isFavorite ? 'Remove favorite' : 'Add favorite',
          onPressed: () => toggleFavorite(book),
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : Colors.grey,
          ),
        ),
        onTap: () => openBookDetails(book),
      ),
    );
  }

  void openBookDetails(Book book) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final isBorrowed = borrowed.contains(book.title);

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 38,
                  backgroundColor: const Color(0xFFE5EDF5),
                  child: Icon(book.icon, size: 40, color: const Color(0xFF355C7D)),
                ),
              ),
              const SizedBox(height: 18),
              Text(book.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('By ${book.author} · ${book.category}'),
              const SizedBox(height: 16),
              Text(book.description),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    if (!isBorrowed) {
                      borrowBook(book);
                    } else {
                      setState(() => selectedTab = 2);
                    }
                  },
                  icon: Icon(isBorrowed ? Icons.bookmark : Icons.add),
                  label: Text(isBorrowed ? 'View My Books' : 'Borrow Book'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget borrowedScreen() {
    final items = books.where((book) => borrowed.contains(book.title)).toList();

    if (items.isEmpty) {
      return emptyScreen(
        Icons.menu_book,
        'No borrowed books yet',
        'Explore the library and borrow your first book.',
        'Explore Books',
        () => setState(() => selectedTab = 1),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: items.map((book) {
        return Card(
          color: Colors.white,
          child: ListTile(
            leading: Icon(book.icon, color: const Color(0xFF355C7D)),
            title: Text(book.title),
            subtitle: Text(book.author),
            trailing: TextButton(
              onPressed: () => returnBook(book.title),
              child: const Text('Return'),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget favoritesScreen() {
    final items = books.where((book) => favorites.contains(book.title)).toList();

    if (items.isEmpty) {
      return emptyScreen(
        Icons.favorite_border,
        'No favorites yet',
        'Tap the heart on any book to save it here.',
        'Browse Books',
        () => setState(() => selectedTab = 1),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: items.map((book) => bookCard(book)).toList(),
    );
  }

  Widget profileScreen() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 20),
        const CircleAvatar(
          radius: 48,
          backgroundColor: Color(0xFFE5EDF5),
          child: Icon(Icons.person, size: 54, color: Color(0xFF355C7D)),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            userName,
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),
        ),
        const Center(child: Text('LibraryHub Member')),
        const SizedBox(height: 28),
        Card(
          color: Colors.white,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Edit Name'),
                trailing: const Icon(Icons.chevron_right),
                onTap: editProfile,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.bookmark_outline),
                title: const Text('Borrowed Books'),
                trailing: Text('${borrowed.length}'),
                onTap: () => setState(() => selectedTab = 2),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.favorite_outline),
                title: const Text('Favorite Books'),
                trailing: Text('${favorites.length}'),
                onTap: () => setState(() => selectedTab = 3),
              ),
              const Divider(height: 1),
              const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('About LibraryHub'),
                subtitle: Text('A student library management project'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget emptyScreen(
    IconData icon,
    String title,
    String message,
    String buttonText,
    VoidCallback onPressed,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: const Color(0xFF7892AA)),
            const SizedBox(height: 18),
            Text(title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 18),
            FilledButton(onPressed: onPressed, child: Text(buttonText)),
          ],
        ),
      ),
    );
  }
}
