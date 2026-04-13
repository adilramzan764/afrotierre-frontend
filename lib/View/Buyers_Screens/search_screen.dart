import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController(
    text: '',
  );

  final List<Map<String, String>> _searchSuggestions = [
    {'term': 'wear for women', 'results': '328 results'},
    {'term': 'wear for men', 'results': '481 results'},
    {'term': 'Shoes for women', 'results': '26 results'},
    {'term': 'equipment', 'results': '37 results'},
    {'term': 'mat', 'results': '93 results'},
  ];

  final List<Map<String, String>> _topResults = [
    {
      'title': 'Under armour sexy ladies gym wear',
      'subtitle': 'Under armour (2022)',
      'image': '', // Add your image asset path here
    },
    {
      'title': 'Addidas ladies gym wear',
      'subtitle': 'Addidas (2023)',
      'image': '', // Add your image asset path here
    },
    {
      'title': 'Under armour sexy ladies gym wear',
      'subtitle': 'Under armour (2022)',
      'image': '', // Add your image asset path here
    },
    {
      'title': 'Addidas ladies gym wear',
      'subtitle': 'Addidas (2023)',
      'image': '', // Add your image asset path here
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            Expanded(
              child: ListView(
                children: [..._buildSearchSuggestions(), _buildTopResults()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Icon(Icons.search, color: Colors.grey),
                ),
                border: InputBorder.none,
                hintText: 'Search',
              ),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () {
              _searchController.clear();
              // Handle cancel
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSearchSuggestions() {
    return _searchSuggestions.map((suggestion) {
      return ListTile(
        title: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black, fontSize: 16),
            children: [
              TextSpan(
                text: 'Gym ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: suggestion['term']!),
            ],
          ),
        ),
        subtitle: Text(
          suggestion['results']!,
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: const Icon(Icons.north_west, color: Colors.grey, size: 18),
      );
    }).toList();
  }

  Widget _buildTopResults() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Results',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _topResults.length,
            itemBuilder: (context, index) {
              final result = _topResults[index];
              return ListTile(
                leading: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.asset(
                    "assets/stock_image.png",
                    fit: BoxFit.cover,
                  ), // Add image here
                ),
                title: Text(result['title']!),
                subtitle: Text(
                  result['subtitle']!,
                  style: const TextStyle(color: Colors.grey),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              );
            },
          ),
        ],
      ),
    );
  }
}
