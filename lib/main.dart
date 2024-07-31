import 'package:flutter/material.dart';
import 'package:recipe_finder/ui/pages/home.page.dart';
import 'package:recipe_finder/ui/pages/recipe.detail.page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe Finder',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      initialRoute: '/',
      onGenerateRoute: _getRoute,
    );
  }

  Route<dynamic> _getRoute(RouteSettings settings) {
    final Uri uri = Uri.parse(settings.name ?? '');

    if (uri.pathSegments.length == 2 && uri.pathSegments[0] == 'recipeDetail') {
      final String id = uri.pathSegments[1];
      return MaterialPageRoute(
        builder: (context) => RecipeDetailPage(recipeId: id),
        settings: settings,
      );
    }

    return MaterialPageRoute(builder: (context) => HomePage());
  }
}
