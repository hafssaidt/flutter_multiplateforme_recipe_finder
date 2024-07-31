import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class RecipeDetailPage extends StatefulWidget {
  final String recipeId;

  RecipeDetailPage({required this.recipeId});

  @override
  _RecipeDetailPageState createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  Map<String, dynamic> _recipeDetails = {};
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchRecipeDetails();
  }

  Future<void> _fetchRecipeDetails() async {
    final String url =
        'https://api.spoonacular.com/recipes/${widget.recipeId}/information?apiKey=ac2187fa1d314d7a9e9e1fb89dfe9d66';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body) as Map<String, dynamic>?;
        if (decodedData != null) {
          setState(() {
            _recipeDetails = decodedData;
            _isLoading = false;
          });
        } else {
          throw Exception('Unexpected data format');
        }
      } else {
        throw Exception('Failed to load recipe details');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe Detail'),
        backgroundColor: Colors.greenAccent,
        elevation: 5,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
        child: Text(
          _errorMessage,
          style: TextStyle(color: Colors.red, fontSize: 18),
        ),
      )
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  child: _recipeDetails['image'] != null
                      ? Image.network(
                    _recipeDetails['image'] as String,
                    fit: BoxFit.cover,
                  )
                      : Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: Text(
                        'No Image Available',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey[700]),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 16,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    color: Colors.black54,
                    child: Text(
                      (_recipeDetails['title'] as String?) ??
                          'Recipe Title',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Ingredients'),
                  _buildIngredients(),
                  SizedBox(height: 20),
                  _buildSectionTitle('Instructions'),
                  _buildInstructions(),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.greenAccent,
        ),
      ),
    );
  }

  Widget _buildIngredients() {
    final ingredients = _recipeDetails['extendedIngredients'] as List<dynamic>?;

    if (ingredients == null || ingredients.isEmpty) {
      return Text('No ingredients available', style: TextStyle(fontSize: 16));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: ingredients.map((ingredient) {
        final name = (ingredient['name'] as String?) ?? 'Unknown';
        final amount = (ingredient['amount'] as num?)?.toString() ?? '0';
        final unit = (ingredient['unit'] as String?) ?? '';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.greenAccent),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  '$name ($amount $unit)',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInstructions() {
    return HtmlWidget(
      (_recipeDetails['instructions'] as String?) ?? 'No instructions available',
    );
  }
}