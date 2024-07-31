import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:recipe_finder/ui/pages/widgets/drawer.widget.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _recipes = [];
  List<dynamic> _randomRecipes = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchRandomRecipes();
  }

  Future<void> _fetchRandomRecipes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String url =
          'https://api.spoonacular.com/recipes/random?number=20&apiKey=ac2187fa1d314d7a9e9e1fb89dfe9d66';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          _randomRecipes = json.decode(response.body)['recipes'];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load random recipes');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $_errorMessage')),
      );
    }
  }

  Future<void> _fetchRecipes() async {
    final query = _controller.text;
    if (query.isNotEmpty) {
      setState(() {
        _isLoading = true;
        _isSearching = true;
        _errorMessage = '';
      });

      try {
        String url =
            'https://api.spoonacular.com/recipes/findByIngredients?ingredients=$query&apiKey=ac2187fa1d314d7a9e9e1fb89dfe9d66';
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          setState(() {
            _recipes = json.decode(response.body);
            _isLoading = false;
          });
        } else {
          throw Exception('Failed to load recipes');
        }
      } catch (error) {
        setState(() {
          _isLoading = false;
          _errorMessage = error.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $_errorMessage')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        title: Text('Recipe Finder'),
        backgroundColor: Colors.greenAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchRandomRecipes,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchBar(),
            SizedBox(height: 16),
            if (_isLoading) _buildLoadingIndicator() else _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Search by ingredients...',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: IconButton(
            icon: Icon(Icons.search, color: Colors.greenAccent),
            onPressed: _fetchRecipes,
          ),
        ),
        onSubmitted: (_) => _fetchRecipes(),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildContent() {
    if (_errorMessage.isNotEmpty) {
      return _buildError();
    } else if (_recipes.isEmpty && !_isSearching) {
      return _buildRecipeList(
          _randomRecipes,
          'No recipes found. Try searching with different ingredients.'
      );
    } else {
      return _buildRecipeList(_recipes, 'No results found for your search.');
    }
  }

  Widget _buildError() {
    return Center(
      child: Text(
        _errorMessage,
        style: TextStyle(color: Colors.red, fontSize: 16),
      ),
    );
  }

  Widget _buildRecipeList(List<dynamic> recipes, String emptyMessage) {
    if (recipes.isEmpty) {
      return Center(child: Text(emptyMessage));
    }

    return Expanded(
      child: ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return _buildRecipeCard(recipe);
        },
      ),
    );
  }

  Widget _buildRecipeCard(dynamic recipe) {
    // Make the card clickable for both types of recipes
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.symmetric(vertical: 12),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/recipeDetail/${recipe['id']}',
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRecipeImage(recipe['image']),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                recipe['title'],
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent,
                ),
              ),
            ),
            if (!_isSearching) // Show details only for random recipes
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 60,
                      child: SingleChildScrollView(
                        child: HtmlWidget(
                          recipe['summary'] ?? 'No description available.',
                          textStyle: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.timer, size: 16, color: Colors.grey[700]),
                            SizedBox(width: 4),
                            Text(
                              '${recipe['readyInMinutes']} mins',
                              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.restaurant_menu, size: 16, color: Colors.grey[700]),
                            SizedBox(width: 4),
                            Text(
                              '${recipe['servings']} servings',
                              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      child: Stack(
        children: [
          Image.network(
            imageUrl,
            width: double.infinity,
            height: 180,
            fit: BoxFit.cover,
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'New',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
