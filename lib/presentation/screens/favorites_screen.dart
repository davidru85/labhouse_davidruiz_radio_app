import 'package:flutter/material.dart';

/// Favorites screen placeholder (stub for the RED phase of slice 3).
class FavoritesScreen extends StatelessWidget {
  /// Creates an instance of [FavoritesScreen].
  const FavoritesScreen({this.onExplore, super.key});

  /// Invoked when the empty-state "Explore Stations" action is tapped.
  final VoidCallback? onExplore;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Favorites')));
  }
}
